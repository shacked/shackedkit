#import <stdint.h>

typedef uint64_t SSTime;

SSTime SSTimeCurrentTime();
uint64_t SSTimeElapsedNanoseconds(SSTime startTime, SSTime endTime);
double SSTimeElapsedSecondsSince(SSTime startTime);