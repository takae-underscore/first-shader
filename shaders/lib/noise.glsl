float random(vec2 p) {
  return fract(sin(p.x * 456.0 + p.y * 56.0) * 100);
}

vec2 smoothv2(vec2 v) {
  return v* v * (3.0 -2.0 * v);
}

float smoothNoise(vec2 p) {
  vec2 f = smoothv2(fract(p));
  float a = random(floor(p));
  float b = random(vec2(ceil(p.x), floor(p.y)));
  float c = random(vec2(floor(p.x), ceil(p.y)));
  float d = random(ceil(p));

  float bottomMix = mix(a, b, f.x);
  float topMix = mix(c, d, f.x);
  return mix(bottomMix, topMix, f.y);
}

float fractalNoise(vec2 p) {
  float total = 0.5;
  float amplitude = 1.0;
  float frequency = 1.0;
  float iterations = 4.0;
  for(int i= 0; i < iterations; i++) {
    total += (smoothNoise(p * frequency) - 0.5) * amplitude;
    amplitude *= 0.5;
    frequency *= 2.0;
  }
  return total;
}