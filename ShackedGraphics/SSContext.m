#import "SSContext.h"

CGContextRef SSContextCreateColor(size_t width, size_t height)
{
        NSCParameterAssert(width);
        NSCParameterAssert(height);
    
    /* Generic RGB colorspace isn't available on iOS. */
    #if SSTargetOSX
        CGColorSpaceRef colorSpace = SSCFAutorelease(CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB));
    #elif SSTargetIOS
        CGColorSpaceRef colorSpace = SSCFAutorelease(CGColorSpaceCreateDeviceRGB());
    #else
        #error Unknown target!
    #endif
    
        SSAssertOrRecover(colorSpace, return nil);
    
    CGContextRef result = CGBitmapContextCreate(nil, width, height, 8, (width * 4),
        colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
        SSAssertOrRecover(result, return nil);
    
    return result;
}

CGContextRef SSContextCreateGray(size_t width, size_t height)
{
        NSCParameterAssert(width);
        NSCParameterAssert(height);
    
    /* Generic gray colorspace isn't available on iOS. */
    #if SSTargetOSX
        CGColorSpaceRef colorSpace = SSCFAutorelease(CGColorSpaceCreateWithName(kCGColorSpaceGenericGray));
    #elif SSTargetIOS
        CGColorSpaceRef colorSpace = SSCFAutorelease(CGColorSpaceCreateDeviceGray());
    #else
        #error Unknown target!
    #endif
    
        SSAssertOrRecover(colorSpace, return nil);
    
    CGContextRef result = CGBitmapContextCreate(nil, width, height, 8, (width * 1),
        colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaNone));
        SSAssertOrRecover(result, return nil);
    
    return result;
}

void SSContextMask(CGContextRef context, void (^drawMaskBlock)(CGContextRef context))
{
        NSCParameterAssert(context);
        NSCParameterAssert(drawMaskBlock);
    
    CGRect maskRect = CGContextGetClipBoundingBox(context);
    size_t maskWidth = lround(maskRect.size.width);
    size_t maskHeight = lround(maskRect.size.height);
    CGContextRef maskContext = SSCFAutorelease(SSContextCreateGray(maskWidth, maskHeight));
        SSAssertOrRecover(maskContext, return);
    
    CGContextClearRect(maskContext, CGRectMake(0, 0, maskWidth, maskHeight));
    drawMaskBlock(maskContext);
    
    CGImageRef maskImage = SSCFAutorelease(CGBitmapContextCreateImage(maskContext));
        SSAssertOrRecover(maskImage, return);
    
    CGContextClipToMask(context, maskRect, maskImage);
}

CGImageRef SSImageCreate(size_t width, size_t height, void (^drawContentBlock)(CGContextRef context))
{
        NSCParameterAssert(width);
        NSCParameterAssert(height);
        NSCParameterAssert(drawContentBlock);
    
    CGContextRef context = SSCFAutorelease(SSContextCreateColor(width, height));
        SSAssertOrRecover(context, return nil);
    
    drawContentBlock(context);
    
    CGImageRef result = CGBitmapContextCreateImage(context);
        SSAssertOrRecover(result, return nil);
    
    return result;
}