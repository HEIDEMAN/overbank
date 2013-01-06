//
//  FileMgr.h
//  FileExample
//
//  Created by Jesus Renero Quintero on 11/12/10.
//  Copyright 2010 Telefonica I+D. All rights reserved.
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

@property (retain) NSFileManager *myFileManager;
@property (retain) NSString *cwd;

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
