#type vertex
#version 450 core

#include "common.h"

layout(location=0) in vec3 Position;

uniform mat4 uModelMatrix;

void main()
{
	gl_Position = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * uModelMatrix * vec4(Position, 1.0);
}

#type fragment
#version 450 core

layout (location = 0) out float oColor;

uniform sampler2D uTexture;

void main()
{
}
