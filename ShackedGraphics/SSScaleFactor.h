#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum : NSUInteger
{
    SSScaleFactorTypeFit,
    SSScaleFactorTypeFill
} SSScaleFactorType;

/* Returns the scale factor to have an element of elementSize fit/fill in a container of containerSize. */
CGFloat SSScaleFactor(SSScaleFactorType type, CGSize elementSize, CGSize containerSize);