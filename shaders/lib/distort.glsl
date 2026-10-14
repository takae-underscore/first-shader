const int shadowMapResolution = 1024; // [512 1024 2048 4096]
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

#include "/lib/settings.glsl"

vec3 distortShadowPos(vec3 shadowPos) {
  float distortionFactor = length(shadowPos.xy);
  distortionFactor += 0.1;

  shadowPos.xy /= distortionFactor;
  shadowPos.z *= 0.5;
  return shadowPos;
}

float computeBias(vec3 shadowClipPos) {
  float numerator = length(shadowClipPos.xy) + 0.1;
  numerator *= numerator;
  return float(8) / shadowMapResolution * numerator / 0.1;
}