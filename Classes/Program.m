/*
 *  Program.cpp
 *  iTerrain
 *
 *  Created by Ohad Eder Pressman on 5/26/10.
 *  Copyright 2010 3D3R Software Studio. All rights reserved.
 *
 */

#include "Program.h"

CProgram::CProgram()
: m_id				(0)
, m_vertShader	(0)
, m_fragShader	(0)
{
}

CProgram::~CProgram()
{
	if (m_id) {
		glDeleteProgram(m_id);
		m_id = 0;
	}	
}


bool CProgram::load(NSString *shaderName)
{
	if (m_id) {
		glDeleteProgram(m_id);
	}
	
    // Create shader program
	m_id = glCreateProgram();
	
    // Create and compile vertex shader
	if (!compileShader(m_vertShader, GL_VERTEX_SHADER, [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh"])) {
        NSLog(@"Failed to compile vertex shader %@", shaderName);
        return FALSE;
	}
	
	if (!compileShader(m_fragShader, GL_FRAGMENT_SHADER, [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh"])) {
        NSLog(@"Failed to compile fragment shader %@", shaderName);
        return FALSE;
	}
	
    // Attach shaders
    glAttachShader(m_id, m_vertShader);
    glAttachShader(m_id, m_fragShader);
	
	return TRUE;	
}

bool CProgram::compileShader(GLuint &shader, GLenum type, NSString* file)
{
    GLint			status;
    const GLchar *source;
	
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load shader");
        return false;
    }
	
    shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
	
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
	
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(shader);
        return false;
    }
	
    return true;
}


bool CProgram::link()
{
    GLint status;
	
    glLinkProgram(m_id);
	
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(m_id, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(m_id, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
	
    glGetProgramiv(m_id, GL_LINK_STATUS, &status);
    if (status == 0)
        return false;
	
    return true;
}

bool CProgram::validate()
{
    GLint logLength, status;
	
    glValidateProgram(m_id);
    glGetProgramiv(m_id, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(m_id, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
	
    glGetProgramiv(m_id, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return false;
	
    return true;
}

void CProgram::use()
{
    glUseProgram(m_id);
}

void CProgram::deleteShaders()
{
	if (m_vertShader) glDeleteShader(m_vertShader);
	if (m_fragShader) glDeleteShader(m_fragShader);
}

void CProgram::bindAttribLocation(GLuint index, const GLchar *name)
{
	glBindAttribLocation(m_id, index, name);	// this needs to be done prior to linking
}

GLint CProgram::getUniformLocation	(const GLchar *name)
{
	return glGetUniformLocation(m_id, name);	
}