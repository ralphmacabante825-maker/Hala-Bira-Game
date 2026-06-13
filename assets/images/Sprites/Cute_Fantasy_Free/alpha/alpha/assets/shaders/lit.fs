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
#include "lit_main.fs"
    Final = vec4(result, 1.0);
}
