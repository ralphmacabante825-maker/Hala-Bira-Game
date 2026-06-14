#type vertex

layout(location = 0) in vec3 iPosition;
layout(location = 1) in vec2 iTexcoord;
out vec2 Texcoord;

void main()
{
	gl_Position = vec4(iPosition, 1.0);
	Texcoord = iTexcoord;
}

#type fragment

#include "common.h"
#include "color_grade.h"

in vec2 Texcoord;
out vec4 Final;

uniform sampler2D uColor;

const float warp_amount = 0.15;
const float noise_amount = 0.005;
const float grille_amount = 0.025;
const float grille_size = 1.5;
const float vignette_amount = 0.25;
const float vignette_intensity = 0.3;
const float aberation_amount = 2.0;

float random(vec2 uv)
{
    return fract(cos(uv.x * 83.4827 + uv.y * 92.2842) * 43758.5453123);
}

vec3 fetch_pixel(vec2 uv, vec2 off)
{
	vec2 pos = floor(uv * CameraBuffer.myResolutionAndTime.xy + off) / CameraBuffer.myResolutionAndTime.xy + vec2(0.5) / CameraBuffer.myResolutionAndTime.xy;

	float noise = 0.0;
	if(noise_amount > 0.0){
		noise = random(pos + fract(CameraBuffer.myResolutionAndTime.z)) * noise_amount;
	}

	if(max(abs(pos.x - 0.5), abs(pos.y - 0.5)) > 0.5){
		return vec3(0.0, 0.0, 0.0);
	}

	vec3 clr = texture(uColor , pos, -16.0).rgb + noise;
	return clr;
}

vec2 warp(vec2 uv)
{
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;

	vec2 warped = uv + delta * delta_offset;
	return (warped - 0.5) / mix(1.0,1.2,warp_amount/5.0) + 0.5;
}

float vignette(vec2 uv)
{
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_amount);
}

vec3 grille(vec2 uv)
{
	float unit = 3.14 / 3.0;
	float scale = 2.0*unit/grille_size;
	float r = smoothstep(0.5, 0.8, cos(uv.x*scale - unit));
	float g = smoothstep(0.5, 0.8, cos(uv.x*scale + unit));
	float b = smoothstep(0.5, 0.8, cos(uv.x*scale + 3.0*unit));
	return mix(vec3(1.0), vec3(r,g,b), grille_amount);
}

void main()
{
   	vec2 pix = gl_FragCoord.xy;
	vec2 pos = warp(Texcoord);

	vec3 clr = fetch_pixel(pos, vec2(0.0));
	float chromatic = aberation_amount;
	vec2 chromatic_x = vec2(chromatic,0.0) / CameraBuffer.myResolutionAndTime.x;
	vec2 chromatic_y = vec2(0.0, chromatic/2.0) / CameraBuffer.myResolutionAndTime.y;
	float r = fetch_pixel(pos - chromatic_x, vec2(0)).r;
	float g = fetch_pixel(pos - chromatic_y, vec2(0)).g;
	float b = fetch_pixel(pos - chromatic_x, vec2(0)).b;
	clr = vec3(r,g,b);
	clr *= SRGBToLinear(grille(pix));
	clr *= vignette(pos);

#ifndef IS_WEBGL
	Final.rgb = ColorGrade(clr);
#else
	Final.rgb = clr;
#endif

	Final.a = 1.0;
}
