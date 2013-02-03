//
//  Graphics.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 1/1/12.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Graphics : NSView 
{
	NSArray *segmentNamesArray;
	NSArray *segmentValuesArray;
	NSMutableArray *segmentPathsArray;
	NSMutableArray *segmentTextsArray;
}

@property (nonatomic, retain) NSArray *segmentNamesArray;
@property (nonatomic, retain) NSArray *segmentValuesArray;
@property (nonatomic, retain) NSMutableArray *segmentPathsArray;
@property (nonatomic, retain) NSMutableArray *segmentTextsArray;

- (NSColor *) randomColor;
- (NSColor *) colorForIndex:(unsigned)index;
- (NSArray *) segmentPathsArray;
- (NSArray *) segmentTextsArray;

- (void) generateDrawingInformation;
- (int)  updatePieData:(NSDictionary *)aggregated;

@end
