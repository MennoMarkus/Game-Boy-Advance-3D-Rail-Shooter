#include "../include/asm/graphics.h"
#include "../include/asm/utils.h"
#include "../include/input.h"
#include "../include/objModel.h"

int main()
{
    s32 camX = 0;
    s32 camY = 0;
    s32 camZ = 10;

    u32 vramAddr = ADDR_VRAM;
    u32 clrScreenColor = 0xFFFFFFFF;
    initGraphics();

    while(true) {
        //vramAddr = startDraw(vramAddr);
        clearScr(vramAddr, (u32)(&clrScreenColor));
        keyPoll();

        // Rendering
        drawObjModel(vramAddr, camX, camY, camZ);

        noCashStartTimer();
        // Movement
        if (keyIsDown(KEY_RIGHT))
            camY--;
        if (keyIsDown(KEY_LEFT))
            camY++;
        if (keyIsDown(KEY_L))
            camX--;
        if (keyIsDown(KEY_R))
            camX++;
        if (keyIsDown(KEY_UP))
            camZ--;
        if (keyIsDown(KEY_DOWN))
            camZ++;

        // Pause
        if (keyIsDown(KEY_START)) {
            BREAK
        }

        noCashStopTimer();
        vramAddr = startDraw(vramAddr);
    }

	return 0;
}