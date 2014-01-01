// 
//  DBCategory.m
//  ovb3
//
//  Created by renero on 19/1/2012.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import "DBCategory.h"

#import "DBEntry.h"

@implementation DBCategory 

@dynamic name;
@dynamic entries;

- (id)initInMOC:(NSManagedObjectContext*)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBCategory" inManagedObjectContext:context];
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self != nil) {
        
        // Perform additional initialization.
        
    }
    return self;
}

@end
