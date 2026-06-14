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
#define SHADOW_DEPTH
#include "sprite_batch.vs"
}

#type fragment

uniform sampler2D uTexture;

in vec2 Texcoord;
in vec4 FragPosDirectionalLightSpace;
in vec3 WorldPosition;
in vec3 Normal;
in vec4 Color;
in float Dissolve;

layout (location = 0) out float Final;

void main()
{
	float alpha = texture(uTexture, Texcoord).a;
	if (alpha < 0.1)
		discard;
}
