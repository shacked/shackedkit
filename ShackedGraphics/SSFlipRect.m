#import "SSFlipRect.h"
#import "ShackedFoundation.h"

CGAffineTransform SSTransformForFlippedRect(CGRect rect, BOOL x, BOOL y)
{
    CGAffineTransform result = CGAffineTransformMakeScale((x ? -1.0 : 1.0), (y ? -1.0 : 1.0));
    CGPoint originAfterFlip = CGPointApplyAffineTransform(rect.origin, result);
    result = CGAffineTransformTranslate(result, (x ? (originAfterFlip.x - rect.origin.x - rect.size.width) : 0), (y ? (originAfterFlip.y - rect.origin.y - rect.size.height) : 0));
    
    return result;
}

CGAffineTransform SSFlipRect(CGContextRef context, CGRect rect, BOOL x, BOOL y)
{
        NSCParameterAssert(context);
    
    CGAffineTransform result = SSTransformForFlippedRect(rect, x, y);;
    CGContextConcatCTM(context, result);
    return result;
}