//
//  Accumulator.m
//  Accumulator
//
//  Created by Jesus Renero on 02/03/13.
//  Copyright (c) 2013 Jesus Renero. All rights reserved.
//

#import "Accumulator.h"

@implementation Accumulator
@synthesize name, data;


- (id)initWithName:(NSString *)initName {
    if ( self = [super init] )
    {
        if ( initName != nil) {
            name = [[NSString alloc] initWithString:initName];
            return self;
        } else {
            return nil;
        }
    } else return nil;
}

-(id) initWithData:(NSArray *)initData
{
    if ( self = [super init] )
    {
        if ( [initData count] > 0) {
            data = [[NSMutableArray alloc] initWithArray:initData copyItems:YES];
            return self;
        } else {
            return nil;
        }
    } else return nil;
}

-(id) initWithNameAndData:(NSString *)initName data:(NSArray *)initData
{
    if ( self = [super init] )
    {
        if ( [initData count] > 0) {
            data = [[NSMutableArray alloc] initWithArray:initData copyItems:YES];
            name = [[NSString alloc] initWithString:initName];
            return self;
        } else {
            return nil;
        }
    } else
        return nil;
}

-(void)logAccumulator
{
    NSLog(@"Histogram name: %@", name);
    for (int i=0;i<[data count];i++) {
        NSLog(@"H[%d]: %@", i, [data objectAtIndex:i]);
    }
}

- (void)setAccName:(NSString *)newName {
    if (newName == NULL) return;
    name = [[NSString alloc] initWithString:newName];
}

- (float)valueAtIndex:(int)index {
    if ((index < 0) || (index >= [data count])) {
        return 0.0f;
    }
    return [[data objectAtIndex:index] floatValue];
}

- (void)setValue:(float)value atIndex:(int)index
{
    if ((index < 0) || (index >= [data count])) {
        return;
    }
    NSNumber *number = [[NSNumber alloc] initWithFloat:value];
    [data setObject:number atIndexedSubscript:index];
    return;
}

- (void)addValue:(float)value atIndex:(int)index
{
    if ((index < 0) || (index >= [data count])) {
        return;
    }
    NSNumber *oldValue = [data objectAtIndex:index];
    float sum = [oldValue floatValue] + value;
    NSNumber *newValue = [[NSNumber alloc] initWithFloat:sum];
    
    [data setObject:newValue atIndexedSubscript:index];
    return;
}

- (void)addNumber:(NSNumber *)value atIndex:(int)index
{
    if ((index < 0) || (index >= [data count])) {
        return;
    }
    NSNumber *oldValue = [data objectAtIndex:index];
    float sum = [oldValue floatValue] + [value floatValue];
    NSNumber *newValue = [[NSNumber alloc] initWithFloat:sum];
    
    [data setObject:newValue atIndexedSubscript:index];
    return;
}


- (long) countOfData {
    return [data count];
}

@end
