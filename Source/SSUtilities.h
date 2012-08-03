#import <TargetConditionals.h>

#define SSTargetOSX (TARGET_OS_MAC && !TARGET_OS_IPHONE)
#define SSTargetIOS (TARGET_OS_MAC && TARGET_OS_IPHONE)

#define SSStringify(a) #a
#define SSStringConstExtern(constantName) extern NSString *const constantName;
#define SSStringConst(constantName) NSString *const constantName = @SSStringify(constantName)

#define SSConfirmOrPerform(condition, action)      \
({                                                 \
    if (!(condition))                              \
    {                                              \
        action;                                    \
    }                                              \
})