#import <Foundation/Foundation.h>

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
    NSString *__note = (note);                                                                                                                                                                  \
    if (!(condition))                                                                                                                                                                           \
        SSAssertHandle(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, SSStringify(condition), (__note ? [[NSString stringWithFormat: __note, ##__VA_ARGS__] UTF8String] : nil), YES);      \
})

#define SSAssertOrBail(condition) SSAssertOrBailWithNote(condition, nil)

#define SSAssertLog(note, ...)                                                                                                                                                                  \
({                                                                                                                                                                                              \
    NSString *__note = (note);                                                                                                                                                                  \
    SSAssertHandle(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, nil, (__note ? [[NSString stringWithFormat: __note, ##__VA_ARGS__] UTF8String] : nil), NO);                              \
})

void SSAssertHandle(const char *file, uintmax_t line, const char *function, const char *assertion, const char *note, BOOL raiseException);