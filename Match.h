//
//  Match.h
//  Banking
//
//  Created by Jesus Renero Quintero on 16/7/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
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

@property (nonatomic,strong) NSString *categoryMatched;
@property (nonatomic,strong) NSMutableArray *tagsMatched;
@property (nonatomic) NSInteger votes;

+(Match *)solveConflict:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictSet;
+(Match *)solveConflictWithUserAction:(NSMutableSet *)matchesSet
                                     :(NSMutableSet *)conflictSet
                                     :(NSString *)userSelectedCategory;
+(Match *)getWinnerCategory:(NSMutableSet *)matchesSet;
+(Match *)getConflictResolved:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictsSet;
+(Match *)markWinnerCategory:(NSMutableSet *)set :(NSString *)userSelectedCategory;
+(int)markWinnerCategoryInConflict:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictSet :(NSString *)userSelectedCategory;
+(Match *)getWinnerCategoryInConflict:(NSMutableSet *)set;
+(NSComparisonResult) compareTwoSets:(NSMutableSet *)setA :(NSMutableSet *)setB :(BOOL)goDeepToCompareTags;
+(BOOL) compareTagsOfTwoMatches:(Match *)matchA :(Match *)matchB;
+(BOOL) addConflict:(NSMutableSet *)conflictSet newConflict:(NSMutableSet *)matchesSet;

+(void)listSet:(NSMutableSet *)set :(NSString *)name;
+(void)listConflictSet:(NSMutableSet *)set;

+(void)sayHello;

@end
