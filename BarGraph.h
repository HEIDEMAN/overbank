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
    
    IBOutlet NSTabView *__strong tabView;
    
    BOOL drawable;
}

@property (atomic, strong) NSArray *amountsArray;
@property (atomic) NSRect incomeRectangle;
@property (atomic) NSRect outcomeRectangle;
@property (nonatomic, strong) NSString *incomeLabel;
@property (nonatomic, strong) NSString *outcomeLabel;
@property (nonatomic, strong) NSArrayController *tableEntriesController;
@property (atomic) BOOL drawable;

@property (strong) IBOutlet NSTabView *tabView;

- (NSGradient *) createGradient:(int)fromColor :(int)toColor;
- (NSColor *)giveMeColor:(int)color;

@end
