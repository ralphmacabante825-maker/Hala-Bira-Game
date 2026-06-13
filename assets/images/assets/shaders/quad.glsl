#type vertex

layout(location=0) in vec3 iPosition;
layout(location=1) in vec2 iTexcoord;
layout(location=2) in vec4 iColor;

out vec4 Color;

uniform mat4 uViewProjMatrix;

void main()
{
	Color = iColor;
	gl_Position = uViewProjMatrix * vec4(iPosition, 1.0);
}

#type fragment

in vec4 Color;
out vec4 Final;

void main()
{
	Final = Color;
}
