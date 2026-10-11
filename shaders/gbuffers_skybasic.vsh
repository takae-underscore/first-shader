#version 330 compatibility

uniform mat4 gbufferModelViewInverse;

out vec3 eyePlayerPos;
out vec4 glcolor;

void main() {
  glcolor = gl_Color;
  vec3 modelPos = gl_Vertex.xyz;
  vec3 viewPos = (gl_ModelViewMatrix * vec4(modelPos, 1.0)).xyz;
  vec4 clipPos = (gl_ProjectionMatrix) * vec4(viewPos, 1.0);
  eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
  gl_Position = clipPos;
}