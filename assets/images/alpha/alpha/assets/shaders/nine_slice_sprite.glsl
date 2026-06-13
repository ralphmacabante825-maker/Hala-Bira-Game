#type vertex

layout(location=0) in vec3 iPosition;
layout(location=1) in vec2 iTexcoord;
layout(location=2) in vec4 iColor;

out vec4 Color;
out vec2 Texcoord;

uniform mat4 uViewProjMatrix;

void main()
{
	Color = iColor;
	Texcoord = iTexcoord;
	gl_Position = uViewProjMatrix * vec4(iPosition, 1.0);
}

#type fragment

in vec4 Color;
in vec2 Texcoord;

out vec4 Final;

uniform sampler2D uTexture;
uniform vec2 uSpriteSheetSize;
uniform vec4 uSlice;
uniform vec2 uSpritePos;
uniform vec2 uSpriteSize;
uniform vec2 uQuadSize;

void main()
{
    vec2 leftTop     = uSlice.xy / uSpriteSize;
    vec2 rightBottom = uSlice.zw / uSpriteSize;

    vec2 quadLT = uSlice.xy / uQuadSize;
    vec2 quadRB = 1.0 - (uSlice.zw / uQuadSize);

    vec2 uv = Texcoord;

    // Horizontal mapping
    if (Texcoord.x < quadLT.x) {
        uv.x = mix(0.0, leftTop.x, Texcoord.x / quadLT.x);
        } else if (Texcoord.x > quadRB.x) {
        uv.x = mix(1.0 - rightBottom.x, 1.0, (Texcoord.x - quadRB.x) / (1.0 - quadRB.x));
    } else {
        uv.x = mix(leftTop.x, 1.0 - rightBottom.x, (Texcoord.x - quadLT.x) / (quadRB.x - quadLT.x));
    }

    // Vertical mapping
    if (Texcoord.y < quadLT.y) {
        uv.y = mix(0.0, leftTop.y, Texcoord.y / quadLT.y);
        } else if (Texcoord.y > quadRB.y) {
        uv.y = mix(1.0 - rightBottom.y, 1.0, (Texcoord.y - quadRB.y) / (1.0 - quadRB.y));
    } else {
        uv.y = mix(leftTop.y, 1.0 - rightBottom.y, (Texcoord.y - quadLT.y) / (quadRB.y - quadLT.y));
    }

    vec2 newUV = (uSpritePos + uv * uSpriteSize) / uSpriteSheetSize;
    newUV.y = 1.0 - newUV.y;

	Final = texture(uTexture, newUV) * Color;
	if (Final.a < 0.01)
	    discard;
}
