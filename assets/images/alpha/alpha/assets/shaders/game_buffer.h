layout (std140) uniform GAME_BUFFER
{
    vec3 myCenter;
    float myPlayerRadius;
    float myCampRadius;
    float myFeather;
    float myWindTime;
    float myWindStrength;
    vec3 myBeaconPos;
    float myBeaconRadius;
    float myRainCloudsAmount;
} GameBuffer;
