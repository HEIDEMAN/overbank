//
//  Graphics.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 1/1/12.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define PALETESTRIPSIZE 30

@interface PieChart : NSView 
{
	NSArray *segmentNamesArray;
	NSArray *segmentValuesArray;
	NSMutableArray *segmentPathsArray;
	NSMutableArray *segmentTextsArray;
    
    NSArray *selectableCategoriesArray;
}

@property (nonatomic, retain) NSArray *segmentNamesArray;
@property (nonatomic, retain) NSArray *segmentValuesArray;
@property (nonatomic, retain) NSMutableArray *segmentPathsArray;
@property (nonatomic, retain) NSMutableArray *segmentTextsArray;
@property (atomic, retain) NSArray *selectableCategoriesArray;

- (void) drawRect:(NSRect)rect;

- (NSArray *) segmentPathsArray;
- (NSArray *) segmentTextsArray;
- (NSArray *) selectableCategoriesArray;

- (void) generateDrawingInformation;
- (int) updatePieData:(NSDictionary *)aggregated;
- (id) initWithFrame:(NSRect)frame;


- (BOOL) isFlipped;
- (void) dealloc;

@end
