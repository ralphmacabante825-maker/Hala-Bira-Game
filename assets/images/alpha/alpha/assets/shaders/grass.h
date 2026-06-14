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
    float big = ValueNoise(mod(worldPos * 0.0075 + time * 0.5, vec2(500.0)));
    float small = ValueNoise(mod(worldPos * 0.05 + time * 1.5, vec2(500.0)));
    float wind = sin(big * 5.0 + time * 0.5) * 0.3 + sin(small * 5.0 + time * 2.0) * 0.3;
    return wind;
}

vec4 GetAtlasSample(vec2 uv, int index, sampler2D tex)
{
    float scaledX = uv.x / 3.0;
    float offset = float(index) / 3.0;

    return texture(tex, vec2(scaledX + offset, uv.y));
}

float GetTierProgress(float distance, float start, float end)
{
    if (distance <= start) return 0.0f;
    if (distance >= end) return 1.0f;

    return clamp((distance - start) / (end - start), 0.0, 1.0);
}

// keep in sync with game_globals.h
vec3 GetGrassColor(float distance)
{
    vec3 tier1Col = SRGBToLinear(vec3(0.471, 0.706, 0.224));
    vec3 tier2Col = SRGBToLinear(vec3(0.969, 0.686, 0.349));
    vec3 tier3Col = SRGBToLinear(vec3(0.847, 0.773, 0.09));
    vec3 result = vec3(0.0, 0.0, 0.0);

    float progress = GetTierProgress(distance, 750.0, 1200.0);
    result = mix(tier1Col, tier2Col, progress);
    float progress2 = GetTierProgress(distance, 1600.0, 2000.0);
    if (progress2 > 0.001) {
        result = mix(tier2Col, tier3Col, progress2);
    }

#ifdef IS_WEBGL
    return result;
#else
    return result * 1.3;
#endif
}
