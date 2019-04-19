#include "../../include/delcs.h"

@@ Data available:
@@ - GRAPHICS_BUFFER

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ -------------DATA------------ @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.data

@ Code data for wireframe mode. This code will be inserted during runtime.
.section .rodata
.align 2
#define wireframeDataSections 1,2,3,4,5,6
.equiv wireframeDataSize1, 2
enableWireframeDataSrc1:
    .macro M_ENABLEWIREFRAMEDATASCR1
        add r11, pc, #WIREFRAME_COLOR - .G_wireframeDataDst1 - 8    @@ Load color address using relative offset
        str r10, [r11]                                              @@ Write color
    .endm
    M_ENABLEWIREFRAMEDATASCR1
disableWireframeDataSrc1:
    .macro M_DISABLEWIREFRAMEDATASCR1
        nop                                                         @@ Padding data
        nop                                                         @@ /
    .endm
    M_DISABLEWIREFRAMEDATASCR1

.equiv wireframeDataSize2, 2
enableWireframeDataSrc2:
    .macro M_ENABLEWIREFRAMEDATASCR2
        add r8, pc, #WIREFRAME_COLOR - .G_wireframeDataDst2 - 8     @@ Load color address using relative offset. TODO check address offset
        str r10, [r8]                                               @@ Write color
    .endm
    M_ENABLEWIREFRAMEDATASCR2
disableWireframeDataSrc2:
    .macro M_DISABLEWIREFRAMEDATASCR2
        nop                                                         @@ Padding data
        nop                                                         @@ /
    .endm   
    M_DISABLEWIREFRAMEDATASCR2                                

.equiv wireframeDataSize3, 2
enableWireframeDataSrc3:
    .macro M_ENABLEWIREFRAMEDATASCR3
        add r6, pc, #WIREFRAME_COLOR - .G_wireframeDataDst3 - 8     @@ Load color address using relative offset
        ldr r6, [r6]                                                @@ Load color
    .endm 
    M_ENABLEWIREFRAMEDATASCR3
disableWireframeDataSrc3:
    .macro M_DISABLEWIREFRAMEDATASCR3
        nop                                                         @@ Padding data
        nop                                                         @@ /
    .endm
    M_DISABLEWIREFRAMEDATASCR3

.equiv wireframeDataSize4, 11
enableWireframeDataSrc4:
    .macro M_ENABLEWIREFRAMEDATASCR4
        cmp r9, r4
        addne pc, pc, #12                                           @@ Skip past if not last line
        str r1, [r7, #DMA3_DST]                                     @@ Write pixel address to dma destination address
        orr r2, r2, #0x81000000                                     @@ Set dma control to copy colour 'curDeltaX' times
        str r2, [r7, #DMA3_CNT]                                     @@ /
        bx lr                                                       @@ Last line, return
        
        add r2, r1, r2, lsl #BPP_POW                                @@ end pixel address = pixel address + curDeltaX * bytes per pixel
        and r1, r1, #0xFFFFFFFC                                     @@ Fix alignment issues
        and r2, r2, #0xFFFFFFFC                                     @@ Fix alignment issues
    #if WIREFRAME_THICK_LINES == 1
        str r6, [r1]                                                @@ Write pixel address
        str r6, [r2]                                                @@ Write end pixel address
    #else
        strh r6, [r1]                                               @@ Write pixel address
        strh r6, [r2]                                               @@ Write end pixel address
    #endif
    .endm
    M_ENABLEWIREFRAMEDATASCR4
    str r6, [r1]                                                    @@ Write pixel address (thick)
    str r6, [r2]                                                    @@ Write end pixel address (thick)
    strh r6, [r1]                                                   @@ Write pixel address (thin)
    strh r6, [r2]                                                   @@ Write end pixel address (thin)
disableWireframeDataSrc4:
    .macro M_DISABLEWIREFRAMEDATASCR4
        add pc, pc, #24                                             @@ Skip past padding data
        nop                                                         @@ Padding data
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        str r1, [r7, #DMA3_DST]                                     @@ Write pixel address to dma destination address
        orr r2, r2, #0x81000000                                     @@ Set dma control to copy colour 'curDeltaX' times
        str r2, [r7, #DMA3_CNT]                                     @@ /
    .endm
    M_DISABLEWIREFRAMEDATASCR4

.equiv wireframeDataSize5, 3
enableWireframeDataSrc5:
    .macro M_ENABLEWIREFRAMEDATASCR5
        add r8, pc, #WIREFRAME_COLOR - .G_wireframeDataDst5         @@ Load color address using relative offset
        sub r8, r8, #8                                              @@ /
        ldr r8, [r8]                                                @@ Load color
    .endm
    M_ENABLEWIREFRAMEDATASCR5
disableWireframeDataSrc5:
    .macro M_DISABLEWIREFRAMEDATASCR5
        nop                                                         @@ Padding data
        nop                                                         @@ /
        nop                                                         @@ /
    .endm
    M_DISABLEWIREFRAMEDATASCR5

.equiv wireframeDataSize6, 12
enableWireframeDataSrc6:
    .macro M_ENABLEWIREFRAMEDATASCR6
        cmp r4, r9
        addne pc, pc, #16                                           @@ Skip past if not last line
        str r5, [r7, #DMA3_DST]                                     @@ Write pixel address to dma destination address
        orr r6, r6, #0x81000000                                     @@ Set dma control to copy colour 'curDeltaX' times
        str r6, [r7, #DMA3_CNT]                                     @@ /
        pop {r4-r8}                                                 @@ Last line, return
        bx lr                                                       @@ /

        add r6, r5, r6, lsl #BPP_POW                                @@ end pixel address = pixel address + curDeltaX * bytes per pixel
        and r5, r5, #0xFFFFFFFC                                     @@ Fix alignment issues
        and r6, r6, #0xFFFFFFFC                                     @@ Fix alignment issues
    #if WIREFRAME_THICK_LINES == 1
        str r8, [r5]                                                @@ Write pixel address
        str r8, [r6]                                                @@ Write end pixel address
    #else
        strh r8, [r5]                                               @@ Write pixel address
        strh r8, [r6]                                               @@ Write end pixel address
    #endif
    .endm
    M_ENABLEWIREFRAMEDATASCR6
    str r8, [r5]                                                    @@ Write pixel address (thick)
    str r8, [r6]                                                    @@ Write end pixel address (thick)
    strh r8, [r5]                                                   @@ Write pixel address (thin)
    strh r8, [r6]                                                   @@ Write end pixel address (thin)
disableWireframeDataSrc6:
    .macro M_DISABLEWIREFRAMEDATASCR6
        add pc, pc, #28                                             @@ Skip past padding data
        nop                                                         @@ Padding data
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        nop                                                         @@ /
        str r5, [r7, #DMA3_DST]                                     @@ Write pixel address to dma destination address
        orr r6, r6, #0x81000000                                     @@ Set dma control to copy colour 'curDeltaX' times
        str r6, [r7, #DMA3_CNT]                                     @@ /
    .endm
    M_DISABLEWIREFRAMEDATASCR6


@ A ram buffer containing graphics data to be draw to the screen.
@ 76800 bytes
@TODO use .sbss to save on rom memory
#if GRAPHICS_MODE == 3 && DUBBLE_BUFFER == 1
.section .ewram
.align 2
.global GRAPHICS_BUFFER
GRAPHICS_BUFFER:
.rept 38400
    .hword 0xFF
.endr
    .size GRAPHICS_BUFFER, .-GRAPHICS_BUFFER
#endif

@@ Functions available:
@@ - m3_initGraphics
@@ - m3_clearScr
@@ - m3_drawPixel
@@ - drawLine
@@ - m3_drawHorzLine
@@ - m3_drawVertLine
@@ - m3_drawRectFromCenter
@@ - m3_drawRectFromCorner
@@ - m3_drawRectEmpty
@@ - m3_drawCircle
@@ - m3_drawCircleEmpty
@@ - m3_mirrorScreenHorz
@@ - m3_mirrorScreenVert
@@ - m3_drawTriangleClipped3D
@@      |- m3_drawTriangleClipped
@@ - m3_drawTriangleClipped
@@      |- m3_drawTriangleClippedBottom
@@      |- m3_drawTriangleClippedTop
@@ - setSpritePalette
@@ - setSpriteSheet

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ ----------FUNCTIONS---------- @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text

@@ Parameters: void
@@ Return: void
.align 2
.arm
.global initGraphics
.type initGraphics STT_FUNC
initGraphics:
    mov r0, #ADDR_IO
    mov r1, #0x1400					@@ /
#if GRAPHICS_MODE == 3
    add r1, r1, #0x43               @@ Load value #0x1443 to enable gfx mode 3, bg 2 and 1d sprite drawing.
#elif GRAPHICS_MODE == 5
    add r1, r1, #0x45				@@ Load value #0x1445 to enable gfx mode 5, bg 2 and 1d sprite drawing.
#endif
    strh r1, [r0]					@@ Write value to memory

#if GRAPHICS_MODE == 5
    mov	r2, #0x4000000				@@ Rotate background 90 degrees and scale x-axis by 2 after
	mov	r0, #0x0					@@ /
	mov	r1, #0x100					@@ /
	mov	r3, #0x80					@@ /
	strh r0, [r2, #0x20]			@@ /
	strh r1, [r2, #0x22]			@@ /
	strh r3, [r2, #0x24]			@@ /
	strh r0, [r2, #0x26]			@@ /
#endif
    bx lr					        @@ Return
.size initGraphics, .-initGraphics


@@ Parameters: (r0, graphics data addr)
@@ Return: (r0, write graphics data addr)
.section .iwram, "ax", %progbits
.align 2
.arm
.global startDraw
.type startDraw STT_FUNC
startDraw:
    mov r1, #ADDR_IO            	@@ /
.L_vDrawWait:                       @@ Wait for vdraw, as to not draw when the screen is being drawn
    ldrh r2, [r1, #6]				@@ Load the vcount
    cmp r2, #0                      @@ Compare to first scan line number, the start of the screen and start of vdraw
    bne .L_vDrawWait                @@ /
.L_vBlankWait:                      @@ Wait for vblank, as to not draw when the screen is being drawn
    ldrh r2, [r1, #6]				@@ Load the vcount
	cmp r2, #SCREEN_HEIGHT     		@@ Compare to last scan line number, the end of the screen and start of vblank
	bne .L_vBlankWait				@@ /

#if GRAPHICS_MODE == 5  && DUBBLE_BUFFER == 1
    eor r0, r0, #0xA000             @@ Switch vram buffer by xor with page flip size
    ldrh r2, [r1]
    eor r2, r2, #0x10
    strh r2, [r1]
#elif GRAPHICS_MODE == 3 && DUBBLE_BUFFER == 1
    mov r2, #ADDR_VRAM
    str r0, [r1, #DMA3_SRC]         @@ Write graphics buffer address to dma source address   
    str r2, [r1, #DMA3_DST]         @@ Write vram address to dma destination address

    mov r3, #0x84000000             @@ Set dma control to copy pixel 0x4b00 times
    orr r3, r3, #0x4B00             @@ /
    str r3, [r1, #DMA3_CNT]         @@ /
#endif
    bx lr                           @@ Return
.size startDraw, .-startDraw


@@ Parameters: (r0, graphics addr), (r1, color addr), (r2, clear mode)
@@ Comments: Available clear modes - (0, none,  clears entire screen)
@@                                 - (1, top,   clears top half for vert/diag mirroring)
@@                                 - (2, left,  clears left side for horz mirroring)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global clearScr
.type clearScr STT_FUNC
clearScr:
    mov r3, #ADDR_IO
    str r1, [r3, #DMA3_SRC]             @@ Write color address to dma source address   
    str r0, [r3, #DMA3_DST]             @@ Write graphics address to dma destination address

#if GRAPHICS_MODE == 3
    mov r1, #0x85000000                 @@ Set dma control to copy colour

    cmp r2, #1                          @@ Clear left side if left mode is selected (clear mode == 2)
    bhi .L_clearScrLeft                 @@ /

    orrne r1, r1, #0x4B00               @@ 0x4b00 times, a full screen, if mode none is selected (clear mode == 0)
    orreq r1, r1, #0x2580               @@ 0x2580 times, a half screen, if top mode is selected (clear mode == 1)
    str r1, [r3, #DMA3_CNT]             @@ /
    bx lr                               @@ Return

.L_clearScrLeft:
    mov r2, #CANVAS_HEIGHT              @@ Height
.L_clearScrLeftLoop:
    orr r1, r1, #CANVAS_WIDTH / 4       @@ Copy colour half width times
    str r1, [r3, #DMA3_CNT]             @@ /

    subs r2, #1                         @@ Height -= 1
    add r0, r0, #CANVAS_WIDTH * BPP     @@ Move destination to next row
    str r0, [r3, #DMA3_DST]             @@ /
    bne .L_clearScrLeftLoop             @@ While Height > 0, copy rows

    bx lr                               @@ Return

#elif GRAPHICS_MODE == 5
    mov r1, #0x85000000                 @@ Set dma control to copy colour
    
    cmp r2, #1                          @@ Clear top side if mode top mode is selected (clear mode == 1)
    beq .L_clearScrLeft                 @@ //

    orrlt r1, r1, #0x2580               @@ 0x2580 times, a full screen, if mode none is selected (clear mode == 0)
    orrgt r1, r1, #0x12C0               @@ 0x12C0 times, a half screen, if left mode is selected (clear mode == 2)
    str r1, [r3, #DMA3_CNT]             @@ /
    bx lr                               @@ Return

.L_clearScrLeft:
    mov r2, #CANVAS_HEIGHT              @@ Height
.L_clearScrLeftLoop:
    orr r1, r1, #CANVAS_WIDTH / 4       @@ Copy colour half width times
    str r1, [r3, #DMA3_CNT]             @@ /

    subs r2, #1                         @@ Height -= 1
    add r0, r0, #CANVAS_WIDTH * BPP     @@ Move destination to next row
    str r0, [r3, #DMA3_DST]             @@ /
    bne .L_clearScrLeftLoop             @@ While Height > 0, copy rows

    bx lr                               @@ Return
#endif
.size clearScr, .-clearScr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ -------MODE 3 FUNCTIONS------- @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@ Parameters: (r0, graphics addr), (r1, x), (r2, y), (r3, 16 bit color)
@@ Return: void
.align 2
.arm
.global drawPixel
.type drawPixel STT_FUNC
drawPixel:
#if GRAPHICS_MODE == 5 && PREPROCESSED_DATA == 0
    add r1, r1, r1, lsl #2          @@ x *= 160 / 2 (width)
    lsl r1, r1, #4                  @@ /
    add r2, r1, r2                  @@ pixel = x * width / 2 + y
    add r2, r0, r2, lsl #BPP_POW    @@ pixel addr = graphics addr + start pixel * bytes per pixel
#else
    rsb r2, r2, r2, lsl #4          @@ y *= 240 (width)
    lsl r2, r2, #4                  @@ /
    add r2, r2, r1                  @@ pixel = y * width + x
    add r2, r0, r2, lsl #BPP_POW    @@ pixel addr = graphics addr + start pixel * bytes per pixel
#endif

    strh r3, [r2]               @@ write pixel
    bx lr					    @@ Return
.size drawPixel, .-drawPixel


@@ Parameters: (r0, graphics addr), (r1, x1), (r2, y1), (r3, x2), (sp #0, y2) (sp #4, 16 bit color)
@@ Return: void
.align 2
.arm
.global drawLine
.type drawLine STT_FUNC
drawLine:
    push {r4, r10, r11}
    ldrh r10, [sp, #(4+12)]         @@ Load y2 and color from the stack
    ldr r4, [sp, #(0+12)]           @@ /

#if GRAPHICS_MODE == 5 && PREPROCESSED_DATA == 0
    mov r12, r2                     @@ Temp = y1
    mov r2, r1, asr #1              @@ y1 = x1 / 2
    mov r1, r12                     @@ x1 = temp (y1)

    mov r12, r4                     @@ Temp = y2
    mov r4, r3, asr #1              @@ y2 = x2 / 2
    mov r3, r12                     @@ x2 = temp (y2)
#endif
                                    @@ Clipping
    bic r1, r1, r1, asr #31         @@ max(x1, 0)
    cmp r1, #CANVAS_WIDTH           @@ min(x1, width - 1)        
    movge r1, #CANVAS_WIDTH-1       @@ /

    bic r2, r2, r2, asr #31         @@ max(y1, 0)
    cmp r2, #CANVAS_HEIGHT          @@ min(y1, height - 1)        
    movge r2, #CANVAS_HEIGHT-1      @@ /

    bic r3, r3, r3, asr #31         @@ max(x1, 0)
    cmp r3, #CANVAS_WIDTH           @@ min(x1, width - 1)        
    movge r3, #CANVAS_WIDTH-1       @@ /

    bic r4, r4, r4, asr #31         @@ max(y2, 0)
    cmp r4, #CANVAS_HEIGHT          @@ min(y2, height - 1)        
    movge r4, #CANVAS_HEIGHT-1      @@ /

    mov r11, #CANVAS_WIDTH * BPP    @@ stepY = CANVAS_WIDTH * bytes per pixel
    subs r12, r4, r2                @@ -deltaY = y2 - y1
    negge r12, r12                  @@ if y2 >= y1: negate -deltaY
    neglt r11, r11                  @@ if y2 < y1: negate stepY

#if GRAPHICS_MODE == 3
    rsb r2, r2, r2, lsl #4          @@ y1 *= 240 (width)
    lsl r2, r2, #4                  @@ /
    rsb r4, r4, r4, lsl #4          @@ y2 *= 240 (width)
    lsl r4, r4, #4                  @@ /
#elif GRAPHICS_MODE == 5
    add r2, r2, r2, lsl #2          @@ y1 *= 160 (width)
    lsl r2, r2, #5                  @@ /
    add r4, r4, r4, lsl #2          @@ y2 *= 160 (width)
    lsl r4, r4, #5                  @@ /
#endif
    add r2, r2, r1                  @@ start pixel = y1 * width + x1
    add r2, r0, r2, lsl #BPP_POW    @@ start pixel addr = graphics addr + start pixel * bytes per pixel
    add r4, r4, r3                  @@ end pixel = y2 * width + x2
    add r0, r0, r4, lsl #BPP_POW    @@ end pixel addr = graphics addr + end pixel * bytes per pixel

    cmp r0, r2                      @@ if line length == 0:
    beq .L_drawLineEnd              @@ end

    mov r4, #-1                     @@ stepX
    subs r1, r1, r3                 @@ deltaX = x1 - x2
    neglt r1, r1                    @@ if x1 < x2: negate deltaX
    neglt r4, r4                    @@ if x1 < x2: negate stepX

    add r3, r1, r12                 @@ error = deltaX + -deltaY

.L_drawLineLoop:
    strh r10, [r2]                  @@ Draw pixel

    cmp r12, r3, lsl #1             @@ if -deltaY <= error * 2
    addle r2, r2, r4, lsl #BPP_POW  @@ x += stepX * bytes per pixel
    addle r3, r3, r12               @@ error += -deltaY
    cmple r2, r0
    beq .L_drawLineEnd

    cmp r1, r3, lsl #1              @@ if deltaX > error * 2
    addgt r2, r2, r11               @@ y += stepY * CANVAS_WIDTH * bytes per pixel
    addgt r3, r3, r1                @@ error += deltaX

    cmp r2, r0                      @@ loop until start address == end address
    bne .L_drawLineLoop

.L_drawLineEnd:
    pop {r4, r10, r11}
    bx lr					        @@ Return
.size drawLine, .-drawLine


@@ Parameters: (r0, graphics addr), (r1, x), (r2, y), (r3, signed width), (sp #0, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global drawHorzLine
.type drawHorzLine STT_FUNC
drawHorzLine:
#if GRAPHICS_MODE == 5 && PREPROCESSED_DATA == 0
    mov r12, r2                     @@ Temp = y
    mov r2, r1, asr #1              @@ y = x / 2
    mov r1, r12                     @@ x =  temp (y)
    mov r3, r3, asr #1              @@ width /= 2
    b .G_drawVertLineASM
#endif

.G_drawHorzLineASM:
    mov r12, #CANVAS_WIDTH
    cmp r3, #0
    negmi r3, r3                    @@ If width < 0: negate width
    submi r1, r1, r3                @@ If width < 0: x -= width

#if GRAPHICS_MODE == 3
    rsb r2, r2, r2, lsl #4          @@ y *= 240 (width)
    lsl r2, r2, #4                  @@ /
#elif GRAPHICS_MODE == 5
    add r2, r2, r2, lsl #2          @@ y *= 160 (width)
    lsl r2, r2, #5                  @@ /
#endif
    add r2, r2, r1                  @@ pixel = y * width + x
    add r2, r0, r2, lsl #BPP_POW    @@ pixel addr = graphics addr + start pixel * bytes per pixel

    ldr r0, [sp, #(0)]              @@ Load colour from stack

    mov r1, #ADDR_IO                @@ Prepare dma address base
    str r0, [r1, #DMA3_SRC]         @@ Write color address to dma source address
    str r2, [r1, #DMA3_DST]         @@ Write pixel address to dma destination address
    orr r3, r3, #0x81000000         @@ Set dma control to copy colour 'width' times
    str r3, [r1, #DMA3_CNT]         @@ /

    bx lr                           @@ Return
.size drawHorzLine, .-drawHorzLine


@@ Parameters: (r0, graphics addr), (r1, x), (r2, y), (r3, signed height), (sp #0, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global drawVertLine
.type drawVertLine STT_FUNC
drawVertLine:
#if GRAPHICS_MODE == 5 && PREPROCESSED_DATA == 0
    mov r12, r2                     @@ Temp = y
    mov r2, r1, asr #1              @@ y = x / 2
    mov r1, r12                     @@ x =  temp (y)
    b .G_drawHorzLineASM
#endif
.G_drawVertLineASM:
    mov r12, #CANVAS_WIDTH
    cmp r3, #0                 
    negmi r3, r3                    @@ If height < 0: negate height
    submi r2, r2, r3                @@ If height < 0: y -= height

#if GRAPHICS_MODE == 3
    rsb r2, r2, r2, lsl #4          @@ y *= 240 (width)
    lsl r2, r2, #4                  @@ /
#elif GRAPHICS_MODE == 5
    add r2, r2, r2, lsl #2          @@ y *= 160 (width)
    lsl r2, r2, #5                  @@ /
#endif
    add r1, r2, r1                  @@ pixel = y * width + x
    add r1, r0, r1, lsl #BPP_POW    @@ pixel addr = graphics addr + start pixel * bytes per pixel

    ldr r0, [sp, #(0)]              @@ Load colour from stack
    ldrh r0, [r0]                   @@ Get color value from addr
    lsl r12, r12, #BPP_POW          @@ Setup (CANVAS_WIDTH) * bytes per pixel
.L_drawVertLineLoopY:
    strh r0, [r1], r12              @@ Draw pixel, and move down vertically
    subs r3, #1                     @@ Height -= 1
    bne .L_drawVertLineLoopY
    bx lr                           @@ Return
.size drawVertLine, .-drawVertLine


@@ Parameters: (r0, graphics addr), (r1, center x), (r2, center y), (r3, half width), (sp #0, half height) (sp #4, 32 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawRectFromCenter
.type m3_drawRectFromCenter STT_FUNC
m3_drawRectFromCenter:
    push {r4}

    ldr r4, [sp, #(0+4)]            @@ Load half height
    sub r1, r1, r3                  @@ x0 = center x - half width
    sub r2, r2, r4                  @@ y0 = center y - half height
    
    mov r12, #CANVAS_WIDTH
    mla r1, r2, r12, r1             @@ pixel = y0 * CANVAS_WIDTH + x0
    add r0, r0, r1, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    lsl r12, r12, #BPP_POW          @@ Setup CANVAS_WIDTH * bytes per pixel
	mov r2, r4, lsl #1  		    @@ Height = 2 * half height

    mov r1, #ADDR_IO                @@ Prepare dma address base
    ldr r4, [sp, #(4+4)]            @@ Load color
    str r4, [r1, #DMA3_SRC]         @@ Write color address to dma source address
    orr r3, r3, #0x85000000         @@ Set dma control to copy colour 'half width' times

.L_drawRectCenterYLoop:
    str r0, [r1, #DMA3_DST]         @@ Write pixel address to dma destination address
    str r3, [r1, #DMA3_CNT]         @@ Set dma control to copy colour 'half width' times

	add r0, r0, r12         	    @@ Move down vertically to next line
	subs r2, r2, #1 			    @@ Height -= 1
	bne .L_drawRectCenterYLoop	    @@ /
    pop {r4}
    bx lr                           @@ Return
.size m3_drawRectFromCenter, .-m3_drawRectFromCenter


@@ Parameters: (r0, graphics addr), (r1, top left x), (r2, top left y), (r3, width), (sp #0, height) (sp #4, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawRectFromCorner
.type m3_drawRectFromCorner STT_FUNC
m3_drawRectFromCorner:
    push {r4}
    mov r12, #CANVAS_WIDTH

    mla r1, r2, r12, r1             @@ pixel = y * CANVAS_WIDTH + x
    add r0, r0, r1, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    lsl r12, r12, #BPP_POW          @@ Setup CANVAS_WIDTH * bytes per pixel
    ldr r2, [sp, #(0+4)]            @@ Load height

    mov r1, #ADDR_IO                @@ Prepare dma address base
    ldr r4, [sp, #(4+4)]            @@ Load color address
    str r4, [r1, #DMA3_SRC]         @@ Write color address to dma source address
    orr r3, r3, #0x81000000         @@ Set dma control to copy colour 'width' times

.L_drawRectCornerYLoop:
    str r0, [r1, #DMA3_DST]         @@ Write pixel address to dma destination address
    str r3, [r1, #DMA3_CNT]         @@ Set dma control to copy colour 'width' times

    add r0, r0, r12         	    @@ Move down vertically to next line
	subs r2, r2, #1 			    @@ Height -= 1
	bne .L_drawRectCornerYLoop	    @@ /
    pop {r4}
    bx lr                           @@ Return
.size m3_drawRectFromCorner, .-m3_drawRectFromCorner


@@ Parameters: (r0, graphics addr), (r1, top left x), (r2, top left y), (r3, width), (sp #0, height), (sp #4, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawRectEmpty
.type m3_drawRectEmpty STT_FUNC
m3_drawRectEmpty:
    push {r4, r5}
    mov r12, #CANVAS_WIDTH

    mla r1, r2, r12, r1             @@ pixel = y * CANVAS_WIDTH + x
    add r0, r0, r1, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    ldr r2, [sp, #(0+8)]            @@ Load height
    lsl r12, r12, #BPP_POW          @@ Setup (CANVAS_WIDTH) * bytes per pixel
    mov r5, #ADDR_IO                @@ Prepare dma address base

    ldr r4, [sp, #(4+8)]            @@ Load color address
    str r4, [r5, #DMA3_SRC]         @@ Write color address to dma source address
    ldrh r4, [r4]                   @@ Load color value

    str r0, [r5, #DMA3_DST]         @@ Write pixel address to dma destination address
    orr r1, r3, #0x81000000         @@ Set dma control to copy colour 'width' times
    str r1, [r5, #DMA3_CNT]         @@ /
    add r0, r3, lsl #BPP_POW        @@ Move right horizotally by width

    mov r1, r2
.L_drawRectEmptyYLoop1:
    strh r4, [r0], r12              @@ Draw pixel, and move down vertically
    subs r1, #1                     @@ Height -= 1
    bne .L_drawRectEmptyYLoop1

    mov r1, #0x81000000             @@ Prepare dma control value
    orr r1, r1, #0x200000           @@ /
    str r0, [r5, #DMA3_DST]         @@ Write pixel address to dma destination address
    orr r1, r3, r1                  @@ Set dma control to copy colour 'width' times
    str r1, [r5, #DMA3_CNT]         @@ /
    sub r0, r3, lsl #BPP_POW        @@ Move left horizotally by width

    mov r1, r2
    neg r12, r12
.L_drawRectEmptyYLoop2:
    strh r4, [r0], r12              @@ Draw pixel, and move up vertically
    subs r1, #1                     @@ Height -= 1
    bne .L_drawRectEmptyYLoop2
    pop {r4, r5}
    bx lr                           @@ Return
.size m3_drawRectEmpty, .-m3_drawRectEmpty


@@ Parameters: (r0, graphics addr), (r1, center x), (r2, center y), (r3, radius), (sp #0, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawCircle
.type m3_drawCircle STT_FUNC
m3_drawCircle:
    push {r4-r10}
    
    mov r12, #CANVAS_WIDTH          @@ Prepeare screen width
    mov r10, #ADDR_IO               @@ Prepare dma address base
    ldr r9, [sp, #(0+28)]           @@ Load color
    str r9, [r10, #DMA3_SRC]        @@ Write color address to dma source address

    mov r4, #0                      @@ y = 0
    rsb r5, r3, #1                  @@ error = 1 - x

.L_drawCircleLoop:
    sub r6, r1, r4                  @@ line x0 = center x - y
    movs r7, r4, lsl #1             @@ line width = y * 2
    beq .L_drawCircleLoopSkip1      @@ Skip if line width is 0
    orr r7, r7, #0x81000000         @@ Set dma control to copy colour 'line width' times

    add r8, r2, r3                  @@ line y = center y + x
    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    str r8, [r10, #DMA3_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA3_CNT]        @@ Draw line

    sub r8, r2, r3                  @@ line y = center y - x
    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    str r8, [r10, #DMA3_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA3_CNT]        @@ Draw line

.L_drawCircleLoopSkip1:
    sub r6, r1, r3                  @@ line x0 = center x - x
    movs r7, r3, lsl #1             @@ line width = x * 2
    beq .L_drawCircleLoopSkip2      @@ Skip if line width is 0
    orr r7, r7, #0x81000000         @@ Set dma control to copy colour 'line width' times

    add r8, r2, r4                  @@ line y = center y + y
    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    str r8, [r10, #DMA3_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA3_CNT]        @@ Draw line

    sub r8, r2, r4                  @@ line y = center y - y
    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    str r8, [r10, #DMA3_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA3_CNT]        @@ Draw line

.L_drawCircleLoopSkip2:
    add r4, r4, #1                  @@ y++
    cmp r5, #0                  
    movle r6, r4                    @@ If error <= 0: r6 = y
    subgt r3, r3, #1                @@ If error > 0: x--
    subgt r6, r4, r3                @@ If error > 0: r6 = y - x

    add r5, r5, r6, lsl #1          @@ error = error + r6 * 2
    add r5, r5, #1                  @@ error += 1
    
    cmp r3, r4                      @@ Loop while x >= y
    bge .L_drawCircleLoop           @@ /
    
    pop {r4-r10}
    bx lr                           @@ Return
.size m3_drawCircle, .-m3_drawCircle


@@ Parameters: (r0, graphics addr), (r1, center x), (r2, center y), (r3, radius), (sp #0, 16 bit color)
@@ Return: void
.align 2
.arm
.global m3_drawCircleEmpty
.type m3_drawCircleEmpty STT_FUNC
m3_drawCircleEmpty:
    push {r4-r9}
    
    mov r12, #CANVAS_WIDTH          @@ Prepeare screen width
    ldrh r9, [sp, #(0+24)]          @@ Load color
    orr r9, r9, r9, lsl #0x10       @@ Turn 16 bit color to 32 bit color using OR

    mov r4, #0                      @@ y = 0
    rsb r5, r3, #1                  @@ error = 1 - x

.L_drawCircleEmptyLoop:
    sub r6, r1, r4                  @@ pixel x0 = center x - y
    add r8, r2, r3                  @@ pixel y = center y + x

    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r4, lsl #BPP            @@ Move left horizontally by radius (y) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    sub r8, r2, r3                  @@ pixel y = center y - x

    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r4, lsl #BPP            @@ Move left horizontally by radius (y) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    sub r6, r1, r3                  @@ pixel x0 = center x - x
    add r8, r2, r4                  @@ pixel y = center y + y

    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r3, lsl #BPP            @@ Move left horizontally by radius (x) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    sub r8, r2, r4                  @@ pixel y = center y - y

    mla r8, r12, r8, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = graphics address + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r3, lsl #BPP            @@ Move left horizontally by radius (x) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    add r4, r4, #1                  @@ y++
    cmp r5, #0                  
    movle r6, r4                    @@ If error <= 0: r6 = y
    subgt r3, r3, #1                @@ If error > 0: x--
    subgt r6, r4, r3                @@ If error > 0: r6 = y - x

    add r5, r5, r6, lsl #1          @@ error = error + r6 * 2
    add r5, r5, #1                  @@ error += 1
    
    cmp r3, r4                      @@ Loop while x >= y
    bge .L_drawCircleEmptyLoop      @@ /
    
    pop {r4-r9}
    bx lr                           @@ Return
.size m3_drawCircleEmpty, .-m3_drawCircleEmpty


@@ Parameters: (r0, graphics addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_mirrorScreenHorz
.type m3_mirrorScreenHorz STT_FUNC
m3_mirrorScreenHorz:  
    mov r1, #ADDR_IO
    mov r2, #CANVAS_HEIGHT          @@ Height

.L_mirrorScreenHorzLoop:
    str r0, [r1, #DMA3_SRC]         @@ Write start of the current row to dma source address
    add r0, #CANVAS_WIDTH * BPP     @@ Write end of the current row to dma destination address
    sub r0, #BPP                    @@ /
    str r0, [r1, #DMA3_DST]         @@ /

    mov r3, #0x80000000             @@ Set dma control to increment the source address and decrement the destination adrress
    orr r3, r3, #0x200000           @@ /
    orr r3, r3, #CANVAS_WIDTH / 2   @@ Set dma control to copy half the width amount of pixels
    str r3, [r1, #DMA3_CNT]         @@ Start dma

    add r0, #BPP                    @@ Increment the current row to next row
    subs r2, #1                     @@ Height -= 1
    bne .L_mirrorScreenHorzLoop     @@ While Height > 0, mirror the current row

    bx lr                           @@ Return
.size m3_mirrorScreenHorz, .-m3_mirrorScreenHorz


@@ Parameters: (r0, graphics addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_mirrorScreenVert
.type m3_mirrorScreenVert STT_FUNC
m3_mirrorScreenVert: 
    push {r4}

    mov r1, #ADDR_IO
    add r2, r0, #PIXEL_COUNT * BPP  @@ Calculate the start address of the last row
    sub r2, r2, #CANVAS_WIDTH * BPP @@ /
    mov r4, #CANVAS_HEIGHT / 2      @@ Height = half screen height

.L_mirrorScreenVertLoop:
    str r0, [r1, #DMA3_SRC]         @@ Write start of the current row to dma source address
    add r0, #CANVAS_WIDTH * BPP     @@ Current row += 1
    str r2, [r1, #DMA3_DST]         @@ Write start of the last row to dma destination address
    sub r2, #CANVAS_WIDTH * BPP     @@ Last row -= 1

    mov r3, #0x84000000             @@ Set dma control to increment the source and destination adrress
    orr r3, r3, #CANVAS_WIDTH / 2   @@ Set dma control to copy the width amount of pixels
    str r3, [r1, #DMA3_CNT]         @@ Start dma

    subs r4, #1                     @@ Height -= 1
    bne .L_mirrorScreenVertLoop     @@ While Height > 0, mirror the current row

    pop {r4}
    bx lr                           @@ Return
.size m3_mirrorScreenVert, .-m3_mirrorScreenVert


@@ Parameters: (r0, graphics addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_mirrorScreenDiag
.type m3_mirrorScreenDiag STT_FUNC
m3_mirrorScreenDiag: 
    mov r1, #ADDR_IO

    str r0, [r1, #DMA3_SRC]         @@ Write the top left corner to dma source address
    add r0, r0, #PIXEL_COUNT * BPP  @@ Write the bottom right corner to dma destination address
    str r0, [r1, #DMA3_DST]         @@ /

    mov r2, #0x80000000             @@ Set dma control to increment the source address and decrement the destination adrress
    orr r2, r2, #0x200000           @@ /
    orr r2, r2, #PIXEL_COUNT / 2    @@ Set dma control to copy half the amount of pixels
    str r2, [r1, #DMA3_CNT]         @@ Start dma

    bx lr                           @@ Return
.size m3_mirrorScreenDiag, .-m3_mirrorScreenDiag


@@ Parameters: (r0, enable), (r1, use thick lines)
@@ Return: void
.section .ewram, "ax", %progbits
.align 2
.arm
.global setWireframe
.type setWireframe STT_FUNC
setWireframe: 
    push {lr}
    cmp r0, #0
    beq .L_setWireframeDisable

    cmp r1, #0                                              @@ Should we use thick lines
    mov r0, #ADDR_IO
.irp section, wireframeDataSections
    .if \section != 4 && \section != 6
        ldr r1, =.G_wireframeDataDst\section                @@ Load destination code address
        ldr r2, =enableWireframeDataSrc\section             @@ Load source code address
        mov r3, #wireframeDataSize\section                  @@ Load code size
        bl .L_setWireframeReplaceCode                       @@ Replace code
    .else
        .irp index, TRI_LOOP_UNROLL
            ldr r1, =.G_wireframeDataDst\section\index      @@ Load destination code address
            ldr r2, =enableWireframeDataSrc\section         @@ Load source code address
            mov r3, #wireframeDataSize\section              @@ Load code size
            bl .L_setWireframeReplaceCode                   @@ Replace code

            .if \section == 4
                                                                @@ Select thin or thick lines
                addeq r2, r2, #52                               @@ Load source code address
                addne r2, r2, #44                               @@ Load source code address
                add r1, r1, #36                                 @@ Load destiantion code address
            .else
                addeq r2, r2, #56                               @@ Load source code address
                addne r2, r2, #48                               @@ Load source code address
                add r1, r1, #40                                 @@ Load destiantion code address
            .endif
            mov r3, #2                                      @@ 2 lines
            bl .L_setWireframeReplaceCode                   @@ Replace code

            ldr r1, =.G_wireframeDataDstClipped\section\index @@ Load destination code address
            ldr r2, =enableWireframeDataSrc\section         @@ Load source code address
            mov r3, #wireframeDataSize\section              @@ Load code size
            bl .L_setWireframeReplaceCode                   @@ Replace code

            .if \section == 4
                                                                @@ Select thin or thick lines
                addeq r2, r2, #52                               @@ Load source code address
                addne r2, r2, #44                               @@ Load source code address
                add r1, r1, #36                                 @@ Load destiantion code address
            .else
                addeq r2, r2, #56                               @@ Load source code address
                addne r2, r2, #48                               @@ Load source code address
                add r1, r1, #40                                 @@ Load destiantion code address
            .endif
            mov r3, #2                                      @@ 2 lines
            bl .L_setWireframeReplaceCode                   @@ Replace code

        .endr
    .endif
.endr
    pop {lr}                                                @@ Return
    bx lr                                                   @@ /

.L_setWireframeDisable:
    mov r0, #ADDR_IO
.irp section, wireframeDataSections
    .if \section != 4 && \section != 6
        ldr r1, =.G_wireframeDataDst\section                @@ Load destination code address
        ldr r2, =disableWireframeDataSrc\section            @@ Load source code address
        mov r3, #wireframeDataSize\section                  @@ Load code size
        bl .L_setWireframeReplaceCode                       @@ Replace code
    .else
        .irp index, TRI_LOOP_UNROLL
            ldr r1, =.G_wireframeDataDst\section\index      @@ Load destination code address
            ldr r2, =disableWireframeDataSrc\section        @@ Load source code address
            mov r3, #wireframeDataSize\section              @@ Load code size
            bl .L_setWireframeReplaceCode                   @@ Replace code

            ldr r1, =.G_wireframeDataDstClipped\section\index @@ Load destination code address
            ldr r2, =disableWireframeDataSrc\section        @@ Load source code address
            mov r3, #wireframeDataSize\section              @@ Load code size
            bl .L_setWireframeReplaceCode                   @@ Replace code
        .endr
    .endif
.endr
    pop {lr}                                                @@ Return
    bx lr                                                   @@ /

.L_setWireframeReplaceCode:
    str r2, [r0, #DMA3_SRC]                                 @@ Write the source code address to dma source address
    str r1, [r0, #DMA3_DST]                                 @@ Write the destination code address to dma destination address
    orr r3, r3, #0x84000000                                 @@ Set dma control to source code to desitination code
    str r3, [r0, #DMA3_CNT]                                 @@ /
    bx lr
.size setWireframe, .-setWireframe


@@ Parameters: void
@@ Return: (r0, enabled)
.section .ewram, "ax", %progbits
.align 2
.arm
.global isWireframeEnabled
.type isWireframeEnabled STT_FUNC
isWireframeEnabled: 
    ldr r1, =.G_wireframeDataDst1           @@ Load the excecuting code
    ldr r1, [r1]                            @@ /
    ldr r2, =enableWireframeDataSrc1        @@ Load the enbled code
    ldr r2, [r2]                            @@ /
    cmp r1, r2                              @@ If the excecuting code is the enbled code
    moveq r0, #1                            @@ return true
    movne r0, #0                            @@ else return false
    bx lr                                   @@ return
.size isWireframeEnabled, .-isWireframeEnabled


@@ Parameters: (r0, graphics addr), (r1, model addr), (r2, triangle count), (r3, xPos), (sp #0, yPos), (sp #4, zpos)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global draw3DModel
.type draw3DModel STT_FUNC
draw3DModel: 
    push {r4-r11, lr}
    mov r4, r1
    ldr r1, =.L_draw3DModelLoopContinue @@ Setup continue addr
    add r2, r2, r2, lsl #2              @@ temp = triangle count * 5
    add r2, r4, r2, lsl #2              @@ model end addr = model addr + temp * 4
    push {r1-r4}                        @@ Save: loop continue addr (r1), end triangle addr (r2), xPos (r3), current triangle addr (r4)
    ldr r12, =LUT_DIVISION              @@ Load lut

.L_draw3DModelLoop:
    ldr r11, [sp, #24]                  @@ Load zPos
    ldrsh r3, [r4, #4]                  @@ Load vertx1.z
    add r3, r3, r11                     @@ zPos + vertx1.z
    cmp r3, #NEAR_PLANE                 @@ If vertx1.z < NEAR_PLANE:
    blt .L_draw3DModelLoopEnd           @@ Skip to next triangle

    add r10, r4, #18                    @@ Load colour
    ldrsh r9, [r4, #16]                 @@ Load vertx3.z
    ldrsh r6, [r4, #10]                 @@ Load vertx2.z

#if GRAPHICS_MODE == 5 && PREPROCESSED_DATA == 0
    ldrsh r2, [r4, #0]                  @@ Load vertx1.x
    ldrsh r8, [r4, #12]                 @@ Load vertx3.x
    ldrsh r5, [r4, #6]                  @@ Load vertx2.x
    ldrsh r1, [r4, #2]                  @@ Load vertx1.y
    ldrsh r7, [r4, #14]                 @@ Load vertx3.y
    ldrsh r4, [r4, #8]                  @@ Load vertx2.y
#else
    ldrsh r2, [r4, #2]                  @@ Load vertx1.y
    ldrsh r8, [r4, #14]                 @@ Load vertx3.y
    ldrsh r5, [r4, #8]                  @@ Load vertx2.y
    ldrsh r1, [r4, #0]                  @@ Load vertx1.x
    ldrsh r7, [r4, #12]                 @@ Load vertx3.x
    ldrsh r4, [r4, #6]                  @@ Load vertx2.x
#endif

    add r9, r9, r11                     @@ zPos + vertx3.z
    add r6, r6, r11                     @@ zPos + vertx2.z
    
    ldr r11, [sp, #52]                  @@ Load yPos
    ldr lr, [sp, #8]                    @@ Load xPos
#if GRAPHICS_MODE == 5 && PREPROCESSED_DATA == 0
    add r2, r2, lr                      @@ xpos + vertex1.y
    add r5, r5, lr                      @@ xpos + vertex3.y
    add r8, r8, lr                      @@ xpos + vertex2.y
    add r1, r1, r11                     @@ ypos + vertex1.x
    add r7, r7, r11                     @@ ypos + vertex3.x
    add r4, r4, r11                     @@ ypos + vertex2.x
    asr r2, r2, #1
    asr r5, r5, #1
    asr r8, r8, #1
#else
    add r2, r2, r11                     @@ ypos + vertex1.y
    add r5, r5, r11                     @@ ypos + vertex3.y
    add r8, r8, r11                     @@ ypos + vertex2.y
    add r1, r1, lr                      @@ xpos + vertex1.x
    add r7, r7, lr                      @@ xpos + vertex3.x
    add r4, r4, lr                      @@ xpos + vertex2.x
#endif

    b .G_drawTriangle3DAsm              @@ Draw triangle
.L_draw3DModelLoopContinue:
    ldr r4, [sp, #12]                   @@ Load current triangle addr
    ldr r2, [sp, #4]                    @@ Load end triangle addr
    mov r12, r8                         @@ Load lut

.L_draw3DModelLoopEnd:
    add r4, r4, #20                     @@ Increment triangle memory addr to next triangle
    str r4, [sp, #12]                   @@ /
    cmp r4, r2                          @@ While triangle count > 0, draw next triangle
    blt .L_draw3DModelLoop              @@ /

    pop {r0-r12}                        @@ Return
    bx r12                              @@ /
.size draw3DModel, .-draw3DModel


@@ Parameters: (r0, graphics addr), (r1, x1),       (r2, y1),       (r3, z1), 
@@                                  (sp #0, x2),    (sp #4, y2),    (sp #8, z2), 
@@                                  (sp #12, x3),   (sp #16, y3),   (sp #20, z3), 
@@             (sp #24, 16 bit color addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangle3D
.type m3_drawTriangle3D STT_FUNC
m3_drawTriangle3D:
    cmp r3, #NEAR_PLANE                 @@ If z1 < NEAR_PLANE:
    bxlt lr                             @@ Return

	push {r4-r11, lr}                   @@ Save registers
    ldr r12, =.G_drawTriangle3dEnd      @@ For if the function is called using .G_drawTriangle3DAsm
    push {r12}                          @@ /
    
	ldr r12, =LUT_DIVISION              @@ Load lut
	add r10, sp, #40                    @@ Get offset into the stack
	ldmia r10, {r4-r9, r10}             @@ Load Vertex2, Vertex3 and colour
.G_drawTriangle3DAsm:
    mov r11, #ADDR_IO                   @@ Dma address base
    str r10, [r11, #DMA3_SRC]           @@ Write color address to dma source address
#if WIREFRAME == 1
.G_wireframeDataDst1:
    M_ENABLEWIREFRAMEDATASCR1
#else
.G_wireframeDataDst1:
    M_DISABLEWIREFRAMEDATASCR1
#endif

    cmp r9, #NEAR_PLANE                 @@ If z3 < NEAR_PLANE:
    bge .L_drawTriangle3DProject        @@ No clipping needed
    
    cmp r6, #NEAR_PLANE                 @@ If z2 < NEAR_PLANE:
    bge .L_drawTriangle3D2Vert          @@ /

                                        @@ Clip 2 vertices, one resulting triangle drawn
    sub r11, r3, #NEAR_PLANE            @@ LerpTemp = z1 - NEAR_PLANE
    lsl r11, r11, #16                   @@ Add precision

    sub r10, r3, r9                     @@ LerpTemp2 = z1 - z3
    ldr r10, [r12, r10, lsl #2]         @@ Load 1 / LerpTemp2
    umull lr, r10, r11, r10             @@ LerpMul2 = LerpTemp / LerpTemp2, lr is trashed

    sub r7, r7, r1                      @@ (((x3 - x1)))
    mul r7, r10, r7                     @@ (((x3 - x1) * LerpMul2))
    add r7, r1, r7, asr #16             @@ (((x3 - x1) * LerpMul2) >> 16) + x1

    sub r8, r8, r2                      @@ (((y3 - y1)))
    mul r8, r10, r8                     @@ (((y3 - y1) * LerpMul2))
    add r8, r2, r8, asr #16             @@ (((y3 - y1) * LerpMul2) >> 16) + y1

    sub r9, r9, r3                      @@ (((z3 - z1)))
    mul r9, r10, r9                     @@ (((z3 - z1) * LerpMul2))
    add r9, r3, r9, asr #16             @@ (((z3 - z1) * LerpMul2) >> 16) + z1

    sub r10, r3, r6                     @@ LerpTemp1 = z1 - z2
    ldr r10, [r12, r10, lsl #2]         @@ Load 1 / LerpTemp1
    umull lr, r10, r11, r10             @@ LerpMul1 = LerpTemp / LerpTemp1, lr is trashed

    sub r4, r4, r1                      @@ (((x2 - x1)))
    mul r4, r10, r4                     @@ (((x2 - x1) * LerpMul1))
    add r4, r1, r4, asr #16             @@ (((x2 - x1) * LerpMul1) >> 16) + x1

    sub r5, r5, r2                      @@ (((y2 - y1)))
    mul r5, r10, r5                     @@ (((y2 - y1) * LerpMul1))
    add r5, r2, r5, asr #16             @@ (((y2 - y1) * LerpMul1) >> 16) + y1

    sub r6, r6, r3                      @@ (((z2 - z1)))
    mul r6, r10, r6                     @@ (((z2 - z1) * LerpMul1))
    add r6, r3, r6, asr #16             @@ (((z2 - z1) * LerpMul1) >> 16) + z1
    
    b .L_drawTriangle3DProject          @@ Draw triangle

.L_drawTriangle3D2Vert:
    push {r4-r6}                        @@ Save vertex 2
    
    sub r11, r6, #NEAR_PLANE            @@ LerpTemp3 = z2 - NEAR_PLANE
    lsl r11, r11, #16                   @@ Add precision

    sub r10, r6, r9                     @@ LerpTemp4 = z2 - z3
    ldr r10, [r12, r10, lsl #2]         @@ Load 1 / LerpTemp4
    umull lr, r10, r11, r10             @@ LerpMul3 = LerpTemp3 / LerpTemp4, lr is trashed

    sub r11, r7, r4                     @@ (((x3 - x2)))
    mul r11, r10, r11                   @@ (((x3 - x2) * LerpMul3))
    add r4, r4, r11, asr #16            @@ (((x3 - x2) * LerpMul3) >> 16) + x2

    sub r11, r8, r5                     @@ (((y3 - y2)))
    mul r11, r10, r11                   @@ (((y3 - y2) * LerpMul3))
    add r5, r5, r11, asr #16            @@ (((y3 - y2) * LerpMul3) >> 16) + y2

    sub r11, r9, r6                     @@ (((z3 - z2)))
    mul r11, r10, r11                   @@ (((z3 - z2) * LerpMul3))
    add r6, r6, r11, asr #16            @@ (((z3 - z2) * LerpMul3) >> 16) + z2
    
    sub r11, r3, #NEAR_PLANE            @@ LerpTemp = z1 - NEAR_PLANE
    lsl r11, r11, #16                   @@ Add precision

    sub r10, r3, r9                     @@ LerpTemp2 = z1 - z3
    ldr r10, [r12, r10, lsl #2]         @@ Load 1 / LerpTemp2
    umull lr, r10, r11, r10             @@ LerpMul2 = LerpTemp / LerpTemp2, lr is trashed

    sub r7, r7, r1                      @@ (((x3 - x1)))
    mul r7, r10, r7                     @@ (((x3 - x1) * LerpMul2))
    add r7, r1, r7, asr #16             @@ (((x3 - x1) * LerpMul2) >> 16) + x1

    sub r8, r8, r2                      @@ (((y3 - y1)))
    mul r8, r10, r8                     @@ (((y3 - y1) * LerpMul2))
    add r8, r2, r8, asr #16             @@ (((y3 - y1) * LerpMul2) >> 16) + y1

    sub r9, r9, r3                      @@ (((z3 - z1)))
    mul r9, r10, r9                     @@ (((z3 - z1) * LerpMul2))
    add r9, r3, r9, asr #16             @@ (((z3 - z1) * LerpMul2) >> 16) + z1
    
    push {r1-r3, r7-r9}                 @@ Save vertices 1 and 3
    ldr lr, =.L_drawTriangle3DSecondTri @@ Set return address to second trinagle draw
    push {lr}
    add r10, r13, #28                   @@ Offset stack pointer
    ldmfd r10, {r1-r3}                  @@ Load vertex 2
    b .L_drawTriangle3DProject          @@ Draw triangle
.L_drawTriangle3DSecondTri:
    mov r12, r8                         @@ Load lut
    mov r11, r0                         @@ Save graphics addr
    pop {r0-r9}                         @@ Load vertices 1, 2 and 3
    mov r0, r11                         @@ Restore graphics addr
    b .L_drawTriangle3DProject          @@ Draw triangle   

.L_drawTriangle3DProject:

                                        @@ Vertex1 to screen pos
	ldr r3, [r12, r3, lsl #2]           @@ Load 1 / z1
#if LUT_DIVISION_SIGNED_FIX == 1
    cmp r1, #0                          @@ Check for sign
    neglt r1, r1                        @@ Remove sign
    lsl r1, r1, #FOV_POW                @@ x1 * fov
	umull r11, r1, r3, r1               @@ (x1 * fov) / z1, r11 is trashed
    neglt r1, r1                        @@ Add sign

    cmp r2, #0                          @@ Check for sign
    neglt r2, r2                        @@ Remove sign
    lsl r2, r2, #FOV_POW                @@ y1 * fov
	umull r11, r2, r3, r2               @@ (y1 * fov) / z1, r11 is trashed
    neglt r2, r2                        @@ Add sign
#else
    lsl r1, r1, #FOV_POW                @@ x1 * fov
	smull r11, r1, r3, r1               @@ (x1 * fov) / z1, r11 is trashed
    lsl r2, r2, #FOV_POW                @@ y1 * fov
	smull r11, r2, r3, r2               @@ (y1 * fov) / z1, r11 is trashed
#endif
	add r1, r1, #CANVAS_WIDTH/2         @@ sX1 = (x1 * fov) / z1 + centerScreenX
	add r2, r2, #CANVAS_HEIGHT/2        @@ sY1 = (y1 * fov) / z1 + centerScreenY
		
                                        @@ Vertex2 to screen pos
	ldr r6, [r12, r6, lsl #2]           @@ Load 1 / z2
#if LUT_DIVISION_SIGNED_FIX == 1
    cmp r4, #0                          @@ Check for sign
    neglt r4, r4                        @@ Remove sign
    lsl r4, r4, #FOV_POW                @@ x2 * fov
	umull r11, r4, r6, r4               @@ (x2 * fov) / z2, r11 is trashed
    neglt r4, r4                        @@ Add sign

    cmp r5, #0                          @@ Check for sign
    neglt r5, r5                        @@ Remove sign
    lsl r5, r5, #FOV_POW                @@ y2 * fov
	umull r11, r5, r6, r5               @@ (y2 * fov) / z2, r11 is trashed
    neglt r5, r5                        @@ Add sign
#else
    lsl r4, r4, #FOV_POW                @@ x2 * fov
	smull r11, r4, r6, r4               @@ (x2 * fov) / z2, r11 is trashed
    lsl r5, r5, #FOV_POW                @@ y2 * fov
	smull r11, r5, r6, r5               @@ (y2 * fov) / z2, r11 is trashed
#endif
	add r3, r4, #CANVAS_WIDTH/2         @@ sX2 = (x2 * fov) / z2 + centerScreenX
	add r4, r5, #CANVAS_HEIGHT/2        @@ sY2 = (y2 * fov) / z2 + centerScreenY

                                        @@ Vertex3 to screen pos
	ldr r9, [r12, r9, lsl #2]           @@ Load 1 / z3
#if LUT_DIVISION_SIGNED_FIX == 1
    cmp r7, #0                          @@ Check for sign
    neglt r7, r7                        @@ Remove sign
    lsl r7, r7, #FOV_POW                @@ x3 * fov
	umull r11, r5, r9, r7               @@ (x3 * fov) / z3, r11 is trashed
    neglt r5, r5                        @@ Add sign

    cmp r8, #0                          @@ Check for sign
    neglt r8, r8                        @@ Remove sign
    lsl r8, r8, #FOV_POW                @@ y3 * fov
	umull r11, r6, r9, r8               @@ (y3 * fov) / z3, r11 is trashed
    neglt r6, r6                        @@ Add sign
#else
    lsl r7, r7, #FOV_POW                @@ x3 * fov
	smull r11, r5, r9, r7               @@ (x3 * fov) / z3, r11 is trashed
    lsl r8, r8, #FOV_POW                @@ y3 * fov
	smull r11, r6, r9, r8               @@ (y3 * fov) / z3, r11 is trashed
#endif
	add r5, r5, #CANVAS_WIDTH/2         @@ sX3 = (x3 * fov) / z3 + centerScreenX
	add r6, r6, #CANVAS_HEIGHT/2        @@ sY3 = (y3 * fov) / z3 + centerScreenY

    mov r8, r12                         @@ Load lut

#if BACKFACE_CULLING == 1
    @@ Backface culling is not always faster!
    @@TODO: Does not work properly with 3d clipping. Vertex order is not the same after clipping. To fix this, sorting needs to be applied.
    sub r7, r3, r1                      @@ Get triangle side vectors
    sub r10, r4, r2                     @@ /
    sub r9, r5, r1                      @@ /
    sub r11, r6, r2                     @@ /

    mul r7, r11, r7                     @@ Calculate cross product
    mul r10, r9, r10                    @@ /
    subs r7, r7, r10                    @@ / 

    bmi .G_drawTriangleClippedAsm       @@ Draw 2d triangle, if facing camera

    ldr r12, [sp]                       @@ First return
    bx r12                              @@ /
#else
	b .G_drawTriangleClippedAsm         @@ Draw 2d triangle
#endif
.G_drawTriangle3dEnd:
    pop {r3-r12}                        @@ Final return
    bx r12                              @@ /
.size m3_drawTriangle3D, .-m3_drawTriangle3D


@@ Parameters: (r0, graphics addr), (r1, x1), (r2, y1), (r3, x2), (sp #0, y2), (sp #4, x3), (sp #8, y3), (sp #12, 16 bit color addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangleClipped
.type m3_drawTriangleClipped STT_FUNC
m3_drawTriangleClipped:
    push {r4-r11, lr}                   @@ Save registers
    ldr r12, =.G_drawTriangle3dEnd      @@ For if the function is called using .G_drawTriangle3DAsm
    push {r12}                          @@ /
    
    add r8, sp, #40                     @@ Get stack offset address
    ldmia r8, {r4, r5, r6, r10}         @@ Load y2, x3, y3 and color addr from stack

    mov r8, #ADDR_IO                    @@ Dma address base
    str r10, [r8, #DMA3_SRC]            @@ Write color address to dma source address
#if WIREFRAME == 1
.G_wireframeDataDst2:
    M_ENABLEWIREFRAMEDATASCR2
#else
.G_wireframeDataDst2:
    M_DISABLEWIREFRAMEDATASCR2
#endif
    ldr r8, =LUT_DIVISION               @@ Load lut
.G_drawTriangleClippedAsm:
                                        @@ Sort vertices by y value (top vertex in v1)
    cmp r2, r4
    ble .L_drawTriangleClippedFirstLE
    eor r1, r1, r3                      @@ Swap v1.x and v2.x
    eor r3, r3, r1                      @@ /
    eor r1, r1, r3                      @@ /
    eor r2, r2, r4                      @@ Swap v1.y and v2.y
    eor r4, r4, r2                      @@ /
    eor r2, r2, r4                      @@ /
.L_drawTriangleClippedFirstLE:
    cmp r4, r6
    ble .L_drawTriangleClippedSecondLE
    eor r3, r3, r5                      @@ Swap v2.x and v3.x
    eor r5, r5, r3                      @@ /
    eor r3, r3, r5                      @@ /
    eor r4, r4, r6                      @@ Swap v2.y and v3.y
    eor r6, r6, r4                      @@ /
    eor r4, r4, r6                      @@ /
.L_drawTriangleClippedSecondLE:
    cmp r2, r4
    ble .L_drawTriangleClippedThirdLE
    eor r1, r1, r3                      @@ Swap v1.x and v2.x
    eor r3, r3, r1                      @@ /
    eor r1, r1, r3                      @@ /
    eor r2, r2, r4                      @@ Swap v1.y and v2.y
    eor r4, r4, r2                      @@ /
    eor r2, r2, r4                      @@ /
.L_drawTriangleClippedThirdLE:

    cmp r2, r4
    bne .L_drawTriangleClippedBottomEnd @@ Skip if triangle is not bottom triangle
    sub r9, r6, r2                      @@ Delta y bottom = v3.y - v1.y
    cmp r1, r3                          @@ if v1.x > v2.x
    eorgt r1, r1, r3                    @@ Swap v1.x and v2.x
    eorgt r3, r3, r1                    @@ /
    eorgt r1, r1, r3                    @@ /
    mov r7, r3
    mov r3, r1

    ldr lr, =.L_drawTriangleClippedEnd  @@ Set return address to end
    b m3_drawTriangleClippedBottom 
.L_drawTriangleClippedBottomEnd:

    sub r9, r4, r2                      @@ Delta y top = v2.y - v1.y
    cmp r4, r6
    bne .L_drawTriangleClippedTopEnd    @@ Skip if triangle is not top triangle
    cmp r3, r5                          @@ if v2.x > v3.x
    eorgt r3, r3, r5                    @@ Swap v2.x and v3.x
    eorgt r5, r5, r3                    @@ /
    eorgt r3, r3, r5                    @@ /
    mov r7, r5
    ldr lr, =.L_drawTriangleClippedEnd  @@ Set return address to end
    b m3_drawTriangleClippedTop
.L_drawTriangleClippedTopEnd:

                                        @@ Calculate v4.x
    mov r12, r9, lsl #16                @@ Delta y top * added precision
    sub r7, r6, r2                      @@ Delta y = v3.y - v1.y
    ldr r7, [r8, r7, lsl #2]            @@ Load (1 / delta y)
    umull lr, r12, r7, r12              @@ Dy = Delta y top / Delta y
    
    sub r7, r5, r1                      @@ Dx = v3.x - v1.x
    mul r12, r7, r12                    @@ Xoffset = dy * dx
    add r7, r1, r12, asr #16            @@ v4.x = v1.x + xoffset / added precision
    
    cmp r3, r7                          @@ if v2.x > v4.x
    eorgt r3, r3, r7                    @@ Swap v2.x and v4.x
    eorgt r7, r7, r3                    @@ /
    eorgt r3, r3, r7                    @@ /

    bl m3_drawTriangleClippedTop
    sub r9, r6, r4                      @@ Delta y bottom = v3.y - v2.y
    bl m3_drawTriangleClippedBottom

.L_drawTriangleClippedEnd:
    ldr r12, [sp]                       @@ First return
    bx r12                              @@ /

.global WIREFRAME_COLOR
WIREFRAME_COLOR:
    .hword	0xBC
.size m3_drawTriangleClipped, .-m3_drawTriangleClipped


@@ Insert the const pool
.LTORG


@@ Parameters: (r0, graphics addr), (r5, x1), (r6, y1), (r3, x2), (r4, y2/y3), (r7, x3), (r9, delta y)
@@ Comments: Not callable from C/C++! Preserves {r0, r1, r2, r3, r4, r6, r8, r9}. Trashes: {r5, r7, r10, r11, r12}
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangleClippedBottom
.type m3_drawTriangleClippedBottom STT_FUNC
m3_drawTriangleClippedBottom:    
    sub r11, r5, r3                         @@ Delta x1 = x1 - x2
    lsl r11, r11, #16                       @@ Add precision
    sub r12, r5, r7                         @@ Delta x2 = x1 - x3
    lsl r12, r12, #16                       @@ Add precision
    
    ldr r1, [r8, r9, lsl #2]                @@ Load (1 / delta y) from lut
#if LUT_DIVISION_SIGNED_FIX == 1
    cmp r11, #0                             @@ Check for sign
    neglt r11, r11                          @@ Remove sign
    umull r10, r11, r1, r11                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    neglt r11, r11                          @@ Add sign

    cmp r12, #0                             @@ Check for sign
    neglt r12, r12                          @@ Remove sign
    umull r10, r12, r1, r12                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)
    neglt r12, r12                          @@ Add sign
#else
    smull r10, r11, r1, r11                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    smull r10, r12, r1, r12                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)
#endif

    lsl r5, r5, #16                         @@ CurX1 add precision
    mov r10, r5                             @@ CurX2

    cmp r4, #CANVAS_HEIGHT-1                @@ if y2/y3 >= 0 && y2/y3 < height &&
    cmpls r6, #CANVAS_HEIGHT-1              @@ if y1 >= 0 && y1 < height
    bls .L_drawTriangleClippedBottomSkipYClip @@ Trinagle doesn't need y-clipping, skip.

                                            @@ Y clipping
    rsbs r1, r6, #CANVAS_HEIGHT-1           @@ TempInvY = maxY - y1. If (tempInvY < 0) clip y max
    mlalt r5, r11, r1, r5                   @@ CurX1 += invSlope1 * tempInvY
    mlalt r10, r12, r1, r10                 @@ CurX2 += invSlope2 * tempInvY
    addlt r9, r9, r1                        @@ Delta y += tempInvY

    cmp r4, #0                              @@ If (y2/y3 < 0) clip y min
    addmi r9, r9, r4                        @@ Delta y += y2
    movmi r4, #0                            @@ Y2 = 0

    cmp r9, #0                              @@ If (delta y < 0) skip.
    bxmi lr                                 @@ Return

.L_drawTriangleClippedBottomSkipYClip:
    add r9, r4, r9                          @@ CurY = y2/y3 - delta y 
#if GRAPHICS_MODE == 3
    rsb r9, r9, r9, lsl #4                  @@ Prepare curY pixel address: curY * 240
    lsl r9, r9, #4                          @@ /
    rsb r4, r4, r4, lsl #4                  @@ Prepare y2 pixel address: y2 * 240
    lsl r4, r4, #4                          @@ /
#elif GRAPHICS_MODE == 5
    add r9, r9, r9, lsl #2                  @@ Prepare curY pixel address: curY * 160
    lsl r9, r9, #5                          @@ /
    add r4, r4, r4, lsl #2                  @@ Prepare y2 pixel address: y2 * 160
    lsl r4, r4, #5                          @@ /
#endif
    add r9, r0, r9, lsl #BPP_POW            @@ Prepare curY pixel address: curY * bytes per pixel
    add r4, r0, r4, lsl #BPP_POW            @@ Prepare y2 pixel address: y2 * bytes per pixel

    cmp r5, #CANVAS_WIDTH-1                 @@ if x1 >= 0 && x1 < width &&
    cmpls r3, #CANVAS_WIDTH-1               @@ if x2 >= 0 && x2 < width &&
    cmpls r7, #CANVAS_WIDTH-1               @@ if x3 >= 0 && x3 < width -> than...

    mov r3, #CANVAS_WIDTH                   @@ Prepare screen width
    mov r7, #ADDR_IO                        @@ Prepare dma address base
#if WIREFRAME == 1
.G_wireframeDataDst3:
    M_ENABLEWIREFRAMEDATASCR3
#else
.G_wireframeDataDst3:
    M_DISABLEWIREFRAMEDATASCR3
#endif

    bls .L_drawTriangleBottomLoop           @@ ...than triangle doesn't need x-clipping, draw without.

.L_drawTriangleClippedBottomLoop:           @@ Draw loop with x-clipping
.irp index, TRI_LOOP_UNROLL
                                            @@ X clipping
    asrs r1, r5, #16                        @@ TempCurX1 = CurX1 remove precision
    movmi r1, #0                            @@ If (tempCurX1 < 0) tempCurX1 = 0

    asr r2, r10, #16                        @@ tempCurX2 = CurX2 remove precision
    cmp r2, #CANVAS_WIDTH                   @@ If (tempCurX2 >= maxX):
    movge r2, #CANVAS_WIDTH-1               @@ TempCurX2 = maxX

    subs r2, r2, r1                         @@ CurDeltaX = TempCurX2 - TempCurX1
    bmi .L_drawTriangleClippedBottomSkip\index @@ If (CurDeltaX < 0) skip
    add r2, r2, #1                          @@ Add bias to right side

    add r1, r9, r1, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
#if WIREFRAME == 1  
.G_wireframeDataDstClipped4\index:
    M_ENABLEWIREFRAMEDATASCR4
#else 
.G_wireframeDataDstClipped4\index:
    M_DISABLEWIREFRAMEDATASCR4
#endif

.L_drawTriangleClippedBottomSkip\index:
    sub r5, r5, r11                         @@ curX1 -= invSlope1
    sub r10, r10, r12                       @@ curX2 -= invSlope2
    sub r9, r9, r3, lsl #BPP_POW            @@ CurY pixel address -= screen width * bytes per pixel
    cmp r9, r4
    bxlt lr                                 @@ Return if (curY < y2/y3)
.endr
    b .L_drawTriangleClippedBottomLoop      @@ Loop while (curY >= y2/y3)

.L_drawTriangleBottomLoop:                  @@ Draw loop without x-clipping
.irp index, TRI_LOOP_UNROLL
    asr r1, r5, #16                         @@ TempCurX1 = CurX1 remove precision
    asr r2, r10, #16                        @@ tempCurX2 = CurX2 remove precision

    subs r2, r2, r1                         @@ CurDeltaX = TempCurX2 - TempCurX1
    bmi .L_drawTriangleBottomSkip\index     @@ If (CurDeltaX < 0) skip
    add r2, r2, #1                          @@ Add bias to right side

    add r1, r9, r1, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
#if WIREFRAME == 1   
.G_wireframeDataDst4\index:
    M_ENABLEWIREFRAMEDATASCR4
#else
.G_wireframeDataDst4\index:
    M_DISABLEWIREFRAMEDATASCR4
#endif

.L_drawTriangleBottomSkip\index:
    sub r5, r5, r11                         @@ curX1 -= invSlope1
    sub r10, r10, r12                       @@ curX2 -= invSlope2
    sub r9, r9, r3, lsl #BPP_POW            @@ CurY pixel address -= screen width * bytes per pixel
    cmp r9, r4
    bxlt lr                                 @@ Return if (curY < y2/y3)
.endr
    b .L_drawTriangleBottomLoop             @@ Loop while (curY >= y2/y3)
.size m3_drawTriangleClippedBottom, .-m3_drawTriangleClippedBottom


@@ Parameters: (r0, graphics addr), (r1, x1), (r2, y1), (r3, x2), (r4, y2/y3), (r7, x3), (r9, delta y)
@@ Comments: Not callable from C/C++! Preserves {r0, r3, r4, r5, r6, r7, r8}. Trashes: {r1, r2, r9, r10, r11, r12}
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangleClippedTop
.type m3_drawTriangleClippedTop STT_FUNC
m3_drawTriangleClippedTop:    
    push {r4-r8}

    sub r11, r3, r1                         @@ Delta x1 = x2 - x1
    lsl r11, r11, #16                       @@ Add precision
    sub r12, r7, r1                         @@ Delta x2 = x3 - x1
    lsl r12, r12, #16                       @@ Add precision

    ldr r5, [r8, r9, lsl #2]                @@ Load (1 / delta y) from lut
#if LUT_DIVISION_SIGNED_FIX == 1
    cmp r11, #0                             @@ Check for sign
    neglt r11, r11                          @@ Remove sign
    umull r10, r11, r5, r11                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    neglt r11, r11                          @@ Add sign

    cmp r12, #0                             @@ Check for sign
    neglt r12, r12                          @@ Remove sign
    umull r10, r12, r5, r12                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)
    neglt r12, r12                          @@ Add sign
#else
    smull r10, r11, r5, r11                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    smull r10, r12, r5, r12                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)
#endif

    lsl r1, r1, #16                         @@ CurX1 add precision
    mov r10, r1                             @@ CurX2 = curX1

    cmp r2, #CANVAS_HEIGHT-1                @@ if y1 >= 0 && y1 < height &&
    cmpls r4, #CANVAS_HEIGHT-1              @@ if y2/y3 >= 0 && y2/y3 < height
    bls .L_drawTriangleClippedTopSkipYClip  @@ Triangle doesn't need y-clipping, skip.

                                            @@ Y clipping
    rsbs r5, r2, #0                         @@ InvY1 = 0 - y1. If (InvY1 > 0) clip y min.
    mlagt r1, r11, r5, r1                   @@ CurX1 += invSlope1 * InvY1
    mlagt r10, r12, r5, r10                 @@ CurX2 += invSlope2 * InvY1
    subgt r9, r9, r5                        @@ Delta y -= InvY1

    subs r5, r4, #CANVAS_HEIGHT-1           @@ TempY = y2/y3 - maxY. If (tempy > 0) clip y max.
    subgt r9, r9, r5                        @@ Delta y -= TempY
    movgt r4, #CANVAS_HEIGHT-1              @@ Y2/y3 = y max

    cmp r9, #0                              @@ If (delta y < 0) skip.
    bmi .L_drawTriangleClippedTopLoopEnd    @@ /

.L_drawTriangleClippedTopSkipYClip:
    sub r9, r4, r9                          @@ CurY = y2 - delta y 
#if GRAPHICS_MODE == 3
    rsb r9, r9, r9, lsl #4                  @@ Prepare curY pixel address: curY * 240
    lsl r9, r9, #4                          @@ /
    rsb r4, r4, r4, lsl #4                  @@ Prepare y2 pixel address: y2 * 240
    lsl r4, r4, #4                          @@ /
#elif GRAPHICS_MODE == 5
    add r9, r9, r9, lsl #2                  @@ Prepare curY pixel address: curY * 160
    lsl r9, r9, #5                          @@ /
    add r4, r4, r4, lsl #2                  @@ Prepare y2 pixel address: y2 * 160
    lsl r4, r4, #5                          @@ /
#endif
    add r9, r0, r9, lsl #BPP_POW            @@ Prepare curY pixel address: curY * bytes per pixel
    add r4, r0, r4, lsl #BPP_POW            @@ Prepare y2 pixel address: y2 * bytes per pixel

    cmp r1, #CANVAS_WIDTH-1                 @@ if x1 >= 0 && x1 < width &&
    cmpls r3, #CANVAS_WIDTH-1               @@ if x2 >= 0 && x2 < width &&
    cmpls r7, #CANVAS_WIDTH-1               @@ if x3 >= 0 && x3 < width -> than...

    mov r2, #CANVAS_WIDTH                   @@ Prepare screen width
    mov r7, #ADDR_IO                        @@ Prepare dma address base
#if WIREFRAME == 1
.G_wireframeDataDst5:
    M_ENABLEWIREFRAMEDATASCR5
#else
.G_wireframeDataDst5:
    M_DISABLEWIREFRAMEDATASCR5
#endif

    bls .L_drawTriangleTopLoop              @@ ...than triangle doesn't need x-clipping, draw without.

.L_drawTriangleClippedTopLoop:              @@ Draw loop with x-clipping
.irp index, TRI_LOOP_UNROLL
                                            @@ X clipping
    asrs r5, r1, #16                        @@ TempCurX1 = CurX1 remove precision
    movmi r5, #0                            @@ If (tempCurX1 < 0) tempCurX1 = 0

    asr r6, r10, #16                        @@ tempCurX2 = CurX2 remove precision
    cmp r6, #CANVAS_WIDTH                   @@ If (tempCurX2 >= maxX):
    movge r6, #CANVAS_WIDTH-1               @@ TempCurX2 = maxX

    subs r6, r6, r5                         @@ CurDeltaX = TempCurX2 - TempCurX1
    bmi .L_drawTriangleClippedTopSkip\index @@ If (CurDeltaX < 0) skip
    add r6, r6, #1                          @@ Add bias to right side

    add r5, r9, r5, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
#if WIREFRAME == 1 
.G_wireframeDataDstClipped6\index:
    M_ENABLEWIREFRAMEDATASCR6
#else
.G_wireframeDataDstClipped6\index:
    M_DISABLEWIREFRAMEDATASCR6
#endif

.L_drawTriangleClippedTopSkip\index:
    add r1, r1, r11                         @@ CurX1 += invSlope1
    add r10, r10, r12                       @@ CurX2 += invSlope2
    add r9, r9, r2, lsl #BPP_POW            @@ CurY pixel address += screen width * bytes per pixel
    cmp r4, r9
    blt .L_drawTriangleClippedTopLoopEnd    @@ Return if (y2/y3 < curY)
.endr
    b .L_drawTriangleClippedTopLoop         @@ Loop while (y2/y3 >= curY)

.L_drawTriangleTopLoop:                     @@ Draw loop without x-clipping
.irp index, TRI_LOOP_UNROLL
    asr r5, r1, #16                         @@ TempCurX1 = CurX1 remove precision
    asr r6, r10, #16                        @@ tempCurX2 = CurX2 remove precision

    subs r6, r6, r5                         @@ CurDeltaX = TempCurX2 - TempCurX1
    bmi .L_drawTriangleTopSkip\index        @@ If (CurDeltaX < 0) skip
    add r6, r6, #1                          @@ Add bias to right side

    add r5, r9, r5, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
#if WIREFRAME == 1     
.G_wireframeDataDst6\index: 
    M_ENABLEWIREFRAMEDATASCR6 
#else
.G_wireframeDataDst6\index:
    M_DISABLEWIREFRAMEDATASCR6
#endif

.L_drawTriangleTopSkip\index:
    add r1, r1, r11                         @@ CurX1 += invSlope1
    add r10, r10, r12                       @@ CurX2 += invSlope2
    add r9, r9, r2, lsl #BPP_POW            @@ CurY pixel address += screen width * bytes per pixel
    cmp r4, r9
    blt .L_drawTriangleClippedTopLoopEnd    @@ Return if (y2/y3 < curY)
.endr
    b .L_drawTriangleTopLoop                @@ Loop while (y2/y3 >= curY)

.L_drawTriangleClippedTopLoopEnd:
    pop {r4-r8}                             @@ Return
    bx lr                                   @@ /
.size m3_drawTriangleClippedTop, .-m3_drawTriangleClippedTop


@@ Parameters: (r0, palette source addr), (r1, palette length), (r2, palette destination index)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global setSpritePalette
.type setSpritePalette STT_FUNC
setSpritePalette:
    mov r3, #ADDR_PAL                   @@ Calculate obj palette destination adress.
    add r3, r3, #0x200                  @@ /
    add r3, r2, lsl #1                  @@ / 

    mov r2, #ADDR_IO                    @@ Load dma base adress
    str r3, [r2, #DMA3_DST]             @@ Write obj palette destination address to dma destination address
    str r0, [r2, #DMA3_SRC]             @@ Write palette source address to dma source address   

    mov r3, #0x80000000                 @@ Set dma control to copy palette colors palette length times
    orr r3, r3, r1                      @@ /
    str r3, [r2, #DMA3_CNT]             @@ /

    bx lr                               @@ Return
.size setSpritePalette, .-setSpritePalette


@@ Parameters: (r0, sprite sheet source addr), (r1, sprite sheet length), (r2, sprite destination index)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global setSpriteSheet
.type setSpriteSheet STT_FUNC
setSpriteSheet:
    mov r3, #ADDR_VRAM                  @@ Calculate sprite destination adress.
    add r3, r3, #0x14000                @@ /
    add r3, r2, lsl #6                  @@ / 

    mov r2, #ADDR_IO                    @@ Load dma base adress
    str r3, [r2, #DMA3_DST]             @@ Write sprite destination address to dma destination address
    str r0, [r2, #DMA3_SRC]             @@ Write sprite sheet source address to dma source address   

    mov r3, #0x84000000                 @@ Set dma control to copy sprite, sprite sheet length times
    orr r3, r3, r1, lsl #4              @@ /
    str r3, [r2, #DMA3_CNT]             @@ /

    bx lr                               @@ Return
.size setSpriteSheet, .-setSpriteSheet