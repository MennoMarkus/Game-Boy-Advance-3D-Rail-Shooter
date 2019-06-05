#include "../../include/utils/delcs.h"

#if TARGET_PLATFORM == TARGET_GBA

#include "../utils/macros.s"
#include "../../include/graphics/resolutions.h"

#define ASSEMBLE_GRAPHICS_S
#include "../asm/graphics.s"


@@@@@@@@@@@@@@@@@@
@@-----DATA-----@@
@@@@@@@@@@@@@@@@@@
.data

@@ Summary:
.global fbPointer

.data
.type fbPointer, %object
.section .fbPointer, "ax", %progbits
.align 2
fbPointer:
	.word 0
.size fbPointer, .-fbPointer

@ A ram buffer containing graphics data to be draw to the screen.
@ 76800 bytes
DATA_EWRAM graphicsRamBuffer
	.fill 38400,2,0 

DATA_EWRAM currentResolution
	.word DEFAULT_RESOLUTION
DATA_EWRAM currentDoubleBuffering
	.word DEFAULT_DOUBLE_BUFFER


@@@@@@@@@@@@@@@@@@
@@-----CODE-----@@
@@@@@@@@@@@@@@@@@@
.text

@@ Summary:
.global initGraphics
.global destroyGraphics
.global setResolution
.global setDoubleBuffer
.global getDoubleBuffer
.global getEncodedResolution
.global startDraw
.global endDraw

@@ Parameters: void
@@ Return: (r0, succes)
FUNC_EWRAM initGraphics, arm
    push {lr}

	ldr r1, =setResolution
	ldr r0, =DEFAULT_RESOLUTION		@@ Set resolution and return true
	mov lr, pc
    bx r1							@@ /

	mov r0, #1						@@ /
    pop {r1}                        @@ Return
    bx r1                           @@ /
FUNC_END initGraphics


@@ Parameters: void
@@ Return: (r0, succes)
FUNC_ROM destroyGraphics
	mov r0, #1
    bx lr                           @@ Return
FUNC_END destroyGraphics


@@ Parameters: (r0, resolution)
@@ Return: (r0, succes)
@@ Comments: resolution is encoded as (xRes << 16) | yRes.
FUNC_EWRAM setResolution, arm
	push {r4, lr}
	mov r4, r0

	REPLACE_CODE_START																	@@ Replace code
	.irp value, %(RESOLUTION_X240Y160), %(RESOLUTION_X160Y120)							@@ /
		RUNTIME_REPLACE_CODE setIoMem, r4, \value										@@ /
		RUNTIME_REPLACE_CODE doubleBufferMode, r4, \value								@@ /
		RUNTIME_REPLACE_CODE clearScreenTop, r4, \value									@@ /
		RUNTIME_REPLACE_CODE clearScreenLeft, r4, \value								@@ /
		RUNTIME_REPLACE_CODE drawPixelResolution, r4, \value							@@ /
		RUNTIME_REPLACE_CODE drawLineSwapResolution, r4, \value							@@ /
		RUNTIME_REPLACE_CODE drawLineResolution, r4, \value								@@ /
		RUNTIME_REPLACE_CODE drawHorzLineSwapResolution, r4, \value						@@ /
		RUNTIME_REPLACE_CODE drawHorzLineResolution, r4, \value							@@ /
		RUNTIME_REPLACE_CODE drawVertLineSwapResolution, r4, \value						@@ /
		RUNTIME_REPLACE_CODE drawVertLineResolution, r4, \value							@@ /
		RUNTIME_REPLACE_CODE draw3DModelLoadResolution, r4, \value						@@ /
		RUNTIME_REPLACE_CODE draw3DModelTranslateResolution, r4, \value					@@ /
		RUNTIME_REPLACE_CODE drawTriangle3DSwapResolution, r4, \value					@@ /
		RUNTIME_REPLACE_CODE drawTriangle3DCenter1Resolution, r4, \value				@@ /
		RUNTIME_REPLACE_CODE drawTriangle3DCenter2Resolution, r4, \value				@@ /
		RUNTIME_REPLACE_CODE drawTriangle3DCenter3Resolution, r4, \value				@@ /
		RUNTIME_REPLACE_CODE drawTriangleClippedSwapResolution, r4, \value				@@ /
		RUNTIME_REPLACE_CODE drawTriangleClippedBottomYClip, r4, \value					@@ /
		RUNTIME_REPLACE_CODE drawTriangleClippedBottomYAddr, r4, \value					@@ /
		RUNTIME_REPLACE_CODE drawTriangleClippedTopYClip1, r4, \value					@@ /
		RUNTIME_REPLACE_CODE drawTriangleClippedTopYClip2, r4, \value					@@ /
		RUNTIME_REPLACE_CODE drawTriangleClippedTopYAddr, r4, \value					@@ /
		.irp index, TRI_LOOP_UNROLL
			RUNTIME_REPLACE_CODE drawTriangleClippedBottomCmp_\index, r4, \value		@@ /
			RUNTIME_REPLACE_CODE drawTriangleClippedBottomMovge_\index, r4, \value		@@ /
			RUNTIME_REPLACE_CODE drawTriangleClippedTopCmp_\index, r4, \value			@@ /
			RUNTIME_REPLACE_CODE drawTriangleClippedTopMovge_\index, r4, \value			@@ /
		.endr
	.endr																		@@ /

	ldr r0, =currentResolution									@@ Store new resolution
	str r4, [r0]												@@ /

	ldr r0, =currentDoubleBuffering								@@ Set flags to conatain whether double buffering is enabled
	ldr r0, [r0]												@@ /
	cmp r0, #1													@@ /
	ldr r4, =fbPointer											@@ Load the framebuffer pointer
	ldreq r2, =graphicsRamBuffer								@@ If resolution == X240Y160: Write graphics ram buffer addr as frame buffer pointer if double buffering is enabled
	
	mov r0, #ADDR_IO											@@ Prepare address
	mov r1, #0x1400												@@ /	
	.macro setIoMem_RESOLUTION_X240Y160
		add r1, r1, #0x43               						@@ Load value #0x1443 to enable gfx mode 3, bg 2 and 1d sprite drawing.
		strh r1, [r0]											@@ Write value to memory

		mov	r12, #0x4000000										@@ Rotate background 90 degrees and scale x-axis by 2 after
		mov	r0, #0x100											@@ /
		mov	r1, #0x0											@@ /
		mov	r3, #0x0											@@ /
		strh r0, [r12, #0x20]									@@ /
		strh r1, [r12, #0x22]									@@ /
		strh r3, [r12, #0x24]									@@ /
		strh r0, [r12, #0x26]									@@ /		

		movne r2, #ADDR_VRAM									@@ Write vram as frame buffer pointer if double buffering is disabled
		str r2, [r4]											@@ /
		nop
	.endm
	RUNTIME_REPLACE_OPTION setIoMem, DEFAULT_RESOLUTION, %(RESOLUTION_X240Y160), setIoMem_RESOLUTION_X240Y160
	.macro setIoMem_RESOLUTION_X160Y120
		add r1, r1, #0x45										@@ Load value #0x1445 to enable gfx mode 5, bg 2 and 1d sprite drawing.
		strh r1, [r0]											@@ Write value to memory

		mov	r2, #0x4000000										@@ Rotate background 90 degrees and scale x-axis by 2 after
		mov	r0, #0x0											@@ /
		mov	r1, #0x100											@@ /
		mov	r3, #0x80											@@ /
		strh r0, [r2, #0x20]									@@ /
		strh r1, [r2, #0x22]									@@ /
		strh r3, [r2, #0x24]									@@ /
		strh r0, [r2, #0x26]									@@ /

		mov r0, #ADDR_VRAM										@@ Write vram as frame buffer pointer
		eoreq r0, #0xa000										@@ Page flip if double buffering is enabled
		str r0, [r4]											@@ /
	.endm
	RUNTIME_REPLACE_OPTION setIoMem, DEFAULT_RESOLUTION, %(RESOLUTION_X160Y120), setIoMem_RESOLUTION_X160Y120

.L_setResolution_End:
	pop {r4, lr}												@@ Return
	mov r0, #1													@@ /
	bx lr                           							@@ /
FUNC_END setResolution


@@ Parameters: void
@@ Return: void
FUNC_EWRAM setDoubleBuffer
	push {r4, lr}
	mov r4, r0

	@@REPLACE_CODE_START										@@ We use the REPLACE_CODE_START from setResolution
	.irp value, 0, 1											@@ Replace code
		RUNTIME_REPLACE_CODE setDoubleBuffer, r4, \value		@@ /
	.endr														@@ /

	ldr r0, =currentDoubleBuffering								@@ Store new double buffering state
	str r4, [r0]												@@ /

	ldr r0, =currentResolution									@@ Select frame buffer address based on resolution.
	ldr r1, =#RESOLUTION_X240Y160								@@ /
	cmp r0, r1													@@ /
	bne .L_setDoubleBuffer_RESOLUTION_X160Y120					@@ /

	cmp r4, #1													@@ Test for double buffering
	ldr r0, =#ADDR_VRAM											@@ Write vram as frame buffer pointer if double buffering is disabled
	bne .L_setDoubleBuffer_End									@@ Write graphics ram buffer as frame buffer if double buffering is enabled.
	ldr r0, =graphicsRamBuffer									@@ /
	b .L_setDoubleBuffer_End									@@ Return

.L_setDoubleBuffer_RESOLUTION_X160Y120:
	cmp r4, #1													@@ Test for double buffering
	ldr r0, =#ADDR_VRAM											@@ Write vram as frame buffer pointer
	bne .L_setDoubleBuffer_End									@@ Page flip if double buffering is enabled
	ldr r1, =#0xa000											@@ /
	eor r0, r0, r1												@@ /

.L_setDoubleBuffer_End:
	ldr r1, =fbPointer											@@ Write frame buffer pointer
	str r0, [r1]												@@ /

	pop {r1, r4}												@@ Return
	eor r1, r1, r4                      						@@ Swap r1 and r4
    eor r4, r4, r1                      						@@ /
    eor r1, r1, r4                      						@@ /
	mov r0, #1													@@ /
	bx r1                           							@@ /
FUNC_END setDoubleBuffer


@@ Parameters: void
@@ Return: (r0, double buffering enabled)
FUNC_EWRAM getDoubleBuffer
	ldr r0, =currentDoubleBuffering
	ldr r0, [r0]
	bx lr
FUNC_END getDoubleBuffer


@@ Parameters: void
@@ Return: (r0, resolution encoded as (x << 16) | y)
FUNC_EWRAM getEncodedResolution
	ldr r0, =currentResolution
	ldr r0, [r0]
	bx lr
FUNC_END getEncodedResolution


@@ Parameters: (r0, x address to write to), (r1, y address to write to)
@@ Return: void
FUNC_EWRAM getResolution
	ldr r2, =currentResolution
	ldr r2, [r2]

	lsr r3, r2, #16				@@ Get x resolution
	str r3, [r0]				@@ /

	ldr r0, =#0xFFFF			@@ Get y resolution
	and r2, r2, r0 				@@ /
	str r2, [r1]				@@ /

	bx lr						@@ Return
FUNC_END getResolution


@@ Parameters: void
@@ Return: (r0, frame buffer address)
FUNC_IWRAM startDraw
										@@ Syncing
	mov r1, #ADDR_IO            		@@ /
.L_vDrawWait:                       	@@ Wait for vdraw, as to not draw when the screen is being drawn
    ldrh r2, [r1, #6]					@@ Load the vcount
    cmp r2, #0                      	@@ Compare to first scan line number, the start of the screen and start of vdraw
    bne .L_vDrawWait                	@@ /
.L_vBlankWait:                      	@@ Wait for vblank, as to not draw when the screen is being drawn
    ldrh r2, [r1, #6]					@@ Load the vcount
	cmp r2, #160             			@@ Compare to last scan line number, the end of the screen and start of vblank
	bne .L_vBlankWait					@@ /

	ldr r12, =fbPointer					@@ Load framebuffer address
	ldr r0, [r12]						@@ /

										@@ Double buffer enabling
	.macro setDoubleBuffer_0			@@ Disable double buffering
		bx lr							@@ Return
	.endm
	RUNTIME_REPLACE_OPTION setDoubleBuffer, DEFAULT_DOUBLE_BUFFER, 0
	.macro setDoubleBuffer_1			@@ Enable double buffering
		nop								@@ /
	.endm
	RUNTIME_REPLACE_OPTION setDoubleBuffer, DEFAULT_DOUBLE_BUFFER, 1

										@@ Double buffer code
	.macro doubleBufferMode_RESOLUTION_X240Y160
		mov r2, #ADDR_VRAM
    	str r0, [r1, #DMA3_SRC]         @@ Write graphics buffer address to dma source address.
    	str r2, [r1, #DMA3_DST]         @@ Write vram address to dma destination address
	
    	mov r3, #0x84000000             @@ Set dma control to copy pixel 0x4b00 times
    	orr r3, r3, #0x4B00             @@ /
    	str r3, [r1, #DMA3_CNT]         @@ /
	.endm
	RUNTIME_REPLACE_OPTION doubleBufferMode, DEFAULT_RESOLUTION, %(RESOLUTION_X240Y160), doubleBufferMode_RESOLUTION_X240Y160
	.macro doubleBufferMode_RESOLUTION_X160Y120
		eor r0, r0, #0xA000           	@@ Switch vram buffer by xor with page flip size
		str r0, [r12]					@@ /

		ldrh r2, [r1]					@@ Set LCD control to display the other frame
    	eor r2, r2, #0x10				@@ /
    	strh r2, [r1]					@@ /
		nop								@@ Padding data
	.endm
	RUNTIME_REPLACE_OPTION doubleBufferMode, DEFAULT_RESOLUTION, %(RESOLUTION_X160Y120), doubleBufferMode_RESOLUTION_X160Y120

    bx lr                               @@ /
FUNC_END startDraw


@@ Parameters: void
@@ Return: void
FUNC_IWRAM endDraw
    bx lr								@@ Return
FUNC_END endDraw

#endif