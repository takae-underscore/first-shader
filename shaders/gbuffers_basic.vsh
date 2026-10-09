#version 330 compatibility

uniform sampler2D lightmap;

out vec2 lmcoord;
out vec4 glcolor;

void main() {
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
  gl_Position = ftransform();
}