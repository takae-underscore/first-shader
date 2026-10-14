const vec3 ambientColor = vec3(0.01);

vec3 getDirectLightColors(float sunAngle)
{
  const vec3 sunlightColor = vec3(2.5);
  const vec3 moonlightColor = vec3(0.1, 0.4, 0.7);

  float sunFade = smoothstep(0.0, 0.02, sunAngle) - smoothstep(0.49, 0.5, sunAngle);
  float moonFade = smoothstep(0.5, 0.51, sunAngle) - smoothstep(0.98, 1.0, sunAngle);

  return sunFade * sunlightColor + moonFade * moonlightColor;
}

vec3 getSkylight(float sunAngle, float skylightLevel)
{
  const vec3 morningColor = vec3(0.05, 0.15, 0.3);
  const vec3 noonColor = vec3(0.14, 0.15, 0.12);
  const vec3 eveningColor = vec3(0.3, 0.08, 0.01);
  const vec3 nightColor = vec3(0.0, 0.05, 0.3);

  float morningFade = smoothstep(0, 0.02, sunAngle) - smoothstep(0.1, 0.15, sunAngle);
  float noonFade = smoothstep(0.15, 0.2, sunAngle) - smoothstep(0.3, 0.35, sunAngle);
  float eveningFade = smoothstep(0.35, 0.4, sunAngle) - smoothstep(0.49, 0.5, sunAngle);
  float nightFade = smoothstep(0.5, 0.51, sunAngle) - smoothstep(0.98, 1.0, sunAngle);

  vec3 morning = morningFade * morningColor;
  vec3 noon = noonFade * noonColor;
  vec3 evening = eveningFade * eveningColor;
  vec3 night = nightFade * nightColor;

  return skylightLevel * (morning + noon + evening + night);
}

vec3 getBlocklight(float blocklightLevel)
{
  const vec3 blocklightColor = vec3(1.0, 0.4, 0.3);

  return blocklightLevel * blocklightColor;
}