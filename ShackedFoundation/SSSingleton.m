#import "SSSingleton.h"
#import "SSAssert.h"
#import "SSUtilities.h"

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
    @synchronized(gEntries)
    {
        id result = [gEntries objectForKey: (id)cls];
        
        if (!result)
        {
            result = [[cls alloc] initWithCallToSuper: YES];
                SSAssertOrRecover(result, return nil);
            
            /* We set the entry in our map *before* we callout to -initSingleton, so that attempts to acquired the shared
               instance of 'cls' within -initSingleton return a value. */
            [gEntries setObject: result forKey: (id)cls];
            [result initSingleton];
        }
        
        return result;
    }
}

- (id)init
{
        /* Verify that -init hasn't been overridden by a subclass (SSSingleton subclasses must use -initSingleton.) */
        SSAssertOrBail([SSSingleton instanceMethodForSelector: @selector(init)] == [[self class] instanceMethodForSelector: @selector(init)]);
    
    return [self initWithCallToSuper: NO];
}

- (id)initWithCallToSuper: (BOOL)callToSuper
{
    if (callToSuper)
        return [super init];
    
    else
        return [[self class] sharedInstance];
}

- (void)initSingleton
{
}

@end