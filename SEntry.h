//
//  simplifiedEntry.h
//  overbank
//
//  Created by Jesus Renero on 03/05/13.
//
//

#import <Foundation/Foundation.h>

@interface SimplifiedEntry : NSObject {
    NSString *fechaOperacion;
    NSString *concepto;
    NSNumber *importe;
}

@property (nonatomic,strong) NSString* fechaOperacion;
@property (nonatomic,strong) NSString* concepto;
@property (nonatomic,strong) NSNumber* importe;

- (void) printSimplifiedEntry;

@end
