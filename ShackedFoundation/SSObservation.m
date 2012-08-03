#if __has_feature(objc_arc)
#error ARC required to be disabled (-fno-objc-arc)
#endif

#import "SSObservation.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

static dispatch_semaphore_t gEntriesLock = nil;
static CFMutableDictionaryRef gEntries = nil;

@implementation SSObservation
{
    @public
    int32_t mInvalidated;
    NSObject *mObservee;
    NSString *mKeyPath;
    NSKeyValueObservingOptions mOptions;
    void (^mHandlerBlock)(SSObservation *observation, NSDictionary *change);
}

#pragma mark - Creation -
+ (void)initialize
{
    static dispatch_once_t initToken = 0;
    dispatch_once(&initToken,
    ^{
        /* Maps observee (NSObject) -> keyPaths (NSString) -> observations (CFSet) */
        gEntriesLock = dispatch_semaphore_create(1);
        gEntries = CFDictionaryCreateMutable(nil, 0, nil, &kCFTypeDictionaryValueCallBacks);
    });
}

+ (SSObservation *)observeObject: (NSObject *)observee keyPath: (NSString *)keyPath
    options: (NSKeyValueObservingOptions)options handlerBlock: (void (^)(SSObservation *observation, NSDictionary *change))handlerBlock
{
    return [[[SSObservation alloc] initWithObservee: observee keyPath: keyPath options: options handlerBlock: handlerBlock] autorelease];
}

- (id)initWithObservee: (NSObject *)observee keyPath: (NSString *)keyPath options: (NSKeyValueObservingOptions)options
    handlerBlock: (void (^)(SSObservation *observation, NSDictionary *change))handlerBlock
{
        NSParameterAssert(observee);
        NSParameterAssert(keyPath && [keyPath length]);
        NSParameterAssert(handlerBlock);
    
    if (!(self = [super init]))
        return nil;
    
    mInvalidated = NO;
    mObservee = observee; /* Weak reference to observee! */
    mKeyPath = [keyPath retain];
    mHandlerBlock = [handlerBlock copy];
    mOptions = options;
    [[self class] addObservation: self];
    
    return self;
}

- (void)invalidate
{
    [self invalidateAcquireLock: YES];
}

- (void)invalidateAcquireLock: (BOOL)acquireLock
{
    /* See handleObserveeDeallocation() for rationale for the 'acquireLock' business */
    if (OSAtomicCompareAndSwap32(NO, YES, &mInvalidated))
    {
        /* Mirror of -init */
        [[self class] removeObservation: self acquireLock: acquireLock];
        
        mOptions = 0;
        
        [mHandlerBlock release],
        mHandlerBlock = nil;
        
        [mKeyPath release],
        mKeyPath = nil;
        
        mObservee = nil;
    };
}

- (void)dealloc
{
    [self invalidate];
    [super dealloc];
}

#pragma mark - Private Methods -
static void handleObserveeDeallocation(NSObject *observee)
{
        NSCParameterAssert(observee);
    
    dispatch_semaphore_wait(gEntriesLock, DISPATCH_TIME_FOREVER);
    
        /* There's no guarantee that keyPath2ObservationsMap will exist for the given observee! (At the instant before we acquire the
           lock, it's possible that another thread -invalidated every SSObservation.) */
        /* Combine all our SSObservations into an array, so we're not enumerating over changing collections */
        NSMutableArray *observations = [NSMutableArray array];
        for (NSSet *currentObservations in [[(id)gEntries objectForKey: observee] objectEnumerator])
            [observations addObjectsFromArray: [currentObservations allObjects]];
        
        /* Invalidate every SSObservation for 'observee' */
        /* We acquired gEntriesLock above, so we avoid acquiring it during invalidation to avoid deadlock. */
        for (SSObservation *observation in observations)
            [observation invalidateAcquireLock: NO];
    
    dispatch_semaphore_signal(gEntriesLock);
}

static void observeeInterposedDealloc(NSObject *observee)
{
        NSCParameterAssert(observee);
    
    /* This function overrides the dynamic KVO subclass' implementation of dealloc. We do not call the original KVO subclass implementation
       because the call to -handleObserveeDeallocation: causes the correct KVO cleanup to occur (-removeObserver:), which would have
       otherwise occurred due to the KVO subclass' -dealloc method. Therefore, we simply call the observee's dealloc method after performing
       our cleanup. */
    handleObserveeDeallocation(observee);
    [observee dealloc];
}

static void interposeDeallocForObserveeClass(Class observeeClass)
{
        NSCParameterAssert(observeeClass);
    
    const char *deallocTypeEncoding = method_getTypeEncoding(class_getInstanceMethod([NSObject class], @selector(dealloc)));
        SSAssertOrPerform(deallocTypeEncoding, return);
    
    IMP replaceMethodResult = class_replaceMethod(observeeClass, @selector(dealloc), (IMP)observeeInterposedDealloc, deallocTypeEncoding);
        SSAssertOrPerform(replaceMethodResult, return);
}

+ (void)addObservation: (SSObservation *)observation
{
        NSParameterAssert(observation);
    
    /* We need to guarantee the observee's lifetime for this method, to ensure that it isn't deallocated
       prematurely. (Namely, before we swizzle the dynamic-KVO-subclass' -dealloc method.) */
    [[observation->mObservee retain] autorelease];
    
    dispatch_semaphore_wait(gEntriesLock, DISPATCH_TIME_FOREVER);
        NSMutableDictionary *keyPath2ObservationsMap = [(id)gEntries objectForKey: observation->mObservee];
            /* Gravely inconsistent state of this assertion fails */
            SSAssertOrRaise(!keyPath2ObservationsMap || [keyPath2ObservationsMap count]);
        
        if (!keyPath2ObservationsMap)
        {
            keyPath2ObservationsMap = [NSMutableDictionary dictionary];
            CFDictionarySetValue(gEntries, observation->mObservee, keyPath2ObservationsMap);
        }
        
        NSMutableSet *observations = [keyPath2ObservationsMap objectForKey: observation->mKeyPath];
            /* Gravely inconsistent state of this assertion fails */
            SSAssertOrRaise(!observations || [observations count] > 0);
        
        if (!observations)
        {
            observations = (id)SSCFAutorelease(CFSetCreateMutable(nil, 0, nil));
            [keyPath2ObservationsMap setObject: observations forKey: observation->mKeyPath];
        }
        
        /* We don't copy the block here! That's the caller's job, which ensures that the same pointer is supplied to both -addObservee and -removeObservee. */
        [observations addObject: observation];
        
        /* We clear the 'Initial' KVO bit because we don't can't call out while our lock is held. (Once we relinquish the lock,
           we invoke the block manually to emulate the Initial functionality.) */
        [observation->mObservee addObserver: (NSObject *)self forKeyPath: observation->mKeyPath
            options: (observation->mOptions & ~NSKeyValueObservingOptionInitial) context: observation];
        
        interposeDeallocForObserveeClass(object_getClass(observation->mObservee));
    dispatch_semaphore_signal(gEntriesLock);
    
    /* Emulate the 'Initial' KVO option, now that we've relinquished the lock and it's safe to call out. */
    if (observation->mOptions & NSKeyValueObservingOptionInitial)
    {
        NSMutableDictionary *change = [NSMutableDictionary dictionary];
        [change setObject: [NSNumber numberWithUnsignedInteger: NSKeyValueChangeSetting] forKey: NSKeyValueChangeKindKey];
        if (observation->mOptions & NSKeyValueObservingOptionNew)
        {
            NSObject *newValue = [observation->mObservee valueForKeyPath: observation->mKeyPath];
            if (!newValue)
                newValue = [NSNull null];
            [change setObject: newValue forKey: NSKeyValueChangeNewKey];
        }
        observation->mHandlerBlock(observation, change);
    }
}

+ (void)removeObservation: (SSObservation *)observation acquireLock: (BOOL)acquireLock
{
        NSParameterAssert(observation);
    
    if (acquireLock)
        dispatch_semaphore_wait(gEntriesLock, DISPATCH_TIME_FOREVER);
    
    NSMutableDictionary *keyPath2ObservationsMap = [(id)gEntries objectForKey: observation->mObservee];
        /* Gravely inconsistent state of this assertion fails */
        SSAssertOrRaise(keyPath2ObservationsMap && [keyPath2ObservationsMap count]);
    
    NSMutableSet *observations = [keyPath2ObservationsMap objectForKey: observation->mKeyPath];
        /* Gravely inconsistent state of this assertion fails */
        SSAssertOrRaise(observations && [observations containsObject: observation]);
    
    [observation->mObservee removeObserver: (NSObject *)self forKeyPath: observation->mKeyPath context: observation];
    [observations removeObject: observation];
    
    if (![observations count])
    {
        [keyPath2ObservationsMap removeObjectForKey: observation->mKeyPath];
        
        if (![keyPath2ObservationsMap count])
            [(id)gEntries removeObjectForKey: observation->mObservee];
    }
    
    if (acquireLock)
        dispatch_semaphore_signal(gEntriesLock);
}

+ (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (NSObject *)observee change: (NSDictionary *)change context: (void *)context
{
        NSParameterAssert(keyPath && [keyPath length]);
        NSParameterAssert(observee);
    
    void (^handlerBlock)(SSObservation *observation, NSDictionary *change) = nil;
    dispatch_semaphore_wait(gEntriesLock, DISPATCH_TIME_FOREVER);
        /* Check if 'context' (a possibly-deallocated SSObservation) exists in the observations set. If so, it's still live
           and we can safely access its mHandlerBlock while we hold the lock, since we know that it hasn't called
           -removeObservation: yet (which happens when it's deallocated.) */
        CFSetRef observations = (CFSetRef)[[(id)gEntries objectForKey: observee] objectForKey: keyPath];
        if (CFSetContainsValue(observations, context))
            handlerBlock = [[((SSObservation *)context)->mHandlerBlock retain] autorelease];
    dispatch_semaphore_signal(gEntriesLock);
    
    if (handlerBlock)
        handlerBlock(context, change);
}

@end