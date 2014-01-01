// 
//  DBEntry.m
//  ovb3
//
//  Created by renero on 19/1/2012.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import "DBEntry.h"

#import "DBCategory.h"

@implementation DBEntry

@dynamic fechaValor;
@dynamic fechaOperacion;
@dynamic votes;
@dynamic saldo;
@dynamic categoryMatched;
@dynamic concepto;
@dynamic tags;
@dynamic importe;
@dynamic category;

- (id)initInMOC:(NSManagedObjectContext*)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBEntry" inManagedObjectContext:context];
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self != nil) {
        
        // Perform additional initialization.
        
    }
    return self;
}

@end
