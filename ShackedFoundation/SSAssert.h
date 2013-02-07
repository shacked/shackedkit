#import <Foundation/Foundation.h>
#import "SSUtilities.h"

#define SSAssertOrRecover(condition, recoveryAction)                                                                                                                                  \
({                                                                                                                                                                                    \
    if (!(condition))                                                                                                                                                                 \
    {                                                                                                                                                                                 \
        SSAssertHandle(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, SSStringify(condition), nil, NO);                                                                          \
        recoveryAction;                                                                                                                                                               \
    }                                                                                                                                                                                 \
})

#define SSAssertOrBailWithNote(condition, note, ...)                                                                                                                                            \
({                                                                                                                                                                                              \
    if (!(condition))                                                                                                                                                                           \
        SSAssertHandle(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, SSStringify(condition), [[NSString stringWithFormat: (note), ##__VA_ARGS__] UTF8String], YES);                       \
})

#define SSAssertOrBail(condition)                                                                                                                                                               \
({                                                                                                                                                                                              \
    if (!(condition))                                                                                                                                                                           \
        SSAssertHandle(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, SSStringify(condition), nil, YES);                                                                                   \
})

#define SSAssertLog(note, ...)                                                                                                                                                                  \
({                                                                                                                                                                                              \
    SSAssertHandle(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, nil, [[NSString stringWithFormat: (note), ##__VA_ARGS__] UTF8String], NO);                                               \
})

void SSAssertHandle(const char *file, uintmax_t line, const char *function, const char *assertion, const char *note, BOOL raiseException);