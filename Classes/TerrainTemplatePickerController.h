//
//  TerrainTemplatePickerController.h
//  iTerrain
//
//  Created by Ohad Eder Pressman on 5/31/10.
//  Copyright 2010 3D3R Software Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TerrainTemplatePickerDelegate
- (void)terrainTemplateSelected:(NSString *)terrain;
@end

@interface TerrainTemplatePickerController : UITableViewController {
	NSMutableArray						*terrains;
	id<TerrainTemplatePickerDelegate>	delegate;
}

@property (nonatomic, retain) NSMutableArray						*terrains;
@property	(nonatomic, assign) id<TerrainTemplatePickerDelegate>	delegate;

@end