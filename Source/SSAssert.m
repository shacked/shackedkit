#import "SSAssert.h"
#import <stdio.h>

void SSAssertLog(const char *filePath, uintmax_t fileLine, const char *functionName, const char *assertion)
{
        NSCParameterAssert(filePath);
        NSCParameterAssert(functionName);
        NSCParameterAssert(assertion);
    
    fprintf(stderr, "=== Assertion failed ===\n  Time: %s\n  File: %s:%ju\n  Function: %s\n  Assertion: %s\n",
        [[[NSDate date] description] UTF8String], [[[NSString stringWithUTF8String: filePath] lastPathComponent] UTF8String], fileLine, functionName, assertion);
}