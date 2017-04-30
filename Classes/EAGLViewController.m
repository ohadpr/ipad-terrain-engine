    //
//  EAGLViewController.m
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/22/10.
//  Copyright 2010 3D3R Software Studio. All rights reserved.
//

#import "EAGLViewController.h"
#import "EAGLView.h"

@implementation EAGLViewController

@synthesize glView;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	[super viewDidLoad];

	// pinch gesture recognizer
	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[self.view addGestureRecognizer:pinchRecognizer];
	[pinchRecognizer release];
	
	// pan gesture recognizer
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	panRecognizer.maximumNumberOfTouches = 1;
	panRecognizer.minimumNumberOfTouches = 1;
	[self.view addGestureRecognizer:panRecognizer];
	[panRecognizer release];
	
	UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[infoBtn setBackgroundImage:[UIImage imageNamed:@"about-normal.png"] forState:UIControlStateNormal];
	[infoBtn setBackgroundImage:[UIImage imageNamed:@"about-pressed.png"] forState:UIControlStateHighlighted];
	infoBtn.frame = CGRectMake(10, 10, 67, 28);
	[self.view addSubview:infoBtn];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)sender {
	CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
	CGFloat velocity	= [(UIPinchGestureRecognizer *)sender velocity];
	
	[glView handlePinch:factor velocity:velocity isDone:(sender.state == UIGestureRecognizerStateEnded)];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
	CGPoint translation	= [sender translationInView:glView];
	CGPoint velocity		= [sender velocityInView:glView];

	[glView handlePan:translation velocity:velocity isDone:(sender.state == UIGestureRecognizerStateEnded)];
}

/*- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}*/


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	//[pinchRecognizer dealloc];
}


- (void)dealloc {
    [super dealloc];
}


@end
