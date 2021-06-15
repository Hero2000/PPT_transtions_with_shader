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
uniform float u_width;
uniform float u_height;
#define PI 3.1415926
// бֱ�߶��� x �ı��ʽ
float fx(float x)
{
	return x - u_width + u_ratio * (u_height + u_width + 100.0);
}
// бֱ�߶��� y �ı��ʽ
float gy(float y)
{
	return y + u_width - u_ratio * (u_height + u_width + 100.0);
}
void main()
{
	vec4 resColor = vec4(u_ratio, 0.0, 0.0, 1.0);
	vec4 texColor1 = texture(u_ourTexture1, texCoord);
	vec4 texColor2 = texture(u_ourTexture2, texCoord);

	// ת��������ʵ����������ϵ���б任
	vec2 coordRealScale = texCoord * vec2(u_width, u_height);

	// �ö��κ������Խҿ��ı�Ե���ƫ��
	float xNor = (coordRealScale.x - gy(0.0)) / (u_width - gy(0.0));
	float yNor = (coordRealScale.y - 0.0) / (fx(u_width) - 0.0);
	if (coordRealScale.x > gy(0.0) && coordRealScale.x < u_width)
		coordRealScale.y = coordRealScale.y + 70.0 * xNor * (1.0 - xNor);
	if (coordRealScale.y > 0.0 && coordRealScale.y < fx(u_width))
		coordRealScale.x = coordRealScale.x - 70.0 * yNor * (1.0 - yNor);

	//  �� y = f(x) ��ת
	coordRealScale = vec2(gy(coordRealScale.y), fx(coordRealScale.x));
	vec2 coord = coordRealScale / vec2(u_width, u_height);
	// ��ӹ�Ӱ�仯
	float intensityOffset = (1.0 - (1.0 - coord.x) * u_width / u_height - coord.y) + 2.0 * u_ratio - 0.1;
	// �ҿ��ı���Ĳ���
	resColor = texture(u_ourTexture1, coord) * intensityOffset;
	if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0)
		resColor = texColor1;
	if (coordRealScale.y > fx(coordRealScale.x))
		resColor = texColor2;
	FragColor = resColor;
};