/*
 *  Texture.cpp
 *  iTerrain
 *
 *  Created by Ohad Eder Pressman on 5/26/10.
 *  Copyright 2010 3D3R Software Studio. All rights reserved.
 *
 */

#include "Texture.h"

CTexture::CTexture()
: m_id (0)
{
}

CTexture::~CTexture()
{
	if (m_id) {
		glDeleteTextures(1, &m_id);
	}
}

bool CTexture::load(NSString* imageName, NSString* imageExt)
{
	DImage	image;
	
	if (!image.load(imageName, imageExt)) {
		return false;
	}
	
	glGenTextures(1, &m_id);
	glBindTexture(GL_TEXTURE_2D, m_id);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);	
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, image.m_width, image.m_height, 0, GL_RGBA, GL_UNSIGNED_BYTE, image.m_data);
	glGenerateMipmap(GL_TEXTURE_2D);	

	return true;
}

void CTexture::bind()
{
	glBindTexture(GL_TEXTURE_2D, m_id);
}



bool DImage::load(NSString *imageName, NSString *imageExt)
{
	NSString	*path		= [[NSBundle mainBundle] pathForResource:imageName ofType:imageExt];
	NSData		*texData	= [[NSData alloc] initWithContentsOfFile:path];
	UIImage	*image		= [[UIImage alloc] initWithData:texData];
	
	if (image == nil) {
		NSLog(@"error loading image %@.%@", imageName, imageExt);
		return false;
	}
	
	m_width = CGImageGetWidth(image.CGImage);
	m_height = CGImageGetHeight(image.CGImage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	m_data = (GLubyte*)malloc(m_height * m_width * 4 );

	CGContextRef context = CGBitmapContextCreate(m_data, m_width, m_height, 8, 4 * m_width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGColorSpaceRelease( colorSpace );
	
	CGContextClearRect( context, CGRectMake( 0, 0, m_width, m_height ) );
	CGContextTranslateCTM( context, 0, m_height - m_height );
	CGContextDrawImage( context, CGRectMake( 0, 0, m_width, m_height ), image.CGImage );
	
CGContextRelease(context);
	
	[image release];
	[texData release];
	
	return true;	
}