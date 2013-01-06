//
//  FileContentsIndexer.h
//  FileExample
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2010 Telefonica I+D. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Prefs.h"
#import "Entry.h"

@interface BankLog : NSObject {
	NSMutableArray *logArray;
}

@property (retain) NSMutableArray* logArray;

- (id)init; 
- (BOOL) addEntry:(Entry *)newEntry;
- (void) matchEntries:(Prefs *)prefs :(NSMutableSet *)conflictsSet;
- (void) printFullEntries; 
- (void) printEntries; 
- (void) printEntriesSummaries;
- (void) printMoneyForAllCategories;
- (void) printMoneyPerCategory;


@end
