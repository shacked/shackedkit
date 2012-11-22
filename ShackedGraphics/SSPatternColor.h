#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ShackedFoundation.h"

CGColorRef SSPatternColorCreate(CGSize size, CGFloat backingScaleFactor, void (^drawPatternBlock)(CGContextRef context));