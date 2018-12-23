#include "../../include/delcs.h"

@@ Functions available:
@@ - m3_initGraphics
@@ - m3_clearScr
@@ - m3_drawPixel
@@ - m3_drawLine
@@ - m3_drawHorzLine
@@ - m3_drawVertLine
@@ - m3_drawRectFromCenter
@@ - m3_drawRectFromCorner
@@ - m3_drawRectEmpty
@@ - m3_drawCircle
@@ - m3_drawCircleEmpty
@@ - m3_drawTriangle
@@      |- m3_drawTriangleBottom
@@      |- m3_drawTriangleTop
@@ - m3_drawTriangleClipped
@@      |- m3_drawTriangleClippedBottom
@@      |- m3_drawTriangleClippedTop
@@ - m3_drawTriangleClipped3D
@@      |- m3_drawTriangleClipped

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
    mov r1, #0x400					@@ /
#if GRAPHICS_MODE == 3
	add r1, r1, #0x3				@@ Load value #403 (0000000110010011) to enable gfx mode 3, and bg 2. See lcd control memory map.
#elif GRAPHICS_MODE == 5
    add r1, r1, #0x5				@@ Load value #405 (0000000110010101) to enable gfx mode 5, and bg 2. See lcd control memory map.
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


@@ Parameters: (r0, vram addr)
@@ Return: (r0, vram addr)
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

#if GRAPHICS_MODE == 5
    eor r0, r0, #PAGE_FLIP_SIZE
    ldrh r2, [r1]
    eor r2, r2, #0x10
    strh r2, [r1]
#endif
    bx lr                           @@ Return


@@ Parameters: (r0, vram addr), (r1, color addr)
@@ Return: void
.align 2
.arm
.global clearScr
.type clearScr STT_FUNC
clearScr:
    mov r2, #ADDR_IO
    str r1, [r2, #DMA0_SRC]         @@ Write color address to dma source address   
    str r0, [r2, #DMA0_DST]         @@ Write vram address to dma destination address

    mov r3, #0x85000000             @@ Set dma control to copy colour 0x2580 times
    orr r3, r3, #0x2580             @@ /
    str r3, [r2, #DMA0_CNT]         @@ /

#if GRAPHICS_MODE == 3
    add r0, r0, #0x9600             @@ Write vram address + 0x2580 * BBP * 2 to dma destination address
    str r0, [r2, #DMA0_DST]         @@ /

    mov r3, #0x85000000             @@ Set dma control to copy colour (amount of pixel - (0x2580 / 2)) times
    orr r3, r3, #0x2580             @@ /
    str r3, [r2, #DMA0_CNT]         @@ /
#endif

    bx lr                           @@ Return


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ -------MODE 3 FUNCTIONS------- @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@ Parameters: (r0, vram addr), (r1, x), (r2, y), (r3, 16 bit color)
@@ Return: void
.align 2
.arm
.global m3_drawPixel
.type m3_drawPixel STT_FUNC
m3_drawPixel:
    mov r12, #CANVAS_WIDTH    
    mla r12, r2, r12, r1        @@ pixel = y * CANVAS_WIDTH + x
    lsl r12, r12, #BPP_POW      @@ pixel address offset = pixel * 2 bytes per pixel

    strh r3, [r0, r12]          @@ write to vram + pixel address offset
    bx lr					    @@ Return


@@ Parameters: (r0, vram addr), (r1, x1), (r2, y1), (r3, x2), (sp #0, y2) (sp #4, 16 bit color)
@@ Return: void
@@ r1: deltaX
@@ r2: deltaY
@@ r3: error
@@ r0: end address
@@ r4: start adress
@@ r5: y2
@@ r8: colour
@@ r9: stepX
@@ r10: stepY
.align 2
.arm
.global m3_drawLine
.type m3_drawLine STT_FUNC
m3_drawLine:
    push {r4, r5, r8-r10}
    mov r12, #CANVAS_WIDTH

    ldrh r8, [sp, #(4+20)]      @@ Load values from the stack
    ldr r5, [sp, #(0+20)]       @@ /

    mla r4, r2, r12, r1          @@ Caluclate start adress, y1 * CANVAS_WIDTH + x1
    add r4, r0, r4, lsl #BPP_POW @@ pixel address = vram adress + pixel * bytes per pixel
    
    mov r9, #-1                 @@ stepX
    subs r1, r1, r3             @@ deltaX = x1 - x2
    neglt r1, r1                @@ if x1 < x2: negate deltaX
    neglt r9, r9                @@ if x1 < x2: negate stepX

    mov r10, #-1                @@ stepY
    subs r2, r5, r2             @@ -deltaY = y2 - y1
    negge r2, r2                @@ if y2 >= y1: negate -deltaY
    negge r10, r10              @@ if y2 >= y1: negate stepY

    mla r3, r5, r12, r3          @@ Calculate end adress, y2 * CANVAS_WIDTH + x2
    add r0, r0, r3, lsl #BPP_POW @@ pixel address = vram adress + pixel * bytes per pixel
    
    add r3, r1, r2              @@ error = deltaX + -deltaY
    lsl r12, r12, #BPP_POW      @@ Setup CANVAS_WIDTH * bytes per pixel
    mul r12, r10, r12           @@ Setup stepY * CANVAS_WIDTH * bytes per pixel

.L_drawLineLoop:
    strh r8, [r4]                     @@ Draw pixel

    cmp r2, r3, lsl #1                @@ if -deltaY <= error * 2
    addle r4, r4, r9, lsl #BPP_POW    @@ x += stepX * bytes per pixel
    addle r3, r3, r2                  @@ error += -deltaY
    cmple r4, r0
    beq .L_drawLineLoopEnd

    cmp r1, r3, lsl #1          @@ if deltaX > error * 2
    addgt r4, r4, r12           @@ y += stepY * CANVAS_WIDTH * bytes per pixel
    addgt r3, r3, r1            @@ error += deltaX

    cmp r4, r0                  @@ loop until start adress == end adress
    bne .L_drawLineLoop
.L_drawLineLoopEnd:
    pop {r4, r5, r8-r10}
    bx lr					    @@ Return


@@ Parameters: (r0, vram addr), (r1, x), (r2, y), (r3, signed width), (sp #0, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawHorzLine
.type m3_drawHorzLine STT_FUNC
m3_drawHorzLine:
    mov r12, #CANVAS_WIDTH

    cmp r3, #0
    negmi r3, r3                    @@ If width < 0: negate width
    submi r1, r1, r3                @@ If width < 0: x -= width

    mla r2, r2, r12, r1             @@ pixel = y * CANVAS_WIDTH + x
    add r2, r0, r2, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    ldr r0, [sp, #(0)]              @@ Load colour from stack

    mov r1, #ADDR_IO                @@ Prepare dma address base
    str r0, [r1, #DMA0_SRC]         @@ Write color address to dma source address
    str r2, [r1, #DMA0_DST]         @@ Write pixel address to dma destination address
    orr r3, r3, #0x81000000         @@ Set dma control to copy colour 'width' times
    str r3, [r1, #DMA0_CNT]         @@ /

    bx lr                           @@ Return


@@ Parameters: (r0, vram addr), (r1, x), (r2, y), (r3, signed height), (sp #0, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawVertLine
.type m3_drawVertLine STT_FUNC
m3_drawVertLine:
    mov r12, #CANVAS_WIDTH

    cmp r3, #0                 
    negmi r3, r3                    @@ If height < 0: negate height
    submi r2, r2, r3                @@ If height < 0: y -= height

    mla r1, r2, r12, r1             @@ pixel = y * CANVAS_WIDTH + x
    add r1, r0, r1, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    ldr r0, [sp, #(0)]              @@ Load colour from stack
    ldrh r0, [r0]                   @@ Get color value from addr
    lsl r12, r12, #BPP_POW          @@ Setup (CANVAS_WIDTH) * bytes per pixel
.L_drawVertLineLoopY:
    strh r0, [r1], r12              @@ Draw pixel, and move down vertically
    subs r3, #1                     @@ Height -= 1
    bne .L_drawVertLineLoopY
    bx lr                           @@ Return


@@ Parameters: (r0, vram addr), (r1, center x), (r2, center y), (r3, half width), (sp #0, half height) (sp #4, 32 bit color addr)
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
    add r0, r0, r1, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    lsl r12, r12, #BPP_POW          @@ Setup CANVAS_WIDTH * bytes per pixel
	mov r2, r4, lsl #1  		    @@ Height = 2 * half height

    mov r1, #ADDR_IO                @@ Prepare dma address base
    ldr r4, [sp, #(4+4)]            @@ Load color
    str r4, [r1, #DMA0_SRC]         @@ Write color address to dma source address
    orr r3, r3, #0x85000000         @@ Set dma control to copy colour 'half width' times

.L_drawRectCenterYLoop:
    str r0, [r1, #DMA0_DST]         @@ Write pixel address to dma destination address
    str r3, [r1, #DMA0_CNT]         @@ Set dma control to copy colour 'half width' times

	add r0, r0, r12         	    @@ Move down vertically to next line
	subs r2, r2, #1 			    @@ Height -= 1
	bne .L_drawRectCenterYLoop	    @@ /
    pop {r4}
    bx lr                           @@ Return


@@ Parameters: (r0, vram addr), (r1, top left x), (r2, top left y), (r3, width), (sp #0, height) (sp #4, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawRectFromCorner
.type m3_drawRectFromCorner STT_FUNC
m3_drawRectFromCorner:
    push {r4}
    mov r12, #CANVAS_WIDTH

    mla r1, r2, r12, r1             @@ pixel = y * CANVAS_WIDTH + x
    add r0, r0, r1, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    lsl r12, r12, #BPP_POW          @@ Setup CANVAS_WIDTH * bytes per pixel
    ldr r2, [sp, #(0+4)]            @@ Load height

    mov r1, #ADDR_IO                @@ Prepare dma address base
    ldr r4, [sp, #(4+4)]            @@ Load color address
    str r4, [r1, #DMA0_SRC]         @@ Write color address to dma source address
    orr r3, r3, #0x81000000         @@ Set dma control to copy colour 'width' times

.L_drawRectCornerYLoop:
    str r0, [r1, #DMA0_DST]         @@ Write pixel address to dma destination address
    str r3, [r1, #DMA0_CNT]         @@ Set dma control to copy colour 'width' times

    add r0, r0, r12         	    @@ Move down vertically to next line
	subs r2, r2, #1 			    @@ Height -= 1
	bne .L_drawRectCornerYLoop	    @@ /
    pop {r4}
    bx lr                           @@ Return


@@ Parameters: (r0, vram addr), (r1, top left x), (r2, top left y), (r3, width), (sp #0, height), (sp #4, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawRectEmpty
.type m3_drawRectEmpty STT_FUNC
m3_drawRectEmpty:
    push {r4, r5}
    mov r12, #CANVAS_WIDTH

    mla r1, r2, r12, r1             @@ pixel = y * CANVAS_WIDTH + x
    add r0, r0, r1, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    ldr r2, [sp, #(0+8)]            @@ Load height
    lsl r12, r12, #BPP_POW          @@ Setup (CANVAS_WIDTH) * bytes per pixel
    mov r5, #ADDR_IO                @@ Prepare dma address base

    ldr r4, [sp, #(4+8)]            @@ Load color address
    str r4, [r5, #DMA0_SRC]         @@ Write color address to dma source address
    ldrh r4, [r4]                   @@ Load color value

    str r0, [r5, #DMA0_DST]         @@ Write pixel address to dma destination address
    orr r1, r3, #0x81000000         @@ Set dma control to copy colour 'width' times
    str r1, [r5, #DMA0_CNT]         @@ /
    add r0, r3, lsl #BPP_POW        @@ Move right horizotally by width

    mov r1, r2
.L_drawRectEmptyYLoop1:
    strh r4, [r0], r12              @@ Draw pixel, and move down vertically
    subs r1, #1                     @@ Height -= 1
    bne .L_drawRectEmptyYLoop1

    mov r1, #0x81000000             @@ Prepare dma control value
    orr r1, r1, #0x200000           @@ /
    str r0, [r5, #DMA0_DST]         @@ Write pixel address to dma destination address
    orr r1, r3, r1                  @@ Set dma control to copy colour 'width' times
    str r1, [r5, #DMA0_CNT]         @@ /
    sub r0, r3, lsl #BPP_POW        @@ Move left horizotally by width

    mov r1, r2
    neg r12, r12
.L_drawRectEmptyYLoop2:
    strh r4, [r0], r12              @@ Draw pixel, and move up vertically
    subs r1, #1                     @@ Height -= 1
    bne .L_drawRectEmptyYLoop2
    pop {r4, r5}
    bx lr                           @@ Return


@@ Parameters: (r0, vram addr), (r1, center x), (r2, center y), (r3, radius), (sp #0, 16 bit color addr)
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
    str r9, [r10, #DMA0_SRC]        @@ Write color address to dma source address

    mov r4, #0                      @@ y = 0
    rsb r5, r3, #1                  @@ error = 1 - x

.L_drawCircleLoop:
    sub r6, r1, r4                  @@ line x0 = center x - y
    movs r7, r4, lsl #1             @@ line width = y * 2
    beq .L_drawCircleLoopSkip1      @@ Skip if line width is 0
    orr r7, r7, #0x81000000         @@ Set dma control to copy colour 'line width' times

    add r8, r2, r3                  @@ line y = center y + x
    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    str r8, [r10, #DMA0_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA0_CNT]        @@ Draw line

    sub r8, r2, r3                  @@ line y = center y - x
    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    str r8, [r10, #DMA0_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA0_CNT]        @@ Draw line

.L_drawCircleLoopSkip1:
    sub r6, r1, r3                  @@ line x0 = center x - x
    movs r7, r3, lsl #1             @@ line width = x * 2
    beq .L_drawCircleLoopSkip2      @@ Skip if line width is 0
    orr r7, r7, #0x81000000         @@ Set dma control to copy colour 'line width' times

    add r8, r2, r4                  @@ line y = center y + y
    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    str r8, [r10, #DMA0_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA0_CNT]        @@ Draw line

    sub r8, r2, r4                  @@ line y = center y - y
    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    str r8, [r10, #DMA0_DST]        @@ Write pixel address to dma destination address
    str r7, [r10, #DMA0_CNT]        @@ Draw line

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


@@ Parameters: (r0, vram addr), (r1, center x), (r2, center y), (r3, radius), (sp #0, 16 bit color)
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

    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r4, lsl #BPP            @@ Move left horizontally by radius (y) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    sub r8, r2, r3                  @@ pixel y = center y - x

    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r4, lsl #BPP            @@ Move left horizontally by radius (y) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    sub r6, r1, r3                  @@ pixel x0 = center x - x
    add r8, r2, r4                  @@ pixel y = center y + y

    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

    strh r9, [r8]                   @@ Draw pixel
    add r8, r3, lsl #BPP            @@ Move left horizontally by radius (x) * 2 * bytes per pixel
    strh r9, [r8]                   @@ Draw pixel

    sub r8, r2, r4                  @@ pixel y = center y - y

    mla r8, r8, r12, r6             @@ pixel = y * CANVAS_WIDTH + x
    add r8, r0, r8, lsl #BPP_POW    @@ pixel address = vram adress + pixel * bytes per pixel

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


@@ Parameters: (r0, vram addr), (r1, x1), (r2, y1), (r3, x2), (sp #0, y2), (sp #4, x3), (sp #8, y3), (sp #12, 16 bit color addr)
@@ Return: void
.align 2
.arm
.global m3_drawTriangle
.type m3_drawTriangle STT_FUNC
m3_drawTriangle:
    mov r12, lr                         @@ Save link register
    push {r4-r12}
    
    add r8, sp, #36                     @@ Get stack offset adress
    ldmia r8, {r4, r5, r6, r10}         @@ Load y2, x3, y3 and color addr from stack

    mov r8, #ADDR_IO                    @@ Dma address base
    str r10, [r8, #DMA0_SRC]            @@ Write color address to dma source address
    ldr r8, =LUT_DIVISION               @@ Load lut

                                        @@ Sort vertices by y value (top vertex in v1)
    cmp r2, r4
    ble .L_drawTriangleFirstLE
    eor r1, r1, r3                      @@ Swap v1.x and v2.x
    eor r3, r3, r1                      @@ /
    eor r1, r1, r3                      @@ /
    eor r2, r2, r4                      @@ Swap v1.y and v2.y
    eor r4, r4, r2                      @@ /
    eor r2, r2, r4                      @@ /
.L_drawTriangleFirstLE:
    cmp r4, r6
    ble .L_drawTriangleSecondLE
    eor r3, r3, r5                      @@ Swap v2.x and v3.x
    eor r5, r5, r3                      @@ /
    eor r3, r3, r5                      @@ /
    eor r4, r4, r6                      @@ Swap v2.y and v3.y
    eor r6, r6, r4                      @@ /
    eor r4, r4, r6                      @@ /
.L_drawTriangleSecondLE:
    cmp r2, r4
    ble .L_drawTriangleThirdLE
    eor r1, r1, r3                      @@ Swap v1.x and v2.x
    eor r3, r3, r1                      @@ /
    eor r1, r1, r3                      @@ /
    eor r2, r2, r4                      @@ Swap v1.y and v2.y
    eor r4, r4, r2                      @@ /
    eor r2, r2, r4                      @@ /
.L_drawTriangleThirdLE:

    cmp r2, r4
    bne .L_drawTriangleBottomEnd        @@ Skip if triangle is not bottom triangle
    sub r9, r6, r2                      @@ Delta y bottom = v3.y - v1.y
    cmp r1, r3                          @@ if v1.x > v2.x
    eorgt r1, r1, r3                    @@ Swap v1.x and v2.x
    eorgt r3, r3, r1                    @@ /
    eorgt r1, r1, r3                    @@ /
    mov r7, r3
    mov r3, r1
    bl m3_drawTriangleBottom
    b .L_drawTriangleEnd
.L_drawTriangleBottomEnd:

    sub r9, r4, r2                      @@ Delta y top = v2.y - v1.y
    cmp r4, r6
    bne .L_drawTriangleTopEnd           @@ Skip if triangle is not top triangle
    cmp r3, r5                          @@ if v2.x > v3.x
    eorgt r3, r3, r5                    @@ Swap v2.x and v3.x
    eorgt r5, r5, r3                    @@ /
    eorgt r3, r3, r5                    @@ /
    mov r7, r5
    bl m3_drawTriangleTop
    b .L_drawTriangleEnd
.L_drawTriangleTopEnd:

                                        @@ Calculate v4.x
    mov r12, r9, lsl #16                @@ Delta y top * added precision
    sub r7, r6, r2                      @@ Delta y = v3.y - v1.y
    ldr r7, [r8, r7, lsl #2]            @@ Load (1 / delta y)
    smull r7, r12, r12, r7              @@ Dy = Delta y top / Delta y

    sub r7, r5, r1                      @@ Dx = v3.x - v1.x
    mul r12, r12, r7                    @@ Xoffset = dy * dx
    add r7, r1, r12, asr #16            @@ v4.x = v1.x + xoffset / added precision
    
    cmp r3, r7                          @@ if v2.x > v4.x
    eorgt r3, r3, r7                    @@ Swap v2.x and v4.x
    eorgt r7, r7, r3                    @@ /
    eorgt r3, r3, r7                    @@ /

    bl m3_drawTriangleTop
    sub r9, r6, r4                      @@ Delta y bottom = v3.y - v2.y
    bl m3_drawTriangleBottom

.L_drawTriangleEnd:
    pop {r4-r12}
    bx r12                              @@ Return


@@ Parameters: (r0, vram addr), (r5, x1), (r6, y1), (r3, x2), (r4, y2/y3), (r7, x3), (r9, delta y)
@@ Comments: Not callable from C/C++! Preserves {r0, r1, r2, r3, r4, r6, r8, r9, r10}. Trashes: {r5, r7, r10, r11, r12}
@@ Return: void
.align 2
.arm
.global m3_drawTriangleBottom
.type m3_drawTriangleBottom STT_FUNC
m3_drawTriangleBottom:
    sub r11, r5, r3                         @@ Delta x1 = x1 - x2
    lsl r11, r11, #16                       @@ Add precision
    sub r12, r5, r7                         @@ Delta x2 = x1 - x3
    lsl r12, r12, #16                       @@ Add precision
    
    ldr r7, [r8, r9, lsl #2]                @@ Load (1 / delta y) from lut
    smull r10, r11, r11, r7                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    smull r10, r12, r12, r7                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)

    lsl r5, r5, #16                         @@ CurX1 add precision
    mov r10, r5                             @@ CurX2

    mov r7, #ADDR_IO                        @@ Prepare dma address base
    add r9, r4, r9                          @@ CurY = y2/y3 - delta y 
    mov r3, #CANVAS_WIDTH                   @@ Prepare screen width
    mul r9, r9, r3                          @@ Prepare curY pixel address
    add r9, r0, r9, lsl #BPP_POW            @@ /
    mul r4, r4, r3                          @@ Prepare y2 pixel address
    add r4, r0, r4, lsl #BPP_POW            @@ /
    lsl r3, r3, #BPP_POW                    @@ Prepare screen width * bytes per pixel
    
.L_drawTriangleBottomLoop:
    asr r1, r5, #16                         @@ TempCurX1 = CurX1 remove precision
    asr r2, r10, #16                        @@ tempCurX2 = CurX2 remove precision
    sub r2, r2, r1                          @@ CurDeltaX = TempCurX2 - TempCurX1
    add r2, r2, #1                          @@ Add bias to right side

    add r1, r9, r1, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
    str r1, [r7, #DMA0_DST]                 @@ Write pixel address to dma destination address
    orr r2, r2, #0x81000000                 @@ Set dma control to copy colour 'curDeltaX' times
    str r2, [r7, #DMA0_CNT]                 @@ /

.L_drawTriangleBottomSkip:
    sub r5, r5, r11                         @@ curX1 -= invSlope1
    sub r10, r10, r12                       @@ curX2 -= invSlope2
    sub r9, r9, r3                          @@ CurY pixel address -= screen width * bytes per pixel
    cmp r9, r4
    bge .L_drawTriangleBottomLoop           @@ Loop while (curY >= y2/y3)
.L_drawTriangleBottomLoopEnd:
    bx lr                                   @@ Return


@@ Parameters: (r0, vram addr), (r1, x1), (r2, y1), (r3, x2), (r4, y2/y3), (r7, x3), (r9, delta y)
@@ Comments: Not callable from C/C++! Preserves {r0, r3, r4, r5, r6, r7, r8}. Trashes: {r1, r2, r9, r10, r11, r12}
@@ Return: void
.align 2
.arm
.global m3_drawTriangleTop
.type m3_drawTriangleTop STT_FUNC
m3_drawTriangleTop:
    push {r4-r7}

    sub r11, r3, r1                         @@ Delta x1 = x2 - x1
    lsl r11, r11, #16                       @@ Add precision
    sub r12, r7, r1                         @@ Delta x2 = x3 - x1
    lsl r12, r12, #16                       @@ Add precision

    ldr r7, [r8, r9, lsl #2]                @@ Load (1 / delta y) from lut
    smull r10, r11, r11, r7                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    smull r10, r12, r12, r7                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)

    lsl r1, r1, #16                         @@ CurX1 add precision
    mov r10, r1                             @@ CurX2 = curX1

    mov r7, #ADDR_IO                        @@ Prepare dma address base
    sub r9, r4, r9                          @@ CurY = y2 - delta y 
    mov r2, #CANVAS_WIDTH                   @@ Prepare screen width
    mul r9, r9, r2                          @@ Prepare curY pixel address
    add r9, r0, r9, lsl #BPP_POW            @@ /
    mul r4, r4, r2                          @@ Prepare y2 pixel address
    add r4, r0, r4, lsl #BPP_POW            @@ /
    lsl r2, r2, #BPP_POW                    @@ Prepare screen width * bytes per pixel

.L_drawTriangleTopLoop:
    asr r5, r1, #16                         @@ TempCurX1 = CurX1 remove precision
    asr r6, r10, #16                        @@ tempCurX2 = CurX2 remove precision
    sub r6, r6, r5                          @@ CurDeltaX = TempCurX2 - TempCurX1
    add r6, r6, #1                          @@ Add bias to right side

    add r5, r9, r5, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
    str r5, [r7, #DMA0_DST]                 @@ Write pixel address to dma destination address
    orr r6, r6, #0x81000000                 @@ Set dma control to copy colour 'curDeltaX' times
    str r6, [r7, #DMA0_CNT]                 @@ /

.L_drawTriangleTopSkip:
    add r1, r1, r11                         @@ CurX1 += invSlope1
    add r10, r10, r12                       @@ CurX2 += invSlope2
    add r9, r9, r2                          @@ CurY pixel address += screen width * bytes per pixel
    cmp r4, r9
    bge .L_drawTriangleTopLoop              @@ Loop while (y2/y3 >= curY)
.L_drawTriangleTopLoopEnd:
    pop {r4-r7}                             @@ Return
    bx lr                                   @@ /


@@ Parameters: (r0, vram addr), (r1, x1), (r2, y1), (r3, x2), (sp #0, y2), (sp #4, x3), (sp #8, y3), (sp #12, 16 bit color addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangleClipped
.type m3_drawTriangleClipped STT_FUNC
m3_drawTriangleClipped:
    mov r12, lr                         @@ Save link register
    push {r4-r12}
    
    add r8, sp, #36                     @@ Get stack offset adress
    ldmia r8, {r4, r5, r6, r10}         @@ Load y2, x3, y3 and color addr from stack

.G_drawTriangleClippedAsm:
    mov r8, #ADDR_IO                    @@ Dma address base
    str r10, [r8, #DMA0_SRC]            @@ Write color address to dma source address
    ldr r8, =LUT_DIVISION               @@ Load lut

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
    bl m3_drawTriangleClippedBottom
    b .L_drawTriangleClippedEnd
.L_drawTriangleClippedBottomEnd:

    sub r9, r4, r2                      @@ Delta y top = v2.y - v1.y
    cmp r4, r6
    bne .L_drawTriangleClippedTopEnd    @@ Skip if triangle is not top triangle
    cmp r3, r5                          @@ if v2.x > v3.x
    eorgt r3, r3, r5                    @@ Swap v2.x and v3.x
    eorgt r5, r5, r3                    @@ /
    eorgt r3, r3, r5                    @@ /
    mov r7, r5
    bl m3_drawTriangleClippedTop
    b .L_drawTriangleClippedEnd
.L_drawTriangleClippedTopEnd:

                                        @@ Calculate v4.x
    mov r12, r9, lsl #16                @@ Delta y top * added precision
    sub r7, r6, r2                      @@ Delta y = v3.y - v1.y
    ldr r7, [r8, r7, lsl #2]            @@ Load (1 / delta y)
    smull r7, r12, r12, r7              @@ Dy = Delta y top / Delta y

    sub r7, r5, r1                      @@ Dx = v3.x - v1.x
    mul r12, r12, r7                    @@ Xoffset = dy * dx
    add r7, r1, r12, asr #16            @@ v4.x = v1.x + xoffset / added precision
    
    cmp r3, r7                          @@ if v2.x > v4.x
    eorgt r3, r3, r7                    @@ Swap v2.x and v4.x
    eorgt r7, r7, r3                    @@ /
    eorgt r3, r3, r7                    @@ /

    bl m3_drawTriangleClippedTop
    sub r9, r6, r4                      @@ Delta y bottom = v3.y - v2.y
    bl m3_drawTriangleClippedBottom

.L_drawTriangleClippedEnd:
    pop {r4-r12}
    bx r12                              @@ Return


@@ Parameters: (r0, vram addr), (r5, x1), (r6, y1), (r3, x2), (r4, y2/y3), (r7, x3), (r9, delta y)
@@ Comments: Not callable from C/C++! Preserves {r0, r1, r2, r3, r4, r6, r8, r9, r10}. Trashes: {r5, r7, r10, r11, r12}
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
    
    ldr r7, [r8, r9, lsl #2]                @@ Load (1 / delta y) from lut
    smull r10, r11, r11, r7                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    smull r10, r12, r12, r7                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)

    lsl r5, r5, #16                         @@ CurX1 add precision
    mov r10, r5                             @@ CurX2

                                            @@ Y clipping
    rsbs r7, r6, #CANVAS_HEIGHT-1           @@ TempInvY = maxY - y1. If (tempInvY < 0) clip y max
    mlalt r5, r11, r7, r5                   @@ CurX1 += invSlope1 * tempInvY
    mlalt r10, r12, r7, r10                 @@ CurX2 += invSlope2 * tempInvY
    addlt r9, r9, r7                        @@ Delta y += tempInvY

    cmp r4, #0                              @@ If (y2/y3 < 0) clip y min
    addmi r9, r9, r4                        @@ Delta y += y2
    movmi r4, #0                            @@ Y2 = 0

    cmp r9, #0                              @@ If (delta y < 0) skip.
    bmi .L_drawTriangleClippedBottomLoopEnd @@ /

    mov r3, #CANVAS_WIDTH                   @@ Prepare screen width
    mov r7, #ADDR_IO                        @@ Prepare dma address base
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

.L_drawTriangleClippedBottomLoop:
                                            @@ X clipping
    asrs r1, r5, #16                        @@ TempCurX1 = CurX1 remove precision
    movmi r1, #0                            @@ If (tempCurX1 < 0) tempCurX1 = 0

    asr r2, r10, #16                        @@ tempCurX2 = CurX2 remove precision
    cmp r2, #CANVAS_WIDTH                   @@ If (tempCurX2 >= maxX):
    movge r2, #CANVAS_WIDTH-1               @@ TempCurX2 = maxX

    subs r2, r2, r1                         @@ CurDeltaX = TempCurX2 - TempCurX1
    bmi .L_drawTriangleClippedBottomSkip    @@ If (CurDeltaX < 0) skip
    add r2, r2, #1                          @@ Add bias to right side

    add r1, r9, r1, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
    str r1, [r7, #DMA0_DST]                 @@ Write pixel address to dma destination address
    orr r2, r2, #0x81000000                 @@ Set dma control to copy colour 'curDeltaX' times
    str r2, [r7, #DMA0_CNT]                 @@ /

.L_drawTriangleClippedBottomSkip:
    sub r5, r5, r11                         @@ curX1 -= invSlope1
    sub r10, r10, r12                       @@ curX2 -= invSlope2
    sub r9, r9, r3, lsl #BPP_POW            @@ CurY pixel address -= screen width * bytes per pixel
    cmp r9, r4
    bge .L_drawTriangleClippedBottomLoop    @@ Loop while (curY >= y2/y3)
.L_drawTriangleClippedBottomLoopEnd:
    bx lr                                   @@ Return


@@ Parameters: (r0, vram addr), (r1, x1), (r2, y1), (r3, x2), (r4, y2/y3), (r7, x3), (r9, delta y)
@@ Comments: Not callable from C/C++! Preserves {r0, r3, r4, r5, r6, r7, r8}. Trashes: {r1, r2, r9, r10, r11, r12}
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangleClippedTop
.type m3_drawTriangleClippedTop STT_FUNC
m3_drawTriangleClippedTop:
    push {r4-r7}

    sub r11, r3, r1                         @@ Delta x1 = x2 - x1
    lsl r11, r11, #16                       @@ Add precision
    sub r12, r7, r1                         @@ Delta x2 = x3 - x1
    lsl r12, r12, #16                       @@ Add precision

    ldr r7, [r8, r9, lsl #2]                @@ Load (1 / delta y) from lut
    smull r10, r11, r11, r7                 @@ Invslope1 = Delta x1 / Delta y. (r10 is trashed)
    smull r10, r12, r12, r7                 @@ Invslope2 = Delta x2 / Delta y. (r10 is trashed)

    lsl r1, r1, #16                         @@ CurX1 add precision
    mov r10, r1                             @@ CurX2 = curX1

                                            @@ Y clipping
    rsbs r7, r2, #0                         @@ InvY1 = 0 - y1. If (InvY1 > 0) clip y min.
    mlagt r1, r11, r7, r1                   @@ CurX1 += invSlope1 * InvY1
    mlagt r10, r12, r7, r10                 @@ CurX2 += invSlope2 * InvY1
    subgt r9, r9, r7                        @@ Delta y -= InvY1

    subs r7, r4, #CANVAS_HEIGHT-1           @@ TempY = y2/y3 - maxY. If (tempy > 0) clip y max.
    subgt r9, r9, r7                        @@ Delta y -= TempY
    movgt r4, #CANVAS_HEIGHT-1              @@ Y2/y3 = y max

    cmp r9, #0                              @@ If (delta y < 0) skip.
    bmi .L_drawTriangleClippedTopLoopEnd    @@ /

    mov r2, #CANVAS_WIDTH                   @@ Prepare screen width
    mov r7, #ADDR_IO                        @@ Prepare dma address base
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

.L_drawTriangleClippedTopLoop:
                                            @@ X clipping
    asrs r5, r1, #16                        @@ TempCurX1 = CurX1 remove precision
    movmi r5, #0                            @@ If (tempCurX1 < 0) tempCurX1 = 0

    asr r6, r10, #16                        @@ tempCurX2 = CurX2 remove precision
    cmp r6, #CANVAS_WIDTH                   @@ If (tempCurX2 >= maxX):
    movge r6, #CANVAS_WIDTH-1               @@ TempCurX2 = maxX

    subs r6, r6, r5                         @@ CurDeltaX = TempCurX2 - TempCurX1
    bmi .L_drawTriangleClippedTopSkip       @@ If (CurDeltaX < 0) skip
    add r6, r6, #1                          @@ Add bias to right side

    add r5, r9, r5, lsl #BPP_POW            @@ pixel address = CurY pixel address + TempCurX1 * bytes per pixel
    str r5, [r7, #DMA0_DST]                 @@ Write pixel address to dma destination address
    orr r6, r6, #0x81000000                 @@ Set dma control to copy colour 'curDeltaX' times
    str r6, [r7, #DMA0_CNT]                 @@ /

.L_drawTriangleClippedTopSkip:
    add r1, r1, r11                         @@ CurX1 += invSlope1
    add r10, r10, r12                       @@ CurX2 += invSlope2
    add r9, r9, r2, lsl #BPP_POW            @@ CurY pixel address += screen width * bytes per pixel
    cmp r4, r9
    bge .L_drawTriangleClippedTopLoop       @@ Loop while (y2/y3 >= curY)
.L_drawTriangleClippedTopLoopEnd:
    pop {r4-r7}                             @@ Return
    bx lr                                   @@ /


@@ Parameters: (r0, vram addr), (r1, x1),       (r2, y1),       (r3, z1), 
@@                              (sp #0, x2),    (sp #4, y2),    (sp #8, z2), 
@@                              (sp #12, x3),   (sp #16, y3),   (sp #20, z3), 
@@             (sp #24, 16 bit color addr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global m3_drawTriangleClipped3D
.type m3_drawTriangleClipped3D STT_FUNC
m3_drawTriangleClipped3D:
    mov r12, lr
	push {r4-r12}
	ldr r12, =LUT_DIVISION
                                        @@ Vertex1 to screen pos
    lsl r1, r1, #FOV_POW                @@ x1 * fov
    lsl r2, r2, #FOV_POW                @@ y1 * fov
	ldr r3, [r12, r3, lsl #2]           @@ Load 1 / z1
	smull r9, r1, r1, r3                @@ (x1 * fov) / z1
	smull r9, r2, r2, r3                @@ (y1 * fov) / z1
	add r1, r1, #CANVAS_WIDTH/2         @@ sX1 = (x1 * fov) / z1 + centerScreenX
	add r2, r2, #CANVAS_HEIGHT/2        @@ sY1 = (y1 * fov) / z1 + centerScreenY
		
	add r10, sp, #36                    @@ Get offset into the stack
	ldmia r10, {r3-r8, r10}             @@ Load Vertex2, Vertex3 and colour

                                        @@ Vertex2 to screen pos
    lsl r3, r3, #FOV_POW                @@ x2 * fov
    lsl r4, r4, #FOV_POW                @@ y2 * fov
	ldr r5, [r12, r5, lsl #2]           @@ Load 1 / z2
	smull r9, r3, r3, r5                @@ (x2 * fov) / z2
	smull r9, r4, r4, r5                @@ (y2 * fov) / z2
	add r3, r3, #CANVAS_WIDTH/2         @@ sX2 = (x2 * fov) / z2 + centerScreenX
	add r4, r4, #CANVAS_HEIGHT/2        @@ sY2 = (y2 * fov) / z2 + centerScreenY

                                        @@ Vertex3 to screen pos
    lsl r6, r6, #FOV_POW                @@ x3 * fov
    lsl r7, r7, #FOV_POW                @@ y3 * fov
	ldr r8, [r12, r8, lsl #2]           @@ Load 1 / z3
	smull r9, r5, r6, r8                @@ (x3 * fov) / z3
	smull r9, r6, r7, r8                @@ (y3 * fov) / z3
	add r5, r5, #CANVAS_WIDTH/2         @@ sX3 = (x3 * fov) / z3 + centerScreenX
	add r6, r6, #CANVAS_HEIGHT/2        @@ sY3 = (y3 * fov) / z3 + centerScreenY
	
	b .G_drawTriangleClippedAsm         @@ Draw 2d triangle