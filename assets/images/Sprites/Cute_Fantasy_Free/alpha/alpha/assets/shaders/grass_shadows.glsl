#type vertex

#include "common.h"
#include "sprite_batch.h"
#include "grass.h"

out vec2 Texcoord;
out float Dissolve;

uniform vec2 uSpriteSheetSize;

void main()
{
#define SHADOW_PASS
#define SKIP_GL_POSITION
#include "sprite_batch.vs"

    float time = CameraBuffer.myResolutionAndTime.z;
    vec2 worldPosXZ = worldPos.xz;
    float windOffset = GetWindDisplacement(worldPosXZ, time) * 0.5;
    float swayAmount = windOffset * aQuadPos.y * 3.0;
    vec3 displaced = worldPos + vec3(swayAmount, 0.0, 0.0); // swaying left-right
    gl_Position = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(displaced, 1.0);
}

#type fragment

in vec2 Texcoord;
in float Dissolve;

layout (location = 0) out float Final;

uniform sampler2D uTexture;

void main()
{
	float alpha = texture(uTexture, Texcoord).a;
	if (alpha < 0.1)
		discard;
}
