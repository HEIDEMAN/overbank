//
//  CSVParser.h
//  CSVImporter
//
//  This is a modified version of the original CSVImporter by Matt Gallagher.
//
//  Created by Matt Gallagher on 2009/11/30.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

#import <Cocoa/Cocoa.h>

#define MAX_RETRIES 12  // This is the maximum number of header entries in BANESTO

#define UNKNOWN_TYPE_STRING 0
#define DATE_TYPE_STRING    1
#define NUMBER_TYPE_STRING  2
#define TEXT_TYPE_STRING    3

@interface CSVParser : NSObject
{
	NSString *csvString;
	NSString *separator;
	NSScanner *scanner;
	BOOL hasHeader;
	NSMutableArray *fieldNames;
	id receiver;
	SEL receiverSelector;
	NSCharacterSet *endTextCharacterSet;
	BOOL separatorIsSingleChar;
    // Need this.
    NSMutableArray *fieldTypes;
    int indexDate;
    int indexConcept;
    int indexAmount;
}

@property (nonatomic, strong) NSMutableArray *fieldNames;
@property (nonatomic) int indexDate;
@property (nonatomic) int indexConcept;
@property (nonatomic) int indexAmount;

- (id)initWithFilePath:(NSString *)inputPath
             separator:(NSString *)aSeparatorString
             hasHeader:(BOOL)header
            fieldNames:(NSArray *)names;
- (id)initWithString:(NSString *)aCSVString
    separator:(NSString *)aSeparatorString
    hasHeader:(BOOL)header
    fieldNames:(NSArray *)names;

- (NSArray *)arrayOfParsedRows;
- (void)parseRowsForReceiver:(id)aReceiver selector:(SEL)aSelector;
- (NSArray *)parseRows;

- (NSArray *)parseFile;
- (NSMutableArray *)parseHeader;
- (NSMutableArray *)parseHeaderWithRetries;
- (NSDictionary *)parseRecord;
- (NSString *)parseName;
- (NSString *)parseField;
- (NSString *)parseEscaped;
- (NSString *)parseNonEscaped;
- (NSString *)parseDoubleQuote;
- (NSString *)parseSeparator;
- (NSString *)parseLineSeparator;
- (NSString *)parseTwoDoubleQuotes;
- (NSString *)parseTextData;

- (BOOL)validHeader:(NSMutableArray *)names;

- (int)typeOfString:(NSString *)string;

- (int)guessFieldTypes:(NSArray *)records;
- (int)guessIndexForFieldTypes:(NSArray *)fieldTypes;
- (int)guessIndexForFieldType:(int)fieldType;


@end
