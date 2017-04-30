//
//  SkyBox.m
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

///
//  Includes
//
#include "SkyBox.h"


// uniform index
enum {
	UNIFORM_MODELVIEWPROJ_MATRIX = 0,
	UNIFORM_TEXTURE,
	
	NUM_UNIFORMS
};

static GLint s_uniforms[NUM_UNIFORMS];

// attribute index
enum {
	ATTRIB_VERTEX,
	ATTRIB_TEXCOORD
};


CSkyBox::CSkyBox()
: m_vertices	(0)
, m_indices	(0)
{
}

CSkyBox::~CSkyBox()
{
	if (m_vertices)	delete m_vertices;
	if (m_indices)	delete m_indices;
}


void CSkyBox::build(GLfloat span)
{
	m_numVertices = 5*4;
	m_vertices = new DTexMappingVertex[m_numVertices];

	// all vertices are laid out as if we're looking at the plane from 0,0,0

	const GLfloat	u0 = 0.5f / 256.f,
					u1 = (256.f-0.5f) / 256.f,
					v0 = 0.5f / 256.f,
					v1 = (256.f-0.5f) / 256.f;
	
	// front
	m_vertices[0*4+0].set(-span,2*span,-span,	u1, v1);
	m_vertices[0*4+1].set(span,2*span,-span,	u0, v1);
	m_vertices[0*4+2].set(span,0,-span,	u0, v0);
	m_vertices[0*4+3].set(-span,0,-span,	u1, v0);
	
	// back
	m_vertices[1*4+0].set(span,2*span,span,		u0, v0);
	m_vertices[1*4+1].set(-span,2*span,span,	u1, v0);
	m_vertices[1*4+2].set(-span,0,span,	u1, v1);
	m_vertices[1*4+3].set(span,0,span,	u0, v1);
	
	// left
	m_vertices[2*4+0].set(-span,2*span,span,	u0, v0);
	m_vertices[2*4+1].set(-span,2*span,-span,	u1, v0);
	m_vertices[2*4+2].set(-span,0,-span,	u1, v1);
	m_vertices[2*4+3].set(-span,0,span,	u0, v1);
	
	// right
	m_vertices[3*4+0].set(span,2*span,-span,	u1, v1);
	m_vertices[3*4+1].set(span,2*span,span,		u0, v1);
	m_vertices[3*4+2].set(span,0,span,	u0, v0);
	m_vertices[3*4+3].set(span,0,-span,	u1, v0);
	
	// top
	m_vertices[4*4+3].set(-span,2*span,-span,	u1, v0);
	m_vertices[4*4+2].set(span,2*span,-span,	u0, v0);
	m_vertices[4*4+1].set(span,2*span,span,		u0, v1);
	m_vertices[4*4+0].set(-span,2*span,span,	u1, v1);
	
	
	m_numIndices = 5*4;
	
	m_indices = (GLushort*)malloc(m_numIndices*sizeof(GLushort));
	memset(m_indices, 0x00, m_numIndices*sizeof(GLushort));
	
	for (int i=0; i<5; i++) {
		m_indices[i*4+0] = i*4+0;
		m_indices[i*4+1] = i*4+3;
		m_indices[i*4+2] = i*4+1;
		m_indices[i*4+3] = i*4+2;
	}
	
	m_textures[0].load(@"skyBox-0", @"png");
	m_textures[1].load(@"skyBox-2", @"png");
	m_textures[2].load(@"skyBox-1", @"png");
	m_textures[3].load(@"skyBox-3", @"png");
	m_textures[4].load(@"skyBox-4", @"png");
}

bool CSkyBox::loadShaders()
{
	m_program.load(@"texMapper");
	m_program.bindAttribLocation(ATTRIB_VERTEX,		"a_position");
	m_program.bindAttribLocation(ATTRIB_TEXCOORD,	"a_texCoord");
	
	if (!m_program.link()) {
        NSLog(@"Failed to link terrain program");
        return false;
    }
	
	// Release vertex and fragment shaders
	m_program.deleteShaders();
	
	m_program.use();
	
	// Get uniform locations
	s_uniforms[UNIFORM_MODELVIEWPROJ_MATRIX]		= m_program.getUniformLocation("u_modelViewProjMatrix");
	s_uniforms[UNIFORM_TEXTURE]						= m_program.getUniformLocation("u_texture");
	
	return true;
}

void CSkyBox::render(ESMatrix &modelViewProj)
{
	m_program.use();	
	
	glActiveTexture(GL_TEXTURE0);
	glUniform1i(s_uniforms[UNIFORM_TEXTURE], 0);
	
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(DTexMappingVertex),	&m_vertices[0].pos);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, sizeof(DTexMappingVertex), &m_vertices[0].texcoord);
	glUniformMatrix4fv(s_uniforms[UNIFORM_MODELVIEWPROJ_MATRIX], 1, GL_FALSE, modelViewProj.d());
	
	for (int i=0; i<5; i++) {
		m_textures[i].bind();
		glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, m_indices+i*4);
	}
}