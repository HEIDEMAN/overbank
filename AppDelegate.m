//
//  ovb3_AppDelegate.m
//  ovb3
//
//  Created by Jesus Renero Quintero on 28/12/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import "AppDelegate.h"
#import "tableColorTransformer.h"


// To control the first execution of the App... and do the proper thing
// with the NSUserPreferences.
NSString * const MDFirstRunKey = @"MDFirstRun";


@implementation AppDelegate

@synthesize window, tabView,
    persistentStoreCoordinator, managedObjectModel, managedObjectContext,
    tableEntriesDictionary, sendAction,
    matchingEnabled, MDFirstRun,
    fromDatePick, toDatePick, searchFieldOutlet, tableEntriesController,
    categoriesController, selectableCategoriesController,
    tableView, pieChartView, bargraphView, yearGraphView;

#pragma mark APP INITIALIZATION

/**
 http://bit.ly/uxcBra
 Basically, you set up all of your default values in your initialize method.
 (The initialize method is called very early on before init is called, so it
 provides a convenient place to make sure user defaults all have default values).
 The registerDefaults: method of NSUserDefaults is special in that the values you
 pass in only are used if a particular value hasn't already been set. In other
 words, when in the code above, I set the first launch key to NO in the
 applicationDidFinishLaunching: method, that overrides the default value and will
 be saved to your application's preferences plist file. The values that are saved
 in the preferences file take precedence over those that you've registered with
 user defaults in the initialize method.
 */
+ (void)initialize
{
	tableColorTransformer *transformer = [[tableColorTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer	forName:@"tableColorTransformer"];
	
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
    [defaultValues setObject:[NSNumber numberWithBool:YES]
                      forKey:MDFirstRunKey];
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
}

/**
 init
 */
- (id)init
{
	if (self = [super init]) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		MDFirstRun = [[userDefaults objectForKey:MDFirstRunKey] boolValue];
	}
	return self;
}

/**
 Application Did Finish Launching
 */
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"--");
	NSLog(@"-- APP DID FINISH LAUNCHING!");
	
	// Allocate memory for the actions proxy object that will handle the interface between
	// the GUI and the app logic.
	if (sendAction == nil) {
		sendAction = [[ActionsProxy alloc] init];
	}
	
	if (MDFirstRun) {
		NSLog(@"-- This IS the first time this App runs...");
		// XXX Estp hay que quitarlo, solo puede valer YES, la primera vez.
		//[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MDFirstRunKey];
		[sendAction actionSetDefaultPreferences:managedObjectContext];
	}
	else {
		NSLog(@"-- NOT the first time this App runs...");
		[sendAction actionReadExistingPreferences];
		// Esto hay que quitarlo. es solo para ver si se puede revertir.
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MDFirstRunKey];
	}
	
	[tabView selectFirstTabViewItem:NULL];
    
    // Bind the contents of the Array controller column "importe" to the bindable array in
    // NSView that will be used to represent the bar graph with the total income and outcome.
    [bargraphView bind:@"amountsArray" toObject:tableEntriesController
           withKeyPath:@"arrangedObjects.importe" options:nil];
    
    // Bind also the whole table array controller to the binding in class YearGraph
    [yearGraphView bind:@"entriesArray" toObject:tableEntriesController
            withKeyPath:@"arrangedObjects" options:nil];
    
    // The binding to the categories array controller that I need does NOT reference
    // "arrangedObjects" but ONLY the selected ones. Therefore, I type "selectedObjects".
    // Cool, ah?
    [yearGraphView bind:@"categoriesArray" toObject:categoriesController
            withKeyPath:@"selectedObjects" options:nil];
    
    // Bind the table with categories to the piechartview.
    [pieChartView bind:@"selectableCategoriesArray" toObject:selectableCategoriesController
           withKeyPath:@"selectedObjects" options:nil];
    
}

- (void) tabView: (NSTabView *) inTabView willSelectTabViewItem: (NSTabViewItem *) inTabViewItem
{
	NSLog(@"tabView (will): <%@>, tabViewItem: <%@>", inTabView, [inTabViewItem label]);
    // TODO: Remove static reference.
    if ([[inTabViewItem label] caseInsensitiveCompare:@"Movimientos"] == NSOrderedSame)
    {
        [bargraphView setDrawable:NO];
    }
    if ([[inTabViewItem label] caseInsensitiveCompare:@"Categorias"] == NSOrderedSame)
    {
        [bargraphView setDrawable:YES];
        [sendAction actionPrepareBarGraphTab:managedObjectContext];
    }
    if ([[inTabViewItem label] caseInsensitiveCompare:@"Estadisticas"] == NSOrderedSame)
    {
        [bargraphView setDrawable:NO];
        [sendAction actionPrepareGraphicsTab:managedObjectContext];
    }    
}


#pragma mark CORE DATA INITIALIZATIONS


/**
 Returns the support directory for the application, used to store the Core Data
 store file.  This code uses a directory named "ovb3" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */
- (NSString *)applicationSupportDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"ovb3"];
}


/**
 Creates, retains, and returns the managed object model for the application
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This
 implementation will create and return a coordinator, having added the
 store for the application to it.  (The directory for the store is created,
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
	
    if (persistentStoreCoordinator) return persistentStoreCoordinator;
	
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@ No model to generate a store from", [self class]);
        return nil;
    }
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO
									 attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@",
						   applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }
    
    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType
												  configuration:nil
															URL:url
														options:nil
														  error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        persistentStoreCoordinator = nil;
        return nil;
    }
	
    return persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.)
 */

- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext) return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
	
    return managedObjectContext;
}

/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


#pragma mark ACTIONS taken from the APP

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.  Any encountered errors
 are presented to the user.
 */
- (IBAction) saveAction:(id)sender {
	
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        //NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
        NSLog(@"%@: unable to commit editing before saving", [self class]);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

/**
 Performs the open action for the application, which is to send the open:
 message to the application's actions proxy.  Any encountered errors
 are presented to the user.
 */
- (IBAction)openAction:(id)sender {
	NSLog(@"doOpen");
	
	NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"csv", @"CSV", nil];
	NSOpenPanel *openPanel	= [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:FALSE];
	[openPanel setFloatingPanel:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setAllowedFileTypes:fileTypes];
	
	NSInteger i	= [openPanel runModalForTypes:fileTypes];
	
	if(i == NSOKButton){
     	NSLog(@" we have an OK button");
	} else if(i == NSCancelButton) {
     	NSLog(@" we have a Cancel button");
     	return;
	} else {
     	NSLog(@"doOpen 'i' not equal 1 or zero = %3ld",i);
     	return;
	} // end if     <
	
	// Cojo el fileName que se ha elegido en el menu y se lo paso al
	// controlador de acciones para que haga lo que tenga que hacer con el.
	NSString *fileName = [[NSString alloc] initWithString:[openPanel filename]];
	NSLog(@"doOpen calling actionOpenFile with filename = %@", fileName);
	
	int rc = [sendAction actionOpenFile:fileName managedObjectContext:managedObjectContext];
	NSLog(@"ActionOpenFile returned %d.", rc);
	
	NSLog(@"Leaving doOpen");
}


/*
 This method is called when the cell pop up menu is clicked.
 I control from here, the category update for the record.
 */
- (IBAction)selectPopUpCellAction:(id)sender
{
	NSInteger selectedRow = [sender selectedRow];
    DBEntry *object = [[tableEntriesController arrangedObjects] objectAtIndex:selectedRow];
    
    [sendAction actionLearnMatchFromUserCategorization:managedObjectContext dbentry:object];
}


/**
 Implementation of the GUI receiver function that takes care of the matching of the
 entries in the database.
 Preconditions: The must be any record in the database for this option to be activated.
 */
- (IBAction) doMatchDatabaseEntries:(id)sender
{
	NSLog(@"Entering doMatchDatabaseEntries...");
	matchingEnabled = YES;
	
	int rc = [sendAction actionMatchDatabaseEntries:managedObjectContext];
	NSLog(@"ActionMatchDatabaseEntries returned %d.", rc);
	
	NSLog(@"Leaving doMatchDatabaseEntries");
}

/**
 drawPieChartAction: Dibuja el pie chart
 */
- (IBAction) drawPieChartAction:(id)sender
{
	if (!managedObjectContext) {
		NSLog(@"Amazingly, there's no managedObjectContext...");
		NSLog(@"Blasting all this untrue comedy... argg...");
		return;
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd-MM-yyyy"];
	NSDate *fromThisDate = [fromDatePick dateValue];
	NSDate *toThisDate = [toDatePick dateValue];
	
	NSLog(@" -- drawPieChart action trapped --");
	NSLog(@" -- from date field: %@", [formatter stringFromDate:fromThisDate]);
	NSLog(@" -- to   date field: %@", [formatter stringFromDate:toThisDate]);
	
	NSDictionary *aggregated = [sendAction actionDrawPieChart:managedObjectContext
                                                      inArray:[pieChartView selectableCategoriesArray]
                                                         from:fromThisDate to:toThisDate];
	[pieChartView updatePieData:(NSDictionary *)aggregated];
}

/**
 drawYearlyDistributionAction: Draws the monthly distribution across all the years.
 */
- (IBAction) drawYearlyDistributionAction:(id)sender {
	if (!managedObjectContext) {
		NSLog(@"Amazingly, there's no managedObjectContext...");
		NSLog(@"Blasting all this untrue comedy... argg...");
		return;
	}
    NSLog(@" -- drawYearlyDistribution action trapped --");
    [yearGraphView computeYear];
}


#pragma mark APP FINISH


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	
    if (!managedObjectContext) return NSTerminateNow;
	
    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }
	
    if (![managedObjectContext hasChanges]) return NSTerminateNow;
	
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
		
        // This error handling simply presents error information in a panel with an
        // "Ok" button, which does not include any attempt at error recovery (meaning,
        // attempting to fix the error.)  As a result, this implementation will
        // present the information to the user and then follow up with a panel asking
        // if the user wishes to "Quit Anyway", without saving the changes.
		
        // Typically, this process should be altered to include application-specific
        // recovery steps.
		
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?",
											   @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save",
										   @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
		
    }
	
    return NSTerminateNow;
}


/*
 This method is bound from IB CatPopUpController "Sort Descriptors" submenu to
 indicate how to sort the contents of the array.
 */
- (NSArray *)categoriesSortDescriptors {
    return [NSArray arrayWithObject:
			[NSSortDescriptor sortDescriptorWithKey:@"name"
										  ascending:YES]];
}


/**
 Implementation of dealloc, to release the retained variables.
 */



@end
