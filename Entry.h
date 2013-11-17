//
//  Entry.h
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Match.h"
#import "SEntry.h"

@interface Entry : NSObject {
	NSString *fechaOperacion;
	NSString *fechaValor;
	NSString *concepto;
	NSNumber *importe;
	NSNumber *saldo;
	
	Match *matchingCategory;
}

@property (nonatomic,strong) NSString* fechaOperacion;
@property (nonatomic,strong) NSString* fechaValor;
@property (nonatomic,strong) NSString* concepto;
@property (nonatomic,strong) NSNumber* importe;
@property (nonatomic,strong) NSNumber* saldo;
@property (nonatomic,strong) Match*    matchingCategory;

- (void) printEntry;
- (BOOL) equals:(Entry *)entry;
- (SimplifiedEntry *)simplified;

@end
