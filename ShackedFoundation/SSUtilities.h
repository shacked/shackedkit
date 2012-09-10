#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#define SSTargetOSX (TARGET_OS_MAC && !TARGET_OS_IPHONE)
#define SSTargetIOS (TARGET_OS_MAC && TARGET_OS_IPHONE)

#define SSStringify(a) #a
#define SSStringConstExtern(constantName) extern NSString *const constantName;
#define SSStringConst(constantName) NSString *const constantName = @SSStringify(constantName)
#define SSUniquePointerConst(constantName) const void *const constantName = (const void *const)&constantName
#define SSStaticArrayCount(array) (sizeof(array) / sizeof(*array))
#define SSEqualBools(a, b) ((bool)(a) == (bool)(b))
#define SSRaise(message, ...) [NSException raise: NSGenericException format: (message), ##__VA_ARGS__]

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
    __value ? __value : (fallback);                    \
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

#define SSCapRange(min, max, value)                                         \
({                                                                          \
    __typeof__(min) __min = (min);                                          \
    __typeof__(max) __max = (max);                                          \
    __typeof__(value) __value = (value);                                    \
    __value <= __min ? __min : (__value >= __max ? __max : __value);        \
})

#define SSValueInRange(min, max, value)         \
({                                              \
    __typeof__(min) __min = (min);              \
    __typeof__(max) __max = (max);              \
    __typeof__(value) __value = (value);        \
    __value >= __min && __value <=  __max;      \
})

#define SSValueInRangeExclusive(min, max, value)      \
({                                                    \
    __typeof__(min) __min = (min);                    \
    __typeof__(max) __max = (max);                    \
    __typeof__(value) __value = (value);              \
    __value >= __min && __value <  __max;             \
})

// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL IsEmpty(id thing) {
	return thing == nil ||
	([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
	([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}
