float Hash(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 78.233);
    return fract(sin(dot(p, vec2(12.9898,78.233))) * 43758.5453);
}

float ValueNoise(vec2 uv)
{
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float a = Hash(i);
    float b = Hash(i + vec2(1.0, 0.0));
    float c = Hash(i + vec2(0.0, 1.0));
    float d = Hash(i + vec2(1.0, 1.0));

    vec2 u = f*f*(3.0 - 2.0*f); // smoothstep-like interp

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float GetWindDisplacement(vec2 worldPos, float time)
{
    float big = ValueNoise(mod(worldPos * 0.008 + time * 0.2, vec2(500.0)));
    float small = ValueNoise(mod(worldPos * 0.025 + time * 1.0, vec2(500.0)));
    float wind = sin(big * 5.0 + time * 0.5) * 0.075 + sin(small * 5.0 + time * 1.0) * 0.025;
    return wind;
}
