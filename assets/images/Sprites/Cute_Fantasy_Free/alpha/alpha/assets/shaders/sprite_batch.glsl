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
#include "lit.fs"
