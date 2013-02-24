//
//  ovb3_AppDelegate.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 28/12/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ActionsProxy.h"
#import "PieChart.h"
#import "BarGraph.h"


// TAB numbers.
#define TABLE_TAB 0
#define MOVEMENTS_TAB 1
#define PIECHART_TAB 2

@interface ovb3_AppDelegate : NSObject <NSTabViewDelegate, NSTableViewDataSource>
{
    NSWindow *window;
	NSTabView *tabView;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSMutableDictionary *tableEntriesDictionary;

	// Actions Proxy. All the actions detected by the Application delegate
    // are sent to the actions proxy for proper handling, and avoiding
    // having too much complexity here.
	ActionsProxy* sendAction;
	
	// Menu flags to control activation
	BOOL matchingEnabled;
	// Flag to control whether it is the first time the app executes.
	BOOL MDFirstRun;
	
	IBOutlet NSDatePicker *fromDatePick;
	IBOutlet NSDatePicker *toDatePick;
    IBOutlet NSSearchField *searchFieldOutlet;
    IBOutlet NSArrayController *tableEntriesController;
    IBOutlet NSTableView *tableView;
    IBOutlet PieChart *graphicsView;
    IBOutlet BarGraph *bargraphView;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableDictionary *tableEntriesDictionary;
@property (nonatomic, retain) ActionsProxy *sendAction;

@property (assign) BOOL matchingEnabled;
@property (assign) BOOL tablePopUpCellChanged;
@property (assign) BOOL MDFirstRun;

@property (nonatomic, retain) IBOutlet NSDatePicker *fromDatePick;
@property (nonatomic, retain) IBOutlet NSDatePicker *toDatePick;
@property (nonatomic, retain) IBOutlet NSSearchField *searchFieldOutlet;
@property (nonatomic, retain) IBOutlet NSArrayController *tableEntriesController;
@property (nonatomic, retain) IBOutlet NSTableView *tableView;
@property (nonatomic, retain) IBOutlet PieChart *graphicsView;
@property (nonatomic, retain) IBOutlet BarGraph *bargraphView;

@property (atomic) int selectedTab;

// -- METHODS


- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;

- (NSMutableDictionary *)tableEntriesDictionary;

- (IBAction) saveAction:(id)sender;
- (IBAction) openAction:(id)sender;
- (IBAction) drawPieChartAction:(id)sender;

- (IBAction) doMatchDatabaseEntries:(id)sender;
- (IBAction) selectPopUpCellAction:(id)sender;

- (NSArray *)categoriesSortDescriptors;

@end
