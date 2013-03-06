//
//  BarGraph.h
//  overbank
//
//  Created by Jesus Renero on 03/02/13.
//
//

#import <Cocoa/Cocoa.h>
#import "ActionsProxy.h"

@interface BarGraph : NSView {
    
    NSArray *amountsArray;
    
    NSRect incomeRectangle;
    NSRect outcomeRectangle;
    NSString *incomeLabel;
    NSString *outcomeLabel;
    
    CGFloat maxHeight;
    
    IBOutlet NSTabView *tabView;
    
    BOOL drawable;
}

@property (atomic, retain) NSArray *amountsArray;
@property (atomic) NSRect incomeRectangle;
@property (atomic) NSRect outcomeRectangle;
@property (nonatomic, retain) NSString *incomeLabel;
@property (nonatomic, retain) NSString *outcomeLabel;
@property (nonatomic, retain) NSArrayController *tableEntriesController;
@property (atomic) BOOL drawable;

@property (assign) IBOutlet NSTabView *tabView;

- (NSGradient *) createGradient:(int)fromColor :(int)toColor;
- (NSColor *)giveMeColor:(int)color;

@end
