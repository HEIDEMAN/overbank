//
//  simplifiedEntry.h
//  overbank
//
//  Created by Jesus Renero on 03/05/13.
//
//

#import <Foundation/Foundation.h>

@interface simplifiedEntry : NSObject {
    NSString *fechaOperacion;
    NSString *concepto;
    NSNumber *importe;
}

@property (nonatomic,retain) NSString* fechaOperacion;
@property (nonatomic,retain) NSString* concepto;
@property (nonatomic,retain) NSNumber* importe;

- (void) printSimplifiedEntry;

@end
