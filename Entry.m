//
//  Entry.m
//  FileExample
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2010 Telefonica I+D. All rights reserved.
//

#import "Entry.h"

@implementation Entry
@synthesize fechaOperacion, fechaValor, concepto, importe, saldo, matchingCategory;

- (id)init {
	self = [super init];
	if (self != nil) {
		fechaOperacion = [[NSString alloc] init];
		fechaValor = [[NSString alloc] init];
		concepto = [[NSString alloc] init];
		importe = [[NSNumber alloc] init];
		saldo = [[NSNumber alloc] init];
		matchingCategory = [[Match alloc] init];
	}
	return self;
}	

- (BOOL) equals:(Entry *)entry 
{
    BOOL cond1,cond2,cond3;
    cond1 = ( [self.fechaOperacion compare:entry.fechaOperacion] == NSOrderedSame);
    cond2 = ( [self.concepto caseInsensitiveCompare:entry.concepto] == NSOrderedSame );
    cond3 = ( [self.importe floatValue] == [entry.importe floatValue] );
    /**
    NSLog(@"    {%@ %@}", (cond1? @"==" : @"!="), entry.fechaOperacion);
    NSLog(@"    {%@ %@}", (cond2? @"==" : @"!="), entry.concepto);
    NSLog(@"    {%@ %@}", (cond3? @"==" : @"!="), entry.importe);
    */
    return (cond1 && cond2 && cond3);
}


- (void)printEntry:(Entry *)entry 
{
	NSLog(@" fechaOperacion: %@\n", entry.fechaOperacion); 
	NSLog(@"     fechaValor: %@\n", entry.fechaValor); 
	NSLog(@"       concepto: %@\n", entry.concepto);
	NSLog(@"        importe: %@\n", entry.importe);
	NSLog(@"          saldo: %@\n", entry.saldo);
}

@end
