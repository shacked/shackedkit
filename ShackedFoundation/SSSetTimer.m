#if __has_feature(objc_arc)
#error ARC required to be disabled (-fno-objc-arc)
#endif

#import "SSSetTimer.h"

void SSSetTimer(NSTimer **oldTimer, NSTimer *newTimer)
{
        NSCParameterAssert(oldTimer);
        SSConfirmOrPerform(*oldTimer != newTimer, return);
    
    [newTimer retain];
    [*oldTimer invalidate];
    [*oldTimer release];
    *oldTimer = newTimer;
}