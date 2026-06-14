#type vertex

layout(location=0) in vec3 iPosition;
layout(location=1) in vec2 iTexcoord;
layout(location=2) in vec4 iColor;

out vec4 Color;
out vec2 Texcoord;

uniform mat4 uViewProjMatrix;
uniform vec2 uSpriteSheetSize;

void main()
{
	Color = iColor;
	Texcoord = iTexcoord / uSpriteSheetSize;
	Texcoord.y = 1.0 - Texcoord.y;
	gl_Position = uViewProjMatrix * vec4(iPosition, 1.0);
}

#type fragment

in vec4 Color;
in vec2 Texcoord;

out vec4 Final;

uniform sampler2D uTexture;

void main()
{
	Final = texture(uTexture, Texcoord) * Color;
}
