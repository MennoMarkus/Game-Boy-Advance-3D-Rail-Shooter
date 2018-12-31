#pragma once
#include "./types.h"

extern "C" void startTimer(); // Use noCashStartTimer and noCashStopTimer for better accuracy.
extern "C" u32 stopTimer();   //
extern "C" u32 lutDiv(u32 numerator, u32 denominator);

// No$Gba emulator specific functions! Become useless outside of the emulator but won't crash.
extern "C" char noCashPrintBuffer[80];
extern "C" void noCashPrintFlush();
extern "C" void noCashPrint(const char* str);

inline void noCashStartTimer() { noCashPrint("TIMER START%zeroclks%"); }
inline void noCashStopTimer() { noCashPrint("TIMER END: %lastclks% cycles"); }
