//
//  Water.m
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

///
//  Includes
//
#include "Water.h"
#include <math.h>


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


CWater::CWater()
: m_vertices	(0)
, m_indices	(0)
{
}

CWater::~CWater()
{
	if (m_vertices)	delete m_vertices;
	if (m_indices)	delete m_indices;
}


void CWater::build(GLfloat span, int resolution)
{
	if (resolution < 2) resolution = 2;
	m_resolution = resolution;
	
	m_numVertices = m_resolution*m_resolution;
	m_vertices = new DTexMappingVertex[m_numVertices];
	
	// generate verticies in range [-span, ..., 0, ..., span]
	GLfloat cstep = ((2.0f*span) / (m_resolution-1));
	GLfloat coffset = -span;
	GLfloat rstep = ((2.0f*span) / (m_resolution-1));
	GLfloat roffset = -span;
	for (int r=0; r<m_resolution; r++)
	{
		for (int c=0; c<m_resolution; c++)
		{
			DTexMappingVertex	&vertex = m_vertices[r*m_resolution + c];
			
			vertex.pos.x = coffset;
			vertex.pos.y = 0.00001f*sin(c);	// avoiding a 100% flat surface
			vertex.pos.z = roffset;
			
			vertex.texcoord.u = r * 20.f / m_resolution;
			vertex.texcoord.v = c * 20.f / m_resolution;
			
			coffset += cstep;
		}
		roffset += rstep;
		coffset = -span;
	}
	
	GLuint numberOfVertices = (2*m_resolution) * (m_resolution-1);
	GLuint numberOfDegenarateVertices = (m_resolution-2) * 2;
	m_numIndices = numberOfVertices + numberOfDegenarateVertices;
	if (m_numIndices > 0xffff)
	{
		fprintf(stderr, "	mesh with %u indicies overflows GLushort\n", m_numIndices);
		exit(0);
	}
	else
	{
		m_indices = (GLushort*)malloc(m_numIndices*sizeof(GLushort));
		memset(m_indices, 0x00, m_numIndices*sizeof(GLushort));
	}
	
	// generate indicies for single triangle strip
	GLuint offset = 0;
	for (int r=0; r<(m_resolution-1); r++)
	{
		for (int c=0; c<m_resolution; c++)
		{
			m_indices[offset++] = (r+0)*m_resolution + c;
			m_indices[offset++] = (r+1)*m_resolution + c;
		}
		
		// extra verticies at the end of this row connecting the end of this row to sthe tart of next one
		if (r < (m_resolution-2))
		{
			// 1st degenerate triangle index
			m_indices[offset++] = (r+1)*m_resolution + (m_resolution-1);
			// 2nd degenerate triangle index
			m_indices[offset++] = (r+1)*m_resolution + 0;
		}
	}
}

bool CWater::loadShaders()
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
	
	m_texture.load(@"water", @"png");
	
	return true;
}

void CWater::render(ESMatrix &modelViewProj)
{
	m_program.use();	
	
	glActiveTexture(GL_TEXTURE0);
	glUniform1i(s_uniforms[UNIFORM_TEXTURE], 0);
	m_texture.bind();
	
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(DTexMappingVertex),	&m_vertices[0].pos);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, sizeof(DTexMappingVertex), &m_vertices[0].texcoord);
	glUniformMatrix4fv(s_uniforms[UNIFORM_MODELVIEWPROJ_MATRIX], 1, GL_FALSE, modelViewProj.d());

	glEnable(GL_BLEND);

		glBlendFunc(GL_CONSTANT_ALPHA, GL_ONE_MINUS_CONSTANT_ALPHA);
		glBlendColor(1,1,1,0.45f);
		glDrawElements(GL_TRIANGLE_STRIP, m_numIndices, GL_UNSIGNED_SHORT, m_indices);

		glBlendFunc(GL_SRC_COLOR, GL_DST_COLOR);		
		glDrawElements(GL_TRIANGLE_STRIP, m_numIndices, GL_UNSIGNED_SHORT, m_indices);
	
	glDisable(GL_BLEND);	
}