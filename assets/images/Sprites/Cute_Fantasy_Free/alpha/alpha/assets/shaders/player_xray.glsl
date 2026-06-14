#type vertex

#include "common.h"
#include "sprite_batch.h"

out vec2 Texcoord;
out vec4 FragPosDirectionalLightSpace;
out vec3 WorldPosition;
out vec3 Normal;
out vec4 Color;
out float Dissolve;

uniform vec2 uSpriteSheetSize;

void main()
{
#include "sprite_batch.vs"
}

#type fragment

#define STATIC_BIAS
#include "common.h"
#include "game_buffer.h"

in vec2 Texcoord;
in vec4 FragPosDirectionalLightSpace;
in vec3 WorldPosition;
in vec3 Normal;
in vec4 Color;
in float Dissolve;

layout (location = 0) out vec4 Final;

uniform sampler2D uTexture;
uniform sampler2D uClouds;
uniform sampler2D uHeavyClouds;

uniform vec3 uAmbientColor;     // Ambient light based on time
uniform vec3 uShadowColor;      // Tint of shadowed areas
uniform float uSunIntensity;    // Light fade (0 at night, 1 at noon)

void main()
{
    vec2 uv = Texcoord;
    float alpha = texture(uTexture, uv).a;
    if (alpha < 0.1) {
        discard;
    }
    Final = vec4(SRGBToLinear(vec3(0.08, 0.11, 0.15)), 1.0);
}
