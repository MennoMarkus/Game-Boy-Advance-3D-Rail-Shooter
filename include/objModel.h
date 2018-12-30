#pragma once
#include "./types.h"
#include "./asm/graphics.h"

#define OBJ_MODEL_SIZE 112
extern "C" const s16 OBJ_MODEL[OBJ_MODEL_SIZE][10];

void drawObjModel(u32 vramAdress, s32 camX, s32 camY, s32 camZ) {
    for (int tri = 0; tri < OBJ_MODEL_SIZE; tri++) {
        drawTriangleClipped3D(vramAdress,   -OBJ_MODEL[tri][2] + camX, OBJ_MODEL[tri][1] + camY, OBJ_MODEL[tri][0] + camZ,
                                            -OBJ_MODEL[tri][5] + camX, OBJ_MODEL[tri][4] + camY, OBJ_MODEL[tri][3] + camZ,
                                            -OBJ_MODEL[tri][8] + camX, OBJ_MODEL[tri][7] + camY, OBJ_MODEL[tri][6] + camZ,
                                            (u32)(&OBJ_MODEL[tri][9]));
    }
}
