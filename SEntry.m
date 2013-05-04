//
//  simplifiedEntry.m
//  overbank
//
//  Created by Jesus Renero on 03/05/13.
//
//

#import "SimplifiedEntry.h"

@implementation SimplifiedEntry
@synthesize fechaOperacion, concepto, importe;

- (id)init {
	self = [super init];
	if (self != nil) {
		fechaOperacion = [[NSString alloc] init];
		concepto = [[NSString alloc] init];
		importe = [[NSNumber alloc] init];
	}
	return self;
}

//
// isEqual
//
// Had to subclass this method (overwrite it) to compute equiality by direct comparison
// of internal values of the "simplifiedEntry".
//
// return TRUE if both objects are identical.
//
- (BOOL)isEqual:(SimplifiedEntry *)other
{
    if (other == self) {
        return YES;
    }
//    if (![super isEqual:other]) {
//        NSLog(@"BOTH OBJECTS DIFFER FROM SUPER CLASS");
//        return NO;
//    }
    BOOL result1 = [[self concepto] isEqualToString:[other concepto]];
    //NSLog(@">>>> CONCEPT match? %d", result1);
    BOOL result2 = [[self fechaOperacion] isEqualToString:[other fechaOperacion]];
    //NSLog(@">>>> FECHA match? %d", result2);
    BOOL result3 = [[self importe]floatValue] == [[other importe] floatValue];
    //NSLog(@">>>> IMPORTE match? %d [%lf =? %lf]", result3, [[self importe] floatValue], [[other importe]floatValue]);
    return result1 & result2 & result3;
}

//
// hash
//
// http://stackoverflow.com/questions/254281/best-practices-for-overriding-isequal-and-hash
// http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
// http://java.sun.com/developer/Books/effectivejava/Chapter3.pdf
//
- (NSUInteger)hash
{
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    // Add any object that already has a hash function (NSString)
    result = prime * result + [self.fechaOperacion hash];
    result = prime * result + [self.concepto hash];
    
    // Add primitive variables (int)
    result = prime * result + (int)[self.importe integerValue];
    
    return result;
}

- (void)printSimplifiedEntry
{
    printf("%-20ld|%s|%-40s|%-8.1f\n",
           (unsigned long)[self hash],
           [fechaOperacion UTF8String],
           [concepto UTF8String],
           [importe floatValue]);
}


@end
