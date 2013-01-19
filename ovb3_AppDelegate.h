//
//  ovb3_AppDelegate.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 28/12/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ActionsProxy.h"
#import "Graphics.h"

@interface ovb3_AppDelegate : NSObject <NSTabViewDelegate, NSTableViewDataSource>
{
    NSWindow *window;
	NSTabView *tabView;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
    NSMutableDictionary *tableEntriesDictionary;

	// Actions Proxy
	ActionsProxy* sendAction;
	
	// Menu flags to control activation
	BOOL matchingEnabled;
    
    // Controls whether Category popupcell in Table has changed
    BOOL tablePopUpCellChanged;
	
	// Flag to control whether it is the first time the app executes.
	BOOL MDFirstRun;
	
	IBOutlet NSDatePicker *fromDatePick;
	IBOutlet NSDatePicker *toDatePick;
    
    IBOutlet NSSearchField *searchFieldOutlet;
    	
	// XXX Experimental
	IBOutlet Graphics *graphicsView;
    IBOutlet NSArrayController *tableEntriesController;
    IBOutlet NSTableView *tableView;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (assign) BOOL matchingEnabled;
@property (assign) BOOL tablePopUpcellChanged;

@property (nonatomic, retain) IBOutlet NSDatePicker *fromDatePick;
@property (nonatomic, retain) IBOutlet NSDatePicker *toDatePick;

@property (nonatomic, retain) IBOutlet NSArrayController *tableEntriesController;
@property (nonatomic, retain) IBOutlet NSTableView *tableView;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;

- (NSMutableDictionary *)tableEntriesDictionary;

- (IBAction) saveAction:(id)sender;
- (IBAction) openAction:(id)sender;
- (IBAction) drawPieChartAction:(id)sender;

- (IBAction) doMatchDatabaseEntries:(id)sender;
- (IBAction) selectPopUpCellAction:(id)sender;

- (NSArray *)categoriesSortDescriptors;

@end
