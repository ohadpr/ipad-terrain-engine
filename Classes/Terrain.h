//
//  Terrain.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#ifndef TERRAIN_H
#define TERRAIN_H

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "defs.h"
#include "Texture.h"
#include "Program.h"
#include "esTransform.h"

struct DTerrainVertex {
	DVector	pos;
	DTexCoord	texcoord;
};

class CTerrain {
public:
	CTerrain();
	~CTerrain();
	
	void				build			(NSString *typePrefix, GLfloat span, GLfloat height, GLfloat waterHeight, int resolution);
	bool				loadShaders	();
	void				render			(ESMatrix &modelViewProj);
	void blet();
	
	struct{
		GLfloat	span;
		GLfloat	height;
		GLfloat	waterHeight;
		GLint		resolution;
	} m_params;
	
	NSString			*m_typePrefix;
	
	int					m_numVertices;
	int					m_numIndices;
	
	DTerrainVertex	*m_vertices;
	GLushort			*m_indices;
	DImage				m_heightMap;
	
	CTexture			m_terrainTexture;
	CTexture			m_detailTexture;
	CProgram			m_program;	
};

#endif // TERRAIN_H