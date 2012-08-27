#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ShackedFoundation.h"

/* If colorSpace == nil, a generic RGB color space is used. (In the case of iOS, this is the device RGB color space.) */
CGContextRef SSContextCreateColor(SSSize size, CGColorSpaceRef colorSpace);
CGContextRef SSContextCreateGray(SSSize size, CGColorSpaceRef colorSpace);
CGImageRef SSImageCreate(SSSize size, CGColorSpaceRef colorSpace, void (^drawContentBlock)(CGContextRef context));