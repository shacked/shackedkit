#import <Foundation/Foundation.h>

@interface SSSingleton : NSObject
/* ### SSSingleton subclasses must not override -init! Instead, you should override -initSingleton to perform initialization. */
/* +sharedInstanceForClass: is provided to allow non-SSSingleton-derived classes to implement singleton-like behavior. */
+ (instancetype)sharedInstance;
+ (instancetype)sharedInstanceForClass: (Class)cls;
- (void)initSingleton;
@end