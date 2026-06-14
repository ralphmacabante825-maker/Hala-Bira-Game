vec3 ColorGrade(vec3 inputCol)
{
    inputCol *= 1.15;

    float warmth = 0.35;
    vec3 warmColor = vec3(1.0, 0.9, 0.7);
    float luma = dot(inputCol, vec3(0.299, 0.587, 0.114));
    inputCol = mix(inputCol, inputCol * warmColor, luma * warmth);

    float saturationAmount = 1.025;
	float luminance = dot(inputCol, vec3(0.2126, 0.7152, 0.0722));
	return mix(vec3(luminance), inputCol, saturationAmount);
}
