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

@property (nonatomic, retain) NSDate * fechaValor;
@property (nonatomic, retain) NSDate * fechaOperacion;
@property (nonatomic, retain) NSNumber * votes;
@property (nonatomic, retain) NSNumber * saldo;
@property (nonatomic, retain) NSString * categoryMatched;
@property (nonatomic, retain) NSString * concepto;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSNumber * importe;
@property (nonatomic, retain) DBCategory * category;

@end



