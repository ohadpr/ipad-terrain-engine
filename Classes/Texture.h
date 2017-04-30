/*
 *  Texture.h
 *  iTerrain
 *
 *  Created by Ohad Eder Pressman on 5/26/10.
 *  Copyright 2010 3D3R Software Studio. All rights reserved.
 *
 */

#ifndef TEXTURE_H
#define TEXTURE_H

#include <OpenGLES/EAGL.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

struct DImage
{
	DImage()
	: m_data	(0)
	, m_width	(0)
	, m_height	(0)
	{};
	
	~DImage() {
		if (m_data) {
			free(m_data);
			m_data = 0;
		}
	};
	
	bool	load	(NSString *imageName, NSString *imageExt);
		
	GLuint		m_width;
	GLuint		m_height;
	GLubyte	*m_data;
};

class CTexture
{
public:
	CTexture();
	~CTexture();
	
	bool	load	(NSString *imageName, NSString *imageExt);
	void	bind	();
	
private:
	GLuint	m_id;
};


#endif // TEXTURE_H