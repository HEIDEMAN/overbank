//
//  YearGraph.h
//  overbank
//
//  Created by Jesus Renero on 25/02/13.
//
//

#import <Cocoa/Cocoa.h>
#import "ActionsProxy.h"

@interface YearGraph : NSView {
    NSArray *entriesArray;
    NSArray *categoriesArray;
    
    NSMutableArray *yearsOfData;
    int minYear;
    int maxYear;
    int numYears;
}

@property (atomic, retain) NSArray *entriesArray;
@property (atomic, retain) NSArray *categoriesArray;
@property (nonatomic, retain) NSMutableArray *yearsOfData;

- (int) computeHowManyYearsInInterval;
- (void) computeYear;

- (NSGradient *) createGradient:(int)fromColor :(int)toColor;
- (NSColor *)giveMeColor:(int)color;

@end
