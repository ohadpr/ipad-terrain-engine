//
//  SkyBox.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#ifndef SKYBOX_H
#define SKYBOX_H

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "defs.h"
#include "Texture.h"
#include "Program.h"
#include "esTransform.h"

class CSkyBox {
public:
	CSkyBox();
	~CSkyBox();

	void					build			(GLfloat span);
	bool					loadShaders	();
	void					render			(ESMatrix &modelViewProj);

	int						m_numVertices;
	int						m_numIndices;
	
	DTexMappingVertex		*m_vertices;
	GLushort				*m_indices;
	
	CTexture				m_textures[6];
	CProgram				m_program;
};

#endif // SKYBOX_H