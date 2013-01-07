//
//  Graphics.m
//  ovb3
//
//  Created by Jesus Renero Quintero on 1/1/12.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import "Graphics.h"

#define PI 3.14159265358979323846
#define FLOAT(x) [NSNumber numberWithFloat:x]

NSPoint makeTextStartingPoint( NSSize textSize, NSRect bounds , float angle, int offset );


@implementation Graphics

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

/**
 - (void)drawRect:(NSRect)dirtyRect {
 // Drawing code here.
 NSRect myRect = NSMakeRect(21, 21, 210, 210);
 [[NSColor blueColor] set];
 NSRectFill(myRect);
 }
 */


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
		[[self colorForIndex:count] set];
		[eachPath fill];
		
		// draw a black border around it
		[[NSColor blackColor] set];
		[eachPath stroke];
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

- (NSColor *)randomColor
{
	float red = (random()%1000)/1000.0;
	float green = (random()%1000)/1000.0;
	float blue = (random()%1000)/1000.0;
	float alpha = (random()%1000)/1000.0;
	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
}

- (NSColor *)colorForIndex:(unsigned)index
{
	static NSMutableArray *colorsArray = nil;
	
	if( colorsArray == nil )
	{
		colorsArray = [[NSMutableArray alloc] init];
	}
	
	if( index >= [colorsArray count] )
	{
		unsigned currentNum = 0;
		for( currentNum = [colorsArray count]; currentNum <= index; currentNum++ )
		{
			[colorsArray addObject:[self randomColor]];
		}
	}
	
	return [colorsArray objectAtIndex:index];
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
									[NSFont systemFontOfSize:12], NSFontAttributeName, 
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
		// We include here the textAttributes lest we decide later to e.g. color the texts the same color as the segment fill
		[segmentTextsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:textPoint.x], 
									  @"textPointX", [NSNumber numberWithFloat:textPoint.y], @"textPointY", eachText, 
									  @"text", textAttributes, @"textAttributes", nil]];
		
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
	segmentNamesArray = [aggregated allKeys];
	
	NSLog(@"Added %ld elements", [segmentValuesArray count]);
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
	
	[super dealloc];
}



/********  UNUSED CODE  **********
 
 
 - (void)drawRect2:(NSRect)dirtyRect 
 {
 int size_x = 1000;
 int size_y = 640;
 float perc = 0.4;
 float mid_angle = perc * 360;
 NSBezierPath *greenPath = [NSBezierPath bezierPath] ;
 NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
 [NSFont fontWithName:@"Helvetica" size:12], 
 NSFontAttributeName,[NSColor blackColor], 
 NSForegroundColorAttributeName, nil];
 
 NSAttributedString * currentText=[[NSAttributedString alloc] 
 initWithString: @"some text" 
 attributes: attributes];
 
 [greenPath setLineWidth: 2 ] ;
 // move to the center so that we have a closed slice
 // size_x and size_y are the height and width of the view
 [greenPath moveToPoint: NSMakePoint( size_x/2, size_y/2 ) ] ;
 
 // draw an arc (perc is a certain percentage ; something between 0 and 1
 [greenPath appendBezierPathWithArcWithCenter:NSMakePoint( size_x/2, size_y/2) radius:50 startAngle:0 endAngle: 360 * perc ] ;
 
 // close the slice , by drawing a line to the center
 [greenPath lineToPoint: NSMakePoint(size_x/2, size_y/2) ] ;
 [greenPath stroke] ;
 
 [[NSColor greenColor] set] ;
 // and fill it
 [greenPath fill] ; 
 
 greenPath = [NSBezierPath bezierPath] ;
 [[NSColor blackColor] set] ;
 [greenPath setLineWidth: 2 ] ;
 
 // draw the second slice, now exploded from the original center
 
 // so to get it exploded I move (10,7) points from the original center
 // but on the imaginary circle (thats why the cos and the sin)
 // note mide_angle is the angle halve way from the arc, you can experiment with multiple
 // angles, note also that the angle is in degrees
 [greenPath moveToPoint: NSMakePoint(size_x/2 - 10 * cos ( PI * mid_angle / 180 ) , 
 size_y/2 - 7 * sin ( PI * mid_angle / 180 )) ] ;
 
 // and now draw the other slice
 [greenPath appendBezierPathWithArcWithCenter:NSMakePoint( size_x/2 - 10 * cos ( PI * mid_angle / 180 ) , 
 size_y/2 - 7 * sin ( PI * mid_angle / 180 )) 
 radius:50 startAngle:360 * perc endAngle:360 ] ;
 
 // close the slice
 [greenPath lineToPoint: NSMakePoint( size_x/2 - 10 * cos ( PI * mid_angle / 180 ) , 
 size_y/2 - 7 * sin ( PI * mid_angle / 180 ) ) ] ;
 [greenPath stroke] ;
 [[NSColor blueColor] set] ;
 
 [greenPath fill] ;
 
 //Then you need to figure out where you will put the text :
 NSPoint dot = NSMakePoint( size_x/2 + cos (PI * mid_angle / 180 ) * 50 , size_y/2 + sin ( PI * mid_angle / 180 ) * 50 ) ;
 [greenPath appendBezierPathWithArcWithCenter: dot radius: 2 startAngle: 0 endAngle: 360 ] ;
 
 // (This is the dot you see in the picture above)
 // The mid_angle is the angle of slice divided by 2
 // Then you draw the text :
 NSPoint textStartPoint = makeTextStartingPoint( [currentText size], [self bounds] , mid_angle, 50 ) ;
 [currentText drawAtPoint:textStartPoint];
 }
 
 NSPoint makeTextStartingPoint( NSSize textSize, NSRect bounds , float angle, int offset )
 {
 NSPoint textStartPoint ;
 float size_x = bounds.size.width ;
 float size_y = bounds.size.height ;
 float angle_radian = PI * angle / 180 ;
 
 if ( angle <= 90 )
 {
 textStartPoint = NSMakePoint( size_x/2 + cos (angle_radian) * offset + 5 , size_y/2 + sin (angle_radian ) * offset ) ;
 }
 if ( angle > 90 && angle <= 180)
 
 {
 textStartPoint = NSMakePoint( size_x/2 + cos ( angle_radian ) * offset - textSize.width - 5 , 
 size_y/2 + sin (angle_radian ) * offset ) ;
 
 }
 if ( angle > 180 && angle <= 270 )
 {
 textStartPoint = NSMakePoint( size_x/2 + cos ( angle_radian ) * offset - textSize.width - 5, 
 size_y/2 + sin ( angle_radian ) * offset - textSize.height ) ;
 }
 if ( angle > 270 )
 {
 textStartPoint = NSMakePoint( size_x/2 + cos ( angle_radian ) * offset + 8 , 
 size_y/2 + sin (angle_radian ) * offset - textSize.height ) ;
 }
 
 return textStartPoint ;
 }
 
 ************************* UNUSED **********************/


@end
