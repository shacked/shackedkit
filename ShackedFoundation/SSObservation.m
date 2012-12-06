#if __has_feature(objc_arc)
#error ARC required to be disabled (-fno-objc-arc)
#endif

#import "SSObservation.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>
#import "SSAssert.h"
#import "SSUtilities.h"
#import "SSCFAutorelease.h"

static SEL kObserveeSwizzledDeallocSelector = nil;
static SSUniquePointerConst(kObservationsMapKey);
static NSLock *gMasterLock = nil;

@implementation SSObservation
{
    @public
    int32_t _invalidated;
    NSObject *_observee;
    NSString *_keyPath;
    NSKeyValueObservingOptions _options;
    void (^_handlerBlock)(SSObservation *observation, NSDictionary *change);
}

#pragma mark - Creation -
+ (void)initialize
{
    static dispatch_once_t initToken = 0;
    dispatch_once(&initToken,
        ^{
            kObserveeSwizzledDeallocSelector = @selector(com_shacked_foundation_observation_observeeSwizzledDealloc);
            gMasterLock = [[NSLock alloc] init];
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
    
    _invalidated = NO;
    _observee = observee; /* Weak reference to observee! */
    _keyPath = [keyPath retain];
    _handlerBlock = [handlerBlock copy];
    _options = options;
    
    NSMutableDictionary *observationsMap = lockWithObserveeAndGetObservationsMap(_observee, YES);
            /* Grave error if we didn't acquire the lock */
            SSAssertOrBail(observationsMap);
        
        CFMutableSetRef observations = (CFMutableSetRef)[observationsMap objectForKey: _keyPath];
            /* Grave error state if this assertion fails */
            SSAssertOrBail(!observations || CFSetGetCount(observations) > 0);
        
        if (!observations)
        {
            observations = SSCFAutorelease(CFSetCreateMutable(nil, 0, nil));
            [observationsMap setObject: (id)observations forKey: _keyPath];
        }
        
        CFSetAddValue(observations, self);
        swizzleDeallocForObserveeClass([_observee class]);
        /* Mask the 'Initial' KVO option to prevent us from calling-out while the lock is held */
        [_observee addObserver: (id)[SSObservation class] forKeyPath: _keyPath options: (_options & ~NSKeyValueObservingOptionInitial) context: self];
    unlockWithObservee(_observee);
    
    /* Emulate the 'Initial' KVO option now that we've relinquished the lock and it's safe to call out. */
    if (_options & NSKeyValueObservingOptionInitial)
    {
        NSMutableDictionary *change = [NSMutableDictionary dictionaryWithObject: [NSNumber numberWithUnsignedInteger: NSKeyValueChangeSetting] forKey: NSKeyValueChangeKindKey];
        if (_options & NSKeyValueObservingOptionNew)
            [change setObject: SSValueOrFallback([_observee valueForKeyPath: _keyPath], [NSNull null]) forKey: NSKeyValueChangeNewKey];
        _handlerBlock(self, change);
    }
    
    return self;
}

- (void)invalidate
{
    [self invalidateWithObservationsMap: nil];
}

- (void)invalidateWithObservationsMap: (NSMutableDictionary *)observationsMap
{
    /* We use the observationsMap as a flag as well as for its content; if observationsMap == nil, then we need to acquire the
       lock for our observee. If observationsMap != nil, then we don't acquire the lock. See handleObserveeDeallocation()
       for the rationale. */
        SSConfirmOrPerform(OSAtomicCompareAndSwap32(NO, YES, &_invalidated), return);
    
    /* Perform in reverse of -init! */
    /* If we weren't given an observations map, we acquire the lock so that we can get it */
    BOOL acquireLock = !observationsMap;
    if (acquireLock)
        observationsMap = lockWithObserveeAndGetObservationsMap(_observee, NO);
    
        /* Grave error if we don't have an observations map at this point, or if the observations map is empty */
        SSAssertOrBail(observationsMap && [observationsMap count]);
    
    [_observee removeObserver: (id)[SSObservation class] forKeyPath: _keyPath context: self];
    
    CFMutableSetRef observations = (CFMutableSetRef)[observationsMap objectForKey: _keyPath];
        /* Grave error if this assertion fails */
        SSAssertOrBail(observations && CFSetGetCount(observations) > 0);
    
    CFSetRemoveValue(observations, self);
    if (!CFSetGetCount(observations))
        [observationsMap removeObjectForKey: _keyPath];
    
    if (acquireLock)
        unlockWithObservee(_observee);
    
    _options = 0;
    
    [_handlerBlock release],
    _handlerBlock = nil;
    
    [_keyPath release],
    _keyPath = nil;
    
    _observee = nil;
}

- (void)dealloc
{
    [self invalidate];
    [super dealloc];
}

#pragma mark - Private Methods -
static NSMutableDictionary *lockWithObserveeAndGetObservationsMap(NSObject *observee, BOOL allowCreateObservationsMap)
{
        NSCParameterAssert(observee);
    
    /* Retain the observee for the duration that we're locked with it */
    [observee retain];
    [gMasterLock lock];
    
    NSMutableDictionary *observationsMap = objc_getAssociatedObject(observee, kObservationsMapKey);
    if (!observationsMap && allowCreateObservationsMap)
    {
        observationsMap = [[[NSMutableDictionary alloc] init] autorelease];
        objc_setAssociatedObject(observee, kObservationsMapKey, observationsMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
        /* Grave error if we don't have an observations map and we were supposed to create one */
        SSAssertOrBail(observationsMap || !allowCreateObservationsMap);
    
    /* Cleanup if we're not returning that we acquired the lock (result == nil), since unlock() won't be called. */
    if (!observationsMap)
    {
        [gMasterLock unlock];
        [observee release];
    }
    return observationsMap;
}

static void unlockWithObservee(NSObject *observee)
{
        NSCParameterAssert(observee);
    
    /* Perform in reverse of lock()! */
    NSMutableDictionary *observationsMap = objc_getAssociatedObject(observee, kObservationsMapKey);
        /* Grave error if we don't have an observations map, since it was created in lock() and no one else should have removed it but us. */
        SSAssertOrBail(observationsMap);
    
    /* Remove the observations map if it's empty */
    if (![observationsMap count])
        objc_setAssociatedObject(observee, kObservationsMapKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [gMasterLock unlock];
    [observee release];
}

static void handleObserveeDeallocation(NSObject *observee)
{
        NSCParameterAssert(observee);
    
    NSMutableDictionary *observationsMap = lockWithObserveeAndGetObservationsMap(observee, NO);
    if (observationsMap)
    {
        /* We have active observations for observee since observationsMap != nil, so iterate over every observations set in the map,
           and invalidate every observation. */
        /* ### We have to invalidate the observations *before* we relinquish the lock, because an observation could be in the process
           of deallocation, and relinquishing the lock would allow the SSObservation to call [super dealloc], and the memory would be
           freed. While we hold the lock, we're guaranteed that the SSObservation hasn't acquired the lock in -invalidate, and
           therefore we can safely message it until we relinquish the lock. */
        /* ### We're forced to use the CFSet APIs to access to the SSObservations, because we have to be sure that they're not going
           to be messaged after we relinquish the lock e.g. by being placed in an autorelease pool. */
        for (id currentObservations in [[observationsMap allValues] objectEnumerator])
        {
            CFIndex currentObservationsCount = CFSetGetCount((CFSetRef)currentObservations);
                /* Grave error if our observations set is empty! */
                SSAssertOrBail(currentObservationsCount > 0);
            
            SSObservation **observations = malloc(sizeof(*observations) * currentObservationsCount);
                SSAssertOrRecover(observations, continue);
            CFSetGetValues((CFSetRef)currentObservations, (const void **)observations);
            
            for (NSUInteger currentObservationIndex = 0; currentObservationIndex < currentObservationsCount; currentObservationIndex++)
                [observations[currentObservationIndex] invalidateWithObservationsMap: observationsMap];
            
            free(observations),
            observations = nil;
        }
        
        unlockWithObservee(observee);
    }
}

static void observeeSwizzledDealloc(NSObject *observee, SEL _cmd)
{
        NSCParameterAssert(observee);
    
    handleObserveeDeallocation(observee);
    objc_msgSend(observee, kObserveeSwizzledDeallocSelector);
}

static void swizzleDeallocForObserveeClass(Class observeeClass)
{
        NSCParameterAssert(observeeClass);
    
    const char *deallocTypeEncoding = method_getTypeEncoding(class_getInstanceMethod([NSObject class], @selector(dealloc)));
        SSAssertOrRecover(deallocTypeEncoding, return);
    
    /* Create our swizzled dealloc method on observeeClass. If class_addMethod() fails, it means we already performed our swizzling on observeeClass, so we'll gracefully return. */
    BOOL addMethodResult = class_addMethod(observeeClass, kObserveeSwizzledDeallocSelector, (IMP)observeeSwizzledDealloc, deallocTypeEncoding);
        SSConfirmOrPerform(addMethodResult, return);
    Method swizzledDeallocMethod = class_getInstanceMethod(observeeClass, kObserveeSwizzledDeallocSelector);
        SSAssertOrRecover(swizzledDeallocMethod, return);
    
    /* Add a -dealloc method at the level of observeeClass, which will simply call super's implementation of dealloc. We want this method to exist at
       the level of observeeClass so that we can swizzle it at that level and not a superclass' level, in order to avoid unnecessary overhead (e.g.,
       if a class inherits from NSObject and doesn't implement a -dealloc method, we would otherwise be swizzling NSObject's -dealloc, and our code
       would be executed any time any object is deallocated). */
    Class observeeSuperclass = [observeeClass superclass];
        /* Sanity-check: avoid swizzling the root class because we be crazy if we're overriding NSObject's -dealloc */
        SSAssertOrBailWithNote(observeeSuperclass, @"Refraining from swizzling -dealloc of root class");
    id deallocTrampolineBlock =
        [[^(NSObject *observee)
        {
            struct objc_super superInfo =
            {
                .receiver = observee,
                .super_class = observeeSuperclass
            };
            
            objc_msgSendSuper(&superInfo, @selector(dealloc));
        } copy] autorelease];
    IMP deallocTrampolineImp = imp_implementationWithBlock(deallocTrampolineBlock);
    addMethodResult = class_addMethod(observeeClass, @selector(dealloc), deallocTrampolineImp, deallocTypeEncoding);
    /* If we successfully added the method to observeeClass, retain the block so its IMP remains valid. */
    if (addMethodResult)
        [deallocTrampolineBlock retain];
    
    Method originalDeallocMethod = class_getInstanceMethod(observeeClass, @selector(dealloc));
        SSAssertOrRecover(originalDeallocMethod, return);
    
    /* Swizzle the method implementations -- invoking 'dealloc' on instances of observeeClass will actually invoke our observeeSwizzledDealloc(),
       and calling kObserveeSwizzledDeallocSelector on instances of observeeClass will actually invoke the original dealloc method. */
    method_exchangeImplementations(originalDeallocMethod, swizzledDeallocMethod);
}

+ (void)observeValueForKeyPath: (NSString *)keyPath ofObject: (NSObject *)observee change: (NSDictionary *)change context: (void *)context
{
        NSParameterAssert(keyPath && [keyPath length]);
        NSParameterAssert(observee);
    
    void (^handlerBlock)(SSObservation *observation, NSDictionary *change) = nil;
    NSMutableDictionary *observationsMap = lockWithObserveeAndGetObservationsMap(observee, NO);
    if (observationsMap)
    {
        /* Check if 'context' (a possibly-deallocated SSObservation) exists in the observations set for the given key path.
           If so, it's still live and we can safely access its _handlerBlock while we hold the lock, since we know that it
           hasn't started its invalidation yet (which happens when it's deallocated.) */
        CFSetRef observations = (CFSetRef)[observationsMap objectForKey: keyPath];
        if (observations && CFSetContainsValue(observations, context))
            handlerBlock = [[((SSObservation *)context)->_handlerBlock retain] autorelease];
        unlockWithObservee(observee);
    }
    
    if (handlerBlock)
        handlerBlock(context, change);
}

@end