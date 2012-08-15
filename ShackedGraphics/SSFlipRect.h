#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ShackedFoundation.h"

CGAffineTransform SSTransformForFlippedRect(CGRect rect, BOOL x, BOOL y);
CGAffineTransform SSFlipRect(CGContextRef context, CGRect rect, BOOL x, BOOL y);