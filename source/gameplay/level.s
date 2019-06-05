#include "../../include/utils/delcs.h"
#include "../utils/macros.s"


@@@@@@@@@@@@@@@@@@
@@-----DATA-----@@
@@@@@@@@@@@@@@@@@@
.data

@@ Summary:

.irp index, SECTION_COUNT
    DATA_IWRAM sectionBuffer\index
        .fill TRIANGLES_PER_SECTION * 10,2,0 
    sectionBuffer\index\()_end:
.endr
sectionsBuffer_end:

DATA_IWRAM lastSectionPointer
    .word sectionBuffer2
DATA_IWRAM copySectionPointer
	.word sectionBuffer2
DATA_IWRAM copyTrianglePointer
	.word TEMPLATE
DATA_IWRAM copyTriangleCount
    .word 6


@@@@@@@@@@@@@@@@@@
@@-----CODE-----@@
@@@@@@@@@@@@@@@@@@
.text

@@ Summary:
.global drawLevel

@@ Parameters: (r0, camX), (r1, camY), (r2, camZ)
@@ Return: void
FUNC_IWRAM drawLevel
	push {r4, r5, lr}
	mov r3, r0										@@ Pass camera values
	mov r4, r1										@@ /
	mov r5, r2										@@ /

	mov r0, #FRAME_BUFFER_ADDR      				@@ Load graphics buffer address
    ldr r0, [r0]                    				@@ /
	ldr r1, =sectionBuffer2							@@ Load section start address
	mov r2, #TRIANGLES_PER_SECTION					@@ Load triangle count
	push {r3}
	push {r4, r5}
	bl draw3DModel

	pop {r4, r5}
	pop {r3}
	mov r0, #FRAME_BUFFER_ADDR      				@@ Load graphics buffer address
    ldr r0, [r0]                    				@@ /
	ldr r1, =sectionBuffer1							@@ Load section start address
	mov r2, #TRIANGLES_PER_SECTION					@@ Load triangle count
	push {r3}
	add r5, r5, #SECTION_LENGTH						@@ Increment z pos
	push {r4, r5}
	bl draw3DModel

	pop {r4, r5}
	pop {r3}
	mov r0, #FRAME_BUFFER_ADDR      				@@ Load graphics buffer address
    ldr r0, [r0]                    				@@ /
	ldr r1, =sectionBuffer0							@@ Load section start address
	mov r2, #TRIANGLES_PER_SECTION					@@ Load triangle count
	push {r3}
	add r5, r5, #SECTION_LENGTH						@@ Increment z pos
	push {r4, r5}
	bl draw3DModel

    ldr r0, =copyTriangleCount                  	@@ Load how many triangles are left to copy
    ldr r4, [r0]                                	@@ /
    cmp r4, #0                                  	@@ If there are no triangles to copy:
	beq .L_drawLevel_nextSection					@@ Load the next section

	subs r1, r4, #TRIANGLES_PER_COPY				@@ Decrement triangle count
	movmi r1, #0									@@ Max(triangle count, 0)
	str r1, [r0]									@@ /

    ldr r1, =copyTrianglePointer                	@@ Load triangle pointer into r2
    ldr r2, [r1]                                	@@ /
    add r3, r2, #TRIANGLES_PER_COPY * 10 * 2    	@@ Increment triangle pointer
    str r3, [r1]                                	@@ /

    ldr r1, =copySectionPointer                		@@ Load copy pointer into r3
    ldr r3, [r1]                                	@@ /
    add r12, r3, #TRIANGLES_PER_COPY * 10 * 2   	@@ Increment copy pointer
	str r12, [r1]                                	@@ /

    mov r1, #ADDR_IO                            	@@ Load dma base adress
	add r1, r1, #DMA3_SRC							@@ /
	mov r12, #0x84000000							@@ Set dma to copy min(triangle count, TRIANGLES_PER_COPY) amount of triangles
	addmi r4, r4, r4, lsl #2						@@ /
	orrmi r12, r12, r4								@@ /
	orrpl r12, r12, #TRIANGLES_PER_COPY * 5			@@ /
	stmia r1, {r2, r3, r12}							@@ Write triangle pointer as dma source and copy pointer as dma destination

	pop {r1, r2, r3, r4, r5, lr}						@@ Return
    bx lr											@@ /

.L_drawLevel_nextSection:
	ldr r1, =lastSectionPointer						@@ Increment the last section pointer to be the next section
	ldr r2, [r1]									@@ /
	add r2, r2, #TRIANGLES_PER_SECTION * 10 * 2		@@ /
	ldr r3, =sectionsBuffer_end						@@ If we go past the sections buffer end:
	cmp r2, r3										@@ /
	ldrge r2, =sectionBuffer0						@@ set the pointer back to the start
	str r2, [r1]									@@ Write last section pointer

	ldr r3, =copySectionPointer                		@@ Write last section pointer as copy pointer
	str r2, [r3]									@@ /

	ldr r1, =copyTrianglePointer					@@ Load new model 
	ldr r2, =TEMPLATE								@@ /
	ldr r3, =6										@@ /
	stmia r1, {r2, r3}								@@ /
	
	pop {r1, r2, r3, r4, r5, lr}						@@ Return
    bx lr											@@ /
FUNC_END drawLevel