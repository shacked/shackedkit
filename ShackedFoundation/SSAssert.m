#import "SSAssert.h"
#import <stdio.h>

void SSAssertHandle(const char *filePath, uintmax_t fileLine, const char *functionName, const char *assertion, const char *note, BOOL raiseException)
{
        NSCParameterAssert(filePath);
        NSCParameterAssert(functionName);
        NSCParameterAssert(assertion);
    
    fprintf(stderr, "=== Assertion failed ===\n  Time: %s\n  File: %s:%ju\n  Function: %s\n  Assertion: %s\n%s%s%s",
        [[[NSDate date] description] UTF8String], [[[NSString stringWithUTF8String: filePath] lastPathComponent] UTF8String], fileLine,
        functionName, assertion, (note ? "\n  ### " : ""), (note ? note : ""), (note ? "\n" : ""));
    
    if (raiseException)
        [NSException raise: NSInternalInconsistencyException format: @"Assertion failed"];
}