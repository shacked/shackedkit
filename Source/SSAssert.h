#import <Foundation/Foundation.h>

#define SSAssertOrPerform(condition, action)                                                \
({                                                                                          \
    if (!(condition))                                                                       \
    {                                                                                       \
        SSAssertLog(__FILE__, (uintmax_t)__LINE__, __PRETTY_FUNCTION__, (#condition));      \
        action;                                                                             \
    }                                                                                       \
})

#define SSAssertOrRaise(condition) SSAssertOrPerform((condition), [NSException raise: NSGenericException format: @"An exception occurred"])

void SSAssertLog(const char *filePath, uintmax_t fileLine, const char *functionName, const char *assertion);