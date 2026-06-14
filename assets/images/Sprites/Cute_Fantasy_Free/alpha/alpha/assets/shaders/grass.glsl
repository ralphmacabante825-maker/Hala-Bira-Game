#type vertex

#include "common.h"
#include "sprite_batch.h"
#include "grass.h"

out vec2 Texcoord;
out vec4 FragPosDirectionalLightSpace;
out vec3 WorldPosition;
out vec3 Normal;
out vec4 Color;
out float Dissolve;

uniform vec2 uSpriteSheetSize;

void main()
{
#define SKIP_GL_POSITION
#include "sprite_batch.vs"

    float time = CameraBuffer.myResolutionAndTime.z;
    vec2 worldPosXZ = worldPos.xz;
    float windOffset = GetWindDisplacement(worldPosXZ, time) * 0.5;
    float swayAmount = windOffset * aQuadPos.y * 3.0;
    vec3 displaced = worldPos + vec3(swayAmount, 0.0, 0.0); // swaying left-right
    gl_Position = CameraBuffer.myProjectionMatrix * CameraBuffer.myViewMatrix * vec4(displaced, 1.0);
}

#type fragment

#define STATIC_BIAS
#define NO_DISSOLVE

#include "common.h"
#include "game_buffer.h"
#include "grass.h"

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
uniform sampler2D uNoise;

uniform vec3 uAmbientColor;     // Ambient light based on time
uniform vec3 uShadowColor;      // Tint of shadowed areas
uniform float uSunIntensity;    // Light fade (0 at night, 1 at noon)

void main()
{
#include "lit_main.fs"

    float noise = texture(uNoise, WorldPosition.xz * 0.001).x;
    result *= GetGrassColor(distance(vec2(0.0, 0.0), WorldPosition.xz));
    result *= SRGBToLinear(vec3(0.75, 0.75, 0.75));
    result *= SRGBToLinear(clamp(noise * 0.75 + 0.65, 0.0, 1.0));

    Final = vec4(result, 1.0);
}
