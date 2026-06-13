vec2 local2D = aQuadPos - iOrigin;
local2D *= iUVRect.zw;
local2D *= iScale;

// specific for this game, rotate 65 degrees in X
vec3 local = vec3(local2D, 0.0);

float cz = cos(iRotation);
float sz = sin(iRotation);
local = vec3(
    local.x * cz - local.y * sz,
    local.x * sz + local.y * cz,
    local.z
);

float cx = cos(-1.13446401);
float sx = sin(-1.13446401);
local = vec3(
    local.x,
    local.y * cx - local.z * sx,
    local.y * sx + local.z * cx
);

vec3 worldPos = iPosition + local;

#ifndef SKIP_GL_POSITION
#ifdef SHADOW_DEPTH
gl_Position = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(worldPos, 1.0);
#else
gl_Position = CameraBuffer.myProjectionMatrix * CameraBuffer.myViewMatrix * vec4(worldPos, 1.0);
#endif
#endif

vec2 spriteLocation = (vec2(0.0, uSpriteSheetSize.y) - (iUVRect.xy + vec2(0.0, iUVRect.w)) * vec2(-1.0, 1.0)) / uSpriteSheetSize;
vec2 spriteSize = iUVRect.zw / uSpriteSheetSize;
vec2 flipped = aQuadUV;
bool flipX = (iFlags & 1u) != 0u;
bool flipY = (iFlags & 2u) != 0u;
if (flipX) flipped.x = 1.0 - flipped.x;
if (flipY) flipped.y = 1.0 - flipped.y;

Dissolve = iCustom.x;
Texcoord = spriteLocation + flipped * spriteSize;

#ifndef SHADOW_PASS
WorldPosition = worldPos;
FragPosDirectionalLightSpace = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(worldPos, 1.0);
Color = HexToRGBA(iColor);
Normal = vec3(0, 1, 0);
#endif
