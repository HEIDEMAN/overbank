//
//  popupTransformer.m
//  ovb3
//
//  Created by Jesus Renero Quintero on 2/1/12.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import "popupTransformer.h"


@implementation popupTransformer

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)category
{
	NSMutableArray *array;
	[array addObject:category];
	return array;
}


@end
