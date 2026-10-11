#version 330 compatibility

uniform sampler2D gtexture;
uniform int worldTime;

uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldPos;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

#include "/lib/noise.glsl"

void main() {
	color = glcolor * vec4(1.2, 1.2, 1.2, 0.5);
	if (color.a < alphaTestRef) {
		discard;
	}
  lightmapData = vec4(lmcoord, 1.0, 1.0);

  float wave_motion = float(worldTime) * 0.01;
  float noiseOffset = 0.05;
  float h1 = fractalNoise(worldPos.xz * 0.3 + wave_motion);
  float h2 = fractalNoise(worldPos.xz * 0.3 + wave_motion + vec2(noiseOffset, 0.0));
  float h3 = fractalNoise(worldPos.xz * 0.3 + wave_motion + vec2(0.0, noiseOffset));
  float h4 = fractalNoise(worldPos.xz * 0.3 - wave_motion);
  float h5 = fractalNoise(worldPos.xz * 0.3 - wave_motion + vec2(noiseOffset, 0.0));
  float h6 = fractalNoise(worldPos.xz * 0.3 - wave_motion + vec2(0.0, noiseOffset));
  vec3 normal = vec3(h2 - h1, h3 - h1, 0.05 + (1.0 - 0.3)) + vec3(h5 - h4, h6 - h4, 0.05 + (1.0 - 0.3));
  encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);

}