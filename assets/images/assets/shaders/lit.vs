#version 450 core

#include "common.h"

layout(location=0) in vec3 Position;
layout(location=1) in vec3 Normal;
layout(location=2) in vec2 Texcoord;

out VERTEX_OUT
{
    vec2 myTexcoord;
    vec4 myFragPosDirectionalLightSpace;
    vec3 myWorldPosition;
    vec3 myNormal;
} VertexOut;

uniform mat4 uModelMatrix;

void main()
{
    VertexOut.myTexcoord = Texcoord;
    gl_Position = CameraBuffer.myProjectionMatrix * CameraBuffer.myViewMatrix * uModelMatrix * vec4(Position, 1.0);

    VertexOut.myNormal = mat3(transpose(inverse(uModelMatrix))) * Normal;

    vec4 worldPosition = uModelMatrix * vec4(Position, 1.0);
    VertexOut.myWorldPosition = worldPosition.xyz;

    vec3 fragPos = vec3(uModelMatrix * vec4(Position, 1.0));
    VertexOut.myFragPosDirectionalLightSpace = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(fragPos, 1.0);
}
