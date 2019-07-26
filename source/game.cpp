#include "../include/graphics/graphics.h"
#include "../include/asm/utils.h"
#include "../include/input.h"
#include "../include/asm/gameObject.h"
#include "../include/asm/objModel.h"
#include "../include/asm/objModelGM.h"
#include "../include/gameplay/level.h"

// 1, 8x8 sprite per row.
const unsigned short PLANE_SPRITES[] = {
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0F00, 0x000F, 0x0000, 0x0000, 0x0900, 0x0B09, 0x0000, 0x0000, 0x0000, 0x0906, 0x0B09, 0x0006, 0x0000, 0x0902, 0x0909, 0x090B, 0x0209, 0x0202, 0x0202, 0x0202, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0009, 0x0000, 0x0000, 0x0000, 0x0604, 0x0906, 0x0B0B, 0x0B0B, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0B0B, 0x0609, 0x0909, 0x070B, 
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0E0C, 0x070E, 0x0000, 0x0000, 
    0x0303, 0x0505, 0x0808, 0x0308, 0x0D0F, 0x080A, 0x0A05, 0x0D03, 0x0000, 0x0A00, 0x0A0A, 0x0808, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
    0x0D08, 0x0F0F, 0x0D0F, 0x030A, 0x0D0F, 0x080A, 0x0303, 0x0503, 0x0105, 0x0301, 0x0303, 0x0303, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x0503, 0x0805, 0x0A0A, 0x0A0A, 0x0D0A, 0x0F0F, 0x0F0F, 0x0F0F, 0x0505, 0x0505, 0x0505, 0x0505, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 
    0x080A, 0x0C07, 0x0008, 0x0000, 0x0F0F, 0x0F0F, 0x000D, 0x0000, 0x0503, 0x0505, 0x0003, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
};

// All 256 colors. Color 0 is transparent.
const unsigned short COLOR_PALETTE[] = {
    0x0000, 0x1084, 0x2C86, 0x2108, 0x410A, 0x35AD, 0x718E, 0x0010, 0x4631, 0x6212, 0x5AD6, 0x7AD8, 0x017A, 0x6B5A, 0x5B9E, 0x7BDE, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF,
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF,
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF,
    0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF, 0x7FFF
};

#define COLOR_256	0x2000
#define SIZE_8		0x0
#define SIZE_16		0x4000
#define SIZE_32		0x8000
#define SIZE_64		0xC000

unsigned short* OAM_MEM =(unsigned short*)0x7000000;	//setup a pointer to OBJ memory

extern "C" bool startGame()
{
    bool succes = initGraphics();
    return succes;
}

extern "C" void runGame()
{
    // Debug
    u32 clrScreenColor = 0xFFFFFFFF;
    u16 testColor = 0xFF;

    // Camera setup
    s32 camX = 0;
    s32 camY = 0;
    s32 camZ = 0;

    while (true) {

        // Input handling
        keyPoll();
        if (keyIsDown(KEY_RIGHT))
            camX--;
        if (keyIsDown(KEY_LEFT))
            camX++;
        if (keyIsDown(KEY_R))
            camY--;
        if (keyIsDown(KEY_L))
            camY++;
        if (keyIsDown(KEY_UP))
            camZ--;
        if (keyIsDown(KEY_DOWN))
            camZ++;

        camZ--;
        if (camZ == -64)
            camZ = 0;

        startDraw(); // Switching resolution can cause a flicker if done before startDraw.
        if (keyIsPressed(KEY_START)) {
            if (getEncodedResolution() == Resolutions::X240Y160)
                setResolution(Resolutions::X160Y120);
            else if (getEncodedResolution() == Resolutions::X160Y120) 
                setResolution(Resolutions::X240Y160);
        }

        // Rendering
        clearScreen((u32)(&clrScreenColor), ClearScreenMode::FULL);
        drawLevel(camX, camY, camZ);

        //draw3DModel((u32)(fbPointer), (u32)(&OBJMODEL), OBJMODEL_SIZE, camX, camY, camZ + 65);
        //draw3DModel((u32)(fbPointer), (u32)(&OBJMODEL), OBJMODEL_SIZE, camX, camY, camZ);

        // Render tests
        //drawPixel(120, 80, testColor);
        //drawLine(130, 90, 220, 150, testColor);
        //drawLine(130, 70, 220, 10, testColor);
        //drawLine(110, 70, 20, 10, testColor);
        //drawLine(110, 90, 20, 150, testColor);
        //drawHorzLine(130, 80, 90, (u32)(&testColor));
        //drawHorzLine(110, 80, -90, (u32)(&testColor));
        //drawVertLine(120, 70, -60, (u32)(&testColor));
        //drawVertLine(120, 90, 60, (u32)(&testColor));
        //drawTriangleClipped((u32)(fbPointer), 10, 80, 230, 10, 120, 150, (u32)(&testColor));
        //drawTriangle3D(-20, 13, 240, 20, 13, 240, -20, 13, 20, (u32)(&testColor));
        //draw3DModel((u32)(fbPointer), (u32)(&OBJMODEL), OBJMODEL_SIZE, 0, 0, 0);

        endDraw();

    }
    return;

    pushGameObject(8, 9, 10, 11, (u32)(updateEnemy));
    pushGameObject(8, 9, 10, 11, (u32)(updateEnemy));
    pushGameObject(8, 9, 10, 11, (u32)(updateEnemy));
    pushGameObject(8, 9, 10, 11, (u32)(updateEnemy));
    pushGameObject(8, 9, 10, 11, (u32)(updateEnemy));
    popGameObject();

    // Rendering setup
    initGraphics();

    // Sprite setup
    setSpritePalette((u32)(&COLOR_PALETTE));
    setSpriteSheet((u32)(&PLANE_SPRITES), 8);

    // debug
    u32 testColorR = 0xFF;
    u32 testColorR2 = 0xFA;
    u32 testColorB = 0xFF00;
    u32 testColorB2 = 0xFA00;
    bool drawThick = true;
	OAM_MEM[0] = COLOR_256 | SIZE_16 | 50; // 256 color mode. Height: 16 pixels. Ypos: 50
	OAM_MEM[1] = SIZE_32 | 110;	// Width: 32 pixels. Xpos: 110.
	OAM_MEM[2] = 512 + 0; // Tile number, starting at 512 because bitmap mode is used.
    OAM_MEM[3] = 0; // Filler

	while(true) {
        /*g_GraphicsAddr = startDraw(g_GraphicsAddr);
        //clearScr(g_GraphicsAddr, (u32)(&clrScreenColor), 0);
        keyPoll();

        // Update
        //updateGameObjects();
        //noCashPrintVar("Camera (%vl%, %vl%, %vl%)", camX, camY, camZ);

        // Rendering
        noCashStartTimer();
        // Floors
        drawTriangle3D(g_GraphicsAddr, -20 + camX,  13 + camY, 240 + camZ, 
                                        20 + camX,  13 + camY, 240 + camZ, 
                                       -20 + camX,  13 + camY,  20 + camZ, (u32)(&testColorB));
        drawTriangle3D(g_GraphicsAddr,  20 + camX,  13 + camY, 240 + camZ, 
                                        20 + camX,  13 + camY,  20 + camZ, 
                                       -20 + camX,  13 + camY,  20 + camZ, (u32)(&testColorB2));  
        drawTriangle3D(g_GraphicsAddr, -20 + camX, -13 + camY, 240 + camZ, 
                                        20 + camX, -13 + camY, 240 + camZ, 
                                       -20 + camX, -13 + camY,  20 + camZ, (u32)(&testColorB2));
        drawTriangle3D(g_GraphicsAddr,  20 + camX, -13 + camY, 240 + camZ, 
                                        20 + camX, -13 + camY,  20 + camZ, 
                                       -20 + camX, -13 + camY,  20 + camZ, (u32)(&testColorB));
        // Walls
        drawTriangle3D(g_GraphicsAddr, -20 + camX,  13 + camY, 240 + camZ, 
                                       -20 + camX,  13 + camY,  20 + camZ, 
                                       -20 + camX, -13 + camY,  20 + camZ, (u32)(&testColorR));
        drawTriangle3D(g_GraphicsAddr, -20 + camX,  13 + camY, 240 + camZ, 
                                       -20 + camX, -13 + camY, 240 + camZ, 
                                       -20 + camX, -13 + camY,  20 + camZ, (u32)(&testColorR2));
        drawTriangle3D(g_GraphicsAddr,  20 + camX,  13 + camY, 240 + camZ, 
                                        20 + camX,  13 + camY,  20 + camZ, 
                                        20 + camX, -13 + camY,  20 + camZ, (u32)(&testColorR2));
        drawTriangle3D(g_GraphicsAddr,  20 + camX,  13 + camY, 240 + camZ, 
                                        20 + camX, -13 + camY, 240 + camZ, 
                                        20 + camX, -13 + camY,  20 + camZ, (u32)(&testColorR));
        noCashStopTimer();

        draw3DModel(g_GraphicsAddr, (u32)(&CANYON), CANYON_SIZE, camX, camY, camZ);
        draw3DModel(g_GraphicsAddr, (u32)(&OBJMODEL), OBJMODEL_SIZE, camX, camY, camZ);
        */

        // Movement
        if (keyIsDown(KEY_RIGHT))
            camX--;
        if (keyIsDown(KEY_LEFT))
            camX++;
        if (keyIsDown(KEY_R))
            camY--;
        if (keyIsDown(KEY_L))
            camY++;
        if (keyIsDown(KEY_UP))
            camZ--;
        if (keyIsDown(KEY_DOWN))
            camZ++;

        // Pause
        if (keyIsPressed(KEY_START)) {
            bool isWireFrame = !isWireframeEnabled();
            setWireframe(!isWireframeEnabled(), drawThick);
            if (isWireFrame)
                drawThick = !drawThick;
        }
    }
}

extern "C" bool exitGame()
{
    bool succes = destroyGraphics();
    return succes;
}