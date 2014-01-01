//
//  DBEntry.h
//  ovb3
//
//  Created by renero on 19/1/2012.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DBCategory;

@interface DBEntry :  NSManagedObject  
{
}

@property (nonatomic, strong) NSDate * fechaValor;
@property (nonatomic, strong) NSDate * fechaOperacion;
@property (nonatomic, strong) NSNumber * votes;
@property (nonatomic, strong) NSNumber * saldo;
@property (nonatomic, strong) NSString * categoryMatched;
@property (nonatomic, strong) NSString * concepto;
@property (nonatomic, strong) NSString * tags;
@property (nonatomic, strong) NSNumber * importe;
@property (nonatomic, strong) DBCategory * category;

- (id)initInMOC:(NSManagedObjectContext*)context;

@end



