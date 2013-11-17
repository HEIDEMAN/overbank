//
//  FileMgr.h
//  FileExample
//
//  Created by Jesus Renero Quintero on 11/12/10.
//  Copyright 2013 Jesus Renero Quintero. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Entry.h"

@interface FileMgr : NSObject 
{
	NSFileManager *myFileManager;
	NSString *path;
	NSString *cwd;
	
	uint numLine;
	
	NSUInteger bufferPosition,parserStateMachineStatus;
}

@property (strong) NSFileManager *myFileManager;
@property (strong) NSString *cwd;

- (id)init;
- (BOOL)fileExists:(NSString *)whichPath;
- (NSString *)suckData;
+ (NSString *)beautify:(NSString *)input flag:(BOOL)verbose;
- (Entry *)getNextEntry:(NSString *)buffer;
+ (void)printASCIITable;
+ (BOOL)isValidCharacter:(unichar)c;
+ (NSNumber *)stringToNumber:(NSString *)tempStr;
- (uint) getNumLines;


@end
