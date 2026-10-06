#version 330 compatibility

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;
uniform vec3 fogColor;
uniform vec3 skyColor;

in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord);
	if (color.a < alphaTestRef) {
		discard;
	}

  color = glcolor;
}