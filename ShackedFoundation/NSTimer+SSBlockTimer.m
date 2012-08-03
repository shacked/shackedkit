#import "NSTimer+SSBlockTimer.h"

@implementation NSTimer (SSBlockTimer)

+ (NSTimer *)scheduledTimerWithTimeInterval: (NSTimeInterval)timeInterval repeats: (BOOL)repeats block: (void (^)(NSTimer *timer))block
{
    NSTimer *result = [self timerWithTimeInterval: timeInterval repeats: repeats block: block];
    [[NSRunLoop currentRunLoop] addTimer: result forMode: NSRunLoopCommonModes];
    
    return result;
}

+ (NSTimer *)timerWithTimeInterval: (NSTimeInterval)timeInterval repeats: (BOOL)repeats block: (void (^)(NSTimer *timer))block
{
        NSParameterAssert(block);
    
    return [NSTimer timerWithTimeInterval: timeInterval target: self selector: @selector(fireBlockTimer:)
        userInfo: [block copy] repeats: repeats];
}

+ (void)fireBlockTimer: (NSTimer *)timer
{
    ((void (^)(NSTimer *))[timer userInfo])(timer);
}

@end