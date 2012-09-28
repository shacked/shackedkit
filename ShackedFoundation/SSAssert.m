#import "SSAssert.h"
#import <stdio.h>

void SSAssertHandle(const char *file, uintmax_t line, const char *function, const char *assertion, const char *note, BOOL raiseException)
{
    NSString *message = [NSString stringWithFormat: @"=== Assertion failed ===\n  Time: %@\n", [[NSDate date] description]];
    
    if (file)
        message = [message stringByAppendingFormat: @"  File: %@:%ju\n", [[NSString stringWithUTF8String: file] lastPathComponent], line];
    
    if (function)
        message = [message stringByAppendingFormat: @"  Function: %@\n", [NSString stringWithUTF8String: function]];
    
    if (assertion)
        message = [message stringByAppendingFormat: @"  Assertion: %@\n", [NSString stringWithUTF8String: assertion]];
    
    if (note)
        message = [message stringByAppendingFormat: @"\n  ### %@\n", [NSString stringWithUTF8String: note]];
    
    fprintf(stderr, "%s", [message UTF8String]);
    
    if (raiseException)
        [NSException raise: NSInternalInconsistencyException format: @"Assertion failed"];
}