#import <stdint.h>

typedef uint64_t SSTime;

SSTime SSTimeCurrentTime(void);
uint64_t SSTimeElapsedNanoseconds(SSTime startTime, SSTime endTime);

double SSTimeElapsedSeconds(SSTime startTime, SSTime endTime);
double SSTimeElapsedSecondsSince(SSTime startTime);