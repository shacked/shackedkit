#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ShackedFoundation.h"

CGContextRef SSContextCreateColor(size_t width, size_t height);
CGContextRef SSContextCreateGray(size_t width, size_t height);

void SSContextMask(CGContextRef context, void (^drawMaskBlock)(CGContextRef context));
CGImageRef SSImageCreate(size_t width, size_t height, void (^drawContentBlock)(CGContextRef context));