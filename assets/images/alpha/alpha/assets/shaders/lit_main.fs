#ifndef NO_DISSOLVE
float sizeX = float(textureSize(uTexture, 0).x);
float sizeY = float(textureSize(uTexture, 0).y);
vec2 uv = Texcoord;
vec2 uvr = vec2(floor(uv.x * sizeX) / sizeX, floor(uv.y * sizeY) / sizeY);
float visible = step(Dissolve, Random(uvr));
if (visible < 0.1)
    discard;
#endif

#ifndef CUSTOM_COLOR
vec4 objectColor = texture(uTexture, Texcoord) * Color;
if (objectColor.a < 0.1) {
    discard;
}
#endif
vec3 normal = normalize(Normal);

float time = GameBuffer.myWindTime;

// shadow
#ifdef NO_SHADOWS
float shadow = 0.0;
#else
vec2 cloudTexCoords = WorldPosition.xz / 1024.0;
cloudTexCoords.xy += time * 0.0025;

float cloudsShadow = texture(uClouds, cloudTexCoords).a;
float heavyCloudsShadow = texture(uHeavyClouds, cloudTexCoords).a;
float combinedClouds = mix(cloudsShadow, heavyCloudsShadow, GameBuffer.myRainCloudsAmount) * 0.5;
#ifdef STATIC_BIAS
float shadow = mix(CalcDirectionalLightShadowStaticBias(LightBuffer.myDirectionalLight, normal, FragPosDirectionalLightSpace, WorldPosition) * LightBuffer.myShadowIntensity, combinedClouds, 0.5);
#else
float shadow = mix(CalcDirectionalLightShadow(LightBuffer.myDirectionalLight, normal, FragPosDirectionalLightSpace, WorldPosition) * LightBuffer.myShadowIntensity, combinedClouds, 0.5);
#endif
shadow = min(shadow, LightBuffer.myShadowIntensity);
#endif

vec3 sunColor = LightBuffer.myDirectionalLight.myColor;

// ambient
float ambientStrength = 1.0;
// vec3 ambientColor = mix(litAmbientColor, shadowAmbientColor, shadow);
vec3 ambient = ambientStrength * LightBuffer.myAmbientColor;

// light direction
vec3 lightDir = normalize(-LightBuffer.myDirectionalLight.myDirection);
float diff = max(dot(normal, lightDir), 0.0);
vec3 diffuse = diff * sunColor * LightBuffer.mySunIntensity;

// final
vec3 litColor = (ambient + (1.0 - shadow) * diffuse);
vec3 result = mix(litColor, LightBuffer.myShadowColor, min(shadow, LightBuffer.mySunIntensity)) * objectColor.xyz;
