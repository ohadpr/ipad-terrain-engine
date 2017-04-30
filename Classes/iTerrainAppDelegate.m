//
//  iTerrainAppDelegate.m
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/18/10.
//  Copyright 3D3R Software Studio 2010. All rights reserved.
//

#import "iTerrainAppDelegate.h"
#import "EAGLViewController.h"
#import "EAGLView.h"

@implementation iTerrainAppDelegate

@synthesize window;
@synthesize glViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions   
{
	[window addSubview:glViewController.glView];
	[window makeKeyAndVisible];
	
	[glViewController.glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glViewController.glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [glViewController.glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glViewController.glView stopAnimation];
}

- (void)dealloc
{
	[window release];
	[glViewController release];

	[super dealloc];
}

@end
