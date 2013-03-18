//
//  Graphics.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 1/1/12.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define PALETESTRIPSIZE 18

@interface PieChart : NSView 
{
	NSArray *segmentNamesArray;
	NSArray *segmentValuesArray;
	NSMutableArray *segmentPathsArray;
	NSMutableArray *segmentTextsArray;
    
    NSArray *categoriesArray;
}

@property (nonatomic, retain) NSArray *segmentNamesArray;
@property (nonatomic, retain) NSArray *segmentValuesArray;
@property (nonatomic, retain) NSMutableArray *segmentPathsArray;
@property (nonatomic, retain) NSMutableArray *segmentTextsArray;

@property (atomic, retain) NSArray *categoriesArray;


- (NSColor *) randomColor;
- (NSColor *) colorForIndex:(unsigned)index;
- (NSArray *) segmentPathsArray;
- (NSArray *) segmentTextsArray;

- (void) generateDrawingInformation;
- (int)  updatePieData:(NSDictionary *)aggregated;

- (NSColor *)colorForIdx:(unsigned)index;

@end
