#import <Foundation/Foundation.h>
#import "ShackedFoundation.h"

#if SSTargetOSX
    #import <ApplicationServices/ApplicationServices.h>
#elif SSTargetIOS
    #import <CoreGraphics/CoreGraphics.h>
#else
    #error Unknown target!
#endif

CGContextRef SSContextCreateColor(size_t width, size_t height);
CGContextRef SSContextCreateGray(size_t width, size_t height);

void SSContextMask(CGContextRef context, void (^drawMaskBlock)(CGContextRef context));
CGImageRef SSImageCreate(size_t width, size_t height, void (^drawContentBlock)(CGContextRef context));