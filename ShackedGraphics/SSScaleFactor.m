#import "SSScaleFactor.h"
#import "ShackedFoundation.h"

CGFloat SSScaleFactor(SSScaleFactorType type, CGSize elementSize, CGSize containerSize)
{
    CGFloat result = 0.0;
    
    result = (containerSize.width / elementSize.width);
    
    if ((type == SSScaleFactorTypeFit && (result * elementSize.height) > containerSize.height) ||
        (type == SSScaleFactorTypeFill && (result * elementSize.height) < containerSize.height))
        result = (containerSize.height / elementSize.height);
    
    return result;
}