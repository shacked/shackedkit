#import <Foundation/Foundation.h>

@interface SSSingleton : NSObject
/* +sharedInstanceForClass: is provided to allow non-SSSingleton-derived classes to implement singleton-like behavior. */
+ (id)sharedInstance;
+ (id)sharedInstanceForClass: (Class)cls;

/* ### SSSingleton subclasses must not override -init! You should override -initSingleton instead.
   Implement your -initSingleton the same as you would implement -init (e.g., by
   calling self = [super initSingleton] and returning self.) */
- (id)initSingleton;
@end