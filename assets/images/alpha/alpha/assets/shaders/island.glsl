#type vertex

#include "common.h"

out vec2 Texcoord;
out vec4 FragPosDirectionalLightSpace;
out vec3 WorldPosition;
out vec3 Normal;
out float Dissolve;

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

    vec3 fragPos = vec3(uModelMatrix * vertex);
    FragPosDirectionalLightSpace = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(fragPos, 1.0);

    Normal = vec3(0, 1, 0);
}

#type fragment
#define STATIC_BIAS
#define CUSTOM_COLOR

#include "common.h"
#include "game_buffer.h"
#include "grass.h"

in vec2 Texcoord;
in vec4 FragPosDirectionalLightSpace;
in vec3 WorldPosition;
in vec3 Normal;
in float Dissolve;

out vec4 Final;

uniform sampler2D uGround;
uniform sampler2D uClouds;
uniform sampler2D uHeavyClouds;
uniform sampler2D uNoise;

uniform vec3 uAmbientColor;     // Ambient light based on time
uniform vec3 uShadowColor;      // Tint of shadowed areas
uniform float uSunIntensity;    // Light fade (0 at night, 1 at noon)

void main()
{
    vec2 uv = WorldPosition.xz * 1.0 / 16.0;
    uv = fract(uv);
    vec4 objectColor = texture(uGround, uv);
    if (objectColor.a < 0.1) {
        discard;
    }

    objectColor.xyz *= GetGrassColor(distance(vec2(0.0, 0.0), WorldPosition.xz));

    // objectColor.xyz = mix() TODO darken outside safe zone

#define NO_DISSOLVE
#include "lit_main.fs"

    float noise = texture(uNoise, WorldPosition.xz * 0.001).x;
    result *= SRGBToLinear(clamp(noise * 0.75 + 0.65, 0.0, 1.0));

    Final = vec4(result, 1.0);
}
