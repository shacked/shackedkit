#import "SSAssert.h"
#import <stdio.h>

void SSAssertHandle(const char *file, uintmax_t line, const char *function, const char *assertion, const char *note, BOOL raiseException)
{
    NSMutableString *message = [NSMutableString stringWithFormat: @"=== Assertion failed ===\n  Time: %@\n", [[NSDate date] description]];
    
    if (file)
        [message appendFormat: @"  File: %@:%ju\n", [[NSString stringWithUTF8String: file] lastPathComponent], line];
    
    if (function)
        [message appendFormat: @"  Function: %@\n", [NSString stringWithUTF8String: function]];
    
    if (assertion)
        [message appendFormat: @"  Assertion: %@\n", [NSString stringWithUTF8String: assertion]];
    
    if (note)
        [message appendFormat: @"\n  ### %@\n", [NSString stringWithUTF8String: note]];
    
    fprintf(stderr, "%s", [message UTF8String]);
    
    if (raiseException)
        [NSException raise: NSInternalInconsistencyException format: message];
}