#version 330 compatibility

uniform sampler2D gtexture;
uniform sampler2D normals;
uniform int worldTime;
uniform vec3 shadowLightPosition;
uniform sampler2D water;

uniform float alphaTestRef = 0.1;

in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;
in vec3 worldPos;
in mat3 tbnMatrix;
in vec3 normal;
in vec3 viewPos;
in vec3 worldLightVector;
in vec3 eyePlayerPos;

/* RENDERTARGETS: 0,1,2,3,4 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormalTexture;
layout(location = 3) out vec4 specular;

#include "/lib/noise.glsl"
#include "/lib/settings.glsl"

#ifdef HIGH_QUALITY_NORMALS
  /*
  const int colortex2Format = RGB16;
  */
#endif

#ifdef REFLECTIONS
#endif

void main() {
  lightmapData = vec4(lmcoord, 0.0, 1.0);
  color = texture(gtexture, texcoord) * glcolor;
  if (color.a < alphaTestRef) {
    discard;
  }

  //normal data
  vec3 normalTexture = texture(normals, texcoord).rgb;
  normalTexture = normalize(tbnMatrix * normalize((normalTexture - 0.5) * 2.0));

  #ifdef WAVES
  float wave_motion = float(worldTime) * 0.005;
  float noiseOffset = 0.5;
  vec3 layer1 = 0.5 * texture(water, fract(worldPos.xz * 0.2 + wave_motion)).rgb;
  vec3 layer2 = 0.5 * texture(water, fract(worldPos.xz * 0.2 - wave_motion + vec2(noiseOffset, 0))).rgb;
  
  
  normalTexture = layer1 + layer2;
  normalTexture = normalize((normalTexture - 0.5) * 2.0);
  normalTexture.xy *= 0.2;
  normalTexture = normalize(tbnMatrix * normalTexture);
  #endif


  encodedNormalTexture = vec4(normalTexture * 0.5 + 0.5, 1.0);


  //specular
  float f0 = 0.8;
  float smoothness = 1.0;
  vec3 rayDir = -normalize(viewPos);
  float fresnel = pow(1 - clamp(dot(normalTexture, rayDir), 0.0, 1.0), 6.0);
  float reflectiveStrength = f0 + (1.0 - f0) * fresnel * smoothness;
  specular = vec4(smoothness, reflectiveStrength, fresnel, 1.0);
  /*
  vec3 reflection = reflect(-rayDir, normalTexture);
  float sunReflection = pow(clamp(dot(reflection, worldLightVector), 0, 1), 1 + 2 * smoothness);
  color.rgb += reflectiveStrength * sunReflection;
  */
  
}