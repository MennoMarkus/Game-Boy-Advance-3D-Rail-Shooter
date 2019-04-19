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
#if DEBUG == 1
    mov r0, #0
    mov r1, #ADDR_IO                @@ Load timers start address
    add r1, r1, #0x100              @@ /

    strh r0, [r1, #0x8]             @@ Write 0 to timer 2 counter
    strh r0, [r1, #0xC]             @@ Write 0 to timer 3 counter
    strh r0, [r1, #0xA]             @@ Write 0 to timer 2 control to init counter
    strh r0, [r1, #0xE]             @@ Write 0 to timer 3 control to init counter

    mov r0, #0x84
    strh r0, [r1, #0xE]             @@ Write to timer 3 control, to start timer and enable cascade (overflow)
    mov r0, #0x80
    strh r0, [r1, #0xA]             @@ Write to timer 2, to start timer
#endif
    bx lr                           @@ Return
.size startTimer, .-startTimer


@@ Parameters: void
@@ Return: (r0, time)
.align 2
.arm
.global stopTimer
.type stopTimer STT_FUNC
stopTimer:
#if DEBUG == 1
    mov r0, #0
    mov r1, #ADDR_IO                @@ Load timers start address
    add r1, r1, #0x100              @@ /

    strh r0, [r1, #0xA]             @@ Write to timer 2 control to stop timer

    ldrh r0, [r1, #0xC]             @@ Read timer 3 count
    ldrh r2, [r1, #0x8]             @@ Read timer 2 count
    orr r0, r2, r0, lsl #16         @@ Combine timer 2 and 3 count
#endif
    bx lr                           @@ Return
.size stopTimer, .-stopTimer


@@ Parameters: (r0, numerator), (r1, denominator)
@@ Comments: Do not use unless you have good reasons to. Swi 0x6000 might be better.
@@ TODO: Use inline assembly
@@ Return: (r0, result)
.section .iwram, "ax", %progbits
.align 2
.arm
.global lutDiv
.type lutDiv STT_FUNC
lutDiv:
    ldr r2, =LUT_DIVISION
    ldr r2, [r2, r1, lsl #2]
    umull r3, r0, r2, r0
    bx lr
.size lutDiv, .-lutDiv

@@ Parameters: void
@@ Return: void
.section .ewram, "ax", %progbits
.align 2
.thumb
.global noCashPrintBuffer
.global noCashPrintFlush
.type noCashPrintFlush STT_FUNC
noCashPrintFlush:
#if DEBUG == 1
    mov r12,r12                     @@ First id  
    b .L_message_end                @@ Skip data and continue excecution at code
    .hword	0x6464                  @@ Second id
    .hword  0                       @@ Flags
noCashPrintBuffer:                  @@ Message data buffer
    .space 82                       @@ /
    .L_message_end:                 @@ Return
#endif
    bx lr                           @@ /
.size noCashPrintFlush, .-noCashPrintFlush


@@ Parameters: (r0, const char* str), (r1, variable 1),   (r2, variable 2),   (r3, variable 3),   (sp #0, varible 4)
@@ Comments: Allows up to 4 variables to be printed. Use %var to insert a variable into the string. After calling this function the string will be modified.
@@           Variables are inserted in order of function arguments. The normal noCashPrint syntax is also allowed.
@@ Return: void (but string is modified)
.align 2
.thumb
.global noCashPrintVar
.type noCashPrintVar STT_FUNC
noCashPrintVar:
#if DEBUG == 1
    push {lr}
    push {r4-r7}

    mov r7, #0                      @@ Variable counter
    mov r12, r7                     @@ /
    mov r4, #0                      @@ String char index counter
.L_noCashPrintVarLoop:
                                    @@ Check for the sub string "%vl%"
    mov r5, r4                      @@ Load forth string char
    add r5, r5, #3                  @@ /
    ldrb r6, [r0, r5]               @@ /
    mov r7, r6                      @@ /
    cmp r7, #37                     @@ If (forth string char != "%"):
    bne .L_noCashPrintVarLoopEnd    @@ Go to next char
    
    sub r5, r5, #3                  @@ Load first string char
    ldrb r6, [r0, r5]               @@ /
    cmp r6, #37                     @@ If (first  string char != "%"):
    bne .L_noCashPrintVarLoopEnd    @@ Go to next char

    add r5, r5, #2                  @@ Load third string char 
    ldrb r6, [r0, r5]               @@ /
    cmp r6, #108                    @@ If (second string char != "l"):
    bne .L_noCashPrintVarLoopEnd    @@ Go to next char

    sub r5, r5, #1                  @@ Load second string char
    ldrb r6, [r0, r5]               @@ /
    cmp r6, #118                    @@ If (third  string char != "v"):
    bne .L_noCashPrintVarLoopEnd    @@ Go to next char

    mov r6, #114                    @@ Write "r" to second string char
    strb r6, [r0, r5]               @@ /
    add r5, r5, #1                  @@ Write number between [4, 7] to thrid string char
    mov r7, r12                     @@ /
    mov r6, #52                     @@ /
    add r6, r6, r7                  @@ /
    strb r6, [r0, r5]               @@ /

    add r7, r7, #1                  @@ Increment variable counter
    cmp r7, #4                      @@ If the variable counter == 4:
    beq .L_noCashPrintVarLoopBreak  @@ End loop, no more variables possible
    mov r12, r7

.L_noCashPrintVarLoopEnd:
    add r4, r4, #1                  @@ Increment string char index
    cmp r7, #0                      @@ If (forth string char != "\0"):
    bne .L_noCashPrintVarLoop       @@ Move to next char, while we're not at the end of the string
.L_noCashPrintVarLoopBreak:
    
    mov r4, r1                      @@ Load all variables in the right registers
    mov r5, r2                      @@ /
    mov r6, r3                      @@ /
    ldr r7, [sp, #20]               @@ /    
    bl noCashPrint                  @@ Print variables

    pop {r4-r7}                     @@ Return
    pop {r1}                        @@ /
    bx r1                           @@ /
#endif
    bx lr                           @@ Return
.size noCashPrintVar, .-noCashPrintVar


@@ Parameters: (r0, const char* str)
@@ Comments: The string may contain parameters, defined as %param%.
@@              - r0,r1,r2,...,r15  show register content. Don't use r0, r1, r2, r3, r12. (displayed as 32bit Hex number)
@@              - sp,lr,pc          alias for r13,r14,r15
@@              - scanline          show current scanline number
@@              - frame             show total number of frames since coldboot
@@              - totalclks         show total number of clock cycles since coldboot
@@              - lastclks          show number of cycles since previous lastclks (or zeroclks)
@@              - zeroclks          resets the 'lastclks' counter
@@ Return: void
.align 2
.thumb
.global noCashPrint
.type noCashPrint STT_FUNC
noCashPrint:
#if DEBUG == 1
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
#else
    bx lr
#endif
.size noCashPrint, .-noCashPrint