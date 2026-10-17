#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex2; //normals
uniform sampler2D colortex3; //pbr data
uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 skyColor;
uniform vec3 fogColor;

uniform float far;
uniform float near;

in vec2 texcoord;

/*
const bool colortex0MipmapEnabled = true;
*/

#include "/lib/projectAndDivide.glsl"
#include "/lib/settings.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float linearizeDepth(float depth) {
  return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
}

float getDepth(vec2 uv) {
  return linearizeDepth(texture(depthtex0, uv).r);
}

vec3 screenToView(vec2 uv) {
  vec3 ndcPos = vec3(uv, texture(depthtex0, uv).r) * 2.0 - 1.0;
  vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
  return viewPos;
}

void main() {
  color = texture(colortex0, texcoord);
  vec3 normal = texture(colortex2, texcoord).xyz * 2.0 - 1.0;
  normal = normalize(normal);
  vec4 pbrData = texture(colortex3, texcoord);
  float smoothness = pbrData.r;
  float reflectiveStrength = pbrData.g;
  float isWater = pbrData.a;
  float f0 = pbrData.b;
  

  if(isWater > 0.5) {
    float refinementMaxIteration = 5;
    float maxIteration = 400;
    float maxThickness = 0.01;
    vec3 startNdcPos = vec3(texcoord, texture(depthtex0, texcoord).r) * 2.0 - 1.0;
    vec3 startViewPos = projectAndDivide(gbufferProjectionInverse, startNdcPos);;
    vec3 startViewDir = normalize(startViewPos);

    vec3 reflectionDirView = normalize(reflect(startViewDir, normal));

    vec3 endViewPos = startViewPos + (reflectionDirView * 1000.0);
    //endViewPos /= endViewPos.z < 0 ? endViewPos.z : 1;
    vec3 endNdcPos = projectAndDivide(gbufferProjection, endViewPos);
    vec3 reflectionDir = normalize(endNdcPos - startNdcPos);
    reflectionDir *= 0.5 + 0.5;

    vec3 startScreenPos = startNdcPos * 0.5 + 0.5;

    float maxTraceDistance = reflectionDir.x >= 0.0 ? (1.0 - startScreenPos.x) / reflectionDir.x : -startScreenPos.x / reflectionDir.x;
    maxTraceDistance = min(maxTraceDistance, reflectionDir.y < 0.0 ? (-startScreenPos.y / reflectionDir.y) : ((1.0 - startScreenPos.y) / reflectionDir.y));
    //maxTraceDistance = min(maxTraceDistance, reflectionDir.z < 0.0 ? (-startScreenPos.z / reflectionDir.z) : ((1.0 - startScreenPos.z) / reflectionDir.z));

    vec3 endScreenPos = startScreenPos + reflectionDir * maxTraceDistance;
    vec3 delta = endScreenPos - startScreenPos;
    ivec2 startFragPos = ivec2(startScreenPos.xy * vec2(viewWidth, viewHeight));
    ivec2 endFragPos = ivec2(endScreenPos.xy * vec2(viewWidth, viewHeight));
    ivec2 fragDelta = endFragPos - startFragPos;
    int maxDist = max(abs(fragDelta.x), abs(fragDelta.y));
    delta /= maxDist;
    vec3 rayPos = startScreenPos + delta;
    vec3 rayDir = delta;
    vec3 rayStartPos = rayPos;
    int hitIndex = -1;

    for(int i = 0; i < maxDist && i < maxIteration; i += 4) {
      float depth0 = 0.0;
      float depth1 = 0.0;
      float depth2 = 0.0;
      float depth3 = 0.0;

      vec3 rayPos0 = rayPos + rayDir * 0.0;
      vec3 rayPos1 = rayPos + rayDir * 1.0;
      vec3 rayPos2 = rayPos + rayDir * 2.0;
      vec3 rayPos3 = rayPos + rayDir * 3.0;

      depth3 = texture(depthtex0, rayPos3.xy).r;
      depth2 = texture(depthtex0, rayPos2.xy).r;
      depth1 = texture(depthtex0, rayPos1.xy).r;
      depth0 = texture(depthtex0, rayPos0.xy).r;
      
      float thickness = rayPos3.z - depth3;
      hitIndex = (thickness >= 0.0 && thickness < maxThickness) ? (i + 3) : hitIndex;

      thickness = rayPos2.z - depth2;
      hitIndex = (thickness >= 0.0 && thickness < maxThickness) ? (i + 2) : hitIndex;

      thickness = rayPos1.z - depth1;
      hitIndex = (thickness >= 0.0 && thickness < maxThickness) ? (i + 1) : hitIndex;

      thickness = rayPos0.z - depth0;
      hitIndex = (thickness >= 0.0 && thickness < maxThickness) ? (i + 0) : hitIndex;

      if(hitIndex != -1) break;

      rayPos = rayPos3 + rayDir;
    }

    bool intersected = hitIndex >= 0;
    vec3 intersection = rayStartPos + rayDir * hitIndex;

    float fresnel = pow(clamp(1 - dot(-startViewDir, normal), 0.0, 1.0), 6.0);
    fresnel *= clamp(min((1.0 - abs(intersection.x - 0.5) * 2.0) * 5.0, (1 - abs(intersection.y - 0.5) * 2.0) * 5.0), 0.0, 1.0);

    vec3 ssrColor = texture(colortex0, intersection.xy).rgb;
    vec3 reflectedColor = ssrColor;

    

    //color.rgb = vec3(reflectionDirView);
    color.rgb = mix(color.rgb, reflectedColor, clamp(fresnel, 0.0, 1.0));
    #if DEBUG_MODE == 4
    color.rgb = vec3(visibility);
    #endif
  }
  
}