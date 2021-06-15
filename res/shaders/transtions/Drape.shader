#shader vertex

#version 330 core

layout (location = 0) in vec3 aPos;
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
// tent ���������ڲ�ͬ�ؼ�֡�����Բ�ֵ
float triFun(float x, float l, float c, float r)
{
	if (l == c) l = c - 0.0001;
	if (r == c) r = c + 0.0001;
	float y1 = (x - l) / (c - l);
	float y2 = (x - r) / (c - r);
	return min(clamp(y1, 0.0, 1.0), clamp(y2, 0.0, 1.0));
}
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}
vec3 transform(vec2 texCoord)
{
	vec2 res = texCoord;
	float t1 = 0.5,t2 = 0.6,t3 = 0.7,t4 = 1.0;
	// �任��˼�������ڣ������Ĺؼ�֡���ڹؼ�ʱ��㶨��ñ任��ʽ��Ȼ���ֵ
	// �� x ����Ĺؼ�֡�任���ʽ
	float fx1_left = 0.0;
	float fx2_left = 0.1 * res.y * (1.0 - res.y);
	float fx3_left = 0.1 * pow(1.0 - res.y, 2.0);
	float fx4_left = 0.0;
	float fx1_right = 1.0;
	float fx2_right = 1.0 - 0.05 * res.y * (1.0 - res.y);
	float fx3_right = 1.0 - 0.05 * pow(1.0 - res.y, 2.0);
	float fx4_right = 1.0;
	// ��x�Ĺؼ�֡���в�ֵ��ʹ�� tent ����
	float deltaX_left =
		triFun(u_ratio, t1, t1, t2) * (fx1_left)
		+triFun(u_ratio, t1, t2, t3) * (fx2_left)
		+triFun(u_ratio, t2, t3, t4) * (fx3_left)
		+triFun(u_ratio, t3, t4, t4) * (fx4_left);
	float deltaX_right =
		triFun(u_ratio, t1, t1, t2) * (fx1_right)
		+triFun(u_ratio, t1, t2, t3) * (fx2_right)
		+triFun(u_ratio, t2, t3, t4) * (fx3_right)
		+triFun(u_ratio, t3, t4, t4) * (fx4_right);
	// �� x ������б任
	res.x = (res.x - deltaX_left) / (deltaX_right - deltaX_left);
	// �� y ����Ĺؼ�֡�任���ʽ
	float fy1_down = 0.0;
	float fy2_down = 0.3 * ((0.2-0.3)*res.x + 0.2);
	float fy3_down = 0.5 * ((0.2 - 0.3) * res.x + 0.2);
	float fy4_down = 0.0;
	float fy1_top = 1.0;
	float fy2_top = 1.0;
	float fy3_top = 1.0;
	float fy4_top = 1.0;
	// ��y�Ĺؼ�֡���в�ֵ��ʹ�� tent ����
	float deltaY_down =
		triFun(u_ratio, t1, t1, t2) * (fy1_down)
		+triFun(u_ratio, t1, t2, t3) * (fy2_down)
		+triFun(u_ratio, t2, t3, t4) * (fy3_down)
		+triFun(u_ratio, t3, t4, t4) * (fy4_down);
	float deltaY_top = 1.0;
	// �� y ������б任
	res.y = (res.y - deltaY_down) / (deltaY_top - deltaY_down);
	// ��Ӱ�仯���ͱ任�������һͬ����
	float intensityOffset = 0.0;
	return vec3(res, intensityOffset);
}

void main()
{
	vec4 resColor = vec4(u_ratio,0.0,0.0,1.0);
    vec4 texColor1 = texture(u_ourTexture1, texCoord);
    vec4 texColor2 = texture(u_ourTexture2, texCoord);

	if (u_ratio < 0.5)
	{
		float R = pow(clamp(1.0 - u_ratio/0.5,0.0,1.0),2.0);
		// ת��������ʵ����������ϵ���б任
		vec2 coord = texCoord;
		coord.y = 2.0*R - coord.y;
		// ��ӹ�Ӱ�仯
		float intensityOffset = -0.5+2.0*(texCoord.y - R) ;
		// �ҿ��ı���Ĳ���
		resColor = texture(u_ourTexture1, coord)*(1.0 + intensityOffset);
		//resColor = vec4(1.0+intensityOffset,0.0,0.0,1.0);
		if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0)
			resColor = texColor1;
		if(texCoord.y < R)
			resColor = texColor2;
	}
	else
	{
		vec3 coord = transform(texCoord);
		resColor = texture(u_ourTexture1, coord.xy);
		if (coord.x < 0.0 || coord.x > 1.0 || coord.y < 0.0 || coord.y > 1.0)
			resColor = texColor2;
	}
    FragColor = resColor;
};