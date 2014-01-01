//
//  DBCategory.h
//  ovb3
//
//  Created by renero on 19/1/2012.
//  Copyright 2012 Telefonica I+D. All rights reserved.
//

#import <CoreData/CoreData.h>

@class DBEntry;

@interface DBCategory :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet* entries;

@end


@interface DBCategory (CoreDataGeneratedAccessors)
- (void)addEntriesObject:(DBEntry *)value;
- (void)removeEntriesObject:(DBEntry *)value;
- (void)addEntries:(NSSet *)value;
- (void)removeEntries:(NSSet *)value;

- (id)initInMOC:(NSManagedObjectContext*)context;

@end

