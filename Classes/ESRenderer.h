//
//  ESRenderer.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)handlePinch:(CGFloat)factor velocity:(CGFloat)velocity isDone:(bool)isDone;
- (void)handlePan:(CGPoint)translation velocity:(CGPoint)velocity isDone:(bool)isDone;
- (void)loadTerrain:(NSString*)terrain;

@end
