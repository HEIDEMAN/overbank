//
//  ActionsProxy.m
//  Overbank
//
//  Created by Jesus Renero Quintero on 23/10/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import "ActionsProxy.h"

@implementation ActionsProxy
@synthesize _fileName,
    structuredMemoryLog,
    _prefs,
    conflicts;

-(id)init
{
	self = [super init];
    if (self) {
		NSLog(@"---- Allocating proxy instance...");
        
		// Creo la estructura para las preferencias, incluyendo el diccionario de tags y categorias.
		// Se establecen a los valores por defecto a lo que haya guardado en el disco en las funciones
		// que controlan la inicialización del AppDelegate.
		NSLog(@"---- Allocating Preferences and Conflicts dictionaries...");
		_prefs = [[Prefs alloc] init];
		conflicts = [[NSMutableSet alloc] init];
		db = [[Database alloc] init];
		NSLog(@"---- done.");
		
	}
	return self;
}



/**
 * This function gets the name selected through the dialog presented when the "Open" item
 * under the "File" menu is selected, and process it to import contents into the CoreData Model.
 * 
 * @param nameOfFile The name of the file to be opened, containing an absolute path.
 * @param managedObjectContext The ManagedObjectContext used in CoreData where data is to be imported.
 * @return 0 if the import was succesful. An error code ≠ 0, otherwise.
 */
-(int) actionOpenFile:(NSString *)nameOfFile managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    CSVParser *parser = [[CSVParser alloc]
                          initWithFilePath:nameOfFile
                          separator:@";" hasHeader:YES
                          fieldNames:nil];
    
    // Guess the type of the fields parsed.
    NSArray *records = [parser parseRows];
    NSUInteger numHeaders = [parser guessFieldTypes:records];
    [parser guessIndexForFieldTypes:[[NSArray alloc] initWithObjects:
                                     [NSNumber numberWithInt:DATE_TYPE_STRING],
                                     [NSNumber numberWithInt:TEXT_TYPE_STRING],
                                     [NSNumber numberWithInt:NUMBER_TYPE_STRING],
                                     nil]];
    NSLog(@"%lu Headers, %lu Records read.", (unsigned long)numHeaders, [records count]);
    
    // Put the elements parsed into a proper "Entry" array for later storing in DB.
    structuredMemoryLog = [[NSMutableArray alloc] init];
    for (NSDictionary *record in records)
    {
        Entry *entry = [[Entry alloc]init];
        entry.fechaOperacion = [record objectForKey:[parser.fieldNames objectAtIndex:[parser indexDate]]];
        
        // Convert Importe from NSString to NSNumber
        entry.importe = [record objectForKey:[parser.fieldNames objectAtIndex:[parser indexAmount]]];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        entry.importe = [f numberFromString:
                         [record objectForKey:[parser.fieldNames objectAtIndex:[parser indexAmount]]]];
        
        // De-localize "concepto" string.
        entry.concepto = [record objectForKey:[parser.fieldNames objectAtIndex:[parser indexConcept]]];
        NSString *localized = [NSString stringWithString:[entry concepto]];
        NSString *delocalized = [NSString stringWithUTF8String:
                                 [localized cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        entry.concepto = [NSString stringWithString:delocalized];
        
        // Relleno el Match para que no se quede vacio y asi no estropee la ejecución de la
        // TableView.
        entry.matchingCategory.categoryMatched = @"";
        [entry.matchingCategory.tagsMatched addObject:(NSString *)@""];
        entry.matchingCategory.votes = 0;
        
        [structuredMemoryLog addObject:entry];
    }
    
	return [db fastImportLog:structuredMemoryLog managedObjectContext:managedObjectContext];
}


/**
 This function will be responsible for the matching of all the entries in the database.
 Preconditions: the database must contain objects, the objects must not be previously
 categorized.
 Since this function is located in the actions proxy between the GUI and the bizz logic,
 it will simply control the execution of the proper function in the database object.
 */
- (int) actionMatchDatabaseEntries:(NSManagedObjectContext *)managedObjectContext
{
	int returnCode = [db categorizeAllEntries:managedObjectContext preferences:_prefs conflictsSet:conflicts
                   solveConflictsFlag:YES verboseFlag:YES];
	[Match listConflictSet:conflicts];
	return returnCode;
}



/*
 This method calls the class database to learn from a new categorization that
 the user has provoked by manually selecting the proper category for an entry.
 */
- (int) actionLearnMatchFromUserCategorization:(NSManagedObjectContext *)moc dbentry:(DBEntry *)dbentry
{
    int rc = [db learnCategorizationFromUserAction:moc
                                           dbentry:dbentry
                                      conflictsSet:conflicts
                                       preferences:_prefs];
    return rc;
}


/**
 * Sets up the preferences from a default set hardwired in the code, and
 * stored in the preferences plist. It also sets the category names list
 * that will be stored in the database (populating it).
 * @param managedObjectContext is the link with the entities in the Core
 *        Data database
 * @return 0 if everything goes fine, and a number ≠ 0, if an error occurs.
 */
- (int) actionSetDefaultPreferences:(NSManagedObjectContext *) moc
{
	int returnCode = 0;
	returnCode = [_prefs defaultPrefs];
	returnCode += [_prefs syncPrefs];
	
	// Store the names of the categories into the corresponding table in DB.
	NSMutableArray *categoryNames = [_prefs getCategoryNames];
	returnCode += [db storeCategoriesInDatabase:(NSArray *)categoryNames
                  managedObjectContext:(NSManagedObjectContext *)moc];
    
	return returnCode;
}



/**
 This function reads the existing preferences stored in the plist file, if this is not the first
 time that the program is executed.
 */
- (int) actionReadExistingPreferences
{
	int returnCode = [_prefs readPrefs];    
    return returnCode;
}


/**
 Synchronize preferences from memory to disk.
 */
- (int) actionSyncPreferences
{
    return [_prefs syncPrefs];
}



/*
 actionPrepareGraphicsTab
 This function do some calculations over the database to prepare
 parts of the graphics
 */
- (int) actionPrepareGraphicsTab:(NSManagedObjectContext *)moc
{
	NSLog(@"Inside actionPrepareGraphicsTab");
	//NSArray *fromAndToDates = [db findDatesInterval:moc];
    
	return 0;
}



/**
 This function is responsible for computing the values to be represented in the pie
 chart and make them drawed.
 */
- (NSDictionary *) actionDrawPieChart:(NSManagedObjectContext *)moc
                              inArray:(NSArray *)selectedCategories
                                 from:(NSDate *)fromThisDate to:(NSDate *)toThisDate
{
	NSLog(@"Inside actionDrawPieChart");
	
	NSDictionary *aggregated = [db computeAggregatedCategories:moc
                                                       inArray:selectedCategories
                                                      fromDate:fromThisDate toDate:toThisDate];
	
	return aggregated;
}


- (int) actionPrepareBarGraphTab:(NSManagedObjectContext *)moc
{
    return 0;
}


//
// To be deprecated
//
-(BOOL)fileSelected {
	return (_fileName == nil ? NO : YES);
}




@end
