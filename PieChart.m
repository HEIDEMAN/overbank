//
//  Graphics.m
//  ovb3
//
//  Created by Jesus Renero Quintero on 1/1/12.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import "PieChart.h"

#define PI 3.14159265358979323846
#define FLOAT(x) [NSNumber numberWithFloat:x]

//NSPoint makeTextStartingPoint( NSSize textSize, NSRect bounds , float angle, int offset );

@implementation PieChart

@synthesize segmentNamesArray,
    segmentValuesArray,
    segmentPathsArray,
    segmentTextsArray,
    selectableCategoriesArray;


+ (void) initialize {
    [self exposeBinding:@"selectableCategoriesArray"];
}

- (NSArray *)selectableCategoriesArray
{
	return [[selectableCategoriesArray retain] autorelease];
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		segmentValuesArray = [NSArray arrayWithObjects:
							  FLOAT(150.0),
							  FLOAT(320.0),
							  FLOAT(15.0),
							  FLOAT(45.0),
							  FLOAT(5.0),
							  nil];
    }
    
    return self;
}


/*
 * Este codigo genera un pie chart a base de meter la información de los BezierPaths dentro
 * de un array, para luego dibujarlos cuando sea conveniente.
 * http://www.timisted.net/blog/archive/a-bindable-custom-nsview-subclass/
 */

- (void)drawRect:(NSRect)rect
{
	// Draw the pie chart segments
	[self generateDrawingInformation];
	NSArray *pathsArray = segmentPathsArray;
	unsigned count;
	for( count = 0; count < [pathsArray count]; count++ ) {
		NSBezierPath *eachPath = [pathsArray objectAtIndex:count];
		
		// fill the path with the drawing color for this index
		[[self colourForIndex:count] set];
		[eachPath fill];

	}
	
	// Draw the text.
	NSArray *textsArray = [self segmentTextsArray];
	for( count = 0; count < [textsArray count]; count++ ) {
		NSDictionary *eachTextDictionary = [textsArray objectAtIndex:count];
		NSPoint textPoint = NSMakePoint( [[eachTextDictionary valueForKey:@"textPointX"] floatValue],
										[[eachTextDictionary valueForKey:@"textPointY"] floatValue] );
		
		NSDictionary *textAttributes = [eachTextDictionary valueForKey:@"textAttributes"];
		
		NSString *text = [eachTextDictionary valueForKey:@"text"];
		[text drawAtPoint:textPoint withAttributes:textAttributes];
	}
}

- (NSColor *)colourForIndex:(unsigned)index
{
    index = (index % PALETESTRIPSIZE);
    
    unsigned char redByte[PALETESTRIPSIZE] = {
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x99, 0x99, 0x99, 0x99, 0x99,
        0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
        0x33, 0x33, 0x66, 0x66, 0x66,
        0x33, 0x66, 0x99, 0xcc, 0xff, 
        0xff, 0xff, 0xcc, 0xcc, 0xcc
    };
    unsigned char greenByte[PALETESTRIPSIZE] = {
        0x00, 0x66, 0x99, 0xcc, 0xff,
        0xff, 0xcc, 0x99, 0x66, 0x00,
        0x00, 0x66, 0x99, 0xcc, 0xff,
        0x66, 0xcc, 0xff, 0xcc, 0x99,
        0x33, 0x66, 0x99, 0xcc, 0xff, 
        0xff, 0xff, 0xff, 0xff, 0xff, 
    };
    unsigned char blueByte[PALETESTRIPSIZE] = {
        0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x33, 0x66, 0x99, 0xcc, 0xff, 
        0x66, 0xcc, 0xcc, 0x66, 0x00 
    };
    
    NSColor *result = [NSColor
                       colorWithCalibratedRed:
                       (CGFloat)redByte[index] / 0xff
                       green:(CGFloat)greenByte[index] / 0xff
                       blue:(CGFloat)blueByte[index] / 0xff
                       alpha:1.0];
    
    return result;
}


- (void)generateDrawingInformation
{
	// Keep a pointer to the segmentValuesArray
	NSArray *cachedSegmentValuesArray = segmentValuesArray;
	NSArray *cachedSegmentNamesArray = segmentNamesArray;
	
	// Get rid of any existing Paths Array
	if( segmentPathsArray ) {
		[segmentPathsArray release];
		segmentPathsArray = nil;
	}
	
	// Get rid of any existing Texts Array
	if( segmentTextsArray ) {
		[segmentTextsArray release];
		segmentTextsArray = nil;
	}
	
	// If there aren't any values to display, we can exit now
	if( [cachedSegmentValuesArray count] < 1 )
		return;
	
	// Get the sum of the amounts and exit if it is zero
	float sumOfAmounts = 0;
	for( NSNumber *eachAmountToSum in cachedSegmentValuesArray )
		sumOfAmounts += [eachAmountToSum floatValue];
	
	if( sumOfAmounts == 0 )
		return;
	
	segmentPathsArray = [[NSMutableArray alloc] initWithCapacity:[cachedSegmentValuesArray count]];
	segmentTextsArray = [[NSMutableArray alloc] initWithCapacity:[cachedSegmentValuesArray count]];
	
#define PADDINGAROUNDGRAPH 100.0
#define TEXTPADDING 5.0
	
	NSRect viewBounds = [self bounds];
	NSRect graphRect = NSInsetRect(viewBounds, PADDINGAROUNDGRAPH, PADDINGAROUNDGRAPH);
	
	// Make the graphRect square and centred
	if( graphRect.size.width > graphRect.size.height )
	{
		double sizeDifference = graphRect.size.width - graphRect.size.height;
		graphRect.size.width = graphRect.size.height;
		graphRect.origin.x += (sizeDifference / 2);
	}
	
	if( graphRect.size.height > graphRect.size.width )
	{
		double sizeDifference = graphRect.size.height - graphRect.size.width;
		graphRect.size.height = graphRect.size.width;
		graphRect.origin.y += (sizeDifference / 2);
	}
	
	// get NSRects for the different quarters of the pie-chart
	NSRect topLeftRect, topRightRect;
	NSDivideRect(viewBounds, &topLeftRect, &topRightRect, (viewBounds.size.width / 2), NSMinXEdge );
	NSRect bottomLeftRect, bottomRightRect;
	NSDivideRect(topLeftRect, &topLeftRect, &bottomLeftRect, (viewBounds.size.height / 2), NSMinYEdge );
	NSDivideRect(topRightRect, &topRightRect, &bottomRightRect, (viewBounds.size.height / 2), NSMinYEdge );
	
	// Calculate how big a 'unit' is
	float unitSize = (360.0 / sumOfAmounts);
	
	if( unitSize > 360 )
		unitSize = 360;
	
	float radius = graphRect.size.width / 2;
	
	NSPoint midPoint = NSMakePoint( NSMidX(graphRect), NSMidY(graphRect) );
	
	// Set the dictionary used to draw the text information in the pie chart
    float red = 0.89;
    float green = 0.89;
    float blue = 0.89;
    float alpha = 1.0;
	NSColor *greyColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
	NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									greyColor, NSBackgroundColorAttributeName,
									[NSColor blackColor], NSForegroundColorAttributeName,
									[NSFont systemFontOfSize:10], NSFontAttributeName,
									nil];
	
	
	// cycle through the segmentValues and create the bezier paths
	float currentDegree = 0;
	unsigned currentIndex;
	for( currentIndex = 0; currentIndex < [cachedSegmentValuesArray count]; currentIndex++ )
	{
		NSNumber *eachValue = [cachedSegmentValuesArray objectAtIndex:currentIndex];
		
		float startDegree = currentDegree;
		currentDegree += ([eachValue floatValue] * unitSize);
		float endDegree = currentDegree;
		float midDegree = startDegree + ((endDegree - startDegree) / 2);
		
		NSBezierPath *eachSegmentPath = [NSBezierPath bezierPath];
		[eachSegmentPath moveToPoint:midPoint];
		
		[eachSegmentPath appendBezierPathWithArcWithCenter:midPoint radius:radius startAngle:startDegree endAngle:midDegree clockwise:NO];
		NSPoint textPoint = [eachSegmentPath currentPoint];
		[eachSegmentPath appendBezierPathWithArcWithCenter:midPoint radius:radius startAngle:midDegree endAngle:endDegree clockwise:NO];
		[eachSegmentPath closePath]; // close path also handles the lines from the midPoint to the start and end of the arc
		[eachSegmentPath setLineWidth:3.0];
		[segmentPathsArray addObject:eachSegmentPath];
		
		/*
		 [eachSegmentPath appendBezierPathWithArcWithCenter:midPoint radius:radius startAngle:startDegree endAngle:endDegree];
		 [eachSegmentPath closePath]; // close path also handles the lines from the midPoint to the start and end of the arc
		 [eachSegmentPath setLineWidth:2.0];
		 [segmentPathsArray addObject:eachSegmentPath];
		 */
		
		// Now, its time to display the text information
		// Get the text to be displayed, if it exists, and see how big it is
		NSString *eachText = @"";
		if( [cachedSegmentNamesArray count] > currentIndex )
			eachText = [cachedSegmentNamesArray objectAtIndex:currentIndex];
		
		NSSize textSize = [eachText sizeWithAttributes:textAttributes];
		
		// Offset it by TEXTPADDING in direction suitable for whichever quarter of the view it is in
		if( NSPointInRect(textPoint, topLeftRect) ) {
			textPoint.y -= (textSize.height + TEXTPADDING);
			textPoint.x -= (textSize.width + TEXTPADDING);
		}
		else if( NSPointInRect(textPoint, topRightRect) ) {
			textPoint.y -= (textSize.height + TEXTPADDING);
			textPoint.x += TEXTPADDING;
		}
		else if( NSPointInRect(textPoint, bottomLeftRect) ) {
			textPoint.y += TEXTPADDING;
			textPoint.x -= (textSize.width + TEXTPADDING);
		}
		else if( NSPointInRect(textPoint, bottomRightRect) ) {
			textPoint.y += TEXTPADDING;
			textPoint.x += TEXTPADDING;
		}
		
		// Make sure the point isn't outside the view's bounds
		if( textPoint.x < viewBounds.origin.x )
			textPoint.x = viewBounds.origin.x;
		
		if( (textPoint.x + textSize.width) > (viewBounds.origin.x + viewBounds.size.width) )
			textPoint.x = viewBounds.origin.x + viewBounds.size.width - textSize.width;
		
		if( textPoint.y < viewBounds.origin.y )
			textPoint.y = viewBounds.origin.y;
		
		if( (textPoint.y + textSize.height) > (viewBounds.origin.y + viewBounds.size.height) )
			textPoint.y = viewBounds.origin.y + viewBounds.size.height - textSize.height;
		
		// Finally add the details as a dictionary to our segmentTextsArray.
		// We include here the textAttributes lest we decide later to e.g. color the texts
        // the same color as the segment fill.
		[segmentTextsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:textPoint.x], @"textPointX",
                                      [NSNumber numberWithFloat:textPoint.y], @"textPointY",
                                      eachText, @"text",
                                      textAttributes, @"textAttributes", nil]];
		
	}
}

/*
 This function receives a dictionary with all the KVPs that we want to
 draw in a pie chart, and they're copied into the object attributes holding
 those arrays.
 */
- (int) updatePieData:(NSDictionary *)aggregated {
	NSLog(@"Removing the segmentsArray");
	[segmentValuesArray release];
	
	NSLog(@"Adding the new values");
	segmentValuesArray = [aggregated allValues];
    
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // Let's build a new array with the keys slightly modified to include the amount information
    // Old version only contained the line below.
	//segmentNamesArray = [aggregated allKeys];
    NSMutableArray *modifiedNames = [[[NSMutableArray alloc]init] autorelease];
    for (id clave in aggregated) {
        NSString *newCatName = [NSString stringWithFormat:@"%@(%ld€)",
                                clave, (long)[[aggregated objectForKey:clave] integerValue]];
        [modifiedNames addObject:newCatName];
    }
    segmentNamesArray = modifiedNames;
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
    // XXXXXXXXXXXX
	
	
    NSLog(@"Added %lu elements", [segmentValuesArray count]);
	NSLog(@"Calling generateDrawingInformation");
	[self generateDrawingInformation];
	[self display];
	
	return 0;
}

/*
 The paths array should be recalculated whenever the bound arrays change,
 so modify the two setter methods:
 */
- (void)setSegmentNamesArray:(NSArray *)newArray {
	[self willChangeValueForKey:@"segmentNamesArray"];
	[segmentNamesArray release];
	segmentNamesArray = [newArray copy];
	[self didChangeValueForKey:@"segmentNamesArray"];
	
	[self generateDrawingInformation];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (void)setSegmentValuesArray:(NSArray *)newArray {
	[self willChangeValueForKey:@"segmentValuesArray"];
	[segmentValuesArray release];
	segmentValuesArray = [newArray copy];
	[self didChangeValueForKey:@"segmentValuesArray"];
	
	[self generateDrawingInformation];
	[self setNeedsDisplayInRect:[self visibleRect]];
}

- (BOOL) isFlipped { return YES; }

- (NSArray *)segmentTextsArray {
	return segmentTextsArray;
}

- (void)dealloc {
	[segmentNamesArray release];
	[segmentValuesArray release];
	
	if( segmentPathsArray )
		[segmentPathsArray release];
	
	if( segmentTextsArray )
		[segmentTextsArray release];
    
    [selectableCategoriesArray release];
    
	[super dealloc];
}

@end
