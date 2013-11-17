//
//  BarGraph.m
//  overbank
//
//  Created by Jesus Renero on 03/02/13.
//  Most ideas here come from: http://www.timisted.net/blog/archive/a-bindable-custom-nsview-subclass/
//
//

#import "BarGraph.h"

#define LightGreen 0
#define DarkGreen  1
#define LightRed   2
#define DarkRed    3

@implementation BarGraph
@synthesize amountsArray,
    incomeRectangle,
    incomeLabel,
    outcomeRectangle,
    outcomeLabel,
    tabView,
    drawable;


+ (void)initialize
{
	[self exposeBinding:@"amountsArray"];
}

- (NSArray *)amountsArray
{
	return amountsArray;
}

- (void)setAmountsArray:(NSArray *)newArray
{
    [self willChangeValueForKey:@"amountsArray"];
	amountsArray = [newArray copy];
	[self didChangeValueForKey:@"amountsArray"];
    
    //NSLog(@"BarGraphView:: Got %ld elements in 'amountsArray'", [amountsArray count]);
    [self computeIncomeAndOutcome];
    [self drawRect:[self visibleRect]];
    [self setNeedsDisplayInRect:[self visibleRect]];
}


- (void) computeIncomeAndOutcome
{
    if ([amountsArray count] == 0) {
        incomeRectangle.size.height = 0;
        outcomeRectangle.size.height = 0;
        
    };
    
    float totalIncome = 0.f;
    float totalOutcome = 0.f;
    for (NSNumber *amount in amountsArray) {
        if (amount.floatValue > 0.f)
            totalIncome += amount.floatValue;
        else
            totalOutcome += amount.floatValue;
    }
    incomeLabel = [NSString stringWithFormat:@"%.f €", totalIncome];
    outcomeLabel = [NSString stringWithFormat:@"%.f €", totalOutcome];
    
    incomeRectangle.size.height = (totalIncome * (maxHeight)) / (totalIncome+(-1.f*totalOutcome));
    outcomeRectangle.size.height = (-1.f) * (totalOutcome * (maxHeight)) / (totalIncome+(-1.f*totalOutcome));
    
    //NSLog(@"income(%f), outcome(%f)", totalIncome, totalOutcome);
    //NSLog(@"height1(%f), height2(%f)", incomeRectangle.size.height, outcomeRectangle.size.height);
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSRect viewBounds = [self bounds];
        CGFloat sidePadding = viewBounds.size.width / 12.0;
        CGFloat vertPadding = viewBounds.size.height / 8.0;
        maxHeight = vertPadding * 6.0;
        
        incomeRectangle.origin.x = viewBounds.origin.x + sidePadding;
        incomeRectangle.origin.y = viewBounds.origin.y + vertPadding;
        incomeRectangle.size.width = sidePadding * 4.0;
        incomeRectangle.size.height = maxHeight;
        
        outcomeRectangle.origin.x = (viewBounds.size.width / 2.0) + sidePadding;
        outcomeRectangle.origin.y = viewBounds.origin.y + vertPadding;
        outcomeRectangle.size.width = sidePadding * 4.0;
        outcomeRectangle.size.height = maxHeight;

        drawable = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Check if the right tab is selected with this boolean
    // flag that is controlled from the main App delegate.
    //NSLog(@"Is the bar graph drawable? = %@", (drawable?@"YES":@"NO"));
    if (drawable == FALSE) return;
    
    // Drawing code here.
    NSGradient *gradient = [self createGradient:LightGreen :DarkGreen];
    NSRectFill (incomeRectangle);
    [gradient drawInRect:incomeRectangle angle:90.0];
    
    NSPoint incomePoint, outcomePoint;
    incomePoint = NSMakePoint((float)incomeRectangle.origin.x,
                              (float)incomeRectangle.origin.y-20.0);
    outcomePoint = NSMakePoint((float)outcomeRectangle.origin.x,
                              (float)outcomeRectangle.origin.y-20.0);
    float red = 0.89;
    float green = 0.89;
    float blue = 0.89;
    float alpha = 1.0;
	NSColor *greyColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
	NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									greyColor, NSBackgroundColorAttributeName,
									[NSColor blackColor], NSForegroundColorAttributeName,
									[NSFont systemFontOfSize:12], NSFontAttributeName,
									nil];
    [incomeLabel drawAtPoint:incomePoint withAttributes:textAttributes];
    [outcomeLabel drawAtPoint:outcomePoint withAttributes:textAttributes];
    
    [[NSColor colorWithSRGBRed:202.0/255.f
                         green:63.0/255.f
                          blue:52.0/255.f
                         alpha:1.0] set];
    gradient = [self createGradient:LightRed :DarkRed];
    NSRectFill(outcomeRectangle);
    [gradient drawInRect:outcomeRectangle angle:90.0];    
}


- (NSGradient *) createGradient:(int)fromColor :(int)toColor
{
    NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:
                             [self giveMeColor:fromColor] endingColor:[self giveMeColor:toColor]];
    
    return aGradient;
}

- (NSColor *)giveMeColor:(int)color
{
    NSColor *yourColor;
    switch (color) {
        case LightGreen:
            yourColor = [NSColor colorWithSRGBRed:160.0/255 green:202.0/255 blue:74.0/255 alpha:1.0];
            break;
        case DarkGreen:
            yourColor = [NSColor colorWithSRGBRed:220.0/255 green:255.0/255 blue:159.0/255 alpha:1.0];
            break;
        case LightRed:
            yourColor = [NSColor colorWithSRGBRed:210.0/255 green:65.0/255 blue:61.0/255 alpha:1.0];
            break;
        case DarkRed:
            yourColor = [NSColor colorWithSRGBRed:254.0/255 green:152.0/255 blue:152.0/255 alpha:1.0];
            break;
        default:
            yourColor = NULL;
            break;
    }
    return yourColor;
}


@end
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
