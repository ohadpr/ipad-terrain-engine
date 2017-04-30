/*
 *  defs.h
 *  iTerrain
 *
 *  Created by Ohad Eder Pressman on 5/26/10.
 *  Copyright 2010 3D3R Software Studio. All rights reserved.
 *
 */

#ifndef DEFS_H
#define DEFS_H


#define PRINT_GL_ERROR			NSLog(@"glGetError = 0x%x (line %d)", glGetError(), __LINE__);
#define min(a, b)					((a)<(b)?(a):(b))
#define max(a, b)					((a)>(b)?(a):(b))
#define limit(val, _min, _max)	max(min((val),(_max)),(_min))


struct DVector {
	GLfloat x, y, z;	
};

struct DColor {
	GLfloat r, g, b, a;
};

struct DTexCoord {
	GLfloat u, v;
};


struct DTexMappingVertex {	
	DVector	pos;
	DTexCoord	texcoord;
	
	void set(GLfloat x, GLfloat y, GLfloat z, GLfloat u, GLfloat v)
	{
		pos.x = x;
		pos.y = y;
		pos.z = z;
		texcoord.u = u;
		texcoord.v = v;
	}	
};



#endif //DEFS_H