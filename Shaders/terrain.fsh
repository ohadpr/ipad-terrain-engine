//
//  Shader.fsh
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

// -> incoming general
uniform sampler2D		u_terrainTexture, u_detailTexture;

// -> incoming per-vertex
varying highp vec2	v_texCoord;
varying lowp	float	v_height;

void main()
{
	if (v_height < 0.0) discard;	// fake clip-plane for stuff under the water
		
	lowp vec4		detailCol		= texture2D(u_detailTexture, v_texCoord*20.0);
	lowp vec4		terrainCol		= texture2D(u_terrainTexture, v_texCoord);

	gl_FragColor	= terrainCol + detailCol - vec4(0.5, 0.5, 0.5, 1);
}
