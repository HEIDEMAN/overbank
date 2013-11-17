//
//  Accumulator.h
//  Accumulator
//
//  Created by Jesus Renero on 02/03/13.
//  Copyright (c) 2013 Jesus Renero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Accumulator : NSObject {
    NSString *name;
    NSMutableArray *data;
}

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSMutableArray *data;


- (id)initWithName:(NSString *)initName;
- (id)initWithData:(NSArray *)initData;
- (id)initWithNameAndData:(NSString *)initName data:(NSArray *)initData;
- (void)logAccumulator;
- (float)valueAtIndex:(int)index;
- (void)setAccName:(NSString *)newName;
- (void)setValue:(float)value atIndex:(int)index;
- (void)addValue:(float)value atIndex:(int)index;
- (void)addNumber:(NSNumber *)value atIndex:(int)index;
- (long)countOfData;


@end
