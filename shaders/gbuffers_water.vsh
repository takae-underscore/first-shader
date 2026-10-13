#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 worldPos;
out vec3 eyePlayerPos;
out vec3 viewPos;
out vec3 normal;
out mat3 tbnMatrix;
out vec3 worldLightVector;

uniform mat4 gbufferModelViewInverse;
uniform vec3 eyePosition;
uniform int worldTime;
uniform vec3 shadowLightPosition;
in vec4 at_tangent;

#include "/lib/noise.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
  lmcoord = lmcoord / (30.0 / 32.0) - (1.0 / 32.0); // change from [0.033, 0.97] to [0,1]
	glcolor = gl_Color;
  vec3 modelPos = gl_Vertex.xyz;
  viewPos = (gl_ModelViewMatrix * vec4(modelPos, 1.0)).xyz;
  vec4 clipPos = (gl_ProjectionMatrix) * vec4(viewPos, 1.0);
  eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
  worldPos = eyePlayerPos + eyePosition;
  normal = gl_NormalMatrix * normalize(gl_Normal);
  vec4 tangent = vec4(gl_NormalMatrix * normalize(at_tangent.xyz), at_tangent.w);
  vec3 bitangent = normalize(cross(tangent.xyz, normal) * tangent.w);
  tbnMatrix = mat3(tangent.xyz, bitangent, normal);
  worldLightVector = normalize(shadowLightPosition);

  
  gl_Position = clipPos;
}