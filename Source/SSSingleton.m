#import "SSSingleton.h"
#import "SSAssert.h"

@implementation SSSingleton
static NSMutableDictionary *gEntries = nil;

#pragma mark - Creation -
+ (void)initialize
{
    static dispatch_once_t initToken;
    dispatch_once(&initToken,
    ^{
        gEntries = [NSMutableDictionary new];
    });
}

+ (id)sharedInstance
{
    return [self sharedInstanceForClass: self];
}

+ (id)sharedInstanceForClass: (Class)cls
{
    id result = nil;
    
    @synchronized(gEntries)
    {
        result = gEntries[cls];
        
        if (!result)
        {
            result = [[cls alloc] initSingleton];
            
            if (result)
                gEntries[(id)cls] = result;
        }
    }
    
    return result;
}

- (id)init
{
    /* Here we'll simply return the object that would have been supplied if the caller invoked [ReceiverClass sharedInstance]. */
        /* Verify that -init hasn't been overridden by a subclass (SSSingleton subclasses must use -initSingleton.) */
        SSAssertOrRaise([SSSingleton instanceMethodForSelector: @selector(init)] == [[self class] instanceMethodForSelector: @selector(init)]);
    
    return [[self class] sharedInstance];
}

- (id)initSingleton
{
    if (!(self = [super init]))
        return nil;
    
    return self;
}

@end