#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

#include "/lib/settings.glsl"

/*
const int colortex0Format = RGB16F;
*/

float luminance(vec3 color)
{
  vec3 magic = vec3(0.2126, 0.7152, 0.0722);
  return dot(magic, color);
}

vec3 reinhard(vec3 color)
{
  float lum = luminance(color);
  float whitePoint = 6.0;
  float num = lum * (1.0 + lum / (whitePoint * whitePoint));
  float denom = 1.0 + lum;
  float lumOut = num / denom;
  return color * lumOut / lum;
}

const mat3 ACESInputMat = mat3(
    0.59719, 0.35458, 0.04823,
    0.07600, 0.90834, 0.01566,
    0.02840, 0.13383, 0.83777
  );
const mat3 ACESOutputMat = mat3(
  1.60475, -0.53108, -0.07367,
  -0.10208, 1.10813, -0.00605,
  -0.00327, -0.07276, 1.0702
);

vec3 RRTAndODTFit(vec3 v)
{
  vec3 a = v * (v + 0.0245786) - 0.000090537;
  vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
  return a / b;
}

vec3 ACESFitted(vec3 color)
{
  color = ACESInputMat * color;

  color = RRTAndODTFit(color);
  
  color = ACESOutputMat * color;

  color = clamp(color, 0.0, 1.0);

  return color;
}

void main() {
	color = texture(colortex0, texcoord);

  color.rgb = reinhard(color.rgb);
  color.rgb = pow(color.rgb, vec3(1.0 / (float(GAMMA) * 0.1 + 2.2)));
}