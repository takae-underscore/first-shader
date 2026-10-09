#version 330 compatibility

uniform int renderStage;
uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float viewHeight;
uniform float viewWidth;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform int worldTime;
uniform float far;
uniform float rainStrength;
uniform int moonPhase;

in vec2 texcoord;
in vec4 glcolor;

#define MOON_RADIANCE 10
#define MOON_BRIGHTNESS 20

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

void main() {
  color = texture(colortex0, texcoord);

  vec3 screenPos = vec3(texcoord.xy, 1.0);
  vec3 ndcPos = screenPos * 2.0 - 1.0;
  vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
  float depth = texture(depthtex0, texcoord).r;
  if(depth < 1.0) {
    return;
  }
  vec3 moonDirection = 0.01 * moonPosition;
  vec3 moonColor = vec3(0.3, 0.5, 0.6) * abs((3.5 - moonPhase)) / 3.5;
  
  float moonFactor = pow(dot(moonDirection, normalize(viewPos)) * 0.5 + 0.5, 10);
  if(rainStrength > 0.0) {
    moonColor.rgb = mix(skyColor, fogColor, 0.5) + (1.0 - rainStrength * 0.8) * moonColor.rgb;
  }
  vec3 defaultColor = color.rgb;
  if(worldTime >= 12000 && worldTime <= 15000) {
    float time = worldTime - 12000;
    color.rgb += fogColor * clamp((time / 1650), 0.0, 0.2) + moonFactor * moonColor * clamp((time / 1650), 0.0, 1.0);
  }
  else if((worldTime > 15000) && (worldTime < 20996)) {
    color.rgb += fogColor * 0.2 + moonFactor * moonColor;
  }
  else if(worldTime >= 20996 && worldTime <= 23996) {
    float time = worldTime - 20996;
    color.rgb += fogColor * (0.2 - clamp((time / 3000), 0.0, 0.2)) + moonFactor * moonColor * (1.0 - clamp((time / 3000), 0.0, 1.0));
  }
  else {
    color.rgb = defaultColor;
  }
}