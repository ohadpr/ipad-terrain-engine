//
//  EAGLViewController.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/22/10.
//  Copyright 2010 3D3R Software Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TerrainTemplatePickerController.h"

@class EAGLView;

@interface EAGLViewController : UIViewController{
	EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end
