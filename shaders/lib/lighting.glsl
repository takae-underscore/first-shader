uniform float sunAngle;

const float pi = 3.14159265359;
const float ambientOcclusionLevel = 0.0;

#include "/lib/lightColors.glsl"
#include "/lib/shadows.glsl"

vec3 calcNormal(vec4 normalTexture, mat3 tbnMatrix)
{
  vec3 normal = vec3(0.0);

  normal.xy = (normalTexture.xy - 0.5) * 2.0;
  normal.z = sqrt(max(1.0 - dot(normal.xy, normal.xy), 0.0));
  normal = normalize(tbnMatrix * normal);

  return normal;
}

vec3 fresnelSchlick(float HdotV, vec3 f0)
{
  return f0 + (1.0 - f0) * pow(clamp(1.0 - HdotV, 0.0, 1.0), 5.0);
}

float distributionGGX(vec3 N, vec3 H, float roughness)
{
  float a2 = roughness * roughness;
  float NdotH = max(dot(N, H), 0.0);
  float NdotH2 = NdotH * NdotH;
  float denom = NdotH2 * (a2 - 1.0) + 1.0;
  denom = pi * denom * denom;

  return a2 / denom;
}

float geometrySchlickGGX(vec3 N, vec3 V, float k)
{
  float NdotV = max(dot(N, V), 0.0);
  float denom = NdotV * (1 - k) + k;

  return NdotV / denom;
}

float geometrySmith(vec3 N, vec3 V, vec3 L, float k)
{
  float GGX1 = geometrySchlickGGX(N, V, k);
  float GGX2 = geometrySchlickGGX(N, L, k);
  return GGX1 * GGX2;
}

vec3 getSpecular(float D, vec3 F, float G, vec3 V, vec3 L, vec3 N)
{
  vec3 num = D * G * F;
  float NdotV = max(dot(N, V), 0.0);
  float NdotL = max(dot(N, L), 0.0);
  float denom = 4 * NdotV * NdotL + 0.0001;

  return num / denom;  
}

vec3 getLighting(vec3 viewPos, vec3 normal, vec3 normalFace, vec3 lightPos, float blocklightLevel, float skylightLevel, vec3 albedo, float isMetal, float roughness, float ao, float f0)
{
  vec3 lightOut = vec3(0.0);
  
  vec3 lightColor = getDirectLightColors(sunAngle);

  float shadowFactor = getSoftShadow(viewPos, skylightLevel, normalFace, lightPos);
  
  if(skylightLevel > 0.01)
  {

    vec3 N = normal;
    vec3 V = -normalize(viewPos);
    
    vec3 L = normalize(lightPos);
    vec3 H = normalize(V + L);

    vec3 radiance = lightColor;

    //fresnel
    float HdotV = max(dot(H, V), 0.0);
    vec3 vecF0 = mix(vec3(f0), albedo, isMetal);
    vec3 F = fresnelSchlick(HdotV, vecF0);

    //geometry
    float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
    float G = geometrySmith(N, V, L, k);

    //distribution
    float D = distributionGGX(N, H, roughness);

    //specular
    vec3 specular = getSpecular(D, F, G, V, L, N);
    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - isMetal;
    
    float NdotL = max(dot(N,L), 0.0);
    lightOut += (kD * albedo / pi + specular) * radiance * NdotL;
  }
  
  vec3 ambient = getSkylight(sunAngle, skylightLevel) + getBlocklight(blocklightLevel) + ambientColor;
  ambient = ambient * albedo * ao;

  vec3 color = ambient + lightOut * shadowFactor;

  #if DEBUG_MODE == 5
  color.rgb = shadow;
  #endif

  return color;
}