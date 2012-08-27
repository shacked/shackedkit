#import "SSContext.h"

CGContextRef SSContextCreateColor(SSSize size, CGColorSpaceRef colorSpace)
{
        NSCParameterAssert(SSSizeValid(size));
    
    if (!colorSpace)
    {
        /* Generic RGB colorspace isn't available on iOS. */
        #if SSTargetOSX
            colorSpace = SSCFAutorelease(CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB));
        #elif SSTargetIOS
            colorSpace = SSCFAutorelease(CGColorSpaceCreateDeviceRGB());
        #else
            #error Unknown target!
        #endif
    }
    
        /* At this point, we must have a color space */
        SSAssertOrRecover(colorSpace, return nil);
    
    CGContextRef result = CGBitmapContextCreate(nil, size.width, size.height, 8, (size.width * 4),
        colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast));
        SSAssertOrRecover(result, return nil);
    
    return result;
}

CGContextRef SSContextCreateGray(SSSize size, CGColorSpaceRef colorSpace)
{
        NSCParameterAssert(SSSizeValid(size));
    
    if (!colorSpace)
    {
        /* Generic gray colorspace isn't available on iOS. */
        #if SSTargetOSX
            colorSpace = SSCFAutorelease(CGColorSpaceCreateWithName(kCGColorSpaceGenericGray));
        #elif SSTargetIOS
            colorSpace = SSCFAutorelease(CGColorSpaceCreateDeviceGray());
        #else
            #error Unknown target!
        #endif
    }
    
        /* At this point, we must have a color space */
        SSAssertOrRecover(colorSpace, return nil);
    
    CGContextRef result = CGBitmapContextCreate(nil, size.width, size.height, 8, (size.width * 1),
        colorSpace, (kCGBitmapByteOrderDefault | kCGImageAlphaNone));
        SSAssertOrRecover(result, return nil);
    
    return result;
}

CGImageRef SSImageCreate(SSSize size, CGColorSpaceRef colorSpace, void (^drawContentBlock)(CGContextRef context))
{
        NSCParameterAssert(SSSizeValid(size));
        NSCParameterAssert(drawContentBlock);
    
    CGContextRef context = SSCFAutorelease(SSContextCreateColor(size, colorSpace));
        SSAssertOrRecover(context, return nil);
    
    drawContentBlock(context);
    
    CGImageRef result = CGBitmapContextCreateImage(context);
        SSAssertOrRecover(result, return nil);
    
    return result;
}