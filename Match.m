//
//  Match.m
//  Banking
//
//  Created by Jesus Renero Quintero on 16/7/11.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import "Match.h"
#import "Prefs.h"

@implementation Match
@synthesize categoryMatched, tagsMatched, votes;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.tagsMatched = [[NSMutableArray alloc] init];
		votes = 0;
	}
	return self;
}	

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:categoryMatched];
    [encoder encodeObject:tagsMatched];
	[encoder encodeValueOfObjCType:@encode(int) at:&votes];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if (self=[super init]) {
		[self setCategoryMatched:[coder decodeObject]];
		[self setTagsMatched:[coder decodeObject]];
		[coder decodeValueOfObjCType:@encode(int) at:&votes];
	}
	return self;
}

/*
 Cuando se detecta un conflicto, se llama a esta funcion, y aqui es donde 
 se resuelve.
 */
+(Match *)solveConflict:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictSet
{
	Match *winner = [Match getWinnerCategory:matchesSet];
	if ( winner == nil )
	{
		NSLog (@"  CONFLICT: Multiple categorizations possible");
		
		// Ahora he detectado un conflicto. Lo que tengo que hacer 
		// es comprobar que no haya otro igual almacenado, en cuyo 
		// caso es posible resolverlo, para guardarlo y preguntar al 
		// usuario como solucionarlo.
		if ( (winner = [Match getConflictResolved:matchesSet :conflictSet]) != nil )
		{
			NSLog (@"    Solved: %@", winner.categoryMatched);
		}
		else
		{
			/*
			int catNum;
			printf("\nWhat should be the right category? ");
			scanf ("%d", &catNum);
			
			winner = [Match markWinnerCategory:matchesSet :catNum];
			*/
            
			// Tengo que marcar la categoria ganadora con un voto más que el resto...
			// Añado el conflicto si no existe ya...
			[self addConflict:conflictSet newConflict:matchesSet];
            
			//[conflictSet addObject:matchesSet];
			/*
			NSLog (@"   Resolved");
			 */
		}
	} 
	else 
	{
		NSLog (@" Winner: %@", winner.categoryMatched);
	}
	
	return winner;
}


+ (Match *)solveConflictWithUserAction:(NSMutableSet *)matchesSet
                                      :(NSMutableSet *)conflictSet
                                      :(NSString *)userSelectedCategory
{
	Match *winner = [Match getWinnerCategory:matchesSet];
	if ( winner == nil )
	{
		NSLog (@"  CONFLICT: Multiple categorizations possible");
		
		// Ahora he detectado un conflicto. Lo que tengo que hacer
		// es comprobar que no haya otro igual almacenado, en cuyo
		// caso es posible resolverlo, para guardarlo y preguntar al
		// usuario como solucionarlo.
		if ( (winner = [Match getConflictResolved:matchesSet :conflictSet]) != nil )
		{
			NSLog (@"    Solved: %@", winner.categoryMatched);
		}
		else
		{
            // A winner is marked with one additional vote, from the user selection.
            winner = [Match markWinnerCategory:matchesSet :userSelectedCategory];
            [self addConflict:conflictSet newConflict:matchesSet];
		}
	}
	else
	{
		NSLog (@" Winner: %@", winner.categoryMatched);
	}
	
	return winner;
}


/*
 Una funcion que entre todas las categorias que han hecho match
 busca la que tenga más tags de todas y esa es la que devuelve.
 Si hay empate, devuelve 'nil'.
 */
+(Match *)getWinnerCategory:(NSMutableSet *)matchesSet
{
	Match *element, *winner=nil;
	BOOL tie = FALSE;
	int maxTags = -1;
    int maxVotes = -1;
	
	for (element in matchesSet)
	{
		int numTagsMatched = [element.tagsMatched count];
		if ( numTagsMatched >= maxTags ) 
		{
			if ((winner == nil) || (numTagsMatched > maxTags)) 
			{
				//NSLog(@"      $ Setting winner (%@) with %d tags.",element.categoryMatched,numTagsMatched);
				winner = element;
				maxTags = numTagsMatched;
                maxVotes = element.votes;
				tie = FALSE;
			} 
			else if (numTagsMatched == maxTags)
			{
                //NSLog (@"      $ Setting tie as numTags (%d) == maxTags (%d)", numTagsMatched, maxTags);
                tie = TRUE;
			}
		}
	}
	if (tie == FALSE) {
		//NSLog(@"      $ Returning Winner %@", winner.categoryMatched);
		return winner;
	} 
	else {
		//NSLog(@"      $ Returning NIL");
		return nil;
	}
}

/*
 Esta funcion recibe los conflictos detectados hasta ahora y 
 uno nuevo, para buscar entre ellos alguno que sea igual y ya 
 este resuelto.
 */
+(Match *)getConflictResolved:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictsSet
{
	Match *winner=nil;
	BOOL solved = false;
	
	//[self listSet:matchesSet :@"conflict"];
	
	// Recorro todos los conflictos.
	for (NSMutableSet *conflict in conflictsSet)
	{
		//[self listSet:conflict :@"conflict stored  "];
		BOOL allesOK = TRUE;
		
		// Si el numero de elementos en el set no es el mismo que en el del conflicto,
		// descartamos este conflicto.
		if ( [conflict count] != [matchesSet count] ) {
			allesOK = NO;
			continue;
		}
		
		// Compruebo si los dos sets son iguales - igual conjunto de categorias dentro.
		allesOK = ([self compareTwoSets:matchesSet :conflict :NO] == NSOrderedSame);
		
		// Si tienen el mismo numero de categorias, ahora toca comprobar que tengan los 
		// mismos tags dentro los dos sets.
		if (allesOK == YES) 
		{
			allesOK = ([self compareTwoSets:matchesSet :conflict :YES] == NSOrderedSame);
			/*
			if (!allesOK) {
				NSLog (@"    Both sets are equal BUT tags are NOT the same.. :-(");
			}
			else {
				NSLog (@"    Both sets are IDENTICAL. Good!");
			}
			 */
		}
		
		// Comprobacion final: si todas las comparaciones han ido OK, este flag estará a TRUE.
		if (allesOK == YES) { 
			solved = YES;
			winner = [self getWinnerCategoryInConflict:conflict];
			//NSLog (@"     It seems that we have a winner...");
			break;
		}
	}
	
	if (solved) {
		return winner;
	} else {
		return nil;
	}	
}


/* 
 Para cada coincidencia del conflicto que ha aparecido, busco entre los que 
 tengo almacenados, uno que sea igual.
 */
+(NSComparisonResult) compareTwoSets:(NSMutableSet *)setA :(NSMutableSet *)setB :(BOOL)goDeepToCompareTags
{
	BOOL flag=YES;
	for(Match *matchA in setA) 
	{
		BOOL doTheyMatch = NO;
		for(Match *matchB in setB) 
		{
			NSComparisonResult result = [matchA.categoryMatched caseInsensitiveCompare:matchB.categoryMatched];
			doTheyMatch = (result == NSOrderedSame);
			
			// Do these two categories match?
			if (doTheyMatch) 
			{
				// Do I compare the two tags sets from this match?
				if (goDeepToCompareTags) 
				{
					doTheyMatch &= [self compareTagsOfTwoMatches:matchA :matchB];
				}
				break;
			}
		}
		
		flag &= doTheyMatch;
		
		if (doTheyMatch == NO)
			break;
	}
	
    if (flag == YES)
        return NSOrderedSame;
    else
        return NSOrderedDescending;
}

/*
 Esta funcion compara los tags de dos Matches para ver si coinciden.
 */
+(BOOL) compareTagsOfTwoMatches:(Match *)matchA :(Match *)matchB
{
	NSString *tagA, *tagB;
	BOOL flag = YES;
	
	if ( [matchA.tagsMatched count] != [matchB.tagsMatched count] )
		return NO;
	
	for ( tagA in matchA.tagsMatched )
	{
		BOOL doTheyMatch = NO;
		for ( tagB in matchB.tagsMatched ) {
			NSComparisonResult result = [tagA caseInsensitiveCompare:tagB];
			doTheyMatch = (result == NSOrderedSame);
			if (doTheyMatch)
				break;
		}
		flag &= doTheyMatch;
		if (doTheyMatch == NO)
			break;		
	}
	return flag;
}


+(BOOL) addConflict:(NSMutableSet *)conflictSet newConflict:(NSMutableSet *)matchesSet
{
	BOOL doesNotExist = YES;
	NSMutableSet *set;
	for (set in conflictSet) {
		if ([self compareTwoSets:set :matchesSet :YES] == NSOrderedSame)
			doesNotExist = NO;
	}
	if (doesNotExist) {
		NSLog(@"    Conflict added.");
		[conflictSet addObject:matchesSet];
	} else {
		NSLog(@"    NOT Adding the conflict.");
	}
	return doesNotExist;
}

/*
 Esta funcion marca una de las categorias de un Match como ganadora de un conflicto.
 */
+(Match *)markWinnerCategory:(NSMutableSet *)set :(NSString *)userSelectedCategory
{
	int i=0;
	BOOL found = NO;
	Match *m;
	for (m in set) {
		i++;
		if ([m.categoryMatched caseInsensitiveCompare:userSelectedCategory] == NSOrderedSame) {
			NSLog(@"  Setting Winner category for %@", m.categoryMatched);
			m.votes++;
			found = YES;
			break;
		}
	}
	if (found) {
		return m;
	}
    NSLog(@"  Ops! Couldn't mark winner category!");
	return nil;
}

// Loop through the sets in conflictSet to find which one
// is the one which represents the match and then mark it
// with the winning category.
+(int)markWinnerCategoryInConflict:(NSMutableSet *)matchesSet :(NSMutableSet *)conflictSet :(NSString *)userSelectedCategory
{
	BOOL doesExist = NO;
    NSMutableSet *set;
    
    for (set in conflictSet) {
        if ([self compareTwoSets:set :matchesSet :YES] == NSOrderedSame) {
            doesExist = YES;
            break;
        }
    }
    
	if (doesExist == NO) {
        NSLog(@"Impossible to mark conflict.");
        return 1;
    } else {
        [self markWinnerCategory:set :userSelectedCategory];
	}
    return 0;
}

/*
 Esta funcion me busca cual es la categoria ganadora de un set de conflictos,
 atendiendo unicamente al numero de votos. A esta funcion se le debe pasar un 
 set de conflictos que ya incluya las categorias candidatas al match. Es decir,
 NO se tienen en cuenta los tags... porque ya se han tenido en cuenta antes pero
 han salido varias categorias candidatas y ha habido un _conflicto_
 */
+(Match *)getWinnerCategoryInConflict:(NSMutableSet *)set
{
	//int maxVotes = -1;
	int maxVotes = 0;
	Match *winner = nil;
	for(Match *match in set) {
		if (match.votes > maxVotes) {
			winner = match;
			maxVotes = match.votes;
		}
	}
	return winner;
}


+(void)listSet:(NSMutableSet *)set :(NSString *)name
{	
	printf("Listing set %s\n  ", [name cStringUsingEncoding:NSUTF8StringEncoding]);		
	for (Match *element in set)	
	{
		printf("'%s' ", [element.categoryMatched cStringUsingEncoding:NSUTF8StringEncoding] );
	}
	printf("\n");
}

+(void)listConflictSet:(NSMutableSet *)set
{
	NSLog(@"-------------------------");
    NSLog(@"Listing Conflicts Set");
    
	if ( [set count] == 0) {
		NSLog(@"WARNING: Empty dictionary");
		return;
	}
	
	NSMutableSet *subset;
	int i=0;
	NSLog(@"Found %04lu conflict sets.", [set count] );
	NSLog(@"-------------------------");
	for ( subset in set ) {
		NSLog(@"Conflict-set-%d", i++);
		for (Match *element in subset) {
			NSLog(@"  -> %@ [%ld]", element.categoryMatched, element.votes );
			for (NSString *tag in element.tagsMatched) {
				NSLog(@"     - %@",tag);
			}
		}
	}
}

+(void)sayHello
{
    NSLog(@"Hi from Matching function.");
}


@end
