#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D depthtex2;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float viewWidth;
uniform float viewHeight;
uniform int worldTime;
uniform float rainStrength;
uniform float far;

const vec3 blocklightColor = vec3(1.0, 0.4, 0.3);
const vec3 morningColor = vec3(0.05, 0.15, 0.3);
const vec3 noonColor = vec3(0.14, 0.15, 0.12);
const vec3 eveningColor = vec3(0.3, 0.08, 0.01);
const vec3 nightColor = vec3(0.0, 0.05, 0.3);
const vec3 sunlightColor = vec3(1.0);
const vec3 moonlightColor = vec3(0.1, 0.4, 0.7);
const vec3 ambientColor = vec3(0.1);
const float shadowDistanceRenderMul = 1.0;

in vec2 texcoord;

#include "/lib/distort.glsl"
#include "/lib/projectAndDivide.glsl"
#include "/lib/settings.glsl"
#include "/lib/noise.glsl"



float convertHandDepth(float depth) {
    float ndcDepth = depth * 2.0 - 1.0;
    ndcDepth /= MC_HAND_DEPTH;
    return ndcDepth * 0.5 + 0.5;
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  color = texture(colortex0, texcoord);
  //color.rgb = pow(color.rgb, vec3(2.2));

  // depth data (don't light the sky)
  /*
  float depth = texture(depthtex0, texcoord).r;
  if (depth == 1.0) {
    return;
  }
  
  // lightmap and normal data
  vec2 lightmap = texture(colortex1, texcoord).rg;
  vec3 encodedNormal = texture(colortex2, texcoord).rgb;
  vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
  vec3 lightVector = normalize(shadowLightPosition);
  vec3 worldLightVector = normalize(mat3(gbufferModelViewInverse) * lightVector);
  vec3 encodedNormalTexture = texture(colortex2, texcoord).rgb;
  vec3 normalTexture = normalize((encodedNormalTexture - 0.5) * 2.0);
  

  // shadows
  float depth1 = texture(depthtex1, texcoord).r;
  float depth2 = texture(depthtex2, texcoord).r;
  if(depth1 != depth2) {
    depth = convertHandDepth(depth);
  }

  vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
  vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
  vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
  float lightDot = clamp(dot(worldLightVector, normalTexture), 0.0, 1.0); 

  //specular data
  float smoothness = texture(colortex3, texcoord).r;
  float reflectiveStrength = texture(colortex3, texcoord).g;
  float fresnel = texture(colortex3, texcoord).b;

  vec3 shadow = getSoftShadow(shadowClipPos, lightmap, normal, lightDot);
  
  // calculate lighting
  vec3 worldlightColor = sunlightColor;
  vec3 worldlight = worldlightColor * lightDot * shadow * (1.0 - reflectiveStrength);
  float skylightIntensity = SKYLIGHT_INTENSITY;
  float worldlightIntensity = SUNLIGHT_INTENSITY;
  vec3 skylightColor = morningColor;
  if(worldTime >= 2000 && worldTime < 4000) {
    float time = worldTime - 2000;
    skylightColor = mix(morningColor, noonColor, time / 2000);
  }
  if(worldTime >= 4000 && worldTime < 10000) {
    skylightColor = noonColor;
  }
  if(worldTime >= 10000 && worldTime < 12000) {
    float time = worldTime - 10000;
    skylightColor = mix(noonColor, eveningColor, time / 2000);
  }
  if(worldTime >= 12000 && worldTime <= 13560) {
    float time = worldTime - 12000;
    skylightColor = mix(eveningColor, nightColor, time / 1560);
    skylightIntensity = mix(SKYLIGHT_INTENSITY, SKYLIGHT_INTENSITY_NIGHT, time / 1560);
    if(time <= 780) {
      worldlightIntensity = SUNLIGHT_INTENSITY * (780 - time) / 780;
    }
    else {
      worldlightIntensity = MOONLIGHT_INTENSITY * (time - 780) / 780;
    }
  }
  if((worldTime > 13560) && (worldTime < 22436)) {
    worldlightColor = moonlightColor;
    worldlightIntensity = MOONLIGHT_INTENSITY;
    skylightColor = nightColor;
    skylightIntensity = SKYLIGHT_INTENSITY_NIGHT;
  }
  if(worldTime >= 22436 && worldTime <= 23996) {
    float time = worldTime - 22436;
    skylightColor = mix(nightColor, morningColor, time / 1560);
    skylightIntensity = mix(SKYLIGHT_INTENSITY_NIGHT, SKYLIGHT_INTENSITY, time / 1560);
    if(time <= 780) {
      worldlightIntensity = MOONLIGHT_INTENSITY * (780 - time) / 780;
    }
    else {
      worldlightIntensity = SUNLIGHT_INTENSITY * (time - 780) / 780;
    }
  }
  if(rainStrength > 0.0){
    skylightColor = mix(skylightColor, nightColor, rainStrength);
    worldlightIntensity = worldlightIntensity - worldlightIntensity * (rainStrength - 0.1);
  }
  vec3 blocklight = lightmap.r * blocklightColor;
  vec3 skylight = lightmap.g * skylightColor;
  vec3 ambient = ambientColor;

  #if DEBUG_MODE == 0
  color.rgb *= BLOCKLIGHT_INTENSITY * blocklight + skylightIntensity * skylight + AMBIENT_INTENSITY * ambient + worldlightIntensity * worldlight;
  #endif
  */
  #if DEBUG_MODE == 1
  color.rgb = vec3(lightmap, 0.0);
  #endif
  
  #if DEBUG_MODE == 3
  color.rgb = texture(colortex0, texcoord).rgb;
  #endif
  
  #if DEBUG_MODE == 6
  color.rgb = texture(shadowtex0, texcoord).rgb;
  #endif
  
}