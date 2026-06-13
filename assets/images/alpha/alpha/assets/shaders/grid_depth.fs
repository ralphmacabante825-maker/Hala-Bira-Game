#version 460 core

layout (location = 0) in vec2 iTexcoord;
layout (location = 0) out vec4 oColor;

#include "grid_params.h"
#include "grid_functions.h"
#include "common.h"

void main()
{
	if (gridColor(iTexcoord).a < 0.1) {
		discard;
	}
}
