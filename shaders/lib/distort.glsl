const int shadowMapResolution = 1024; // [512 1024 2048 4096]
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

#include "/lib/settings.glsl"

#ifdef SHADOW_DISTORT_ENABLED
  vec3 distortShadowPos(vec3 shadowPos) {
    float distortionFactor = length(shadowPos.xy) + SHADOW_DISTORT_FACTOR;

    shadowPos.xy /= distortionFactor;
    shadowPos.z *= 0.5;
    return shadowPos;
  }

  float computeBias(vec3 shadowClipPos) {
    float numerator = length(shadowClipPos.xy) + SHADOW_DISTORT_FACTOR;
    numerator *= numerator;
    return SHADOW_BIAS / shadowMapResolution * numerator / SHADOW_DISTORT_FACTOR;
  }
#else
  vec3 distortShadowPos(vec3 shadowPos) {
    return vec3(shadowPos.xy, shadowPos.z * 0.5);
  }

  float computeBias(vec3 shadowClipPos)
  {
    return SHADOW_BIAS / shadowMapResolution;
  }
#endif