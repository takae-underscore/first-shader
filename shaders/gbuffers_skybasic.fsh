#version 330 compatibility

uniform int renderStage;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float viewHeight;
uniform float viewWidth;

in vec4 glcolor;

#define SUN_RADIANCE 12
#define SUN_BRIGHTNESS 20

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

void main() {
  vec3 screenPos = vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0);
  vec3 ndcPos = screenPos * 2.0 - 1.0;
  vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
  vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
  float skyPos = normalize(eyePlayerPos).y;
  float fogFactor = 1.0;
  vec3 skycolor = skyColor;
  
  if(renderStage == MC_RENDER_STAGE_STARS) {
    color = glcolor;
  }
  else {
    if(skyPos > 0.0) {
      fogFactor = 0.01 / (skyPos * skyPos + 0.01);
    }
    color.rgb = mix(skycolor, fogColor, fogFactor);
  }
}