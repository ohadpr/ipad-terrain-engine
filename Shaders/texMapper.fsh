//
//  generic.fsh
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

// -> incoming general
uniform sampler2D		u_texture;

// -> incoming per-vertex
varying highp vec2	v_texCoord;

void main()
{
	gl_FragColor = texture2D(u_texture, v_texCoord);
}
