#import <Foundation/Foundation.h>
#if SSTargetOSX
#import <ApplicationServices/ApplicationServices.h>
#elif SSTargetIOS
#import <CoreGraphics/CoreGraphics.h>
#endif

CGAffineTransform SSTransformForFlippedRect(CGRect rect, BOOL x, BOOL y);
CGAffineTransform SSFlipRect(CGContextRef context, CGRect rect, BOOL x, BOOL y);