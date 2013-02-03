//
//  Database.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 28/12/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Entry.h"
#import "Prefs.h"
#import "Match.h"
#import "DBCategory.h"
#import "DBEntry.h"

/**
#define ENTRY_ENTITYNAME	"Entry";
#define FECHAO				@"fechaOperacion";
#define FECHAV				@"fechaValor";
#define CONCEPTO			@"concepto";
#define IMPORTE				@"importe";
#define SALDO				@"saldo";
**/

@interface Database : NSObject {

}

- (BOOL) matchesExistingEntry:(Entry *)line managedObjectContext:(NSManagedObjectContext *)moc;
- (BOOL) matchesExistingCategory:(NSString *)catName managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (BOOL) arrayContainsEntry:(NSArray*)array Entry:(Entry*)line;
- (DBCategory *)findCategory:(NSString *)catName managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (int)  categorizeAllEntries:(NSManagedObjectContext *)managedObjectContext 
				  preferences:(Prefs *)prefs 
				 conflictsSet:(NSMutableSet *)conflictsSet
		   solveConflictsFlag:(BOOL)solveConflict
				  verboseFlag:(BOOL)verbose;
- (int) learnCategorizationFromUserAction:(NSManagedObjectContext *)moc
                                  dbentry:(DBEntry *)dbentry
                             conflictsSet:(NSMutableSet *)conflictsSet
                              preferences:(Prefs *)prefs;
- (int) recategorizeRelatedEntries:(NSArray *)moc
                       preferences:(Prefs *)prefs
                      conflictsSet:(NSMutableSet *)conflictsSet
              ManagedObjectContext:(NSManagedObjectContext *)moc;

- (NSManagedObject*) entryToDBEntry:(Entry*)line inManagedObjectContext:(NSManagedObjectContext*)moc;
- (Entry *)dbEntryToEntry:(NSManagedObject *)object;
- (int) updateCategoriesInDatabase:(NSManagedObject *)dbEntry fromEntry:(Entry *)entry 
			  managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (int) storeEntryInDatabase:(Entry *)entry managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (int) storeCategoriesInDatabase:(NSArray *)categoryNames 
			 managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSArray *)findDatesInterval:(NSManagedObjectContext *)managedObjectContext;
- (NSDictionary *) computeAggregatedCategories:(NSManagedObjectContext *)moc fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSDate*) stringToNSDate:(NSString *)string;
- (NSDate*) dateWithNoTime:(NSDate *)date;

- (int)  fastImportLog:(NSMutableArray *)log managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (NSArray*)loadTableToArray:(NSManagedObjectContext*)moc;
- (void) dumpDatabase:(NSManagedObjectContext *)moc number:(NSNumber *)importe;

- (void) printDBEntry:(DBEntry *)record;

+ (NSNumber *)abs:(NSNumber *)input;

@end
