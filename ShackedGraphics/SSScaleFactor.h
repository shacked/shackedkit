#import <Foundation/Foundation.h>
#import "ShackedFoundation.h"

#if SSTargetOSX
    #import <ApplicationServices/ApplicationServices.h>
#elif SSTargetIOS
    #import <CoreGraphics/CoreGraphics.h>
#else
    #error Unknown target!
#endif

typedef enum : NSUInteger
{
    SSScaleFactorTypeFit,
    SSScaleFactorTypeFill
} SSScaleFactorType;

/* Returns the scale factor to have an element of elementSize fit/fill in a container of containerSize. */
CGFloat SSScaleFactor(SSScaleFactorType type, CGSize elementSize, CGSize containerSize);