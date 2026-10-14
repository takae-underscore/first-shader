uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float viewWidth;
uniform float viewHeight;

const float shadowDistanceRenderMul = 0.5;

#include "/lib/settings.glsl"
#include "/lib/distort.glsl"
#include "/lib/projectAndDivide.glsl"
#include "/lib/noise.glsl"

float convertHandDepth(float depth) {
    float ndcDepth = depth * 2.0 - 1.0;
    ndcDepth /= MC_HAND_DEPTH;
    return ndcDepth * 0.5 + 0.5;
}

vec3 getShadow(vec3 shadowScreenPos) {
  float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
  if (transparentShadow == 1.0) {
    return vec3(1.0);
  }

  float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
  if(opaqueShadow == 0.0) {
    return vec3(0.0);
  }

  vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
  return shadowColor.rgb * (1.0 - shadowColor.a);
}

float ign(vec2 coords)
{
  vec3 magic = vec3(0.06711056, 0.00583715, 52.9829189);
  return fract(magic.z * fract(dot(coords, magic.xy)));  
}

vec2 vogelDiskOffset(int sampleIndex, int samplesCount, float phi)
{
  float GoldenAngle = 2.4;

  float r = sqrt(sampleIndex + 0.5) / sqrt(samplesCount);
  float theta = sampleIndex * GoldenAngle + phi;

  float sine = sin(theta);
  float cosine = cos(theta);

  return vec2(r * cosine, r * sine);
}

vec3 getSoftShadow(vec3 viewPos, vec2 lightmap, vec3 normal, vec3 lightPos)
{
  //change from view space to shadow clip space

  vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
  vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
  vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);

  vec3 lightDir = normalize(mat3(gbufferModelViewInverse) * normalize(lightPos));
  normal = normalize(mat3(gbufferModelViewInverse) * normal);
  float lightDot = dot(lightDir, normal);
  vec3 shadowAccum = vec3(0.0);
  const int samples = SHADOW_RANGE * SHADOW_RANGE;
  if(lightmap.g > 0.01 && lightDot > 0.01) {
    float noise = ign(gl_FragCoord.xy);

    vec3 shadowViewNormal = mat3(shadowModelView) * normal;
    vec4 shadowClipNormal = shadowProjection * vec4(shadowViewNormal, 1.0);
    vec3 shadowNormal = shadowClipNormal.xyz / shadowClipNormal.w;
    vec3 shadowSpaceScale = vec3(shadowProjection[0][0], shadowProjection[1][1], shadowProjection[2][2]);

    vec2 slidePlane = shadowViewNormal.xy / shadowViewNormal.z / shadowSpaceScale.xy * shadowSpaceScale.z;

    for(int i = 0; i < samples; i++)
    {
      vec2 offset = vogelDiskOffset(i, samples, noise);
      offset /= shadowMapResolution;
      vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
      float bias = computeBias(offsetShadowClipPos.xyz);
      offsetShadowClipPos.xyz = distortShadowPos(offsetShadowClipPos.xyz);
      
      vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
      vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
      
      float zOffset = clamp(dot(offset, slidePlane), 0.0, 1.0);
      shadowScreenPos.z -= zOffset;
      shadowScreenPos.xyz += shadowNormal * bias;
      shadowAccum += getShadow(shadowScreenPos);
    }

  }
  else {
    shadowAccum = lightmap.g > 0.01 ? vec3(1.0) * clamp((lightDot + 1.0), 0.0, 1.0) : shadowAccum;
    return shadowAccum;
  }

  return shadowAccum / float(samples);
}