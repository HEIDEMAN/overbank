//
//  Match.h
//  Banking
//
//  Created by Jesus Renero Quintero on 16/7/11.
//  Copyright 2011 Jesus Renero. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Match : NSObject <NSCoding>
{
	NSString *categoryMatched;
	NSMutableArray *tagsMatched;
	NSInteger votes;
}

-(void)encodeWithCoder:(NSCoder *)encoder;
-(id)initWithCoder:(NSCoder *)coder;

@property (nonatomic,retain) NSString *categoryMatched;
@property (nonatomic,retain) NSMutableArray *tagsMatched;
@property (nonatomic) NSInteger votes;

+(Match *)solveConflict:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictSet;
+(Match *)getWinnerCategory:(NSMutableSet *)matchesSet;
+(Match *)getConflictResolved:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictsSet;
+(Match *)markWinnerCategory:(NSMutableSet *)set :(int)numCat;
+(Match *)getWinnerCategoryInConflict:(NSMutableSet *)set;
+(BOOL) compareTwoSets:(NSMutableSet *)setA :(NSMutableSet *)setB :(BOOL)goDeepToCompareTags;
+(BOOL) compareTagsOfTwoMatches:(Match *)matchA :(Match *)matchB;
+(BOOL) addConflict:(NSMutableSet *)conflictSet newConflict:(NSMutableSet *)matchesSet;

+(void)listSet:(NSMutableSet *)set :(NSString *)name;
+(void)listConflictSet:(NSMutableSet *)set;

@end
