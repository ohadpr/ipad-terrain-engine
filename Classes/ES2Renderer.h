//
//  ES2Renderer.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#include "esTransform.h"

#import "Terrain.h"
#import "Water.h"
#import "SkyBox.h"

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
	EAGLContext	*m_context;

	// The pixel dimensions of the CAEAGLLayer
	GLint			m_backingWidth, m_backingHeight;

	// The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
	GLuint			m_frameBuffer;
	GLuint			m_colorBuffer;
	GLuint			m_depthBuffer;

	CTerrain		m_terrain;
	CWater			m_water;
	CSkyBox		m_skyBox;
	
	// interactive params
	CGFloat		m_zoomFactor[3];	
	CGFloat		m_rotateAngle[3];
	CGFloat		m_pitchAngle[3];
}

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)setupGLView:(CGSize)size;
- (void)loadTerrain:(NSString*)terrain;

@end

