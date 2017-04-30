//
//  ES2Renderer.m
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

/***

	TODO

	* enable static data caching

***/
 
#import "ES2Renderer.h"

// uniform index
enum {
	UNIFORM_MODELVIEW_PROJECTION_MATRIX = 0,
	UNIFORM_TERRAIN_TEXTURE,
	UNIFORM_DETAIL_TEXTURE,
	
	NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
	ATTRIB_VERTEX,
	ATTRIB_TEXCOORD
};

// terrain properties
#define TERRAIN_RES		120		// how many vertices are on each axis of the terrain
#define TERRAIN_SPAN		1.0		// how wide and deep is the terrain (1 means -0.5 to +0.5)
#define TERRAIN_HEIGHT	0.15	// how high does the terrain go

#define WATER_HEIGHT		0.36	// water height (in percentage compared to terrain height, so 0.5 is the middle)
#define WATER_RES			4		// how many sections is the water split into (just to avoid a single huge polygon)

@interface ES2Renderer (PrivateMethods)

@end

@implementation ES2Renderer

// Create an OpenGL ES 2.0 context
- (id)init
{
    if ((self = [super init]))
    {
		m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

		if (!m_context || ![EAGLContext setCurrentContext:m_context])
		{
			[self release];
			return nil;
		}
		
		if (!m_water.loadShaders() || 
			!m_skyBox.loadShaders()) return false;		
	}

    return self;
}

- (void)loadTerrain:(NSString*)terrain
{
	if ([terrain compare:@"Wild Mountains"] == NSOrderedSame) {
		m_terrain.build(@"classic", TERRAIN_SPAN/2, TERRAIN_HEIGHT, WATER_HEIGHT*TERRAIN_HEIGHT, TERRAIN_RES);	
	} else if ([terrain compare:@"Private Island"] == NSOrderedSame) {
		m_terrain.build(@"island", TERRAIN_SPAN/2, TERRAIN_HEIGHT, WATER_HEIGHT*TERRAIN_HEIGHT, TERRAIN_RES);	
	} else if ([terrain compare:@"Explosive Volcano"] == NSOrderedSame) {
		m_terrain.build(@"volcano", TERRAIN_SPAN/2, TERRAIN_HEIGHT*2, WATER_HEIGHT*TERRAIN_HEIGHT*1.5, TERRAIN_RES);
	}

	m_water.build(TERRAIN_SPAN*2, WATER_RES);		
	m_skyBox.build(TERRAIN_SPAN*2);
	
	m_terrain.loadShaders();

	m_zoomFactor[0] = m_zoomFactor[1] = 0.6f;
	m_rotateAngle[0] = m_rotateAngle[1] = 0.f;
	m_pitchAngle[0] = m_pitchAngle[1] = 45.f;	// looking down at 45 degrees

	m_rotateAngle[2] = m_rotateAngle[2] = 0.f;
	m_zoomFactor[2] = 1.f;
}

- (void)render
{
	//terrain.blet();

    // This application only creates a single default frameBuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple frameBuffers.
    glBindFramebuffer(GL_FRAMEBUFFER, m_frameBuffer);
    glViewport(0, 0, m_backingWidth, m_backingHeight);
	
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_DEPTH_BUFFER_BIT);
	
	// setup view and projection matrices
	ESMatrix	view, proj, viewProj;

	// view matrix
	esMatrixLoadIdentity(&view);
	
	// handle any velocity to params
#define EPSILON					0.001f
#define VELOCITY_DECAY_FACTOR	0.8f
#define ZOOM_DECAY_FACTOR		0.85f

	if (fabsf(m_zoomFactor[2]-1.f) > EPSILON) {
		m_zoomFactor[2] = 1.f + (m_zoomFactor[2]-1.f)*ZOOM_DECAY_FACTOR;
		m_zoomFactor[0] /= m_zoomFactor[2];
		m_zoomFactor[0] = m_zoomFactor[1] = limit(m_zoomFactor[0], 0.2f, 1.6f);
	}
	
//	NSLog(@"zoom[0]: %2.3f", zoomFactor[0]);	
	
	if (fabsf(m_rotateAngle[2]) > EPSILON) {
		m_rotateAngle[2] *= VELOCITY_DECAY_FACTOR;
		m_rotateAngle[0] += m_rotateAngle[2];
		m_rotateAngle[1] = m_rotateAngle[0];
	}

	if (fabsf(m_pitchAngle[2]) > EPSILON) {
		m_pitchAngle[2] *= VELOCITY_DECAY_FACTOR;
		m_pitchAngle[0] += m_pitchAngle[2];
		m_pitchAngle[0] = m_pitchAngle[1] = limit(m_pitchAngle[0], 30.f, 90.f);
	}

	
	// build eye position vector
	CGFloat eyeX, eyeY, eyeZ;
		
	eyeX = m_zoomFactor[0] * cosf(m_rotateAngle[0]);
	eyeZ = m_zoomFactor[0] * sinf(m_rotateAngle[0]);
	eyeY = (m_pitchAngle[0]/90.f) * m_zoomFactor[0];

	esLookAt(&view,	eyeX, eyeY, eyeZ,		0, 0.01, 0,		0, 1, 0);
	
	// projection matrix
	esMatrixLoadIdentity(&proj);
	esPerspective(&proj, 45.f, CGFloat(m_backingWidth)/CGFloat(m_backingHeight), 0.01f, 10000.f);
	
	// view-proj
	esMatrixLoadIdentity(&viewProj);
	esMatrixMultiply(&viewProj, &view, &proj);

	// model
	ESMatrix	model;
	
	esMatrixLoadIdentity(&model);
	
	// calculate and set model-view-proj matrix
	ESMatrix modelViewProj;
	esMatrixLoadIdentity(&modelViewProj);
	esMatrixMultiply(&modelViewProj, &model, &viewProj);
	
	ESMatrix	modelUpsideDown;
	esMatrixLoadIdentity(&modelUpsideDown);
	esScale(&modelUpsideDown, 1.0, -1.0, 1.0);
	
	ESMatrix modelViewProjUpsideDown;
	esMatrixMultiply(&modelViewProjUpsideDown, &modelUpsideDown, &viewProj);
	
	
	// skybox
	m_skyBox.render(modelViewProj);
	glCullFace(GL_FRONT);
	m_skyBox.render(modelViewProjUpsideDown);
	glCullFace(GL_BACK);
	
	// inverse terrain
	glCullFace(GL_FRONT);
	m_terrain.render(modelViewProjUpsideDown);
	glCullFace(GL_BACK);
	
	// render water
	m_water.render(modelViewProj);

	// render top terrain
	m_terrain.render(modelViewProj);
	
	
	glDisableVertexAttribArray(ATTRIB_VERTEX);
	glDisableVertexAttribArray(ATTRIB_TEXCOORD);
	
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer(GL_RENDERBUFFER, m_colorBuffer);
    [m_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{
	// delete old stuff
	if (m_frameBuffer) {
		glDeleteFramebuffers(1, &m_frameBuffer);
		m_frameBuffer = 0;
	}

	if (m_colorBuffer) {
		glDeleteRenderbuffers(1, &m_colorBuffer);
		m_colorBuffer = 0;
	}

	if (m_depthBuffer) {
		glDeleteRenderbuffers(1, &m_depthBuffer);
		m_depthBuffer = 0;
	}
	
	// render buffer
	glGenFramebuffers(1, &m_frameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, m_frameBuffer);

	// color buffer
	glGenRenderbuffers(1, &m_colorBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, m_colorBuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_colorBuffer);
	[m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &m_backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &m_backingHeight);

	// z-buffer
	glGenRenderbuffers(1, &m_depthBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, m_depthBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, m_backingWidth, m_backingHeight);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depthBuffer);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Failed to make complete frameBuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
	
	[self setupGLView:layer.bounds.size];

    return YES;
}

- (void) setupGLView:(CGSize)size {

	// settings
	glEnable		(GL_TEXTURE_2D);
	glEnable		(GL_DEPTH_TEST);
	glDepthFunc	(GL_LEQUAL);
	glEnable		(GL_CULL_FACE);
	glCullFace		(GL_BACK);
}

- (void)handlePinch:(CGFloat)factor velocity:(CGFloat)velocity isDone:(bool)isDone
{
	m_zoomFactor[0] = m_zoomFactor[1] / factor;
	m_zoomFactor[0] = limit(m_zoomFactor[0], 0.2f, 1.6f);
	
	if (isDone) {
		m_zoomFactor[1] = m_zoomFactor[0];
		m_zoomFactor[2] = 1.f + ((velocity-1.f) / 175.f);
		
		NSLog(@"zoom: %2.3f", m_zoomFactor[2]);
	}
}

- (void)handlePan:(CGPoint)translation velocity:(CGPoint)velocity isDone:(bool)isDone
{
	m_rotateAngle[0]	= m_rotateAngle[1] + translation.x/200.f;
	m_pitchAngle[0]	= m_pitchAngle[1] + translation.y/5.f;
	m_pitchAngle[0]	= limit(m_pitchAngle[0], 30.f, 90.f);
	
	if (isDone) {
		m_rotateAngle[1]	= m_rotateAngle[0];
		m_pitchAngle[1]		= m_pitchAngle[0];
		
		velocity.x = min(velocity.x, 1250.f);
		velocity.y = min(velocity.y, 750.f);
		
		m_rotateAngle[2]	= velocity.x/5000.f;
		m_pitchAngle[2]		= velocity.y/100.f;
		
		//NSLog(@"x: %2.3f, y: %2.3f", velocity.x, velocity.y);
	}
}

- (void)dealloc
{
    // Tear down GL
	if (m_frameBuffer) {
		glDeleteFramebuffers(1, &m_frameBuffer);
		m_frameBuffer = 0;
	}
	
	if (m_colorBuffer) {
		glDeleteRenderbuffers(1, &m_colorBuffer);
		m_colorBuffer = 0;
	}
	
	if (m_depthBuffer) {
		glDeleteRenderbuffers(1, &m_depthBuffer);
		m_depthBuffer = 0;
	}

    // Tear down context
    if ([EAGLContext currentContext] == m_context)
        [EAGLContext setCurrentContext:nil];

    [m_context release];
    m_context = nil;

    [super dealloc];
}

@end
