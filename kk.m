- (int)fastImportLog:(NSMutableArray *)log managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    BOOL errorOcurred=FALSE;
    NSArray *array = [self loadTableToArray:managedObjectContext];
    
    NSHashTable *dbHashTable = [[NSHashTable alloc]init];
    for (DBEntry *record in array) {
        [dbHashTable addObject:[self dbEntryToSimplifiedEntry:record]];
    }
    NSHashTable *memHashTable = [[NSHashTable alloc]init];
    
	for (Entry *line in log) {
		// Do not consider empty entries. Use a simpified version of the Line Entry to perform comparisons.
		if ( [[line fechaOperacion] length] == 0) continue;
        SimplifiedEntry *sline = [line simplified];
        // Skip also lines that are already in the table to avoid duplicates.
        if ( [dbHashTable containsObject:sline] ) {
            //if ( [self arrayContainsEntry:array Entry:line] ) {
            NSLog(@"Duplicate entry (%@|%@|%f)",
                  sline.fechaOperacion, sline.concepto, [sline.importe floatValue]);
            SimplifiedEntry *e = [dbHashTable member:sline];
            continue;
        }
        BOOL doNotInsertFlag = FALSE;
        
        // Now I must search this entry within the previous entries of the array to avoid inserting duplicates. O(1)
        if ( [memHashTable containsObject:sline] ) {
            NSLog(@"Duplicate entry (%@|%@|%f), already inserted. Skipping.",
                  sline.fechaOperacion, sline.concepto, [sline.importe floatValue]);
            SimplifiedEntry *e = [memHashTable member:sline];
            doNotInsertFlag = TRUE;
        }
        if (doNotInsertFlag) continue;
        
        // Create the MOC that will hold the entry.
        NSManagedObject *entry = [self entryToDBEntry:line
                               inManagedObjectContext:managedObjectContext];
        if (entry == nil) {
            NSLog(@"  ERROR: Unable to save the entry to database.");
            errorOcurred = TRUE;
            break;
        }
        
        // Insert the line into the DB if previous controls are OK.
        if ([managedObjectContext save:nil] == NO) {
			NSLog(@"  ERROR: An error occurred while saving entry.");
			errorOcurred = TRUE;
		}
        
        // Add this entry to the memTable to perform further comparisons against entries already inserted.
        [memHashTable addObject:sline];
    }
    return errorOcurred;
}