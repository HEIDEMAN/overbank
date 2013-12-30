//
//  Database.m
//  ovb3
//
//  Created by Jesus Renero Quintero on 28/12/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import "Database.h"

@implementation Database

#pragma mark Import Entry objects into the database.

- (void)displayDuplicateEntry:(SimplifiedEntry *)sline hashTable:(NSHashTable *)hashTable
{
    NSLog(@"Duplicate entry (%@|%@|%f), already inserted. Skipping.",
          sline.fechaOperacion, sline.concepto, [sline.importe floatValue]);
    SimplifiedEntry *e = [hashTable member:sline];
    NSLog(@"%@|%@|%f", e.fechaOperacion, e.concepto, [e.importe floatValue]);
}

/**
 * Create a Core Data "DBEntry" entity to save the contents of "line" object passed.
 *
 * @param  line   The "Entry" object to save into the Core Data database.
 * @param  inMOC  The Managed Object Context.
 * @return TRUE if an error ocurred, FALSE otherwise.
 */
- (BOOL)saveEntry:(Entry *)line inMOC:(NSManagedObjectContext *)moc
{
    // Create the MOC that will hold the entry.
    NSManagedObject *entry = [self entryToDBEntry:line inManagedObjectContext:moc];
    if (entry == nil) {
        NSLog(@"  ERROR: Unable to save the entry to database.");
        return TRUE;
    }

    // Insert the line into the DB if previous controls are OK.
    if ([moc save:nil] == NO) {
        NSLog(@"  ERROR: An error occurred while saving entry.");
        return TRUE;
    }
    return FALSE;;
}

/**
 * Take the log from memory and import it into the database, avoiding duplicates.
 */
- (int)fastImportLog:(NSMutableArray *)log managedObjectContext:(NSManagedObjectContext *)moc
{
    BOOL errorOcurred=FALSE;
    
    // Take the table up to memory
    NSArray *array = [self loadTableToArray:moc];
    
    // These 2 hastables contain the elements to compare with, in order to avoid duplicates.
    NSHashTable *dbHashTable = [[NSHashTable alloc]init];
    for (DBEntry *record in array) {
        [dbHashTable addObject:[self dbEntryToSimplifiedEntry:record]];
    }
    NSHashTable *memHashTable = [[NSHashTable alloc]init];
    
    // Loop throughout the entire log in memory to insert those lines not
    // already in memory
	for (Entry *line in log) {
		// Do not consider empty entries, and operate on simplified entries.
		if ( [[line fechaOperacion] length] == 0) continue;
        SimplifiedEntry *sline = [line simplified];
        
        // Skip also lines that are already in the table to avoid duplicates.
        if ( [dbHashTable containsObject:sline] ) {
            [self displayDuplicateEntry:sline hashTable:dbHashTable];
            continue;
        }
        // Now I must search this entry within the previous entries of the array
        // to avoid inserting duplicates. O(1)
        if ( [memHashTable containsObject:sline] ) {
            [self displayDuplicateEntry:sline hashTable:memHashTable];
            continue;
        }
        
        // Save the entry in the DB, but if an error occurs, then break the loop.
        if ( [self saveEntry:line inMOC:moc] == TRUE )
            break;
        
        // Add this entry to the memTable to perform further comparisons against entries already inserted.
        [memHashTable addObject:sline];
    }
    
    // Return the number of entries updated.
    return errorOcurred;
}

- (NSArray*)loadTableToArray:(NSManagedObjectContext*)moc
{
    // Set up the object that connects to the entity in Core Data to perform the fetch
    NSEntityDescription *entityDescription = [NSEntityDescription  entityForName:@"DBEntry" inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
    // You can add sorting like this
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fechaOperacion" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:fetchRequest error:&error];
    if (array == nil) {
        NSLog(@"NO Results Back. Failed Fetch!!");
        return nil;
    }
    return array;
}

- (BOOL)arrayContainsEntry:(NSArray*)array Entry:(Entry*)line
{
    for (DBEntry *record in array) {
        if ( [line equals:[self dbEntryToEntry:record]] ) {
            return TRUE;
        }
    }
    
    return FALSE;
}


#pragma mark Categorization methods: establishing category for every entry.


/**
 This function list out all the elements in the main entry of the core database to
 run the matching function over it, trying to pair it with a category.
 If a category is found without conflict, is simply assigned to it.
 If a category is not found, it is left blank.
 If multiple categories are found, a conflict raises, and multiple categories are assigned
 to that entry.
 */
- (int) categorizeAllEntries:(NSManagedObjectContext *)managedObjectContext preferences:(Prefs *)prefs
                conflictsSet:(NSMutableSet *)conflictsSet solveConflictsFlag:(BOOL)solveConflict
                 verboseFlag:(BOOL)verbose
{
    NSLog(@"(categorizeAllEntries): Classifying entries in DB.");
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBEntry"
                                              inManagedObjectContext:managedObjectContext];
	
    [Match listConflictSet:conflictsSet];
    
	// Get ALL the objects in entity.
	NSError *error;
	[fetchRequest setEntity:entity];
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	
	// Iterate
	for (NSManagedObject *line in fetchedObjects)
	{
		// Convert the object returned by the fetch request to Core Data into a valid Entry object
		Entry *entry = [self dbEntryToEntry:line];
		
		// If the line is already categorized, I re-do the process only if the override flag is set
		if ( [entry.matchingCategory.categoryMatched length] != 0) {
			if (verbose) NSLog(@"Skipping entry classification. Already classified.");
            NSLog(@"  '%@' -> [%@]", entry.concepto, entry.matchingCategory.categoryMatched);
			continue;
		}
		
		// Busco a que categorias puede pertenecer esta entrada bancaria.
		Match *winner=nil;
		NSMutableSet *matchesSet = [prefs matchTag:[entry concepto]];
		if (matchesSet.count == 0) {
			if (verbose) NSLog (@"-- MISMATCH -- Entry doesn't match any category!!");
			if (verbose) NSLog (@"   '%@'", entry.concepto);
			winner = nil;
		}
		else
		{
			NSLog (@"ENTRY: '%@'.", [entry concepto]);
            
			// Recorro todas las categorias con las que ha habido "match"
			int j=0;
			for (Match *match in matchesSet)
            {
				// Pinto cada categoria del Set.
				if (verbose) NSLog (@"  > MATCH (%d/%ld): '%@' #%ld votes", j+1,
                                    matchesSet.count, match.categoryMatched, match.votes);
				
				// Pinto las etiquetas que han producido el match.
				for (int k=0;((verbose) && (k<[match.tagsMatched count]));k++) {
					NSLog (@"    > %d - %@",k+1, [match.tagsMatched objectAtIndex:k]);
				}
				j++;
			}
            
			// Si hay mas de una categoria tenemos un conflicto.
			if ( matchesSet.count > 1 )
            {
				if (solveConflict) // Soluciono el conflicto de manera interactiva, o...
				{
                    NSLog(@"  : Selecting winner from Match.");
					winner = [Match solveConflict:matchesSet :conflictsSet];
				}
				else // Rehago el "winner" para que incluya todas las categorias concatenadas.
				{
                    NSLog(@"  : Generating Winner from multiple possible winners.");
					winner = [[Match alloc] init];
					NSString *allMatches = [[NSString alloc] init];
					for (Match *m in matchesSet) {
						allMatches = [allMatches stringByAppendingFormat:@"%@,", m.categoryMatched];
						for(int i=0;i<[m.tagsMatched count];i++) {
							[winner.tagsMatched addObject:[ m.tagsMatched objectAtIndex:i ]];
						}
					}
					winner.categoryMatched = [NSString stringWithString:allMatches];
				}
			}
			// Si solo hay una, sacamos el elemento del set y ese es el winner.
			else if ( matchesSet.count == 1 )
            {
                NSLog(@"  : Setting winner from Set.");
				NSEnumerator *e = [matchesSet objectEnumerator];
				winner = [e nextObject];
			}
		}
		// And the WINNER catgoy is...
		entry.matchingCategory = winner;
		if (verbose) {
            NSLog(@">> \"%@\" CATEGORIZED AS %@", entry.concepto, entry.matchingCategory.categoryMatched );
        }
		
		// Now, it's time to grab it down into the DB, in case there's a winner.
		if ( (matchesSet.count != 0) && (winner != nil) ) {
			[self updateCategoriesInDatabase:line fromEntry:entry managedObjectContext:managedObjectContext];
		}
	}
	
	NSLog(@"(categorizeAllEntries): Returning 0.");
	return 0;
}


- (int) learnCategorizationFromUserAction:(NSManagedObjectContext *)moc
                                  dbentry:(DBEntry *)dbentry
                             conflictsSet:(NSMutableSet *)conflictsSet
                              preferences:(Prefs *)prefs
{
    NSLog(@"Entering 'learn from action'...\n");
    Entry *entry = [self dbEntryToEntry:dbentry];
    
    // If the entry the user manually updated was NULL, then I try to learn,
    // Otherwise, I dont do anything.
    if ([entry.matchingCategory.categoryMatched length] != 0) {
        NSLog(@"  This entry was already categorized (%@). Nothing to learn.",
              entry.matchingCategory.categoryMatched);
        return 1;
    }
    
    [entry printEntry];
    [self printDBEntry:dbentry];
    
    // Now, I must update de Entry object with the contents of the DBEntry object
    // obtanined from the managedObjectContext. I also must update the conflicts
    // set adding a vote to the category newly matched. And then, run the matching
    // again to check if I can learn something from that.
    
    // Search what categories could match this entry
    Match *winner=nil;
    NSMutableSet *matchesSet = [prefs matchTag:[entry concepto]];
    if (matchesSet.count == 0) {
        NSLog (@"-- MISMATCH -- Entry doesn't match any category!!");
        NSLog (@"   '%@'", entry.concepto);
        winner = nil;
    }
    else
    {
        NSLog (@"ENTRY: '%@' matches 1 or more categories!", [entry concepto]);
        
        // Recorro todas las categorias con las que ha habido "match"
        int j=0;
        for (Match *match in matchesSet)
        {
            // Pinto cada categoria del Set.
            NSLog (@"  > CATEGORY MATCH (%d/%ld): '%@' [#%ld]", j+1,
                   matchesSet.count, match.categoryMatched, match.votes);
            for (int k=0;(k<[match.tagsMatched count]);k++) {
                NSLog (@"    > Tag#%d - '%@'",k+1, [match.tagsMatched objectAtIndex:k]);
            }
            j++;
        }
        
        // Si hay mas de una categoria tenemos un conflicto.
        if ( matchesSet.count > 1 ) {
            winner = [Match solveConflictWithUserAction:matchesSet :conflictsSet :dbentry.category.name];
        }
        // Si solo hay una, sacamos el elemento del set y ese es el winner.
        else if ( matchesSet.count == 1 )
        {
            NSEnumerator *e = [matchesSet objectEnumerator];
            winner = [e nextObject];
        }
    }
    // And the WINNER catgoy is...
    entry.matchingCategory = winner;
    [Match markWinnerCategoryInConflict:matchesSet :conflictsSet :winner.categoryMatched];
    NSLog(@">> \"%@\" CATEGORIZED AS %@", entry.concepto, entry.matchingCategory.categoryMatched );
    NSLog(@"--endoflearnedlesson--");
    [Match listConflictSet:conflictsSet];
    NSLog(@"--endoflearnedlesson--");
    
    // If I can find more unclassified objects, then I ask the user whether
    // to extend the change applied to the data to the rest of them.
    NSArray *fetchedObjects = [self selectEntriesMatchingCategory:nil :moc];
    if ([fetchedObjects count] != 0)
    {
        // Ask the user if wants to apply the new learning to the rest of the table.
        NSInteger returnValue = NSRunAlertPanel(@"Apply...",
                                                @"Do you want to apply the selection to entire table?",
                                                @"OK", @"Cancel", nil);
        if (returnValue == NSAlertDefaultReturn)
            [self recategorizeRelatedEntries:fetchedObjects preferences:prefs
                                conflictsSet:conflictsSet ManagedObjectContext:moc];
    }
    return 0;
}


/**
 This function list out all the elements in the main entry of the core database to
 run the matching function over it, trying to pair it with a category.
 If a category is found without conflict, is simply assigned to it.
 If a category is not found, it is left blank.
 If multiple categories are found, a conflict raises, and multiple categories are assigned
 to that entry.
 */
- (int) recategorizeRelatedEntries:(NSArray *)fetchedObjects
                       preferences:(Prefs *)prefs
                      conflictsSet:(NSMutableSet *)conflictsSet
              ManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSLog(@"");
    NSLog(@"Re-categorization based on user manual change.\n");
    NSLog(@"");
    
	for (NSManagedObject *line in fetchedObjects)
	{
		Entry *entry = [self dbEntryToEntry:line];
        if ( [entry.matchingCategory.categoryMatched length] != 0) {
			NSLog(@"Skipping entry classification. Already classified.");
            NSLog(@"  '%@' => [%@]", entry.concepto, entry.matchingCategory.categoryMatched);
			continue;
		}
		
        NSLog (@"ENTRY: '%@'.", [entry concepto]);
        
		// Busco a que categorias puede pertenecer esta entrada bancaria.
		Match *winner=nil;
		NSMutableSet *matchesSet = [prefs matchTag:[entry concepto]];
		if (matchesSet.count == 0) {
			NSLog (@"-- MISMATCH -- Entry doesn't match any category!!");
			NSLog (@"   '%@'", entry.concepto);
			winner = nil;
		}
		else
		{
			// Recorro todas las categorias con las que ha habido "match"
			int j=0;
			for (Match *match in matchesSet)
            {
				// Pinto cada categoria del Set.
				NSLog (@"  > MATCH (%d/%lu): '%@' #%ld votes", j+1,
                       matchesSet.count, match.categoryMatched, match.votes);
				
				// Pinto las etiquetas que han producido el match.
				for (int k=0;(k<[match.tagsMatched count]);k++) {
					NSLog (@"    > %d - %@",k+1, [match.tagsMatched objectAtIndex:k]);
				}
				j++;
			}
            
			// Si hay mas de una categoria tenemos un conflicto.
			if ( matchesSet.count > 1 )
            {
				winner = [Match solveConflict:matchesSet :conflictsSet];
				if (winner == nil)
				{
					winner = [[Match alloc] init];
					NSString *allMatches = [[NSString alloc] init];
					for (Match *m in matchesSet) {
						allMatches = [allMatches stringByAppendingFormat:@"%@,", m.categoryMatched];
						for(int i=0;i<[m.tagsMatched count];i++) {
							[winner.tagsMatched addObject:[ m.tagsMatched objectAtIndex:i ]];
						}
					}
				}
			}
			// Si solo hay una, sacamos el elemento del set y ese es el winner.
			else if ( matchesSet.count == 1 )
            {
				NSEnumerator *e = [matchesSet objectEnumerator];
				winner = [e nextObject];
			}
		}
        
		// And the WINNER catgoy is...
		entry.matchingCategory = winner;
		if ( (matchesSet.count != 0) && (winner != nil) ) {
			[self updateCategoriesInDatabase:line fromEntry:entry managedObjectContext:moc];
		}
        NSLog(@">> \"%@\" CATEGORIZED AS %@", entry.concepto, entry.matchingCategory.categoryMatched );
		
	}
	
	return 0;
}

/**
 * Updates a DBEntry object with the contents of an updated Entry object, that reflects updated category matching.
 * @param dbEntry   The DBEntry object to updated.
 * @param entry     The Entry object with updated matched category.
 * @parammanagedObjectContext   The NSManagedObjectContext.
 * @return  (0) if the update operation when OK. (1) if an error ocurred
 *          during saving to MOC. (-1) if the category already existed.
 */
- (int) updateCategoriesInDatabase:(DBEntry *)dbEntry fromEntry:(Entry *)entry
			  managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	int returnCode=0;
	
	dbEntry.categoryMatched = entry.matchingCategory.categoryMatched;
	
	NSLog(@"(updateCategoriesInDatabase) ~~~> Entering the creation of the relationship: %@", entry.matchingCategory.categoryMatched);
	// create the entities (you could fetch these instead, if they already exist)
	DBCategory *dbcategory = [self findCategory:entry.matchingCategory.categoryMatched
						   managedObjectContext:managedObjectContext];
    
    if (dbcategory == nil) {
        NSLog(@"(updateCategoriesInDatabase) No categories found. Returning -1.");
        return -1;
    }
	
	// set the relationships
	NSLog(@"(updateCategoriesInDatabase) Setting Category to: %@", dbcategory.name);
	dbEntry.category = dbcategory;
	NSError *error;
	if (![managedObjectContext save:&error]) {
		NSLog(@"(updateCategoriesInDatabase) Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
	// Extract the array of tags into a concatenated string.
	NSString *tags = [[NSString alloc] init];
	for (int i=0;i<[ entry.matchingCategory.tagsMatched count ]; i++) {
		tags = [tags stringByAppendingFormat:@"%@;", [entry.matchingCategory.tagsMatched objectAtIndex:i] ];
	}
	dbEntry.tags = tags;
	
	if ([managedObjectContext save:nil] == NO) {
		NSLog(@"(updateCategoriesInDatabase) ** An error occurred while saving entry.");
		returnCode = 1;
	}
    NSLog(@"(updateCategoriesInDatabase)  ~~~> Leaving.");
	return returnCode;
}


#pragma mark Matching methods: preventing duplicates.


/*
 Runs a query with a basic predicate where "category" must match the
 argument passed. It returns the array with the elements.
 */
- (NSArray *)selectEntriesMatchingCategory:(NSString *)category :(NSManagedObjectContext *)moc
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DBEntry"
                                              inManagedObjectContext:moc];
	NSError *error;
	[fetchRequest setEntity:entity];
    NSPredicate *pr = [NSPredicate predicateWithFormat:@"(category == %@)", category];
	[fetchRequest setPredicate:pr];
    
	NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    NSLog(@"Re-categorization returned %ld elements", [fetchedObjects count]);
    
    
    return fetchedObjects;
}


/**
 This function searchs for entry logs matching the one trying to append to the DB
 to avoid inserting duplicating lines when importing.
 */
- (BOOL)matchesExistingEntry:(Entry *)line managedObjectContext:(NSManagedObjectContext *)moc
{
    NSDate *capturedDate = [self stringToNSDate:line.fechaOperacion];
	
    // Set up the object that connects to the entity in Core Data to perform the fetch
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"DBEntry" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
    // Form the predicate and send the request to the core data...
    // Be careful when comparing two floats, as they need to be converted to their float
    // values, instead of trying to use the NSNumber object directly.
    NSPredicate *pr = [NSPredicate predicateWithFormat:
					   @"(fechaOperacion == %@) AND (concepto LIKE[c] %@) AND (importe == %f)",
					   capturedDate, line.concepto, [line.importe floatValue] ];
	[request setPredicate:pr];
    NSLog(@"Predicate <%@> sent...", pr);
    
    // Checking if I can add a new line by comparing existing ones.
    NSLog(@"%@|%50@|%6@", [self dateWithNoTime:capturedDate], line.concepto, line.importe);
    NSLog(@"----------------------------------------------------------------------------");
    [self dumpDatabase:moc number:line.importe];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil) {
        NSLog(@"NIL Results Back. The line is unique");
        NSLog(@"%@", error);
        return NO;
    }
    if ([array count] == 0) {
        NSLog(@"ZERO Result. The line is unique");
        NSLog(@"%@", error);
        return NO;
    }
	
	// Now go throughout all the elements in the array to compare individual records.
	NSLog(@"Duplicate entry (%lu)!", [array count]);
	return YES;
}

/**
 This function searchs for entry logs matching the one trying to append to the DB
 */
- (BOOL)matchesExistingCategory:(NSString *)catName managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	// Form the predicate
	// Process every field that I've to.
	// Setup the string that will contain the query to the Core data.
	NSString *predicate;
	predicate = [NSString stringWithFormat:@"(name LIKE[c] '%@')",catName ];
	
	// Set up the object that connects to the entity in Core Data to perform the fetch
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"DBCategory"
											  inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	// I send the request to the core data...
	NSPredicate *pr = [NSPredicate predicateWithFormat:predicate];
	[request setPredicate:pr];
	
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	if ([array count] == 0)	{
		return NO;
	}
	
	NSLog(@"(matchesExistingCategory) -> Duplicate entry (%lu)!", [array count]);
	return YES;
}

/**
 * Searchs for entry logs matching the one trying to append to the DB.
 * @param   catName A String representing the category name to be found in the DB.
 * @param   managedObjectContext    The Managed Object Context where entities are created.
 * @return  The object matching the category name found, or NIL if none found.
 */
- (DBCategory *)findCategory:(NSString *)catName managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	// Form the predicate
	// Process every field that I've to.
	// Setup the string that will contain the query to the Core data.
	NSString *predicate;
	predicate = [NSString stringWithFormat:@"(name LIKE[c] '%@')",catName ];
	NSLog(@"(findCategory)   Search category predicate: <%@>", predicate);
	
	// Set up the object that connects to the entity in Core Data to perform the fetch
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"DBCategory"
											  inManagedObjectContext:managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	NSPredicate *pr = [NSPredicate predicateWithFormat:predicate];
	[request setPredicate:pr];
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	if ([array count] == 0)	{
		NSLog(@"(findCategory)   NO Results Back. The line is unique");
		return nil;
	}
	
	NSLog(@"(findCategory)   Found category!");
	return [array objectAtIndex:0];
}

/**
 This method searches for the earlier and later dates stored in the database
 */
- (NSArray *)findDatesInterval:(NSManagedObjectContext *)managedObjectContext
{
	// Set up the object that connects to the entity in Core Data to perform the fetch
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"DBEntry"
											  inManagedObjectContext:managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entityDescription];
	
	//[fetchRequest setPredicate:@"*"];
	// You can add sorting like this
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fechaOperacion" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([array count] == 0)
	{
		NSLog(@"NO Results Back. Failed Fetch!!");
		return nil;
	}
	DBEntry *oldest = [array objectAtIndex:0];
	DBEntry *newest = [array objectAtIndex:[array count]-1];
	NSLog(@"Retrieved %ld items\n1st one <%@>\nLast one <%@>", [array count],
		  oldest.fechaOperacion, newest.fechaOperacion);
    
	NSArray *fromAndToArray = [[NSArray alloc] initWithObjects:
							   oldest.fechaOperacion, newest.fechaOperacion, nil];
	return fromAndToArray;
}

/**
 Esta funciona deberá sumar para cada categoria, los importes totales y devolver el porcentaje
 que representan con el total.
 */
- (NSDictionary *) computeAggregatedCategories:(NSManagedObjectContext *)moc
                                       inArray:(NSArray *)selectedCategories
                                      fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSString *stringDate1;
	NSString *stringDate2;
	NSDate *fechaFrom;
	NSDate *fechaTo;
    
	NSLog(@"Entering computeAggregatedCategories");
	// Parameters needed to convert the dates..
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
	
	stringDate1 = [dateFormatter stringFromDate:fromDate];
	stringDate2 = [dateFormatter stringFromDate:toDate];
	
	fechaFrom = [dateFormatter dateFromString:stringDate1];
	fechaTo = [dateFormatter dateFromString:stringDate2];
	
	// Set up the object that connects to the entity in Core Data to perform the fetch
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"DBEntry"
											  inManagedObjectContext:moc];
	[request setEntity:entityDescription];
	NSLog(@"Context, MgdObj and Fetch request objects created.");
	
	// Form the predicate and send the request to the core data...
	NSPredicate *pr = [NSPredicate predicateWithFormat:
					   @"(fechaOperacion >= %@) AND (fechaOperacion <= %@)",fechaFrom, fechaTo];
	NSLog(@"Pr.......: <%@>", pr);
	[request setPredicate:pr];
	NSLog(@"Predicate sent...");
	
	/*
     Launch the fetch
	 */
	NSLog(@"  launching the fetch");
	NSError *error = nil;
	NSLog(@"    getting the array");
	NSArray *array = [moc executeFetchRequest:request error:&error];
	NSLog(@"    Checking results...");
	if (array == nil)
	{
		NSLog(@"NO Results Back. Failed Fetch!!");
		return nil;
	}
	NSLog(@"  %lu results obtained", [array count]);
    NSLog(@"  %lu categories selected", [selectedCategories count]);
	
	/*
     Build the dictionary
	 */
	NSLog(@"  building the dictionary");
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
	for (DBEntry *line in array) {
		if (line.category.name == nil) continue;
        
        // XXXXXXXXXXX
        // XXXXXXXXXXX
        // XXXXXXXXXXX
        // TODO Verify that this works.... probably NOT.!!!!!!!!!!!!!!!!
        // XXXXXXXXXXX
        // XXXXXXXXXXX
        // XXXXXXXXXXX
        BOOL entryCategoryWithinSelectedCategories = NO;
        for (int i=0;i<[selectedCategories count];i++) {
            NSString *selectedCategoryName = [[selectedCategories objectAtIndex:i] name];
            if ( [line.category.name caseInsensitiveCompare:selectedCategoryName] == NSOrderedSame ) {
                entryCategoryWithinSelectedCategories = YES;
                break;
            }
        }
        if (entryCategoryWithinSelectedCategories == NO) continue;
        
		// Original way of setting keys: only the name of the category.
        NSString *category = line.category.name;
		if ([dict valueForKey:category] == nil)
		{
			NSNumber *value = [Database abs:line.importe];
			//[dict setKey:category];
			[dict setObject:value forKey:category];
		}
		else
		{
			NSNumber *accumulated = [NSNumber numberWithFloat:
									 ([[Database abs:line.importe] floatValue] +
                                      [[dict valueForKey:category] floatValue])];
			[dict setValue:accumulated forKey:category];
		}
	}
	
	/*
     Showing the results.
	 */
	NSLog(@"  showing the dictionary");
	for (NSString *key in dict) {
		NSLog(@"%@ accumulates %@", key, [dict valueForKey:key]);
	}
	
	return dict;
}


+(NSNumber *)abs:(NSNumber *)input {
	return [NSNumber numberWithDouble:fabs([input doubleValue])];
}


#pragma mark DB Initialization and Tools


/**
 * This function stores in the "Categories" table the names of the categories, as set in the
 * default preferences. It is called only when the program is run for the first time.
 * @param categoryNames is the strings array with the names of the categories to be stored.
 * @param moc is the core data context to be used to link with the database.
 * @return 0 if everything went well, or a number ≠ 0, otherwise.
 */
- (int) storeCategoriesInDatabase:(NSArray *)categoryNames
			 managedObjectContext:(NSManagedObjectContext *)moc
{
    NSLog(@"(storeCategoriesInDatabase): Ready to store categories in DB.");
	int returnCode=0;
	for (NSString *catName in categoryNames)
	{
		if ( [self matchesExistingCategory:catName managedObjectContext:moc] == NO )
		{
			// Set up the object that connects to the entity in Core Data, and place it in an object.
			NSManagedObject *dbEntry = [NSEntityDescription insertNewObjectForEntityForName:@"DBCategory"
																	 inManagedObjectContext:moc];
			[dbEntry setValue:catName forKey:@"name"];
			if ([moc save:nil] == NO)
            {
				NSLog(@"(storeCategoriesInDatabase):   ERROR! An error occurred while saving entry.");
				returnCode = 1;
			} else {
                NSLog(@"(storeCategoriesInDatabase):   Category '%@' stored in DB.", catName);
            }
		}
	}
    NSLog(@"(storeCategoriesInDatabase):   Done! Returning %d", returnCode);
	return returnCode;
}

/**
 * Converts an "Entry" object into a DBEntry Core Data entity object.
 * @param   line Is the Entry object to convert.
 * @param   moc  Is the ManagedObjectContext from where extracting the DBEntry entity.
 * @return  A DBEntry object with the contents of the Entry object passed.
 */
- (NSManagedObject*) entryToDBEntry:(Entry*)line inManagedObjectContext:(NSManagedObjectContext*)moc
{
    // Set up the object that connects to the entity in Core Data, and place it in an object.
    NSManagedObject *dbEntry = [NSEntityDescription insertNewObjectForEntityForName:@"DBEntry"
                                                             inManagedObjectContext:moc];
    
    NSDate *date1 = [self stringToNSDate:line.fechaOperacion];
    NSDate *date2 = ([line.fechaValor length] == 0) ? date1 : [self stringToNSDate:line.fechaValor];
    [dbEntry setValue:date1 forKey:@"fechaOperacion"];
    [dbEntry setValue:date2 forKey:@"fechaValor"];
    [dbEntry setValue:line.concepto forKey:@"concepto"];
    [dbEntry setValue:line.importe forKey:@"importe"];
    [dbEntry setValue:line.saldo forKey:@"saldo"];
    
    return dbEntry;
}

/**
 * Converts a DBEntry object to Entry object.
 * @param   object    The DBEntry object to be converted to Entry format.
 * @return  A newly created Entry object with the exact field present in the DBEntry object passed.
 */
- (Entry *)dbEntryToEntry:(NSManagedObject *)object
{
	Entry *entry = [[Entry alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
	
	// The dates must be formatted into strings from NSDate formats.
	entry.fechaOperacion = [dateFormatter stringFromDate:[object valueForKey:@"fechaOperacion"]];
	entry.fechaValor = [dateFormatter stringFromDate:[object valueForKey:@"fechaValor"]];
	entry.concepto = [NSString stringWithString:[object valueForKey:@"concepto"]];
	entry.importe =	[NSNumber numberWithDouble:[[object valueForKey:@"importe"] doubleValue ]];
	entry.saldo = [NSNumber numberWithDouble:[[object valueForKey:@"saldo"] doubleValue ]];
	
	// Check whether categorization has been done
	if ( ([object valueForKey:@"categoryMatched"] != nil) )
    {
		entry.matchingCategory.categoryMatched = [NSString stringWithString:[object valueForKey:@"categoryMatched"]];
        NSString *tagsReturned = [NSString stringWithString:[object valueForKey:@"tags"]];
        [entry.matchingCategory.tagsMatched addObject:tagsReturned];
	}
	
	return entry;
}

/**
 * Convert a Managed Object Entry from the database into a simplified version
 * with only 3 fields: "fechaOPeracion", "concepto" and "importe".
 * 
 * @param object The object to be converted from Database Entry model format.
 * @return A "SimplifiedEntry" object.
 */
- (SimplifiedEntry *)dbEntryToSimplifiedEntry:(NSManagedObject *)object
{
	SimplifiedEntry *entry = [[SimplifiedEntry alloc] init];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd-MM-yyyy"];
	
	// The dates must be formatted into strings from NSDate formats.
	entry.fechaOperacion = [dateFormatter stringFromDate:[object valueForKey:@"fechaOperacion"]];
	
	entry.concepto = [NSString stringWithString:[object valueForKey:@"concepto"]];
	entry.importe =	[NSNumber numberWithDouble:[[object valueForKey:@"importe"] doubleValue ]];
	
	return entry;
}

/**
 Convert a String into a NSDate field, appropiate for being
 stored into Core Data.
 */
- (NSDate *) stringToNSDate:(NSString *)string
{
    // Parameters needed to convert the dates..
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // We've different possibilities for the date format.
    if ( [string length] > 9)
    {
        NSRange range = [string rangeOfString:@"-"];
        if (range.location != NSNotFound)
        {
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        } else {
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        }

    } else {
        [dateFormatter setDateFormat:@"dd/MM/yy"];
    }
    
    NSDate *date = [self dateWithNoTime:[dateFormatter dateFromString:string]];
	return date;
}

- (NSDate *) dateWithNoTime:(NSDate *)date
{
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:date];
    NSDate* dateOnly = [calendar dateFromComponents:components];
    return dateOnly;
}


- (void) dumpDatabase:(NSManagedObjectContext *)moc number:(NSNumber *)importe
{
    NSArray *array = [self loadTableToArray:moc];
    if (array == nil) {
        NSLog(@"NO Results Back. Failed Fetch!!");
        return;
    }
    for (DBEntry *record in array) {
        NSLog(@"%@|%30@|%6@ [%d]", [self dateWithNoTime:record.fechaOperacion], record.concepto, record.importe,
              [record.importe floatValue] == [importe floatValue]);
    }
}

- (void) printDBEntry:(DBEntry *)record
{
    NSLog(@"DBEntry:");
    NSLog(@"%@|%30@|%6@", [self dateWithNoTime:record.fechaOperacion], record.concepto, record.importe);
    NSLog(@"  > %@", record.category.name);
}


/**
 U N U S E D
 */
- (int) storeEntryInDatabase:(Entry *)entry managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	int rc=0;
	
	// Set up the object that connects to the entity in Core Data, and place it in an object.
	NSManagedObject *dbEntry = [NSEntityDescription insertNewObjectForEntityForName:@"DBEntry"
															 inManagedObjectContext:managedObjectContext];
	[dbEntry setValue:entry.fechaOperacion forKey:@"fechaOperacion"];
	[dbEntry setValue:entry.fechaValor forKey:@"fechaValor"];
	[dbEntry setValue:entry.concepto forKey:@"concepto"];
	[dbEntry setValue:entry.importe forKey:@"importe"];
	[dbEntry setValue:entry.saldo forKey:@"saldo"];
	
	[dbEntry setValue:entry.matchingCategory.categoryMatched forKey:@"categoryMatched"];
	
	// Extract the array of tags into a concatenated string.
	NSString *tags = [[NSString alloc] init];
	for (int i=0;i<[ entry.matchingCategory.tagsMatched count ]; i++) {
		tags = [tags stringByAppendingFormat:@"%@,", [entry.matchingCategory.tagsMatched objectAtIndex:i] ];
	}
	[dbEntry setValue:tags forKey:@"tags"];
	
	// Save the entry.
	if ([managedObjectContext save:nil] == NO) {
		NSLog(@"** An error occurred while saving entry.");
		rc = 1;
	}
	return rc;
}

@end
