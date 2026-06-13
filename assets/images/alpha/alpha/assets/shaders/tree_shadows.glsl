#type vertex

#include "common.h"
#include "game_buffer.h"
#include "sprite_batch.h"
#include "tree.h"

out vec2 Texcoord;
out float Dissolve;

uniform vec2 uSpriteSheetSize;

void main()
{
#define SHADOW_PASS
#define SKIP_GL_POSITION
#include "sprite_batch.vs"

    float time = GameBuffer.myWindTime;
    vec2 worldPosXZ = worldPos.xz;
    float windOffset = GetWindDisplacement(worldPosXZ, time) * GameBuffer.myWindStrength;
    float swayAmount = windOffset * aQuadPos.y * 3.0;
    vec3 displaced = worldPos + vec3(swayAmount, 0.0, 0.0); // swaying left-right
    gl_Position = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(displaced, 1.0);
}

#type fragment

#include "common.h"

layout (location = 0) out float Final;

uniform sampler2D uTexture;

in vec2 Texcoord;
in float Dissolve;

void main()
{
    float sizeX = float(textureSize(uTexture, 0).x);
    float sizeY = float(textureSize(uTexture, 0).y);
    vec2 uv = Texcoord;
    vec2 uvr = vec2(floor(uv.x * sizeX) / sizeX, floor(uv.y * sizeY) / sizeY);
    float visible = step(Dissolve, Random(uvr));
    if (visible < 0.1)
        discard;

    float alpha = texture(uTexture, uv).a;
    if (alpha < 0.1)
        discard;
}
