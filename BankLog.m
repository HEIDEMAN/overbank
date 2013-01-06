//
//  BankLog.m
//  FileExample
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2010 Telefonica I+D. All rights reserved.
//

#import "BankLog.h"
#import "Entry.h"
#import "Levenshtein.h"
#import "Prefs.h"
#import "Match.h"

@implementation BankLog
@synthesize logArray;

- (id)init {
	self = [super init];
	if (self != nil) {
		logArray = [[NSMutableArray alloc]init];
	}
	return self;
}

/* 
 Esta funcion recorre toda la lista de entries del banklog y 
 busca con qué categorias hace matching cada una.
 in prefs: las categorias en las que estoy clasificando las entradas del banco
			junto con los tags asociados a cada una.
 in conflictsSet: los conflictos que he ido aprendiendo y que me enseñan a 
			resolver un empate entre categorias para una entrada.
 */
- (void)matchEntries:(Prefs *)prefs :(NSMutableSet *)conflictsSet
{
	Entry *entry;
	int numEntries = [logArray count];
	NSMutableSet *matchesSet;
	
	LogIt(@"Matching entries with categories...");
	
	// Recorro el numero de entradas, que ya tengo en memoria.
	for(int i=0; i<numEntries; i++) 
	{
		Match *winner;
		entry = [logArray objectAtIndex:i];
		// Busco a que categorias puede pertenecer esta entrada bancaria.
		matchesSet = [prefs matchTag:[entry concepto]];
		if (matchesSet.count == 0) {
			LogIt (@"-- MISMATCH -- Entry doesn't match any category!!");
			LogIt (@"   '%@'", entry.concepto);
			winner = nil;
		} 
		else 
		{
			LogIt (@"ENTRY: '%@'.", [entry concepto]);
			// Recorro todas las categorias con las que ha habido "match"
			int j=0;
			for (Match *match in matchesSet) {
				// Pinto cada categoria del Set.
				LogIt (@"  > MATCH (%d/%d): '%@'", j+1, matchesSet.count, match.categoryMatched);
				
				// Pinto las etiquetas que han producido el match.
				for (int k=0;k<[match.tagsMatched count];k++) {
					LogIt (@"    > %d - %@",k+1, [match.tagsMatched objectAtIndex:k]);
				}
				j++;
			 }
			 
			
			// Si hay mas de una categoria tenemos un conflicto.
			if ( matchesSet.count > 1 ) {
				winner = [Match solveConflict:matchesSet :conflictsSet];
			}
			// Si solo hay una, sacamos el elemento del set y ese es el winner.
			else if ( matchesSet.count == 1 ) {
				NSEnumerator *e = [matchesSet objectEnumerator];
				winner = [e nextObject];
			}
		}
		entry.matchingCategory = winner;
		[logArray replaceObjectAtIndex:i withObject:entry];
	}
	
	LogIt(@"DONE!");
}

- (void)printFullEntries 
{
	Entry *entry;
	
	for (int index=0; index<[logArray count]; index++) 
	{
		entry = [logArray objectAtIndex:index];
		NSLog(@" fechaOperacion: %@ ", entry.fechaOperacion); 
		NSLog(@"     fechaValor: %@ ", entry.fechaValor); 
		NSLog(@"       concepto: %@ ", entry.concepto);
		NSLog(@"        importe: %@ ", entry.importe);
		NSLog(@"          saldo: %@ ", entry.saldo);
		LogIt(@"      categoria: %@ ", entry.matchingCategory);
	}
}

- (BOOL)addEntry:(Entry *)newEntry 
{
	NSString *localized = [NSString stringWithString:[newEntry concepto]];
	
	//[[newEntry concepto] stringByReplacingOccurrencesOfString:@"ó" withString:@"o"];
	NSString *delocalized = [NSString stringWithUTF8String:[localized cStringUsingEncoding:[NSString defaultCStringEncoding]]];
	
	newEntry.concepto = [NSString stringWithString:delocalized];
	
	// Relleno el Match para que no se quede vacio y asi no estropee la ejecución de la 
	// TableView.
	newEntry.matchingCategory.categoryMatched = [NSString stringWithString:@""];
	[newEntry.matchingCategory.tagsMatched addObject:(NSString *)@""];
	newEntry.matchingCategory.votes = 0;
							 
	[logArray addObject:newEntry];
	return YES;
}

- (void) printEntries
{
	Entry *e;
	int numUnclassfied=0;
	
	for (e in logArray) {
		if (e.matchingCategory != nil) 
			LogIt(@"%@ (%.0f.€) .... %@", [e.matchingCategory categoryMatched], [e.importe floatValue], e.concepto);
		else {
			numUnclassfied++;
			LogIt(@"NULL (%.0f.€) .... %@", [e.importe floatValue], e.concepto);
		}
	}
	LogIt(@"\n%d Entries.\n%d Unclassified.\n%.02f %% Success rate.\n",
		  [logArray count], numUnclassfied, 
		  (((float)[logArray count]-(float)numUnclassfied)/(float)[logArray count])*100.0 );
}

- (void) printEntriesSummaries
{
	Entry *e;
	NSCountedSet *summary = [[NSCountedSet alloc] init];
	
	for (e in logArray) {
		if (e.matchingCategory != nil) {
			[summary addObject:[e.matchingCategory categoryMatched]];
		}
	}
	for (id s in summary) {
		// "n" es el numero de veces que esta presente esa categoria en todo el LOG.
		int n = [summary countForObject:s];
		LogIt(@"%@ - %.0f%% (%d)", s,
			  ((float)n/(float)[logArray count])*100.0, n );
	}
}

- (void) printMoneyForAllCategories
{
	Entry *e;
	NSCountedSet *summary = [[NSCountedSet alloc] init];
	float total=0.0;
	
	// Saco todas las categorias que me han salido en el log.
	for (e in logArray) {
		if (e.matchingCategory != nil) {
			[summary addObject:[e.matchingCategory categoryMatched]];
		}
		total += [e.importe floatValue];
	}
	// Para cada categoria, sumo la cantidad de pasta que sale.
	for (NSString *category in summary) {
		float money = 0.0;
		// Si esta entrada pertenece a esta categoria, hago cuentas...
		for (e in logArray) {
			NSComparisonResult res = [category caseInsensitiveCompare:[e.matchingCategory categoryMatched]];
			if (res == NSOrderedSame) {
				money += [e.importe floatValue];
			}
		}
		LogIt(@"%@: %.0f.€", category, money);
	}
}

- (void) printMoneyPerCategory
{
	Entry *e;
	NSCountedSet *summary = [[NSCountedSet alloc] init];
	NSArray *categories;
	
	// Saco todas las categorias que me han salido en el log.
	for (e in logArray) {
		if (e.matchingCategory != nil) {
			[summary addObject:[e.matchingCategory categoryMatched]];
		}
	}
	categories = [summary allObjects];
	for (int i=0; i<categories.count; i++) {
		printf ( "%d) %s\n", i, [[categories objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding] );
	}
	int d;
	printf("\nWhat category? ");
	scanf ("%d", &d);
	NSString *category = [categories objectAtIndex:d];
	float money=0.0;
	for (e in logArray) {
		NSComparisonResult res = [category caseInsensitiveCompare:[e.matchingCategory categoryMatched]];
		if (res == NSOrderedSame) {
			LogIt(@"%@ (%.0f.€) .... %@", [e.matchingCategory categoryMatched], [e.importe floatValue], e.concepto);
			money += [e.importe floatValue];
		}
	}
	LogIt(@"\nTOTAL %@: %.0f.€", category, money);
}








@end
