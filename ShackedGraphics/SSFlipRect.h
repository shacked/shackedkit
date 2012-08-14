#import <Foundation/Foundation.h>
#import "ShackedFoundation.h"

#if SSTargetOSX
    #import <ApplicationServices/ApplicationServices.h>
#elif SSTargetIOS
    #import <CoreGraphics/CoreGraphics.h>
#else
    #error Unknown target!
#endif

CGAffineTransform SSTransformForFlippedRect(CGRect rect, BOOL x, BOOL y);
CGAffineTransform SSFlipRect(CGContextRef context, CGRect rect, BOOL x, BOOL y);