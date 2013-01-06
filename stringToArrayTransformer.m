//
//  valueTransformer.m
//  Transformer
//
//  Created by renero on 2/1/2012.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import "stringToArrayTransformer.h"


@implementation stringToArrayTransformer

+ (Class)transformedValueClass
{
    return [NSArray self];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)category
{
	NSLog(@"NSValueTransformer called with object: %@", category);
	NSMutableArray *array = (NSMutableArray *)[category componentsSeparatedByString:@";"];
	for (NSUInteger i=0;i<[array count];i++) {
		NSString *trimmed = [array objectAtIndex:i];
		trimmed = [ trimmed stringByTrimmingCharactersInSet:
						   [NSCharacterSet whitespaceAndNewlineCharacterSet] ];
		[array replaceObjectAtIndex:i withObject:trimmed];
	}
	
	NSLog(@"Returning array with %lu elements", [array count]);
	return array;
}

@end
