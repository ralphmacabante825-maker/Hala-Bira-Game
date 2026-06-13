#type vertex

layout(location=0) in vec3 iPosition;
layout(location=1) in vec2 iTexcoord;
layout(location=2) in vec4 iColor;

out vec2 Texcoord;
out vec4 Color;

uniform mat4 uViewProjMatrix;

void main()
{
	Texcoord = iTexcoord;
	Color = iColor;
	gl_Position = uViewProjMatrix * vec4(iPosition, 1.0);
}

#type fragment

in vec2 Texcoord;
in vec4 Color;

layout (location = 0) out vec4 Final;

uniform sampler2D uTexture;
uniform float uRange;
uniform vec2 uAtlasSize;

float Median(float r, float g, float b)
{
	return max(min(r, g), min(max(r, g), b));
}

void main()
{
	vec2 uv = Texcoord;
	vec3 tex = texture(uTexture, uv).rgb;
	float med = Median(tex.r, tex.g, tex.b);
	float sdPixels = (med - 0.5) * uRange;

	float dudx = abs(dFdx(uv.x)) * uAtlasSize.x;
	float dudy = abs(dFdy(uv.x)) * uAtlasSize.x;
	float dvdx = abs(dFdx(uv.y)) * uAtlasSize.y;
	float dvdy = abs(dFdy(uv.y)) * uAtlasSize.y;

	float lambda = max(max(dudx, dudy), max(dvdx, dvdy));
	// float smoothing = max(1e-6, uRange * lambda) * 0.5;
	// float alpha = clamp(sdPixels / smoothing + 0.5, 0.0, 1.0);
	float alpha = sdPixels < 0.01 ? 0.0 : 1.0;
	if (alpha < 0.1)
		discard;
	Final = vec4(Color.rgb, Color.a * alpha);
}
