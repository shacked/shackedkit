#import <Foundation/Foundation.h>

@interface SSObservation : NSObject

+ (SSObservation *)observeObject: (NSObject *)observee keyPath: (NSString *)keyPath
    options: (NSKeyValueObservingOptions)options handlerBlock: (void (^)(SSObservation *observation, NSDictionary *change))handlerBlock;

- (void)invalidate;

@end