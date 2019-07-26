#include "../include/utils/delcs.h"
#include "utils/macros.s"

.extern startGame
.extern runGame
.extern exitGame

@@@@@@@@@@@@@@@@@@
@@-----CODE-----@@
@@@@@@@@@@@@@@@@@@

@@ Entry point
#if TARGET_PLATFORM == TARGET_GBA
  .global main
  FUNC main
#elif TARGET_PLATFORM == TARGET_LINUX
  .global _start
  FUNC _start
#endif
    ldr r0, =startGame
    mov lr, pc
    bx r0

    cmp r0, #0
    ldrne r0, =runGame
    movne lr, pc
    bxne r0

    ldr r0, =exitGame
    mov lr, pc
    bx r0
#if DEBUG == 1
    ASM_BREAK
infLoop:
    b infLoop
#endif

#if TARGET_PLATFORM == TARGET_GBA
  FUNC_END main
#elif TARGET_PLATFORM == TARGET_LINUX
  FUNC_END _start
#endif