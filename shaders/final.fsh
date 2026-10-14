#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/settings.glsl"

/*
const int colortex0Format = RGB16;
*/

void main() {
	color = texture(colortex0, texcoord);

  //color.rgb = color.rgb / (color.rgb + vec3(1.0));
  color.rgb = pow(color.rgb, vec3(1.0 / (float(GAMMA) * 0.1 + 2.2)));
}