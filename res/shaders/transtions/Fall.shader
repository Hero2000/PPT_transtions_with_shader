#shader vertex

#version 330 core

layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTexCoord;
out vec2 texCoord;
void main()
{
	texCoord = aTexCoord;
	gl_Position = vec4(aPos, 1.0);
};

#shader fragment

#version 330 core

out vec4 FragColor;
in vec2 texCoord;
uniform sampler2D u_ourTexture1;
uniform sampler2D u_ourTexture2;
uniform float u_ratio;
#define PI 3.1415926
vec2 transform(vec2 texCoord, vec2 xyOffset, float zOffset, vec2 scaleCenter, float theta, vec2 rotateCenter)
{
	vec2 res = texCoord;
	//  �����������Ҫ z ƫ�ƣ��ʿ�עȥ
	//res = res - scaleCenter;
	//res = res * (1.0 + zOffset);
	//res = res + scaleCenter;

	// �� x ����ת���͸�ӣ�����Ϊ x �᷽��ļ��У�y�᷽������źͼ��У���������������أ�ʹ��ͼƬ����ȥ������
	res = res - rotateCenter;
	res.y = clamp(res.y / cos(theta), -0.5, 1.5);
	float yWrapFact = (0.3 * (1.0 - res.x) * u_ratio);// y ������������� x �����Ա仯������Ϊ��ߵ�һЩ
	res.y = res.y * (1.0 + res.y * sin(theta) + yWrapFact);
	float xWrapFact = 0.2 * (1.1 - res.x) * u_ratio * sin((res.y + 0.2 * res.x + 0.1) * PI);// x ������������� sin �������и���
	res.x = res.x * (1.0 + (res.y * sin(theta) + xWrapFact));
	res = res + rotateCenter;

	//  �����������Ҫ xy ƫ�ƣ��ʿ�עȥ
	// res = res - xyOffset;
	return res;
}
void main()
{
	vec4 resColor = vec4(1.0, 0.0, 0.0, 1.0);
	float zOffset1 = 0.0;
	vec2 screenCenter = vec2(0.5);
	vec2 xyOffset = vec2(0.0);
	vec2 rotateCenter = vec2(0.5, 0.0);

	// theta ��һ���ֶκ��������ڿ���׹���ٶȣ������Ժ����κ���
	float b = 0.001;
	float a = 0.2;
	float theta = b / a * u_ratio * PI * 0.5;
	if (u_ratio > a)
		theta = (pow((u_ratio - a) / (1.0 - a), 3.0) * (1.0 - b) + b) * PI * 0.5;

	vec2 coord1 = transform(texCoord, xyOffset, zOffset1, screenCenter, theta, rotateCenter);

	//  ����ͼƬ�䰵������
	float fadeRatio = 1.0 - 0.5 * u_ratio;
	resColor = fadeRatio * texture(u_ourTexture1, coord1);
	// ׹��ͼƬ�����������ʾ�ڶ���ͼ
	if (coord1.x < 0.0 || coord1.x > 1.0 || coord1.y < 0.0 || coord1.y > 1.0)
		resColor = texture(u_ourTexture2, texCoord);

	FragColor = resColor;
};