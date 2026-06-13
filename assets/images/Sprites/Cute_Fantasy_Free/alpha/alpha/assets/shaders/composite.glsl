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

void main()
{
#ifdef IS_WEBGL
    Final = texture(uColor, Texcoord);
#else
    Final.rgb = ColorGrade(texture(uColor, Texcoord).xyz);
    Final.a = 1.0;
#endif
	// vec2 uv = gl_FragCoord.xy / CameraBuffer.myResolutionAndTime.xy * 2.0 - 1.0;
	// uv.x *= CameraBuffer.myResolutionAndTime.x / CameraBuffer.myResolutionAndTime.y;
	// float d = length(uv);
	// d *= d;
	// d += 0.5;
	// d = smoothstep(0.75, 1.0, d);
	// if (Final.a < 0.1)
		// discard;
	// Final.a = 1.0 - d;
	// Final = vec4(length(uv), 0.0, 0.0, 1.0);
}
