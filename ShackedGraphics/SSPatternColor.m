#import "SSPatternColor.h"
#import "ShackedFoundation.h"

static void drawPatternCallback(void *info, CGContextRef context)
{
        NSCParameterAssert(info);
    
    ((__bridge void (^)(CGContextRef context))info)(context);
}

static void releaseInfoCallback(void *info)
{
        NSCParameterAssert(info);
    
    CFRelease(info);
}

CGColorRef SSPatternColorCreate(CGSize size, void (^drawPatternBlock)(CGContextRef context))
{
    static const struct CGPatternCallbacks kPatternCallbacks =
    {
        .version = 0,
        .drawPattern = drawPatternCallback,
        .releaseInfo = releaseInfoCallback
    };
    /* This is to be supplied to CGColorCreateWithPattern(). We support up to 4 components (for CMYK), +1 for the alpha channel. */
    static CGFloat kColorComponents[] = {1, 1, 1, 1, 1};
    
        NSCParameterAssert(drawPatternBlock);
    
    void (^drawPatternBlockCopy)(CGContextRef context) = [drawPatternBlock copy];
    CGPatternRef pattern = SSCFAutorelease(CGPatternCreate((__bridge void *)drawPatternBlockCopy, CGRectMake(0, 0, size.width, size.height), CGAffineTransformIdentity,
        size.width, size.height, kCGPatternTilingNoDistortion, YES, &kPatternCallbacks));
        SSAssertOrRecover(pattern, return nil);
    
    /* If we get here, the pattern was created and therefore we need to retain the block on behalf of it */
    CFRetain((__bridge void *)drawPatternBlockCopy);
    
    CGColorSpaceRef patternColorSpace = SSCFAutorelease(CGColorSpaceCreatePattern(nil));
        SSAssertOrRecover(patternColorSpace, return nil);
        
        /* Verify that kColorComponents has enough elements for the given colorspace. CGColorSpaceGetNumberOfComponents()
           doesn't return the alpha component, so we add one. */
        SSAssertOrRecover(CGColorSpaceGetNumberOfComponents(patternColorSpace) + 1 <= SSStaticArrayCount(kColorComponents), return nil);
    
    return CGColorCreateWithPattern(patternColorSpace, pattern, kColorComponents);
}