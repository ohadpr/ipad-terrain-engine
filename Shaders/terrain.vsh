//
//  Shader.vsh
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

// -> incoming general
uniform mat4		u_modelViewProjMatrix;

// -> incoming per-vertex
attribute vec4	a_position;
attribute vec2	a_texCoord;

// -> outgoing per-vertex
varying vec2		v_texCoord;
varying float		v_height;

void main()
{
	gl_Position	= u_modelViewProjMatrix * a_position;
	v_texCoord		= a_texCoord;
	v_height		= a_position.y;	// for user-defined clip-plane
}
