//
//  FileContentsIndexer.h
//  FileExample
//
//  Created by Jesus Renero Quintero on 24/12/10.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Prefs.h"
#import "Entry.h"

@interface BankLog : NSObject {
	NSMutableArray *logArray;
}

@property (strong) NSMutableArray* logArray;

- (id)init; 
- (BOOL) addEntry:(Entry *)newEntry;
- (void) matchEntries:(Prefs *)prefs :(NSMutableSet *)conflictsSet;
- (void) printFullEntries; 
- (void) printEntries; 
- (void) printEntriesSummaries;
- (void) printMoneyForAllCategories;
- (void) printMoneyPerCategory;


@end
