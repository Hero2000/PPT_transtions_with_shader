#pragma once
#include"VertexArray.h"
#include"Shader.h"
#include"IndexBuffer.h"

class Renderer
{
private:

public:
	Renderer(){}
	void Draw(const VertexArray& va, const Shader& shader) const
	{
		shader.Bind();
		va.Bind();
		glDrawArrays(GL_TRIANGLES, 0, 36); // ʹ�� VBO
	}
	void Draw(const VertexArray& va, const Shader& shader,const unsigned int count) const
	{
		shader.Bind();
		va.Bind();
		glDrawArrays(GL_TRIANGLES, 0, count); // ʹ�� VBO
	}
	void DrawInstance(const VertexArray& va, const Shader& shader, const unsigned int count, const unsigned int num) const
	{
		shader.Bind();
		va.Bind();
		glDrawArraysInstanced(GL_TRIANGLES, 0, count,num); // ʹ�� VBO
	}
	void Draw(const VertexArray& va, const IndexBuffer& ib, const Shader& shader) const
	{
		shader.Bind();
		va.Bind();
		ib.Bind();
		glDrawElements(GL_TRIANGLES, ib.GetCount(), GL_UNSIGNED_INT, 0); // ʹ�� EBO
	}
	void Clear()
	{
		glClearColor(0.2f, 0.2f, 0.2f, 1.0f);//�����������ɫ����������ɫ
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);//�˴�������ѡ��GL_COLOR_BUFFER_BIT��GL_DEPTH_BUFFER_BIT��GL_STENCIL_BUFFER_BIT

		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LESS);
	}
};