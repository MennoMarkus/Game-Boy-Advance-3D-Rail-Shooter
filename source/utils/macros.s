#ifndef MACROS_S
#define MACROS_S

@@@@@@@@@@@@@@@@@@@@@@@
@@-----CONSTANTS-----@@
@@@@@@@@@@@@@@@@@@@@@@@

#define REPLACE_CODE_LABEL 1


@@@@@@@@@@@@@@@@@@@@
@@-----MACROS-----@@
@@@@@@@@@@@@@@@@@@@@
.altmacro

@@ Summary:
@@  - FUNC
@@  - FUNC_END
@@  - FUNC_IWRAM
@@  - FUNC_EWRAM
@@  - FUNC_ROM

.macro FUNC name:req, alignment=2, type=arm, section:vararg
        .ifb \section
            .section .text
        .else
            .section \section
        .endif
        .\type
        .align \alignment
        .type \name, %function
        \name:
.endm


.macro FUNC_END name:req
        .size \name, .-\name
.endm


.macro FUNC_IWRAM name:req
        .section .iwram, "ax", %progbits
        .align 2
        .arm
        .type \name, %function
        \name:  
.endm


.macro FUNC_EWRAM name:req, type:vararg
        .section .ewram, "ax", %progbits
        .align 2
        .ifb \type
            .thumb
        .else
            .\type
        .endif
        .type \name, %function
        \name:  
.endm


.macro FUNC_ROM name:req
        FUNC \name, 2, thumb, .rodata
.endm


.macro DATA name:req, alignment=2, section:vararg 
        .data
        .ifnb \section
            .section \section
        .endif
        .align \alignment
        \name:
.endm


.macro DATA_END name:req
        .size \name, .-\name
.endm


.macro DATA_IWRAM name:req
        .data
        .section .iwram, "ax", %progbits
        .align 2
        \name:
.endm


.macro DATA_EWRAM name:req
        .data
        .section .ewram, "ax", %progbits
        .align 2
        \name:
.endm


.macro DATA_ROM name:req
        DATA \name, 2, .rodata 
.endm


@@ Return: (r0, string address)
@@ Clobbers: r0
.macro LOAD_STR, string
        .text
        ldr r0, =.L_LOAD_STR\@  @@ Load file string address
        b 999f                  @@ Jump forward, past the data
    DATA_ROM .L_LOAD_STR\@
        .asciz "\string"
        .align 2                @@ Strings can be an odd number of bytes. Align back to 4 bytes.
        .text
    999:
.endm


@@ Return: (r0, string address)
@@ Clobbers: r0
.macro LOAD_STR_INLINE, string
        .text
        mov r0, pc              @@ Load file string address
        b 999f                  @@ Jump forward, past the data
        .asciz "\string"
        .align 2                @@ Strings can be an odd number of bytes. Align back to 4 bytes.
        .text
    999:
.endm


@@ Combine a and b without spaces
.macro CONCAT2, a:req, b:req, spacer:vararg
    .ifnb \spacer
        \a\spacer\b
    .else
        \a\b
    .endif
.endm


@@ Return: void
@@ Clobbers: r0, r1, r2, r3
@@ Comments: Code can be placed between REPLACE_CODE_START and REPLACE_CODE but should not touch the clobbered registers
.macro REPLACE_CODE_START
        mov r3, #ADDR_IO
        add pc, pc, #16

    REPLACE_CODE_LABEL:                                         @@ TODO: Add linux compatibility
        str r0, [r3, #DMA3_SRC]                                 @@ Write the source code address to dma source address
        str r1, [r3, #DMA3_DST]                                 @@ Write the destination code address to dma destination address
        orr r2, r2, #0x84000000                                 @@ Set dma control to source code to desitination code
        str r2, [r3, #DMA3_CNT]                                 @@ /
        bx lr
.endm
.macro REPLACE_CODE src:req, dst:req, size:req, branchName:vararg
        ldr r0, =\src
        ldr r1, =\dst
        mov r2, #\size
        .ifnb \branchName
            bl \branchName
        .else
            bl REPLACE_CODE_LABEL\()b
        .endif
.endm


@@ Return: void
@@ Clobbers: void
@@ Comments: Creates all the needed defines for code replacement. If the value of variable matches the value, the code will be placed
@@           where RUNTIME_REPLACE_OPTION is called. Else the code will be placed in rom as arm code. RUNTIME_REPLACE_OPTION should
@@           be called after the macro this option applies to. Expressions should be evaluated before passed to RUNTIME_REPLACE_OPTION.
.macro RUNTIME_REPLACE_OPTION name:req, variable:req, value:req, macro:vararg
    .if \variable == \value
    \name\()_Dst:
        .ifnb \macro
            \macro
        .else
            \name\()_\value
        .endif
    \name\()_DstEnd:
        .equ \name\()_Size, ( \name\()_DstEnd - \name\()_Dst ) / 4
    .endif
    FUNC \name\()_Src\()_\value, 2, arm, .rodata
        .ifnb \macro
            \macro
        .else
            \name\()_\value
        .endif
    .previous
.endm


.macro RUNTIME_REPLACE_LINE name:req, variable:req, value:req, instruction:vararg
    .if \variable == \value
    \name\()_Dst:
        \instruction
    \name\()_DstEnd:
        .equ \name\()_Size, ( \name\()_DstEnd - \name\()_Dst ) / 4
    .endif
    FUNC \name\()_Src\()_\value, 2, arm, .rodata
        \instruction
    .previous
.endm


@@ Return: void
@@ Clobbers: r0, r1, r2, r3
@@ Comments: Calls REPLACE_CODE for the RUNTIME_REPLACE_OPTION's with the specified name, but only when the registers specified by 
@@           variableRegister equals the value given by value. Experssions should be evaluated before passed to RUNTIME_REPLACE_CODE
.macro RUNTIME_REPLACE_CODE name:req, variableRegister:req, value:req, branchName:vararg
    ldr r1, =# \value
    cmp r1, \variableRegister
    bne \name\()_ReplaceEnd_\()\value
    
    REPLACE_CODE \name\()_Src_\()\value, \name\()_Dst, \name\()_Size, \branchName

    \name\()_ReplaceEnd_\()\value :
.endm

#endif