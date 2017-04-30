/*
 *  Program.h
 *  iTerrain
 *
 *  Created by Ohad Eder Pressman on 5/26/10.
 *  Copyright 2010 3D3R Software Studio. All rights reserved.
 *
 */

#ifndef PROGRAM_H
#define PROGRAM_H

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


class CProgram
{
public:
	CProgram();
	~CProgram();
	
	bool	load					(NSString *shaderName);
	bool	link					();
	
	void	bindAttribLocation	(GLuint index, const GLchar *name);
	GLint	getUniformLocation	(const GLchar *name);
	void	deleteShaders			();

	void	use						();
	bool	validate				();
	
private:
	bool	compileShader			(GLuint &shader, GLenum type, NSString* file);
	
	GLuint	m_id;
	GLuint	m_vertShader, m_fragShader;
};

#endif // PROGRAM_H