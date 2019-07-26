#include "../../include/utils/delcs.h"

#if TARGET_PLATFORM == TARGET_LINUX

#include "../utils/macros.s"
#include "../../include/graphics/resolutions.h"

#define ASSEMBLE_GRAPHICS_S
#include "../asm/graphics.s"


@@@@@@@@@@@@@@@@@@@@@@@
@@-----CONSTANTS-----@@
@@@@@@@@@@@@@@@@@@@@@@@

@@ #include <fcntl.h>
.equ O_RDWR, 0x2
.equ O_DSYNC, 0x1000
.equ __O_SYNC, 0x100000
.equ O_SYNC, __O_SYNC|O_DSYNC

@@ #include <linux/fb.h>
.equ FBIOGET_VSCREENINFO, 0x4600
.equ FBIOPUT_VSCREENINFO, 0x4601
.equ FBIOGET_FSCREENINFO, 0x4602

@@ #include <sys/mman.h>
.equ PROT_READ, 0x1
.equ PROT_WRITE, 0x2
.equ MAP_SHARED, 0x1

@@ #include <linux/kd.h>
.equ KDSETMODE, 0x4B3A
.equ KDGETMODE, 0x4B3B
.equ KD_TEXT, 0x0
.equ KD_GRAPHICS, 0x1


@@@@@@@@@@@@@@@@@@@@
@@-----MACROS-----@@
@@@@@@@@@@@@@@@@@@@@

@@ Summary:
@@  - SYS_OPEN
@@  - SYS_CLOSE
@@  - SYS_IOCTL

@@ Return: (r0, error code)
@@ Clobbers: r0, r1, r7
.macro SYS_OPEN fileName, fileMode
        LOAD_STR "\fileName"    @@ Load file
        ldr r1, =\fileMode      @@ Load file mode
        mov r7, #5              @@ System call open file
        swi #0                  @@ /
.endm


@@ Return: (r0, error code)
@@ Clobbers: r0, r7
.macro SYS_CLOSE fileDescriptor
        mov r0, \fileDescriptor @@ Load file descriptor
        mov r7, #6              @@ System call close file
        swi #0                  @@ /
.endm


@@ Return: (r0, ioctl return value)
@@ Clobbers: r0, r7
.macro SYS_IOCTL cmpReturnTo:vararg
        mov r7, #54             @@ Call SYS_IOCTL
        swi #0                  @@ /
        .ifnb \cmpReturnTo      @@ Compare the return value
                cmp r0, \cmpReturnTo
        .endif
.endm


@@@@@@@@@@@@@@@@@@
@@-----CODE-----@@
@@@@@@@@@@@@@@@@@@

@@ Summary:
.global initGraphics
.global destroyGraphics
.global setResolution
.global startDraw
.global endDraw

@@ Parameters: void
@@ Return: (r0, framebuffer pointer)
FUNC fbCreateFramebuffer
    push {r4, r7}
    SYS_OPEN "/dev/fb0", O_SYNC|O_RDWR              @@ Open framebuffer file
    cmp r0, #0                                      @@ If file descriptor == null:
    blt .L_fbCreateFramebuffer_Return               @@ Return

    ldr r1, =fbFileDescriptor                       @@ Save framebuffer file descriptor
    str r0, [r1]                                    @@ /
    mov r4, r0                                      @@ /

    ldr r1, =#FBIOGET_VSCREENINFO                   @@ Get the variable screen info
    ldr r2, =fb_var_screeninfo_orig                 @@ Write a copy of the orginal variable screen info
    SYS_IOCTL #0                                    @@ /
    blt .L_fbCreateFramebuffer_Return               @@ If SYS_IOCTL failed: return

    mov r0, r4                                      @@ Get framebuffer file descriptor
    ldr r2, =fb_var_screeninfo                      @@ Get the variable screen info to modify
    SYS_IOCTL                                       @@ /

                                                    @@ Setup framebuffer settings:
    ldr r0, =fb_var_screeninfo_bits_per_pixel       @@ Set bits per pixel
    mov r1, #BPP                                    @@ /
    str r1, [r0]                                    @@ /
    ldr r0, =fb_var_screeninfo_xres                 @@ Set x resolution
    mov r1, #(DEFAULT_RESOLUTION) >> 16             @@ /
    str r1, [r0]                                    @@ /
    ldr r0, =fb_var_screeninfo_xres_virtual         @@ /
    str r1, [r0]                                    @@ /
    ldr r0, =fb_var_screeninfo_yres                 @@ Set y resolution
    mov r1, #(DEFAULT_RESOLUTION) & 0xFFFF          @@ /
    str r1, [r0]                                    @@ /
    ldr r0, =fb_var_screeninfo_yres_virtual         @@ /
    str r1, [r0]                                    @@ /

    mov r0, r4                                      @@ Get framebuffer file descriptor
    ldr r1, =#FBIOPUT_VSCREENINFO                   @@ Set the modified variable screen info
    ldr r2, =fb_var_screeninfo                      @@ Get the variable screen info to read from
    SYS_IOCTL #0                                    @@ /
    blt .L_fbCreateFramebuffer_Return               @@ If SYS_IOCTL failed: return

    mov r0, r4                                      @@ Get framebuffer file descriptor
    ldr r1, =#FBIOGET_FSCREENINFO                   @@ Get the fixed screen info
    ldr r2, =fb_fix_screeninfo                      @@ Get the address to write the fixed screen info to
    SYS_IOCTL #0                                    @@ /
    blt .L_fbCreateFramebuffer_Return               @@ If SYS_IOCTL failed: return

                                                    @@ Map the framebuffer memory to a vertial memory address in our process
    mov r0, #0                                      @@ Let the kernel choose an address to map to
    ldr r1, =fb_fix_screeninfo_smem_len             @@ Get framebuffer size
    ldr r1, [r1]                                    @@ /
    ldr r2, =#PROT_READ|PROT_WRITE                  @@ Make memory read and writable
    ldr r3, =#MAP_SHARED                            @@ Make the memory shared between processes
    mov r5, #0                                      @@ Offset memory by 0
    mov r7, #192                                    @@ Call SYS_MMAP
    swi #0                                          @@ /
    cmp r0, #0                                      @@ If SYS_MMAP failed:
    blt .L_fbCreateFramebuffer_Return               @@ Return

    ldr r1, =fbPointer                              @@ Store the framebuffer pointer
    str r0, [r1]                                    @@ /

    SYS_OPEN "/dev/tty0", O_RDWR                    @@ Open current virtual console file
    cmp r0, #0                                      @@ If file descriptor == null:
    blt .L_fbCreateFramebuffer_Return               @@ Return
    mov r4, r0

    ldr r1, =KDGETMODE                              @@ Get the current mode
    ldr r2, =fbGraphicsModeSet                      @@ Get the address to write to
    SYS_IOCTL                                       @@ /
    ldr r3, [r2]                                    @@ Get the value written
    cmp r3, #0                                      @@ If the mode is graphics || get mode failed:
    bne .L_fbCreateFramebuffer_CloseTTY0            @@ Close tty0 and return
    mov r3, r2

    mov r0, r4                                      @@ Get tty0 file descriptor
    ldr r1, =KDSETMODE                              @@ Set mode to graphics
    ldr r2, =KD_GRAPHICS                            @@ /
    SYS_IOCTL #0                                    @@ If SYS_IOCTL was succeful:
    moveq r2, #1                                    @@ Set fbGraphicsModeSet to true
    streq r2, [r3]                                  @@ /
    mov r0, r4

.L_fbCreateFramebuffer_CloseTTY0:
    SYS_CLOSE r0

.L_fbCreateFramebuffer_Return:
    ldr r0, =fbPointer                              @@ Load the framebuffer pointer
    ldr r0, [r0]                                    @@ /
    pop {r4, r7}                                    @@ Return
    bx lr                                           @@ /
FUNC_END fbCreateFramebuffer


@@ Parameters: void
@@ Return: (r0, success)
FUNC fbDestroyFramebuffer
    push {r4, r7}

    ldr r3, =fbGraphicsModeSet                      @@ Get graphics mode set
    ldr r0, [r3]                                    @@ /
    cmp r0, #0                                      @@ If graphics mode was not set:
    beq .L_fbDestroyFramebuffer_SkipTTY0            @@ Skip

    SYS_OPEN "/dev/tty0", O_RDWR                    @@ Open current virtual console file
    cmp r0, #0                                      @@ If file descriptor == null:
    blt .L_fbDestroyFramebuffer_SkipTTY0            @@ Skip
    mov r4, r0

    ldr r1, =KDSETMODE                              @@ Set mode to text
    ldr r2, =KD_TEXT                                @@ /
    SYS_IOCTL #0                                    @@ If SYS_IOCTL was succeful:
    moveq r2, #0                                    @@ Set fbGraphicsModeSet to false
    streq r2, [r3]                                  @@ /
        
    SYS_CLOSE r4                                    @@ Close current virtual console file
.L_fbDestroyFramebuffer_SkipTTY0:

    ldr r3, =fbPointer                              @@ Get framebuffer pointer
    ldr r0, [r3]                                    @@ /
    cmp r0, #0                                      @@ If framebuffer pointer was not set:
    beq .L_fbDestroyFramebuffer_SkipUnMap           @@ Skip

    ldr r1, =fb_fix_screeninfo_smem_len             @@ Get framebuffer size
    ldr r1, [r1]                                    @@ /
    mov r7, #91                                     @@ Call SYS_MUNMAP
    swi #0                                          @@ /
    cmp r0, #0                                      @@ If SYS_MUNMAP was succeful:
    moveq r2, #0                                    @@ Set framebuffer pointer to null
    streq r2, [r3]                                  @@ /
.L_fbDestroyFramebuffer_SkipUnMap:

    ldr r3, =fbFileDescriptor                       @@ Get framebuffer file descriptor
    ldr r0, [r3]                                    @@ /
    cmp r0, #0                                      @@ If the framebuffer file descriptor was not set:
    beq .L_fbDestroyFramebuffer_SkipResetScreenInfo @@ Skip
    mov r4, r0

	ldr r1, =#FBIOPUT_VSCREENINFO                   @@ Set variable screen info to original screen info
	ldr r2, =fb_var_screeninfo_orig                 @@ /
	SYS_IOCTL                                       @@ /

    SYS_CLOSE r4                                    @@ Close framebuffer file
    cmp r0, #0                                      @@ If SYS_CLOSE was succesful:
    moveq r2, #0                                    @@ Set framebuffer file descriptor to null
    streq r2, [r3]                                  @@ /
.L_fbDestroyFramebuffer_SkipResetScreenInfo:

    ldr r0, =fbFileDescriptor                       @@ Determin success by all members set to 0
    ldr r0, [r0]                                    @@ /
    ldr r1, =fbPointer                              @@ /
    ldr r1, [r1]                                    @@ /
    orr r0, r0, r1                                  @@ /
    ldr r1, =fbGraphicsModeSet                      @@ /
    ldr r1, [r1]                                    @@ /
    orr r0, r0, r1                                  @@ /
    cmp r0, #0                                      @@ /
    moveq r0, #1                                    @@ /
    movne r0, #0                                    @@ /

    pop {r4, r7}                                    @@ Return
    bx lr                                           @@ /
FUNC_END fbDestroyFramebuffer


@@ Parameters: void
@@ Return: (r0, succes)
FUNC initGraphics
    push {lr}

    bl fbCreateFramebuffer          @@ Create framebuffer
    cmp r0, #0                      @@ Return true on succes, else return false
    movne r0, #1                    @@ /

    pop {lr}                        @@ Return
    bx lr                           @@ /
FUNC_END initGraphics


@@ Parameters: void
@@ Return: (r0, succes)
FUNC destroyGraphics
    push {lr}
    bl fbDestroyFramebuffer 
    pop {lr}                        @@ Return
    bx lr                           @@ /
FUNC_END destroyGraphics


@@ Parameters: (r0, resolution)
@@ Return: (r0, succes)
@@ Comments: resolution is encoded as (xRes << 16) | yRes.
FUNC setResolution
    ldr r1, =fbFileDescriptor                       @@ Get framebuffer file descriptor
    ldr r1, [r1]                                    @@ /
    cmp r1, #0                                      @@ If the framebuffer file descriptor was not set:
    moveq r0, #0									@@ Return false
	bxeq lr                                         @@ /

    push {r7}
    mov r2, r0, lsr #16                             @@ Get x resolution
    ldr r3, =fb_var_screeninfo_xres                 @@ Set x resolution
    str r2, [r3]                                    @@ /
    ldr r3, =fb_var_screeninfo_xres_virtual         @@ /
    str r2, [r3]                                    @@ /

    ldr r2, =#0xFFFF                                @@ Get y resolution
    add r2, r2, r0                                  @@ /
    ldr r3, =fb_var_screeninfo_yres                 @@ Set y resolution
    str r2, [r3]                                    @@ /
    ldr r3, =fb_var_screeninfo_yres_virtual         @@ /
    str r2, [r3]                                    @@ /

    mov r0, r1                                      @@ Get framebuffer file descriptor
    ldr r1, =#FBIOPUT_VSCREENINFO                   @@ Set the modified variable screen info
    ldr r2, =fb_var_screeninfo                      @@ Get the variable screen info to read from
    SYS_IOCTL #0                                    @@ /
	movlt r0, #0									@@ Return false on fail
	movge r0, #1									@@ Else return true

    pop {r7}
    bx lr
FUNC_END setResolution


@@ Parameters: void
@@ Return: (r0, frame buffer address)
@@ TODO: Enable double buffering
FUNC startDraw
    ldr r0, =fbPointer
    ldr r0, [r0]
    bx lr                                           @@ Return
FUNC_END startDraw


@@ Parameters: void
@@ Return: void
FUNC endDraw
    bx lr                                           @@ Return
FUNC_END endDraw


@@@@@@@@@@@@@@@@@@
@@-----DATA-----@@
@@@@@@@@@@@@@@@@@@

@@ Summary:
.global fbPointer

.data
.section .bss
.align 2

fbPointer:              .word 0
fbFileDescriptor:       .word 0
fbGraphicsModeSet:      .word 0

@@ #include <linux/fb.h>
fb_fix_screeninfo:
        fb_fix_screeninfo_id:                   .fill 16, 1, 0
        fb_fix_screeninfo_smem_start:           .word 0
        fb_fix_screeninfo_smem_len:             .word 0
        fb_fix_screeninfo_type:                 .word 0
        fb_fix_screeninfo_type_aux:             .word 0
        fb_fix_screeninfo_visual:               .word 0
        fb_fix_screeninfo_xpanstep:             .hword 0
        fb_fix_screeninfo_ypanstep:             .hword 0
        fb_fix_screeninfo_ywrapstep:            .hword 0
        fb_fix_screeninfo_line_length:          .word 0
        fb_fix_screeninfo_mmio_start:           .word 0
        fb_fix_screeninfo_mmio_len:             .word 0
        fb_fix_screeninfo_accel:                .word 0
        fb_fix_screeninfo_capabilities:         .hword 0
        fb_fix_screeninfo_reserved:             .fill 2, 2, 0
DATA_END fb_fix_screeninfo

fb_var_screeninfo:
        fb_var_screeninfo_xres:                 .word 0
        fb_var_screeninfo_yres:                 .word 0
        fb_var_screeninfo_xres_virtual:         .word 0
        fb_var_screeninfo_yres_virtual:         .word 0
        fb_var_screeninfo_xoffset:              .word 0
        fb_var_screeninfo_yoffset:              .word 0
        fb_var_screeninfo_bits_per_pixel:       .word 0
        fb_var_screeninfo_grayscale:            .word 0
        @@ fb_bitfield {
        @@      offset          .word 0
        @@      length          .word 0
        @@      msb_right       .word 0
        @@ } 
        @@ fb_bitfield values:
        fb_var_screeninfo_red:                  .word 0, 0, 0
        fb_var_screeninfo_green:                .word 0, 0, 0
        fb_var_screeninfo_blue:                 .word 0, 0, 0
        fb_var_screeninfo_transp:               .word 0, 0, 0
        @@
        fb_var_screeninfo_nonstd:               .word 0
        fb_var_screeninfo_activate:             .word 0
        fb_var_screeninfo_height:               .word 0
        fb_var_screeninfo_width:                .word 0
        fb_var_screeninfo_accel_flags:          .word 0
        fb_var_screeninfo_pixclock:             .word 0
        fb_var_screeninfo_left_margin:          .word 0
        fb_var_screeninfo_right_margin:         .word 0
        fb_var_screeninfo_upper_margin:         .word 0
        fb_var_screeninfo_lower_margin:         .word 0
        fb_var_screeninfo_hsync_len:            .word 0
        fb_var_screeninfo_vsync_len:            .word 0
        fb_var_screeninfo_sync:                 .word 0
        fb_var_screeninfo_vmode:                .word 0
        fb_var_screeninfo_rotate:               .word 0
        fb_var_screeninfo_colorspace:           .word 0
        fb_var_screeninfo_reserved:             .fill 4, 4, 0
DATA_END fb_var_screeninfo

fb_var_screeninfo_orig:
        fb_var_screeninfo_orig_xres:            .word 0
        fb_var_screeninfo_orig_yres:            .word 0
        fb_var_screeninfo_orig_xres_virtual:    .word 0
        fb_var_screeninfo_orig_yres_virtual:    .word 0
        fb_var_screeninfo_orig_xoffset:         .word 0
        fb_var_screeninfo_orig_yoffset:         .word 0
        fb_var_screeninfo_orig_bits_per_pixel:  .word 0
        fb_var_screeninfo_orig_grayscale:       .word 0
        @@ fb_bitfield values:
        fb_var_screeninfo_orig_red:             .word 0, 0, 0
        fb_var_screeninfo_orig_green:           .word 0, 0, 0
        fb_var_screeninfo_orig_blue:            .word 0, 0, 0
        fb_var_screeninfo_orig_transp:          .word 0, 0, 0
        @@
        fb_var_screeninfo_orig_nonstd:          .word 0
        fb_var_screeninfo_orig_activate:        .word 0
        fb_var_screeninfo_orig_height:          .word 0
        fb_var_screeninfo_orig_width:           .word 0
        fb_var_screeninfo_orig_accel_flags:     .word 0
        fb_var_screeninfo_orig_pixclock:        .word 0
        fb_var_screeninfo_orig_left_margin:     .word 0
        fb_var_screeninfo_orig_right_margin:    .word 0
        fb_var_screeninfo_orig_upper_margin:    .word 0
        fb_var_screeninfo_orig_lower_margin:    .word 0
        fb_var_screeninfo_orig_hsync_len:       .word 0
        fb_var_screeninfo_orig_vsync_len:       .word 0
        fb_var_screeninfo_orig_sync:            .word 0
        fb_var_screeninfo_orig_vmode:           .word 0
        fb_var_screeninfo_orig_rotate:          .word 0
        fb_var_screeninfo_orig_colorspace:      .word 0
        fb_var_screeninfo_orig_reserved:        .fill 4, 4, 0
DATA_END fb_var_screeninfo_orig

#endif