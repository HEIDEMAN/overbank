//
//  Entry.m
//  FileExample
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
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

    return (cond1 && cond2 && cond3);
}

- (SimplifiedEntry *)simplified
{
    SimplifiedEntry *s = [[[SimplifiedEntry alloc]init]autorelease];
    s.fechaOperacion = self.fechaOperacion;
    s.concepto = self.concepto;
    s.importe = self.importe;
    return s;
}

- (void)printEntry
{
    NSLog(@"Entry:");
    NSLog(@"%@|%30@|%6@", fechaOperacion, concepto, importe);
    NSLog(@"  > %@ (%ld)", matchingCategory.categoryMatched,
          (matchingCategory.categoryMatched != nil) ? matchingCategory.votes : 0);

    /*
	NSLog(@" fechaOperacion: %@\n", fechaOperacion);
	NSLog(@"     fechaValor: %@\n", fechaValor);
	NSLog(@"       concepto: %@\n", concepto);
	NSLog(@"        importe: %@\n", importe);
	NSLog(@"          saldo: %@\n", saldo);
    NSLog(@"      >category: %@\n", matchingCategory.categoryMatched);
    NSLog(@"         >votes: %lu\n",matchingCategory.votes);
    for (int i=0; i<[matchingCategory.tagsMatched count]; i++)
    {
        NSLog(@"           >tag: %@", [matchingCategory.tagsMatched objectAtIndex:i]);
    }
     */

}

@end
