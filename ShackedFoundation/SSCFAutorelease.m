#if __has_feature(objc_arc)
#error ARC required to be disabled (-fno-objc-arc)
#endif

#import "SSCFAutorelease.h"

void *SSCFAutorelease(CFTypeRef object)
{
    return (void *)[(id)object autorelease];
}