//
//  ovb3_AppDelegate.h
//  ovb3
//
//  Created by Jesus Renero Quintero on 28/12/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ActionsProxy.h"
#import "BarGraph.h"
#import "MASPreferencesWindowController.h"
#import "prefsViewController.h"
#import "PieChart.h"
#import "YearGraph.h"


// TAB numbers.
#define TABLE_TAB 0
#define MOVEMENTS_TAB 1
#define PIECHART_TAB 2

@interface AppDelegate : NSObject <NSTabViewDelegate, NSTableViewDataSource>
{
    NSWindow *_window;
	NSTabView *__strong _tabView;

    // Here it is the preferences window controller.
    NSWindowController *_preferencesWindow;
    
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
    IBOutlet NSArrayController *categoriesController;
    IBOutlet NSArrayController *selectableCategoriesController;
    IBOutlet NSTableView *tableView;
    IBOutlet PieChart *pieChartView;
    IBOutlet BarGraph *bargraphView;
    IBOutlet YearGraph *yearGraphView;
}

@property (nonatomic, strong) IBOutlet NSWindow *_window;
@property (strong) IBOutlet NSTabView *_tabView;
@property (nonatomic, strong) NSWindowController *_preferencesWindow;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableDictionary *tableEntriesDictionary;
@property (nonatomic, strong) ActionsProxy *sendAction;

@property (assign) BOOL matchingEnabled;
@property (assign) BOOL tablePopUpCellChanged;
@property (assign) BOOL MDFirstRun;

@property (nonatomic, strong) IBOutlet NSDatePicker *fromDatePick;
@property (nonatomic, strong) IBOutlet NSDatePicker *toDatePick;
@property (nonatomic, strong) IBOutlet NSSearchField *searchFieldOutlet;
@property (nonatomic, strong) IBOutlet NSArrayController *tableEntriesController;
@property (nonatomic, strong) IBOutlet NSArrayController *categoriesController;
@property (nonatomic, strong) IBOutlet NSArrayController *selectableCategoriesController;
@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet PieChart *pieChartView;
@property (nonatomic, strong) IBOutlet BarGraph *bargraphView;
@property (nonatomic, strong) IBOutlet YearGraph *yearGraphView;

@property (atomic) int selectedTab;

// -- METHODS


- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;

- (NSMutableDictionary *)tableEntriesDictionary;

- (IBAction) saveAction:(id)sender;
- (IBAction) openAction:(id)sender;
- (IBAction) drawPieChartAction:(id)sender;
- (IBAction) drawYearlyDistributionAction:(id)sender;

- (IBAction) doMatchDatabaseEntries:(id)sender;
- (IBAction) selectPopUpCellAction:(id)sender;

- (NSArray *)categoriesSortDescriptors;

@end
