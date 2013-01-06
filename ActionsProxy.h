//
//  ActionsProxy.h
//  Overbank
//
//  Created by Jesus Renero Quintero on 23/10/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileMgr.h"
#import "BankLog.h"
#import "Entry.h"
#import "Prefs.h"
#import "Database.h"

#define KFIND_MATCHES					1
#define KSET_DEFAULT_CATEGORIES			2
#define KSHOW_CATEGORIZATION_RESULTS	3
#define KSHOW_CATEGORIZATION_SUMMARY	4
#define KSHOW_MONEY_FLOW				5
#define KSHOW_MONEY_FLOW_CATEGORY		6

#define KREAD_CATEGORIES_STORED			8
#define	KLIST_CATEGORIES_MEMORY			9
#define KSYNC_CATEGORIES_FILE			10

#define KREAD_CONFLICTS_STORED			12
#define KLIST_CONFLICTS					13
#define KSYNC_CONFLICTS_FILE			14

@interface ActionsProxy : NSObject {
	NSString *fileName;
	BankLog  *structuredMemoryLog;
	Prefs	 *prefs;
	NSMutableSet *conflicts;
	Database *db;
}

@property (retain) NSString* fileName; 
@property (retain) BankLog* structuredMemoryLog; 
@property (retain) Prefs* prefs; 
@property (retain) NSMutableSet *conflicts;

- (BOOL) fileSelected;
//- (int)  processAction:(int)actionMenuCode sender:(id)obj;
- (int)  actionOpenFile:(NSString *)nameOfFile managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
- (int)  actionMatchDatabaseEntries:(NSManagedObjectContext *)managedObjectContext;
- (int)  actionReadExistingPreferences;
- (int)  actionSetDefaultPreferences:(NSManagedObjectContext *)managedObjectContext;

- (int)  actionPrepareGraphicsTab:(NSManagedObjectContext *)moc;
- (NSDictionary *)  actionDrawPieChart:(NSManagedObjectContext *)moc from:(NSDate *)fromThisDate to:(NSDate *)toThisDate;

@end
