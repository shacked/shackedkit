#import <TargetConditionals.h>

#define SSTargetOSX (TARGET_OS_MAC && !TARGET_OS_IPHONE)
#define SSTargetIOS (TARGET_OS_MAC && TARGET_OS_IPHONE)

#define SSStringify(a) #a
#define SSStringConstExtern(constantName) extern NSString *const constantName;
#define SSStringConst(constantName) NSString *const constantName = @SSStringify(constantName)
#define SSStaticArrayCount(array) (sizeof(array) / sizeof(*array))
#define SSEqualBools(a, b) ((bool)(a) == (bool)(b))

#define SSConfirmOrPerform(condition, action)      \
({                                                 \
    if (!(condition))                              \
    {                                              \
        action;                                    \
    }                                              \
})
#define SSNoOp (void)0

#define SSValueOrFallback(value, fallback)             \
({                                                     \
    __typeof__(value) __value = (value);               \
    __typeof__(fallback) __fallback = (fallback);      \
    __value ? __value : __fallback;                    \
})

#define SSMin(a, b)               \
({                                \
    __typeof__(a) __a = (a);      \
    __typeof__(b) __b = (b);      \
    __a < __b ? __a : __b;        \
})

#define SSMax(a, b)               \
({                                \
    __typeof__(a) __a = (a);      \
    __typeof__(b) __b = (b);      \
    __a < __b ? __b : __a;        \
})

#define SSCapMin SSMax
#define SSCapMax SSMin

#define SSCapRange(value, min, max)                                         \
({                                                                          \
    __typeof__(value) __value = (value);                                    \
    __typeof__(min) __min = (min);                                          \
    __typeof__(max) __max = (max);                                          \
    __value <= __min ? __min : (__value >= __max ? __max : __value);        \
})

#define SSValueInRange(value, min, max)         \
({                                              \
    __typeof__(value) __value = (value);        \
    __typeof__(min) __min = (min);              \
    __typeof__(max) __max = (max);              \
    __value >= __min && __value <=  __max;      \
})

#define SSValueInRangeExclusive(value, min, max)      \
({                                                    \
    __typeof__(value) __value = (value);              \
    __typeof__(min) __min = (min);                    \
    __typeof__(max) __max = (max);                    \
    __value >= __min && __value <  __max;             \
})