#include "../../include/delcs.h"

@@ Functions available:
@@ - startTimer
@@ - stopTimer
@@ - lutDiv
@@ - noCashPrintFlush
@@      |- noCashPrintBuffer
@@ - noCashPrint

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


@@ Parameters: void
@@ Return: void
.section .ewram, "ax", %progbits
.align 2
.thumb
.global noCashPrintBuffer
.global noCashPrintFlush
.type noCashPrintFlush STT_FUNC
noCashPrintFlush:
    mov r12,r12                     @@ First id  
    b .L_message_end                @@ Skip data and continue excecution at code
    .hword	0x6464                  @@ Second id
    .hword  0                       @@ Flags
noCashPrintBuffer:                  @@ Message data buffer
    .space 82                       @@ /
    .L_message_end:                 @@ Return
    bx lr                           @@ /


@@ Parameters: (r0, const char* str)
@@ Comments: The string may contain parameters, defined as %param%.
@@              - r0,r1,r2,...,r15  show register content (displayed as 32bit Hex number)
@@              - sp,lr,pc          alias for r13,r14,r15
@@              - scanline          show current scanline number
@@              - frame             show total number of frames since coldboot
@@              - totalclks         show total number of clock cycles since coldboot
@@              - lastclks          show number of cycles since previous lastclks (or zeroclks)
@@              - zeroclks          resets the 'lastclks' counter
@@ Return: void
.section .rodata, "x", %progbits
.align 2
.thumb
.global noCashPrint
.type noCashPrint STT_FUNC
noCashPrint:
    push {lr}
    ldr r1, =noCashPrintBuffer      @@ Load buffer address
    ldr r2, =noCashPrintFlush       @@ Load noCashPrintFlush function address
    mov r12, r2                     @@ /

.L_noCashPrintLoop:
    mov r2, #0

.L_noCashPrintCopy:
    ldrb r3, [r0, r2]               @@ Load string char
    strb r3, [r1, r2]               @@ Write string char to buffer
    cmp r3, #0                      @@ If (string char == "\0"):
    beq .L_noCashPrintFlush         @@ End of string, go print the buffer to the console

    add r2, r2, #1                  @@ Copy 80 characters, go print the buffer to the console after
    cmp r2, #80                     @@ /
    bne .L_noCashPrintCopy          @@ /

.L_noCashPrintFlush:
    bl .L_noCashPrintFlushFar       @@ Set return address to here, go to noCashPrintFlush

    add r0, r0, r2                  @@ Move forward in the string to where the copy left off
    cmp r3, #0                      @@ If (string char != "\0"):
    bne .L_noCashPrintLoop          @@ Continue printing

    pop {r1}
    bx r1
.L_noCashPrintFlushFar:
    bx r12                          @@ Go to noCashPrintFlush