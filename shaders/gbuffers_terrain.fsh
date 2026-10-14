#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;

uniform vec3 shadowLightPosition;
uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normalFace;
in mat3 tbnMatrix;
in vec3 viewPos;

/* RENDERTARGETS: 0,2,4 */
layout(location = 0) out vec4 color;
layout(location = 2) out vec4 encodedNormal;
layout(location = 3) out vec4 encodedTangent;

#include "/lib/lighting.glsl"

void main() {
	color = texture(gtexture, texcoord) * glcolor;
  color.rgb = pow(color.rgb, vec3(2.2));
	if (color.a < alphaTestRef) {
		discard;
	}

  vec3 albedo = color.rgb;
  float blocklightLevel = lmcoord.r;
  float skylightLevel = lmcoord.g;
  vec3 lightPos = shadowLightPosition;

  //normal data
  vec4 normalTexture = texture(normals, texcoord);
  #if PBR_TEXTURES == 1
  const float ambientOcclusionLevel = 0.0;
  float ao = normalTexture.b;
  #else
  float ao = 1.0;
  #endif
  vec3 normal = calcNormal(normalTexture, tbnMatrix);

  //specular data
  #if PBR_TEXTURES == 1
  vec4 specularTexture = texture(specular, texcoord);
  float perceptualSmoothness = specularTexture.r;
  float f0 = clamp(specularTexture.g * 255 / 229, 0.0, 1.0);
  float isMetal = specularTexture.g * 255 >= 230 ? 1.0 : 0.0;
  float porosity = specularTexture.b;
  #else
  float perceptualSmoothness = 0.01;
  float f0 = 0.04;
  float isMetal = 0.0;
  #endif

  float roughness = pow(1.0 - perceptualSmoothness, 2.0);

  color.rgb = getLighting(viewPos, normal, normalFace, lightPos, blocklightLevel, skylightLevel, albedo, isMetal, roughness, ao, f0);
  #if DEBUG_MODE == 2
  color.rgb = normal;
  #endif
  //olor.rgb = shadow;
  encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
}