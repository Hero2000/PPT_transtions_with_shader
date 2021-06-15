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
// tent ���������ڲ�ͬ�ؼ�֡�����Բ�ֵ
float triFun(float x, float l, float c, float r)
{
	float y1 = x / (c - l) - l / (c - l);
	float y2 = x / (c - r) + r / (r - c);
	return min(clamp(y1, 0.0, 1.0), clamp(y2, 0.0, 1.0));
}
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}
vec3 hash33(vec3 p) {
	float n = sin(dot(p, vec3(7, 157, 113)));
	return fract(vec3(2097152, 262144, 32768) * n) * 2. - 1.;
}
float tetraNoise(in vec3 p)
{
	vec3 i = floor(p + dot(p, vec3(0.333333)));  p -= i - dot(i, vec3(0.166666));
	vec3 i1 = step(p.yzx, p), i2 = max(i1, 1.0 - i1.zxy); i1 = min(i1, 1.0 - i1.zxy);
	vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
	vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.0);
	vec4 d = vec4(dot(p, hash33(i)), dot(p1, hash33(i + i1)), dot(p2, hash33(i + i2)), dot(p3, hash33(i + 1.)));
	return clamp(dot(d, v * v * v * 8.) * 1.732 + .5, 0., 1.); // Not sure if clamping is necessary. Might be overkill.
}
// һ�� transform ��ɵ��ߴ�����������ı任�������� main ����Ҫ�� 0.5 ���ҷֱ����
vec3 transform(vec2 texCoord)
{
	vec2 res = texCoord;
	// �任��˼�������ڣ������Ĺؼ�֡���ڹؼ�ʱ��㶨��ñ任��ʽ��Ȼ���ֵ
	float t1 = 0.0, t2 = 0.5 / 6.0, t3 = 2.0 / 6.0, t4 = 3.0 / 6.0, t5 = 3.5 / 6.0, t6 = 4.5 / 6.0, t7 = 5.3 / 6.0, t8 = 1.0;
	// �� x ����Ĺؼ�֡�任���ʽ
	float fx1 = 0.0;
	float fx2 = 0.5 * pow(res.y, 2.0);
	float fx3 = 0.5;
	float fx4 = 0.5 + 0.25 * pow(1.0 - res.y, 2.0);
	float fx5 = 0.5;
	float fx6 = 0.5 - 0.25 * pow(1.0 - res.y, 2.0);
	float fx7 = 1.0 - 0.75 * pow(1.0 - res.y, 2.0);
	float fx8 = 1.0;
	// ��x�Ĺؼ�֡���в�ֵ��ʹ�� tent ����
	float deltaX =
		triFun(u_ratio, t1, t1, t2) * (fx1)
		+triFun(u_ratio, t1, t2, t3) * (fx2)
		+triFun(u_ratio, t2, t3, t4) * (fx3)
		+triFun(u_ratio, t3, t4, t5) * (fx4)
		+triFun(u_ratio, t4, t5, t6) * (fx5)
		+triFun(u_ratio, t5, t6, t7) * (fx6)
		+triFun(u_ratio, t6, t7, t8) * (fx7)
		+triFun(u_ratio, t7, t8, t8) * (fx8);
	// �� x ������б任������ȵĴ������� and ϸ΢��ƫ��
	res.x = (res.x - deltaX) / (1.0 + 0.2 * u_ratio - deltaX);
	res.x = res.x - 0.02 * cos(20.0 * PI * res.x) * deltaX;
	// �� y ����Ĺؼ�֡�任���ʽ
	float fy1 = 0.0;
	float fy2 = 0.2 * pow(1.0 - res.x, 2.0);
	float fy3 = 0.0;
	float fy4 = 0.05 * pow(1.0 - (res.x), 2.0);
	float fy5 = 0.0;
	float fy6 = 0.05 * pow(1.0 - (res.x), 2.0);
	float fy7 = 0.3 * pow(1.0 - (res.x), 2.0);
	float fy8 = 0.0;
	// �� y �Ĺؼ�֡���в�ֵ��ʹ�� tent ����
	float deltaY =
		triFun(u_ratio, t1, t1, t2) * (fy1)
		+triFun(u_ratio, t1, t2, t3) * (fy2)
		+triFun(u_ratio, t2, t3, t4) * (fy3)
		+triFun(u_ratio, t3, t4, t5) * (fy4)
		+triFun(u_ratio, t4, t5, t6) * (fy5)
		+triFun(u_ratio, t5, t6, t7) * (fy6)
		+triFun(u_ratio, t6, t7, t8) * (fy7)
		+triFun(u_ratio, t7, t8, t8) * (fy8);
	// �� y ������б任������ȵĴ������� and ϸ΢��ƫ��
	res.y = (res.y - 1.0) / (1.0 - deltaY) + 1.0;
	res.y = res.y + 0.05 * sin(20.0 * PI * res.x) * deltaX * (1.0 - res.y) * random(vec2(floor(res.x * 20.0), 1.0));
	float noise = tetraNoise(vec3(res * vec2(5.0, 0.2), u_ratio * 1.0));
	//res.x = res.x - clamp(0.2 * noise * pow(deltaX, 0.5),0.0,res.x);

	// �������������Ǻ����Ĺ�Ӱ�仯���ͱ任�������һͬ����
	float intensityOffset = 0.2 * cos(20.0 * PI * (res.x - clamp(0.2 * noise * pow(deltaX, 0.5), 0.0, res.x))) * deltaX;
	return vec3(res, intensityOffset);
}


void main()
{
	vec4 resColor = vec4(1.0, 0.0, 0.0, 1.0);
	vec4 texColor2 = texture(u_ourTexture2, texCoord);
	// ���Ұ벿�֣��� 0.5 -> 1.0 ӳ�䵽 0.0 -> 1.0������ transform ����ӳ�����
	if (texCoord.x > 0.5)
	{
		vec2 coord = vec2(texCoord.x * 2.0 - 1.0, texCoord.y);
		vec3 res = transform(coord);
		resColor = texture(u_ourTexture1, vec2(res.x * 0.5 + 0.5, res.y));
		resColor = resColor * (1.0 + res.z);
		// ������һ��ͼ���� 0-1 ��Χ�ĵط�����ʾ��һ��ͼ
		if (res.x < 0.0 || res.x > 1.0 || res.y < 0.0 || res.y > 1.0)
			resColor = texColor2;
	}
	// ����벿�֣��� 0.0 -> 0.5 ӳ�䵽 1.0 -> 0.0������ transform ����ӳ�����
	if (texCoord.x <= 0.5)
	{
		vec2 coord = vec2(1.0 - texCoord.x * 2.0, texCoord.y);
		vec3 res = transform(coord);
		resColor = texture(u_ourTexture1, vec2(0.5 - res.x * 0.5, res.y));

		resColor = resColor * (1.0 + res.z);
		if (res.x < 0.0 || res.x > 1.0 || res.y < 0.0 || res.y > 1.0)
			resColor = texColor2;
	}
	FragColor = resColor;
};