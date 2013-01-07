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

@interface ovb3_AppDelegate : NSObject <NSTabViewDelegate>
{
    NSWindow *window;
	NSTabView *tabView;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	// Actions Proxy
	ActionsProxy* sendAction;
	
	// Menu flags to control activation
	BOOL matchingEnabled;
	
	// Flag to control whether it is the first time the app executes.
	BOOL MDFirstRun;
	
	IBOutlet NSDatePicker *fromDatePick;
	IBOutlet NSDatePicker *toDatePick;
    
    IBOutlet NSSearchField *searchFieldOutlet;
    	
	// XXX Experimental
	IBOutlet Graphics *graphicsView;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTabView *tabView;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (assign) BOOL matchingEnabled;

@property (nonatomic, retain) IBOutlet NSDatePicker *fromDatePick;
@property (nonatomic, retain) IBOutlet NSDatePicker *toDatePick;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification;

- (IBAction) saveAction:(id)sender;
- (IBAction) openAction:(id)sender;
- (IBAction) drawPieChartAction:(id)sender;

- (IBAction) doMatchDatabaseEntries:(id)sender;
- (IBAction) selectPopUpCellAction:(id)sender;

- (NSArray *)categoriesSortDescriptors;

@end
