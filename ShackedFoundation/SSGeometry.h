#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SSAssert.h"
#import "SSUtilities.h"

typedef struct SSSize
{
    NSUInteger width;
    NSUInteger height;
} SSSize;

extern SSSize SSSizeNull;

static inline SSSize SSSizeMake(NSUInteger width, NSUInteger height)
{
    SSSize result = {.width = width, .height = height};
    return result;
}

static inline BOOL SSSizesEqual(SSSize size1, SSSize size2)
{
    return (size1.width == size2.width && size1.height == size2.height);
}

static inline BOOL SSSizeValid(SSSize size)
{
    return (size.width > 0 && size.height > 0 && !SSSizesEqual(size, SSSizeNull));
}

static inline CGSize SSSizeToCGSize(SSSize size)
{
    return CGSizeMake(size.width, size.height);
}

static inline SSSize SSSizeFromCGSize(CGSize size)
{
    return SSSizeMake(SSCapMin(0, round(size.width)), SSCapMin(0, round(size.height)));
}

SSStringConstExtern(SSSizeWidthKey);
SSStringConstExtern(SSSizeHeightKey);
static inline NSDictionary *SSSizeToDictionary(SSSize size)
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInteger: size.width],   SSSizeWidthKey,
        [NSNumber numberWithUnsignedInteger: size.height],  SSSizeHeightKey, nil];
}

static inline SSSize SSSizeFromDictionary(NSDictionary *sizeDictionary)
{
        NSCParameterAssert(sizeDictionary);
    
    NSNumber *widthNumber = [sizeDictionary objectForKey: SSSizeWidthKey];
        SSAssertOrRecover(widthNumber, return SSSizeNull);
    NSNumber *heightNumber = [sizeDictionary objectForKey: SSSizeHeightKey];
        SSAssertOrRecover(heightNumber, return SSSizeNull);
    
    return SSSizeMake([widthNumber unsignedIntegerValue], [heightNumber unsignedIntegerValue]);;
}