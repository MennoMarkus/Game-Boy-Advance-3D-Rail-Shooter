#ifndef RESOLUTIONS_H
#define RESOLUTIONS_H

#if TARGET_PLATFORM == TARGET_LINUX
    #define RESOLUTION_X480Y240 (480<<16)|240
    #define RESOLUTION_X320Y240 (320<<16)|240
#endif
#define RESOLUTION_X240Y160 (240*65536)|160
#define RESOLUTION_X160Y120 (160*65536)|120
#define DEFAULT_RESOLUTION RESOLUTION_X240Y160

#ifndef __ASSEMBLER__
    enum Resolutions {
        #if TARGET_PLATFORM == TARGET_LINUX
            X320Y240 = RESOLUTION_X480Y240,
            X320Y240 = RESOLUTION_X320Y240,
        #endif
        X240Y160 = RESOLUTION_X240Y160,
        X160Y120 = RESOLUTION_X160Y120,
        DEFAULT = DEFAULT_RESOLUTION
    };
#endif

#endif