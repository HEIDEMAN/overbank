//
//  tableColorTransformer.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 2/1/12.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//
// ValueTransformer for setting the text color based on the existence of various categories.
//


#import "tableColorTransformer.h"
#import "DBCategory.h"

@implementation tableColorTransformer


+ (Class)transformedValueClass
{
    return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)object
{
	//NSLog(@"··> Entering transformedValue inside tableColorTransformer.");
	//NSLog(@"··> Object class: %@", [object class]);
	//DBCategory *dbobject = object;
	if (object != nil) 
	{
		//NSString *category = dbobject.name;
		NSString *category = object;
		//NSLog(@"  ··> Category value <%@>", category);
		if ([category caseInsensitiveCompare:@"No Value"] == NSOrderedSame) {
			//NSLog(@"  ··> No value: RED");
			return [NSColor redColor];
		}
		else {
			//NSLog(@"  ··> It has a value: BLACK");
			return [NSColor blackColor];
		}
	} 
	else {
		//NSLog(@"  ··> nil value: RED");
		return [NSColor redColor];
	}

	//NSLog(@"  ··> default: RED");
	return [NSColor redColor];
}

@end

