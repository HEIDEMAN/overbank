//
//  Graphics.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 1/1/12.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Graphics : NSView 
{
	NSArray *segmentNamesArray;
	NSArray *segmentValuesArray;
	NSMutableArray *segmentPathsArray;
	NSMutableArray *segmentTextsArray;
}

- (NSColor *) randomColor;
- (NSColor *) colorForIndex:(unsigned)index;
- (NSArray *) segmentPathsArray;
- (NSArray *) segmentTextsArray;

- (void) generateDrawingInformation;
- (int)  updatePieData:(NSDictionary *)aggregated;

@end
