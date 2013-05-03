//
//  Entry.h
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Match.h"
#import "simplifiedEntry.h"

@interface Entry : NSObject {
	NSString *fechaOperacion;
	NSString *fechaValor;
	NSString *concepto;
	NSNumber *importe;
	NSNumber *saldo;
	
	Match *matchingCategory;
}

@property (nonatomic,retain) NSString* fechaOperacion;
@property (nonatomic,retain) NSString* fechaValor;
@property (nonatomic,retain) NSString* concepto;
@property (nonatomic,retain) NSNumber* importe;
@property (nonatomic,retain) NSNumber* saldo;
@property (nonatomic,retain) Match*    matchingCategory;

- (void) printEntry;
- (BOOL) equals:(Entry *)entry;
- (simplifiedEntry *)simplified;

@end
