#pragma once
#include "../types.h"
#if DEBUG == 1
#include <string.h>
#endif

extern "C" void startTimer(); // Use noCashStartTimer and noCashStopTimer for better accuracy.
extern "C" u32 stopTimer();   //
extern "C" u32 lutDiv(u32 numerator, u32 denominator);

// No$Gba emulator specific functions! Become useless outside of the emulator but won't crash.
extern "C" char noCashPrintBuffer[80];
extern "C" void noCashPrintFlush();
extern "C" void noCashPrint(const char* str);
extern "C" void noCashPrintVar(char* str, u32 var1=0, u32 var2=0, u32 var3=0, u32 var4=0);
inline void noCashPrintVar(const char* str, u32 var1=0, u32 var2=0, u32 var3=0, u32 var4=0) 
{
#if DEBUG == 1
    u32 length = strlen(str)+1;
    char buffer[length];
    strncpy(buffer, str, length);
    noCashPrintVar(buffer, var1, var2, var3, var4);
#endif
}

inline void noCashStartTimer() { noCashPrint("TIMER START%zeroclks%"); }
inline void noCashStopTimer() { noCashPrint("TIMER END: %lastclks% cycles"); }
