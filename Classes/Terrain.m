//
//  Terrain.m
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

///
//  Includes
//
#include "Terrain.h"
#include <math.h>

// uniform index
enum {
	UNIFORM_MODELVIEWPROJ_MATRIX = 0,
	UNIFORM_TERRAIN_TEXTURE,
	UNIFORM_DETAIL_TEXTURE,
	
	NUM_UNIFORMS
};

static GLint s_uniforms[NUM_UNIFORMS];

// attribute index
enum {
	ATTRIB_VERTEX,
	ATTRIB_TEXCOORD
};


CTerrain::CTerrain()
: m_vertices	(0)
, m_indices	(0)
{
}	

CTerrain::~CTerrain()
{
	if (m_vertices)	delete m_vertices;
	if (m_indices)	delete m_indices;
	[m_typePrefix dealloc];//?
}


void CTerrain::build(NSString *typePrefix, GLfloat span, GLfloat height, GLfloat waterHeight, int resolution)
{
	m_typePrefix = typePrefix;	// TODO: look for memory leaks
	
	if (!m_heightMap.load([m_typePrefix stringByAppendingString:@"-heightmap"], @"png")) {
		return;
	}
	
	if (resolution < 2) resolution = 2;
	
	m_params.span			= span;
	m_params.height		= height;
	m_params.waterHeight	= waterHeight;
	m_params.resolution	= resolution;
	
	
	m_numVertices = resolution*resolution;
	m_vertices = new DTerrainVertex[m_numVertices];
	
	// generate verticies in range [-span, ..., 0, ..., span]
	GLfloat cstep = ((2.0f*span) / (resolution-1));
	GLfloat coffset = -span;
	GLfloat rstep = ((2.0f*span) / (resolution-1));
	GLfloat roffset = -span;
	for (int r=0; r<resolution; r++)
	{
		for (int c=0; c<resolution; c++)
		{
			DTerrainVertex	&vertex = m_vertices[r*resolution + c];
			
			vertex.pos.x = coffset;
			
			int tx = r * m_heightMap.m_width / resolution;
			int ty = c * m_heightMap.m_height / resolution;
			int h	= m_heightMap.m_data[(ty*m_heightMap.m_width+tx)*4];
			
			vertex.pos.y = (h * height / 255.f) - waterHeight;
			vertex.pos.z = roffset;
			
			vertex.texcoord.u = r * 1.f / resolution;
			vertex.texcoord.v = c * 1.f / resolution;
			
			coffset += cstep;
		}
		roffset += rstep;
		coffset = -span;
	}
	
	GLuint numberOfVertices = (2*resolution) * (resolution-1);
	GLuint numberOfDegenarateVertices = (resolution-2) * 2;
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
	for (int r=0; r<(resolution-1); r++)
	{
		for (int c=0; c<resolution; c++)
		{
			m_indices[offset++] = (r+0)*resolution + c;
			m_indices[offset++] = (r+1)*resolution + c;
		}
		
		// extra verticies at the end of this row connecting the end of this row to sthe tart of next one
		if (r < (resolution-2))
		{
			// 1st degenerate triangle index
			m_indices[offset++] = (r+1)*resolution + (resolution-1);
			// 2nd degenerate triangle index
			m_indices[offset++] = (r+1)*resolution + 0;
		}
	}
}

bool CTerrain::loadShaders()
{
	m_program.load(@"terrain");
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
	s_uniforms[UNIFORM_TERRAIN_TEXTURE]			= m_program.getUniformLocation("u_terrainTexture");
	s_uniforms[UNIFORM_DETAIL_TEXTURE]				= m_program.getUniformLocation("u_detailTexture");
	
	m_terrainTexture.load([m_typePrefix stringByAppendingString:@"-terrain"], @"png");
	m_detailTexture.load(@"detail", @"png");
	
	return true;
}

void CTerrain::render(ESMatrix &modelViewProj)
{
	m_program.use();	
	
	glActiveTexture(GL_TEXTURE0);
	glUniform1i(s_uniforms[UNIFORM_TERRAIN_TEXTURE], 0);
	m_terrainTexture.bind();

	glActiveTexture(GL_TEXTURE1);
	glUniform1i(s_uniforms[UNIFORM_DETAIL_TEXTURE], 1);
	m_detailTexture.bind();
	
	
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glEnableVertexAttribArray(ATTRIB_TEXCOORD);
	glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, sizeof(DTerrainVertex),	&m_vertices[0].pos);
	glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, sizeof(DTerrainVertex), &m_vertices[0].texcoord);
	glUniformMatrix4fv(s_uniforms[UNIFORM_MODELVIEWPROJ_MATRIX], 1, GL_FALSE, modelViewProj.d());
	
	// Validate program before drawing. This is a good check, but only really necessary in a debug build.
	// DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
	if (!m_program.validate()) {
		NSLog(@"Failed to validate terrain program");
		return;
	}
#endif

	glDrawElements(GL_TRIANGLE_STRIP, m_numIndices, GL_UNSIGNED_SHORT, m_indices);
}

void CTerrain::blet()
{
	int bspan = 16;
	
	int u = 10 + (rand() % (m_heightMap.m_width-bspan-20));
	int v = 10 + (rand() % (m_heightMap.m_height-bspan-20));
	int c = (rand()%150) - 75;
	
	for (int y=0; y<bspan; y++) {
		for (int x=0; x<bspan; x++) {
			m_heightMap.m_data[(u+x+(v+y)*m_heightMap.m_width)*4] += c;
		}
	}

	// generate verticies in range [-span, ..., 0, ..., span]
	GLfloat cstep = ((2.0f*m_params.span) / (m_params.resolution-1));
	GLfloat coffset = -m_params.span;
	GLfloat rstep = ((2.0f*m_params.span) / (m_params.resolution-1));
	GLfloat roffset = -m_params.span;
	for (int r=0; r<m_params.resolution; r++)
	{
		for (int c=0; c<m_params.resolution; c++)
		{
			DTerrainVertex	&vertex = m_vertices[r*m_params.resolution + c];
			
			vertex.pos.x = coffset;
			
			int tx = r * m_heightMap.m_width / m_params.resolution;
			int ty = c * m_heightMap.m_height / m_params.resolution;
			int h	= m_heightMap.m_data[(ty*m_heightMap.m_width+tx)*4];
			
			vertex.pos.y = (h * m_params.height / 255.f) - m_params.waterHeight;
			vertex.pos.z = roffset;
			
			vertex.texcoord.u = r * 1.f / m_params.resolution;
			vertex.texcoord.v = c * 1.f / m_params.resolution;
			
			coffset += cstep;
		}
		roffset += rstep;
		coffset = -m_params.span;
	}	
}