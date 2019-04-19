#include "../../include/delcs.h"

@@ Data available:
@@ - GAMEOBJECT_BUFFER
@@ - GAMEOBJECT_START_PTR
@@ - GAMEOBJECT_END_PTR

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ -------------DATA------------ @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.data

@@ A ram buffer containing gameobjects data. Each gameobjects update method is called each frame
@@ TODO use .sbss to save on rom memory
.section .iwram
.align 2
.global GAMEOBJECT_BUFFER
GAMEOBJECT_BUFFER:
.rept GAMEOBJECT_BUFFER_SIZE
    .space GAMEOBJECT_SIZE
.endr
.size GAMEOBJECT_BUFFER, .-GAMEOBJECT_BUFFER

@@ A pointer to the current start of the gameobject que
.section .iwram
.align 2
.global GAMEOBJECT_START_PTR
GAMEOBJECT_START_PTR:
.word GAMEOBJECT_BUFFER
.size GAMEOBJECT_START_PTR, .-GAMEOBJECT_START_PTR

@@ A pointer to the current end of the gameobject que
.section .iwram
.align 2
.global GAMEOBJECT_END_PTR
GAMEOBJECT_END_PTR:
.word GAMEOBJECT_BUFFER
.size GAMEOBJECT_END_PTR, .-GAMEOBJECT_END_PTR

@@ Functions available:
@@ - pushGameObject
@@ - popGameObject

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ ----------FUNCTIONS---------- @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.text

@@ Parameters: (r0, data), (r1, x), (r2, y), (r3, z), (sp #0, updateAddr)
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global pushGameObject
.type pushGameObject STT_FUNC
pushGameObject:
    ldr r12, =GAMEOBJECT_END_PTR        @@ Load the end pointer of the gameobject queue
    ldr r12, [r12]                      @@ /

    orr r0, r0, #0x8000                 @@ Set the first bit of the data to 1, to enable the active flag
    orr r0, r1, r0, lsl #16             @@ Combine 16 bit data and 16 bit xPos into a single 32 bit value
    orr r2, r3, r2, lsl #16             @@ Combine 16 bit yPos and 16 bit zPos into a single 32 bit value
    ldr r3, [sp]                        @@ Load the updateAddr from the stack
    stmia r12!, {r0, r2, r3}            @@ Write gameobject data

    ldr r0, =GAMEOBJECT_BUFFER + GAMEOBJECT_BUFFER_SIZE * GAMEOBJECT_SIZE
    cmp r12, r0                         @@ If we go past the buffer end:
    ldrge r12, =GAMEOBJECT_BUFFER       @@ Set end pointer of the gameobject queue to the buffer start

    ldr r0, =GAMEOBJECT_END_PTR         @@ Write the new end pointer of the gameobject queue
    str r12, [r0]                       @@ /
    bx lr                               @@ Retrun
.size pushGameObject, .-pushGameObject


@@ Parameters: void
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global popGameObject
.type popGameObject STT_FUNC
popGameObject:
    ldr r0, =GAMEOBJECT_START_PTR       @@ Load the start pointer of the gameobject que
    ldr r1, [r0]                        @@ /

    add r1, r1, #GAMEOBJECT_SIZE        @@ Move the start pointer of the gameobject que
    ldr r2, =GAMEOBJECT_BUFFER + GAMEOBJECT_BUFFER_SIZE * GAMEOBJECT_SIZE
    cmp r1, r0                          @@ If we go past the buffer end:
    ldrge r1, =GAMEOBJECT_BUFFER        @@ Set start pointer of the gameobject que to the buffer start

    str r1, [r0]                        @@ Write the new start pointer of the gameobject que
    bx lr                               @@ Return
.size popGameObject, .-popGameObject


@@ Parameters: void
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global updateGameObjects
.type updateGameObjects STT_FUNC
updateGameObjects:
    push {lr}                           @@ Push return address to the stack

    ldr r0, =GAMEOBJECT_START_PTR       @@ Load the start pointer of the gameobject que
    ldr r1, [r0]                        @@ /
    ldr r0, =GAMEOBJECT_BUFFER + GAMEOBJECT_BUFFER_SIZE * GAMEOBJECT_SIZE
    ldr r2, =GAMEOBJECT_END_PTR         @@ Load the end pointer of the gameobject queue
    ldr r2, [r2]                        @@ 

.L_updateGameObjectsLoop:
    add lr, pc, #4                      @@ Load return adddress
   @ ldr pc, [r1, #8]                    @@ Call updateMethodAddr
    @@ UPDATE
    add r1, r1, #GAMEOBJECT_SIZE        @@ Move the start pointer of the gameobject que
    cmp r1, r0                          @@ If we go past the buffer end:
    ldrge r1, =GAMEOBJECT_BUFFER        @@ Set start pointer of the gameobject que to the buffer start

    cmp r1, r2                          @@ If we have not reached the end of the buffer
    bne .L_updateGameObjectsLoop        @@ Loop back up

    pop {lr}                            @@ Return
    bx lr                               @@ /
.size updateGameObjects, .-updateGameObjects


@@ Parameters: void
@@ Return: void
.section .iwram, "ax", %progbits
.align 2
.arm
.global updateEnemy
.type updateEnemy STT_FUNC
updateEnemy:
    ASM_BREAK
    bx lr                               @@ Return
.size updateEnemy, .-updateEnemy