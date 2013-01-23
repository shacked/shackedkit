#import "SSTime.h"
#import <mach/mach_time.h>
#import <libkern/OSAtomic.h>
#import "SSAssert.h"

SSTime SSTimeCurrentTime()
{
    return mach_absolute_time();
}

uint64_t SSTimeElapsedNanoseconds(SSTime startTime, SSTime endTime)
{
    /* Initialize kTimebaseInfo, thread-safely */
    static mach_timebase_info_t kTimebaseInfo = nil;
    if (!kTimebaseInfo)
    {
        mach_timebase_info_t newTimebaseInfo = malloc(sizeof(*newTimebaseInfo));
        kern_return_t timebaseInfoResult = mach_timebase_info(newTimebaseInfo);
            SSAssertOrRecover(timebaseInfoResult == KERN_SUCCESS, return 0);
        
        /* Atomically swap kTimebaseInfo with newTimebaseInfo. If the swap fails, then it's because some other thread has
           initialized kTimebaseInfo, so we need to free newTimebaseInfo. */
        if (!OSAtomicCompareAndSwapPtr(nil, newTimebaseInfo, (void * volatile *)&kTimebaseInfo))
        {
            free(newTimebaseInfo),
            newTimebaseInfo = nil;
        }
    }
    
    return (endTime - startTime) * kTimebaseInfo->numer / kTimebaseInfo->denom;
}

double SSTimeElapsedSecondsSince(SSTime startTime)
{
    return (double)SSTimeElapsedNanoseconds(startTime, SSTimeCurrentTime()) / 1e9;
}