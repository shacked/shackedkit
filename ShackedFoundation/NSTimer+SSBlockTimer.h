#import <Foundation/Foundation.h>

@interface NSTimer (SSBlockTimer)
/* -scheduledTimerWithTimeInterval: has different behavior than the Foundation version: the timer is scheduled in the
   NSRunLoopCommonModes mode, rather than NSDefaultRunLoopMode. */
+ (NSTimer *)scheduledTimerWithTimeInterval: (NSTimeInterval)timeInterval repeats: (BOOL)repeats block: (void (^)(NSTimer *timer))block;
+ (NSTimer *)timerWithTimeInterval: (NSTimeInterval)timeInterval repeats: (BOOL)repeats block: (void (^)(NSTimer *timer))block;
@end