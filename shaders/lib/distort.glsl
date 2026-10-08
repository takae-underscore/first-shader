const int shadowMapResolution = 2048;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;
#define SHADOW_BIAS 2.00

vec3 distortShadowClipPos(vec3 shadowClipPos) {
  float distortionFactor = length(shadowClipPos.xy);
  distortionFactor += 0.1;

  shadowClipPos.xy /= distortionFactor;
  shadowClipPos.z *= 0.5;
  return shadowClipPos;
}

float computeBias(vec3 shadowClipPos) {
  float numerator = length(shadowClipPos.xy) + 0.1;
  numerator *= numerator;
  return SHADOW_BIAS / shadowMapResolution * numerator / 0.1;
}