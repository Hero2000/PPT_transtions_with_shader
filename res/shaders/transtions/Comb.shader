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

// �˱任������ ͼƬ �������ź���ת
vec2 transform(vec2 texcoord, vec2 ceter, vec2 scaleRatio,float theta)
{
    vec2 res = texcoord - ceter;// ͼƬ���������ĵ��ƶ���ԭ��
    // ��תǰת����ʵ���������꣬��Ȼ���ܱ�֤�Ƕ���Ȼ�Ǿ�ʮ��
    res = res * vec2(u_width,u_height);
    // ִ����ת
    res = vec2(dot(vec2(cos(theta),sin(theta)),res),dot(vec2(-sin(theta),cos(theta)), res));
    res = res / scaleRatio;// ִ������

    res = res / vec2(u_width, u_height);
    res = res + ceter;// ͼƬ��ԭ���ƶ����������ĵ�
    return res;
}
// �˱任������ ����״ �������ź���ת
vec2 transform(vec2 texcoord, float theta,vec2 hexagonNum)
{
    vec2 res = texcoord;
    res = res * vec2(u_width, u_height);
    res = res * hexagonNum;
    res = vec2(dot(vec2(cos(theta), sin(theta)), res), dot(vec2(-sin(theta), cos(theta)), res));
    res = res / vec2(u_width, u_height);
    return res;
}

float and(float a, float b)
{
    if(a > 0.5 && b > 0.5)      return 1.0;
    else                        return 0.0;
}
float or(float a, float b)
{
    if (a > 0.5 || b > 0.5)     return 1.0;
    else                        return 0.0;
}
float not(float a)
{
    return 1.0 -a;
}
float random(vec2 st) {
    //return dot(st,vec2(1.0,1.0));
    st = floor(st*1000.0)/1000.0 + vec2(0.001); // ������λС������ֹ���ھ��Ȳ������������
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);

}
float generateHoneyComb(vec2 hexagonNum,vec2 texCoord)
{
    // ȷ��ÿ�� ��Сƴ�ӿ� ������
    vec2 center = floor(texCoord * hexagonNum) * (1.0 / hexagonNum) + 0.5 / hexagonNum;

    vec2 coord = texCoord - center;

    // Ϊ�˻���һ�������Σ��ֱ�ִ�� 0�ȡ�60�ȡ�120�� ��ת
    vec2 coord1 = transform(coord, PI / 3.0, hexagonNum);
    vec2 coord2 = transform(coord, -PI / 3.0, hexagonNum);
    vec2 coord3 = transform(coord, 0.0, hexagonNum);

    // ���ѱ�Ե�Ŀ��
    float lineWidth = 0.05;

    // �ֱ������Сƴ�ӿ��ڵĸ������ı��ʽ��ͨ����������������
    float k1 = 1.0 / (0.5 - lineWidth);
    float v1 = floor(clamp(abs(coord1.y) * k1, 0.0, 1.0));
    float v2 = floor(clamp(abs(coord2.y) * k1, 0.0, 1.0));
    float v3 = floor(clamp(abs(coord3.y) * k1, 0.0, 1.0));

    float k2 = 1.0 / (0.5 + lineWidth);
    float v4 = floor(clamp(abs(coord1.y) * k2, 0.0, 1.0));
    float v5 = floor(clamp(abs(coord2.y) * k2, 0.0, 1.0));
    float v6 = floor(clamp(abs(coord3.y) * k2, 0.0, 1.0));

    float k3 = 1.0 / lineWidth;
    float v7 = floor(clamp(abs(coord3.y) * k3, 0.0, 1.0));

    float vrt = and(floor(coord3.x) + 1.0, floor(coord3.y) + 1.0);
    float vlt = and(-floor(coord3.x), floor(coord3.y) + 1.0);
    float vrd = and(floor(coord3.x) + 1.0, -floor(coord3.y));
    float vld = and(-floor(coord3.x), -floor(coord3.y));

    // ��ÿ�� ��Сƴ�ӿ� �Ĳ�ͬ�����εĲ��֣����ò�ͬ���������
    float r1 = and(v7, and(vlt, or(or(v4, v5), v6))) * random(center + vec2(0.5 / hexagonNum) * vec2(-1.0, 1.0));
    float r2 = and(v7, and(vrt, or(or(v4, v5), v6))) * random(center + vec2(0.5 / hexagonNum) * vec2(1.0, 1.0));
    float r3 = and(v7, and(vld, or(or(v4, v5), v6))) * random(center + vec2(0.5 / hexagonNum) * vec2(-1.0, -1.0));
    float r4 = and(v7, and(vrd, or(or(v4, v5), v6))) * random(center + vec2(0.5 / hexagonNum) * vec2(1.0, -1.0));
    float r5 = not(or(or(v1, v2), v3)) * random(center);

    float v = r1 + r2 + r3 + r4 + r5;

    return v;
}

void main()
{
    // ���õ�һ��ͼ�� ��ת�Ƕȡ��������ӣ������б任
    float theta1 = PI / 3.0 * u_ratio;
    vec2 scaleRatio1 = vec2(1.0 + 7.0 * u_ratio);
    vec2 coord1 = transform(texCoord, vec2(0.5, 0.5), scaleRatio1, theta1);
    vec4 texColor1 = texture(u_ourTexture1, coord1);

    // ���õڶ���ͼ�� ��ת�Ƕȡ��������ӣ������б任
    float theta2 = PI / 3.0 * (u_ratio - 1.0);
    vec2 scaleRatio2 = vec2(1.0 - 0.9 * (1.0-u_ratio));
    vec2 coord2 = transform(texCoord, vec2(0.5, 0.5), scaleRatio2, theta2);
    vec4 texColor2 = texture(u_ourTexture2, coord2);

    // ��Сƴ�ӿ������
    vec2 hexagonNum = vec2(7.0, 7.0);
    float v1 = generateHoneyComb(hexagonNum, coord1);
    if (u_ratio > v1)
        v1 = 0.0;
    float v2 = 1.0 - generateHoneyComb(hexagonNum, coord2);
    if (u_ratio > v2)
        v2 = 0.0;

    float w = 0.3;
    // �� ����״����״ �� ��ʼ�Լ������Ĳ��� ��ͬȷ��͸����
    float R1 = clamp(-1.0 / w * coord1.x + u_ratio * 10.0 * (w + 1.0) / w, 0.0, 1.0);
    float R2 = clamp(-1.0 / w * coord2.x + (w + 1.0) / w + (u_ratio - 0.9) * 10.0 * (-(w + 1.0) / w), 0.0, 1.0);

    float mixPar1 = (1.0 - ceil(v1 - 0.0001))* R1;
    float mixPar2 = ceil(v2 - 0.0001) * R2;

    texColor2 = mix(texColor2, vec4(0.0), mixPar2);
    FragColor = mix(texColor1, texColor2, mixPar1);
};