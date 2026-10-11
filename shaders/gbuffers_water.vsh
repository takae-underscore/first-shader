#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos;
uniform mat4 gbufferModelViewInverse;
uniform vec3 eyePosition;
uniform int worldTime;

#include "/lib/noise.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0); // change from [0.033, 0.97] to [0,1]
	glcolor = gl_Color;
  vec3 modelPos = gl_Vertex.xyz;
  vec3 viewPos = (gl_ModelViewMatrix * vec4(modelPos, 1.0)).xyz;
  vec4 clipPos = (gl_ProjectionMatrix) * vec4(viewPos, 1.0);
  vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
  worldPos = eyePlayerPos + eyePosition;

  
  gl_Position = clipPos;
}