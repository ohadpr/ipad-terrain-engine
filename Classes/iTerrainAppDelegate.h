//
//  iTerrainAppDelegate.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLViewController;

@interface iTerrainAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow				*window;
	EAGLViewController	*glViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLViewController *glViewController;

@end

