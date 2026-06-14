#type vertex

#include "common.h"

out vec2 Texcoord;
out vec3 WorldPosition;
out vec3 Normal;

uniform mat4 uModelMatrix;

void main()
{
    vec2 vertices[6] = vec2[](
        vec2(-0.5,  0.5),
        vec2(-0.5, -0.5),
        vec2( 0.5, -0.5),

        vec2(-0.5,  0.5),
        vec2( 0.5, -0.5),
        vec2( 0.5,  0.5)
    );

    vec2 texCoords[6] = vec2[](
        vec2(1.0, 0.0),
        vec2(1.0, 1.0),
        vec2(0.0, 1.0),

        vec2(1.0, 0.0),
        vec2(0.0, 1.0),
        vec2(0.0, 0.0)
    );

    Texcoord = texCoords[gl_VertexID];
    vec4 vertex = vec4(vertices[gl_VertexID] * 5000.0f, 0.0, 1.0);
    gl_Position = CameraBuffer.myProjectionMatrix * CameraBuffer.myViewMatrix * uModelMatrix * vertex;

    vec4 worldPosition = uModelMatrix * vertex;
    WorldPosition = worldPosition.xyz;

    Normal = vec3(0, 1, 0);
}

#type fragment
#define STATIC_BIAS
#define CUSTOM_COLOR

#include "common.h"
#include "game_buffer.h"

in vec2 Texcoord;
in vec3 WorldPosition;
in vec3 Normal;

out vec4 Final;

uniform sampler2D uNoise;

uniform vec3 uAmbientColor;     // Ambient light based on time
uniform vec3 uShadowColor;      // Tint of shadowed areas
uniform float uSunIntensity;    // Light fade (0 at night, 1 at noon)

// modified version of https://godotshaders.com/shader/pixelated-warped-fractal-noise/
// Pixelated noise effect based on https://godotshaders.com/shader/warped-fractal-noise/
//
// Copyright Gerardo Montaño 2025
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

float speed = 0.025;

float pixelation = 0.000000075;
float zoom = 40.0;

float gradientPixelation = 0.05;
float backgroundThreshold = 0.0;
float colorLowThreshold = 0.0;
float colorMidThreshold  = 0.3;

vec4 colorLow = vec4(0.65, 0.7, 0.7, 1.0);
vec4 colorMid = vec4(0.9, 0.9, 0.9, 1.0);
vec4 colorHigh = vec4(0.65, 0.65, 0.6, 1.0);

#define iTime CameraBuffer.myResolutionAndTime.z * speed
#define iResolution 1.0/CameraBuffer.myResolutionAndTime.xy

const mat2 mtx = mat2( vec2(0.80, -0.60), vec2(0.60, 0.80) );

float Noise(vec2 p)
{
    return texture(uNoise, p * 0.2).x;
}

float Fbm(vec2 p)
{
    float f = 0.0;

    // Octave 1: Large features
    f += 0.5000 * Noise( p + iTime );
    p = mtx * p * 3.0;

    // Octave 2: Medium detail
    f += 0.3125 * Noise( p );
    p = mtx * p * 2.0;

    // Octave 3: Fine grain
    f += 0.1563 * Noise( p + sin(iTime) );

    return f / 0.9688;
}

float Pattern( in vec2 p )
{
	return Fbm( p + Fbm( p + Fbm( p ) ) );
}

vec4 Colormap(float x, vec2 uv) {

	x *= (1.0 - pow(max(abs(0.5 - uv.x), abs(0.5 - uv.y)) * 2.0, 3.0));

    if (x < backgroundThreshold) {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
    else if (x < colorLowThreshold) {
        return mix(
			vec4(0.0, 0.0, 0.0, 0.0),
			colorLow,
			round((x - backgroundThreshold) / (colorLowThreshold - backgroundThreshold) / gradientPixelation) * gradientPixelation
		);
    }
    else if (x < colorMidThreshold) {
        return
			mix(
				colorLow,
				colorMid,
				round((x - colorLowThreshold) / (colorMidThreshold - colorLowThreshold) / gradientPixelation) * gradientPixelation
			);
    }
	else {
	return
		mix(
			colorMid,
			colorHigh,
			round((x - colorMidThreshold) / (1.0 - colorMidThreshold) / gradientPixelation) * gradientPixelation
		);
	}
}


void main()
{
    vec3 center = vec3(0, 0, -20); // TODO move this into gamebuffer
    float radiusCenter = GameBuffer.myCampRadius;
    float feather = GameBuffer.myFeather;

    vec2 uv = floor(Texcoord / CameraBuffer.myResolutionAndTime.xy / pixelation) * CameraBuffer.myResolutionAndTime.xy * pixelation;
    float noise = texture(uNoise, uv * zoom + vec2(CameraBuffer.myResolutionAndTime.z * 0.01)).x;
    float distToCenter = distance(center, WorldPosition) + noise * 50.0;
    float alphaCenter = smoothstep(radiusCenter, radiusCenter - feather, distToCenter);

    float distToPlayer = distance(GameBuffer.myCenter, WorldPosition) + noise * 50.0;
    float radiusPlayer = GameBuffer.myPlayerRadius;
    float alphaPlayer = smoothstep(radiusPlayer, radiusPlayer - feather, distToPlayer);

    float distToBeacon = distance(GameBuffer.myBeaconPos, WorldPosition) + noise * 50.0;
    float alphaBeacon = smoothstep(GameBuffer.myBeaconRadius, GameBuffer.myBeaconRadius - feather, distToBeacon);

#ifdef IS_WEBGL
    float alpha = SMaxExp(alphaCenter, alphaPlayer, 50.0);
    alpha = SMaxExp(alpha, alphaBeacon, 50.0);
#else
    float alpha = SMaxExp(alphaCenter, alphaPlayer, 20.0);
    alpha = SMaxExp(alpha, alphaBeacon, 20.0);
#endif

    float shade = Pattern(uv * zoom);
    vec4 objectColor = vec4(0.0);
    if (alpha < 0.9) {
        objectColor = SRGBToLinear(mix(Colormap(shade, uv), vec4(0.0), alpha));
    }
#define NO_DISSOLVE
#define NO_SHADOWS
#include "lit_main.fs"

    Final = vec4(result, 1.0 - alpha);
}
