//
//  Prefs.h
//  NSUserDefaults
//
//  Created by Jesus Renero Quintero on 27/2/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void LogIt (NSString *format, ...);

@interface Prefs : NSObject {
	NSUserDefaults *prefs;
	NSMutableDictionary *diccionario;
}

@property (nonatomic,strong) NSUserDefaults *prefs;

-(int) syncPrefs;
-(int) readPrefs;
-(int) defaultPrefs;

-(int) storeInPrefs:(NSMutableSet *)conflictsSet;
-(NSMutableSet *)readFromPrefs;

-(int) searchCategory:(NSString *)category;
-(int) createCategory:(NSString *)newCategory;
-(int) addTagToCategory:(NSString *)newTag :(NSString *)targetCategory;
-(int) removeCategory:(NSString *)category;
-(int) removeTag:(NSString *)tag :(NSString*)category;
-(int) renameTag:(NSString *)tag :(NSString*)category :(NSString *)newTag;
-(int) renameCategory:(NSString *)oldCategory :(NSString *)newCategory;
-(int) searchTag:(NSString *)tag;
-(NSMutableSet *) matchTag:(NSString *)inputString;
-(NSArray *) matchTag_old:(NSString *)inputString;

-(void) listCategories;
-(NSMutableArray *) getCategoryNames;

// Methods to fulfill the NSTableProtocol, exposed and used from prefsViewController
-(int) numCategories;
-(id) categoryAtRow:(NSInteger)rowIndex;
-(id) tagsAtRow:(NSInteger)rowIndex;

@end