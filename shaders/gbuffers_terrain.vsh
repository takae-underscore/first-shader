#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;
uniform mat4 gbufferModelViewInverse;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0); // change from [0.033, 0.97] to [0,1]
	glcolor = gl_Color;
  normal = gl_NormalMatrix * gl_Normal;
  normal = mat3(gbufferModelViewInverse) * normal;
  	gl_Position = ftransform();
}