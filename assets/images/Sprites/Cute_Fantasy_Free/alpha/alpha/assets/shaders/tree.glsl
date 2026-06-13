#type vertex

#include "common.h"
#include "game_buffer.h"
#include "sprite_batch.h"
#include "tree.h"

out vec2 Texcoord;
out vec4 FragPosDirectionalLightSpace;
out vec3 WorldPosition;
out vec3 Normal;
out vec4 Color;
out float Dissolve;
out float Variation;

uniform vec2 uSpriteSheetSize;

void main()
{
#define SKIP_GL_POSITION
#include "sprite_batch.vs"

    float time = GameBuffer.myWindTime;
    vec2 worldPosXZ = worldPos.xz;
    float windOffset = GetWindDisplacement(worldPosXZ, time) * GameBuffer.myWindStrength;
    float swayAmount = windOffset * aQuadPos.y * 3.0;
    vec3 displaced = worldPos + vec3(swayAmount, 0.0, 0.0); // swaying left-right
    gl_Position = CameraBuffer.myProjectionMatrix * CameraBuffer.myViewMatrix * vec4(displaced, 1.0);

    Variation = iCustom.y;
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
in float Variation;

layout (location = 0) out vec4 Final;

uniform sampler2D uTexture;
uniform sampler2D uClouds;
uniform sampler2D uHeavyClouds;

uniform vec3 uAmbientColor;
uniform vec3 uShadowColor;
uniform float uSunIntensity;

void main()
{
#define RAISE_FOG
#include "lit_main.fs"
    result.x *= SRGBToLinear(Variation);
    Final = vec4(result, 1.0);
}
