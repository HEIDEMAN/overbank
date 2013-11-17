//
//  YearGraph.m
//  overbank
//
//  Created by Jesus Renero on 25/02/13.
//
//

#import "YearGraph.h"
#import "DBEntry.h"
#import "Accumulator.h"

#define LightGreen 0
#define DarkGreen  1
#define LightRed   2
#define DarkRed    3

#define MAXBOXWIDTH  1000
#define MAXBOXHEIGHT 90

@implementation YearGraph
@synthesize entriesArray, categoriesArray, yearsOfData;


+ (void) initialize {
    [self exposeBinding:@"entriesArray"];
    [self exposeBinding:@"categoriesArray"];
}

//- (NSArray *)entriesArray
//{
//	return [[entriesArray retain] autorelease];
//}
//- (NSArray *)categoriesArray
//{
//	return [[categoriesArray retain] autorelease];
//}



- (void) computeYear
{
    NSLog(@"There're %ld elements in my binding", [entriesArray count]);
    
    numYears = [self computeHowManyYearsInInterval];
    NSLog(@"We have %d years interval", numYears);
    NSLog(@"There're %ld elements in categories array", [categoriesArray count]);
    NSLog(@"  -> %@", [[categoriesArray objectAtIndex:0] name]);
    if (numYears <= 0) {
        NSLog(@"  Years not computed correctly yet.");
        return;
    }
    NSLog(@"We've %ld entries bound to this category", [[[categoriesArray objectAtIndex:0] entries] count]);
    
    // Create the data structure that holds the cummulated monthly data per category.
    yearsOfData = [[NSMutableArray alloc]init];
    NSArray *emptyMonths = [self emptyArray];
    for (DBCategory *dbcat in categoriesArray) {
        for (int y=0;y<numYears; y++)
        {
            Accumulator *year = [[Accumulator alloc]initWithData:emptyMonths];
            [yearsOfData addObject:year];
        }
    }
    
    [self populateEntries];
    //[self drawRect:[self visibleRect]];
    [self setNeedsDisplayInRect:[self visibleRect]];
    [self display];
    
    return;
}

- (int) populateEntries
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    for (DBEntry *dbentry in [[categoriesArray objectAtIndex:0] entries])
    {
        NSDate *date = dbentry.fechaOperacion;
        int entryYear = [[gregorian components:NSYearCalendarUnit fromDate:date] year];
        int entryMonth = [[gregorian components:NSMonthCalendarUnit fromDate:date] month];
        
        Accumulator *year = [yearsOfData objectAtIndex:(entryYear-minYear)];
        [year setAccName:[NSString stringWithFormat:@"%d", entryYear]];
        [year addNumber:dbentry.importe atIndex:entryMonth-1];
        
    }
    [[yearsOfData objectAtIndex:0] logAccumulator];
    return 0;
}


// Calculate how many years cover the list of entries that we have in the main entries Table.
// The entries table is accessible through the arraySelector "entriesArray".
-(int)computeHowManyYearsInInterval
{
    // Set minDate and maxDate two values that will enable calculate what is the max and min
    // dates in the entries Table.
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:25];
    [comps setMonth:12];
    [comps setYear:2100];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *minDate = [gregorian dateFromComponents:comps];
    [comps setYear:1971];
    NSDate *maxDate = [gregorian dateFromComponents:comps];
    
    // Establish what is the min and max dates in range to later determine
    // what is the time period covered by this set of entries.
    for (DBEntry *dbentry in entriesArray) {
        if ([minDate compare:dbentry.fechaOperacion] == NSOrderedDescending)
            minDate = dbentry.fechaOperacion;
        if ([maxDate compare:dbentry.fechaOperacion] == NSOrderedAscending)
            maxDate = dbentry.fechaOperacion;
    }
    
    minYear = [[gregorian components:NSYearCalendarUnit fromDate:minDate] year];
    maxYear = [[gregorian components:NSYearCalendarUnit fromDate:maxDate] year];
    numYears = maxYear-minYear+1;
    
    return numYears;
}


- (NSArray *)emptyArray {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (int i=0;i<12;i++) {
        NSNumber *n = [[NSNumber alloc] initWithFloat:0.0f];
        [array addObject:n];
    }
    return array;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (numYears <= 0) return;
    
    NSLog(@"drawRect YearGraph.");
    NSLog(@"Self is %@",self);
    
    // Compute the max and min to later normalize.
    float maxValue=-1000000.0f;
    for (int y=0; y<[yearsOfData count]; y++) {
        Accumulator *year = [yearsOfData objectAtIndex:y];
        int numElements = [[year data]count];
        for (int i=0; i<numElements; i++) {
            if (abs([year valueAtIndex:i]) > maxValue) maxValue = abs([year valueAtIndex:i]);
        }
    }
    
    // Draw one rectangle per month value.
    int maxBarWidth = 40;
    int padding = 8;
    int Yo = 100;
    int Width = 83.333f;
    int Height = 90;
    int barwidth = (maxBarWidth / numYears) + (padding*numYears);
    for (int y=0; y<[yearsOfData count]; y++) {
        Accumulator *year = [yearsOfData objectAtIndex:y];
        int numElements = [[year data]count];
        for (int i=0; i<numElements; i++) {
            NSRect r;
            r.origin.x = (Width*(i+1))-(Width/2)-(barwidth/2);
            r.size.width = barwidth;
            r.size.height = ((Height * abs([year valueAtIndex:i])) / maxValue);
            if (r.size.height >= Height) r.size.height = Height-5.0;
            
            NSGradient *gradient;
            
            // Possitives are drawed green, negatives, red.
            if ([year valueAtIndex:i] > 0) {
                gradient = [self createGradient:LightGreen :DarkGreen];
                r.origin.y = Yo;
            } else {
                gradient = [self createGradient:LightRed :DarkRed];
                r.origin.y = Yo-r.size.height;
            }
            
            [self logRect:r];
            if ([self rectWithinBounds:r]) NSRectFill(r);
            [gradient drawInRect:r angle:90.0];
        }
    }
}

-(BOOL)rectWithinBounds:(NSRect)r {
    if ((r.origin.x < 1) || (r.origin.x >= MAXBOXWIDTH)) return NO;
    if ((r.origin.y < 1) || (r.origin.y >= MAXBOXHEIGHT)) return NO;
    if ((r.size.height < 0) || (r.size.height >= MAXBOXHEIGHT)) return NO;
    if ((r.size.width < 0) || (r.size.width >= 50)) return NO;
    return YES;
}

-(void)logRect:(NSRect)r {
    NSLog(@"Rect[%.0f, %.0f]; W:%.0f, H:%.0f", r.origin.x, r.origin.y, r.size.width, r.size.height);
}

- (NSGradient *) createGradient:(int)fromColor :(int)toColor
{
    NSGradient* aGradient = [[NSGradient alloc] initWithStartingColor:
                              [self giveMeColor:fromColor] endingColor:[self giveMeColor:toColor]];

    return aGradient;
}

- (NSColor *)giveMeColor:(int)color
{
    NSColor *yourColor = [[NSColor alloc] init];
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
