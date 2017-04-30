//
//  Water.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#ifndef WATER_H
#define WATER_H

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "defs.h"
#include "Texture.h"
#include "Program.h"
#include "esTransform.h"

class CWater {
public:
	CWater();
	~CWater();
	
	void					build			(GLfloat span, int resolution);
	bool					loadShaders	();
	void					render			(ESMatrix &modelViewProj);
	
	
	int						m_resolution;	// # of vertices per row/col
	
	int						m_numVertices;
	int						m_numIndices;
	
	DTexMappingVertex		*m_vertices;
	GLushort				*m_indices;
	
	CTexture				m_texture;
	CProgram				m_program;	
};

#endif // WATER_H