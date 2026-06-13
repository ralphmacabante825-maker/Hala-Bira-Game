struct DirectionalLight
{
	vec3 myColor;
	vec3 myDirection;
};

struct SpotLight
{
	vec4 myColor;
	vec3 myPosition;
	vec3 myDirection;
	float myCutOff;
	float myOuterCutOff;
	float myDistance;
	float myIntensity;
};

layout (std140) uniform CAMERA_BUFFER
{
	mat4 myProjectionMatrix;
	mat4 myPrevProjectionMatrix;
	mat4 myViewMatrix;
    mat4 myViewMatrixCentered;
	mat4 myPrevViewMatrix;
    mat4 myPrevViewMatrixCentered;
	mat4 myInvProjViewMatrix;
    mat4 myInvProjectionMatrix;
    mat4 myInvViewMatrix;
	vec4 myResolutionAndTime;
	vec4 myCameraPos;
    vec4 myCameraDir;
    vec4 myCameraUp;
    vec4 myCameraRight;
    vec4 myNearFarFOV;
} CameraBuffer;

layout (std140) uniform LIGHT_BUFFER
{
	DirectionalLight myDirectionalLight;
	vec3 myAmbientColor;
    float myShadowIntensity;
    vec3 myShadowColor;
    float mySunIntensity;
} LightBuffer;

layout (std140) uniform SPOT_LIGHT_SHADOW_BUFFER
{
	mat4 myProjectionMatrix;
	mat4 myViewMatrix;
	vec3 myLightPos;
	float myFarPlane;
} SpotLightBuffer;

layout (std140) uniform DIRECTIONAL_LIGHT_SHADOW_BUFFER
{
	mat4 myProjectionMatrix;
	mat4 myViewMatrix;
} DirectionalLightBuffer;

uniform sampler2D uSpotLightDepth;
uniform sampler2D uDirectionalLightDepth;

float LinearDepth(float depthSample)
{
    float near = CameraBuffer.myNearFarFOV.x;
    float far = CameraBuffer.myNearFarFOV.y;
    return near * far / (far + depthSample * (near - far));
}

float CalcSpotLightShadow(vec3 normal, vec3 fragPos, vec4 fragPosSpotLightSpace)
{
    vec3 lightDir = normalize(SpotLightBuffer.myLightPos - fragPos);
    vec3 projCoords = fragPosSpotLightSpace.xyz / fragPosSpotLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;
    float closestDepth = texture(uSpotLightDepth, projCoords.xy).r;
    float currentDepth = projCoords.z;
    float bias = max(0.001 * (1.0 - dot(normal, lightDir)), 0.0001);
    float shadow = currentDepth - bias > closestDepth  ? 1.0 : 0.0;
    return shadow;
}

vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 objectColor, vec3 fragPos, vec4 fragPosSpotLightSpace)
{
    vec3 lightDir = normalize(light.myPosition - fragPos);
    float diff = max(dot(normal, lightDir), 0.0);
    float theta = dot(lightDir, normalize(light.myDirection));
    float epsilon = (light.myCutOff - light.myOuterCutOff);
    float intensity = clamp((theta - light.myOuterCutOff) / epsilon, 0.0, 1.0);
    float distance = length(light.myPosition - fragPos);
    float attenuation = clamp(light.myIntensity - distance * distance / (light.myDistance * light.myDistance), 0.0, 1.0); attenuation *= attenuation;
    vec3 diffuse = light.myColor.xyz * objectColor * diff * intensity * attenuation;
    return diffuse * (1.0 - CalcSpotLightShadow(normal, fragPos, fragPosSpotLightSpace));
}

float Linstep(float low, float high, float v)
{
	return clamp((v-low)/(high-low), 0.0, 1.0);
}

float CalcDirectionalLightVarianceShadow(DirectionalLight light, vec3 normal, vec4 fragPosDirectionalLightSpace)
{
    vec3 projCoords = fragPosDirectionalLightSpace.xyz / fragPosDirectionalLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;
    float currentDepth = projCoords.z;

    float bias = max(0.001 * (1.0 - dot(normal, light.myDirection)), 0.0001);

    if(projCoords.z > 1.0)
        return 1.0;

    vec2 moments = texture(uDirectionalLightDepth, projCoords.xy).rg;
    float E_x = moments.x;
    float E_x2 = moments.y;

    float variance = E_x2 - (E_x * E_x);
    variance = max(variance, 0.00001);
    float delta = currentDepth - E_x;
    float p_max = variance / (variance + delta * delta);
    float shadow = (delta <= bias) ? 1.0 : p_max;
    return clamp(shadow, 0.0, 1.0);
}

vec3 CalcDirectionalLightVariance(DirectionalLight light, vec3 normal, vec3 objectColor, vec4 fragPosDirectionalLightSpace)
{
    vec3 lightDir = normalize(-light.myDirection);
    float diff = max(dot(normal, lightDir), 0.2);
    vec3 diffuse = light.myColor.xyz * objectColor * diff;
    return (LightBuffer.myAmbientColor - clamp(-CalcDirectionalLightVarianceShadow(light, normal, fragPosDirectionalLightSpace) + diff, 0.0, 0.45) + diffuse) * objectColor.xyz;
}

float CalcDirectionalLightShadow(DirectionalLight light, vec3 normal, vec4 fragPosDirectionalLightSpace, vec3 worldPos)
{
    float shadowPixelWorldSize = 1.0;
    vec3 quantizedWorldPos = floor(worldPos / shadowPixelWorldSize) * shadowPixelWorldSize;
    vec4 quantizedLightSpacePos = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(quantizedWorldPos, 1.0);
    vec3 projCoords = quantizedLightSpacePos.xyz / quantizedLightSpacePos.w;
    projCoords = projCoords * 0.5 + 0.5;

    float currentDepth = (fragPosDirectionalLightSpace.xyz / fragPosDirectionalLightSpace.w).z * 0.5 + 0.5;
    float bias = max(0.05 * (1.0 - dot(normal, light.myDirection)), 0.005);

    if(projCoords.z > 1.0)
        return 0.0;

    float closestDepth = texture(uDirectionalLightDepth, projCoords.xy).r;
    float shadow = currentDepth - bias > closestDepth  ? 1.0 : 0.0;

    return clamp(shadow, 0.0, 1.0);
}

float CalcDirectionalLightShadowStaticBias(DirectionalLight light, vec3 normal, vec4 fragPosDirectionalLightSpace, vec3 worldPos)
{
    float shadowPixelWorldSize = 1.0;
    vec3 quantizedWorldPos = floor(worldPos / shadowPixelWorldSize) * shadowPixelWorldSize;
    vec4 quantizedLightSpacePos = DirectionalLightBuffer.myProjectionMatrix * DirectionalLightBuffer.myViewMatrix * vec4(quantizedWorldPos, 1.0);
    vec3 projCoords = quantizedLightSpacePos.xyz / quantizedLightSpacePos.w;
    projCoords = projCoords * 0.5 + 0.5;

    float currentDepth = (fragPosDirectionalLightSpace.xyz / fragPosDirectionalLightSpace.w).z * 0.5 + 0.5;
    float bias = 0.005;

    if(projCoords.z > 1.0)
        return 0.0;

    float closestDepth = texture(uDirectionalLightDepth, projCoords.xy).r;
    float shadow = currentDepth - bias > closestDepth  ? 1.0 : 0.0;

    return clamp(shadow, 0.0, 1.0);
}

vec3 CalcDirectionalLight(DirectionalLight light, vec3 normal, vec3 objectColor, vec4 fragPosDirectionalLightSpace, vec3 worldPos)
{
    vec3 lightDir = normalize(-light.myDirection);
    float diff = max(dot(normal, lightDir), 0.2);
    vec3 diffuse = light.myColor.xyz * objectColor * diff;
    float shadow = CalcDirectionalLightShadow(light, normal, fragPosDirectionalLightSpace, worldPos);
    return diffuse - clamp(shadow, 0.0, 0.45);//(LightBuffer.myAmbientColor - clamp(-CalcDirectionalLightShadow(light, normal, fragPosDirectionalLightSpace) + diff, 0.0, 0.45) + diffuse) * objectColor.xyz;
}

float Random(vec2 uv)
{
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 438.5453);
}

float SRGBToLinear(float c)
{
#ifdef IS_WEBGL
    return c;
#else
    return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
#endif
}

vec3 SRGBToLinear(vec3 c)
{
#ifdef IS_WEBGL
    return c;
#else
    return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
#endif
}

vec4 SRGBToLinear(vec4 c)
{
#ifdef IS_WEBGL
    return c;
#else
    return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
#endif
}

float LinearToSRGB(float c)
{
    return max(1.055 * pow(c, 1.0/2.4) - 0.055, 0.0);
}

vec3 LinearToSRGB(vec3 c)
{
    return max(1.055 * pow(c, vec3(1.0/2.4)) - 0.055, 0.0);
}

vec4 LinearToSRGB(vec4 c)
{
    return max(1.055 * pow(c, vec4(1.0/2.4)) - 0.055, 0.0);
}

vec4 HexToRGBA(uint value)
{
    return vec4(
            float((value >> 24u) & 0xFFu) / 255.0,
            float((value >> 16u) & 0xFFu) / 255.0,
            float((value >> 8u) & 0xFFu) / 255.0,
            float(value & 0xFFu) / 255.0
        );
}


float SMin(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float SMax(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (a - b) / k, 0.0, 1.0);
    return mix(b, a, h) + k * h * (1.0 - h);
}

float SMaxExp(float a, float b, float k)
{
    return log(exp(k * a) + exp(k * b)) / k;
}
