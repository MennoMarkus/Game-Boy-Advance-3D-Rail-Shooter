#pragma once
#include "./types.h"

extern "C" void startTimer();
extern "C" u32 stopTimer();
extern "C" u32 lutDiv(u32 numerator, u32 denominator);
