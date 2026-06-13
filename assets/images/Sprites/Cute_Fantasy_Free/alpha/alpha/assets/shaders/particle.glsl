#type vertex

layout(location=0) in vec2 iCorner;
layout(location=1) in vec3 iPosition;
layout(location=2) in vec4 iColor;
layout(location=3) in float iSize;

#include "common.h"

out vec4 Color;
out vec3 WorldPosition;
out vec3 Normal;

uniform mat4 uViewProjMatrix;

void main()
{
	Color = iColor;
	vec3 worldPos = iPosition + (CameraBuffer.myCameraRight.xyz * iCorner.x + CameraBuffer.myCameraUp.xyz * iCorner.y) * iSize * 0.5;
	gl_Position = CameraBuffer.myProjectionMatrix * CameraBuffer.myViewMatrix * vec4(worldPos, 1.0f);
	WorldPosition = worldPos;
	Normal = vec3(0, 1, 0);
}

#type fragment

#include "common.h"
#include "game_buffer.h"

in vec4 Color;
in vec3 WorldPosition;
in vec3 Normal;

layout (location = 0) out vec4 Final;

void main()
{
	Final = Color;
	vec3 objectColor = Color.xyz;
#define CUSTOM_COLOR
#define NO_SHADOWS
#define NO_DISSOLVE
#include "lit_main.fs"
	Final = vec4(result, Final.a);
}
