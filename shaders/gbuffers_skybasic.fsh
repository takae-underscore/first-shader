#version 330 compatibility

uniform int renderStage;
uniform vec3 fogColor;
uniform vec3 skyColor;

in vec3 eyePlayerPos;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
  float fogFactor = 1.0;
  float skyPos = normalize(eyePlayerPos).y;
  
  if(renderStage == MC_RENDER_STAGE_STARS) {
    color = glcolor;
  }
  else {
    if(skyPos > 0.0) {
      fogFactor = 0.07 / (skyPos * skyPos + 0.07);
    }
    color.rgb = mix(skyColor, fogColor, fogFactor);
  }

  color.rgb = 2 * pow(color.rgb, vec3(2.2));
}