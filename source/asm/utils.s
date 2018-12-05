#include "../../include/delcs.h"

@@ Functions available:
@@ - startTimer
@@ - stopTimer
@@ - lutDiv

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ ----------FUNCTIONS---------- @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text

@@ Parameters: void
@@ Return: void
.align 2
.arm
.global startTimer
.type startTimer STT_FUNC
startTimer:
    mov r0, #0
    mov r1, #ADDR_IO                @@ Load timers start adress
    add r1, r1, #0x100              @@ /

    strh r0, [r1, #0x8]             @@ Write 0 to timer 2 counter
    strh r0, [r1, #0xC]             @@ Write 0 to timer 3 counter
    strh r0, [r1, #0xA]             @@ Write 0 to timer 2 control to init counter
    strh r0, [r1, #0xE]             @@ Write 0 to timer 3 control to init counter

    mov r0, #0x84
    strh r0, [r1, #0xE]             @@ Write to timer 3 control, to start timer and enable cascade (overflow)
    mov r0, #0x80
    strh r0, [r1, #0xA]             @@ Write to timer 2, to start timer
    bx lr                           @@ Return


@@ Parameters: void
@@ Return: (r0, time)
.align 2
.arm
.global stopTimer
.type stopTimer STT_FUNC
stopTimer:
    mov r0, #0
    mov r1, #ADDR_IO                @@ Load timers start adress
    add r1, r1, #0x100              @@ /

    strh r0, [r1, #0xA]             @@ Write to timer 2 control to stop timer

    ldrh r0, [r1, #0xC]             @@ Read timer 3 count
    ldrh r2, [r1, #0x8]             @@ Read timer 2 count
    orr r0, r2, r0, lsl #16         @@ Combine timer 2 and 3 count
    bx lr                           @@ Return


@@ Parameters: (r0, numerator), (r1, denominator)
@@ Comments: Do not use unless you have good reasons to. Swi 0x6000 is propabily faster otherwise.
@@ TODO: Inline assembly
@@ Return: (r0, result)
.section .iwram, "ax", %progbits
.align 2
.arm
.global lutDiv
.type lutDiv STT_FUNC
lutDiv:
    ldr r2, =LUT_DIVISION
    ldr r2, [r2, r1, lsl #2]
    smull r3, r0, r0, r2
    bx lr