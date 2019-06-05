#pragma once
#include "../utils/delcs.h"
#include "../types.h"
#include "resolutions.h"

///////////////////////
//-----CONSTANTS-----//
///////////////////////

enum ClearScreenMode {
    FULL = 0,
    TOP  = 1,
    LEFT = 2
};


///////////////////////////////////
//-----ASSEMBLY DECLERATIONS-----//
///////////////////////////////////
extern "C" u16* fbPointer;

extern "C" bool initGraphics();                             // Returns success
extern "C" bool destroyGraphics();                          // Returns success

extern "C" u32 startDraw();                                 // Returns the frame buffer pointer
extern "C" void endDraw();

extern "C" bool setResolution(Resolutions resolution);      // Returns success
extern "C" u32 getEncodedResolution();                      // Get the resolution encoded as (x << 16) | y. Faster than getResolution.
extern "C" void getResolution(u32& x, u32& y);

extern "C" bool setDoubleBuffer(bool enabled);              // Returns success
extern "C" bool getDoubleBuffer(); 

extern "C" void clearScreen(u32 colorAddr, ClearScreenMode clearMode = ClearScreenMode::FULL);
extern "C" void drawPixel(u32 x, u32 y, u32 color16Addr);
extern "C" void drawLine(u32 x, u32 y, u32 x2, u32 y2, u16 color);
extern "C" void drawHorzLine(u32 x, u32 y, s32 width, u32 color16Addr);
extern "C" void drawVertLine(u32 x, u32 y, s32 height, u32 color16Addr);
extern "C" void draw3DModel(u32 graphicsAddr, u32 modeladdr, u32 triangleCount, s32 camX, s32 camY, s32 camZ);
extern "C" void drawTriangle3D(u32 graphicsAddr, s32 x1, s32 y1, s32 z1, s32 x2, s32 y2, s32 z2, s32 x3, s32 y3, s32 z3, u32 color16Addr);
extern "C" void drawTriangleClipped(u32 graphicsAddr, s32 x1, s32 y1, s32 x2, s32 y2, s32 x3, s32 y3, u32 color16Addr);

extern "C" void setSpritePalette(u32 paletteSourceAddr, u32 palletLength = 256, u8 paletteDestinationIndex = 0);
extern "C" void setSpriteSheet(u32 spriteSheetSourceAddr, u32 spriteCount = 256, u8 spriteDestinationIndex = 0);

//Available clear modes - (0, none,  clear none)
//                      - (1, clears entire screen)
//                      - (2, top,   clears top half for vert/diag mirroring)
//                      - (3, left,  clears left side for horz mirroring)
//extern "C" void clearScr(u32 graphicsAddr, u32 colorAddr, u32 clearMode = 0);
//extern "C" void drawPixel(u32 graphicsAddr, u32 x, u32 y, u16 color);
//extern "C" void drawLine(u32 graphicsAddr, u32 x, u32 y, u32 x2, u32 y2, u16 color);
//extern "C" void drawHorzLine(u32 graphicsAddr, u32 x, u32 y, s32 width, u32 color16Addr);
//extern "C" void drawVertLine(u32 graphicsAddr, u32 x, u32 y, s32 height, u32 color16Addr);
extern "C" void m3_drawRectFromCenter(u32 graphicsAddr, u32 x, u32 y, u32 halfWidth, u32 halfHeight, u32 color32Addr);
extern "C" void m3_drawRectFromCorner(u32 graphicsAddr, u32 x, u32 y, u32 width, u32 height, u32 color16Addr);
extern "C" void m3_drawRectEmpty(u32 graphicsAddr, u32 x, u32 y, u32 width, u32 height, u32 color16Addr);
extern "C" void m3_drawCircle(u32 graphicsAddr, u32 x, u32 y, u32 radius, u32 color16Addr);
extern "C" void m3_drawCircleEmpty(u32 graphicsAddr, u32 x, u32 y, u32 radius, u16 color);
extern "C" void m3_mirrorScreenHorz(u32 graphicsAddr);
extern "C" void m3_mirrorScreenVert(u32 graphicsAddr);
extern "C" void m3_mirrorScreenDiag(u32 graphicsAddr);
extern "C" void setWireframe(bool enabled, bool useThickLines=false);
extern "C" bool isWireframeEnabled();
//extern "C" void draw3DModel(u32 graphicsAddr, u32 modeladdr, u32 triangleCount, s32 camX, s32 camY, s32 camZ);
//extern "C" void m3_drawTriangleClipped(u32 graphicsAddr, s32 x1, s32 y1, s32 x2, s32 y2, s32 x3, s32 y3, u32 color16Addr);
// Expects vertices to be z-sorted with the furthest vertex in z1.
//extern "C" void m3_drawTriangle3D(u32 graphicsAddr, s32 x1, s32 y1, s32 z1, s32 x2, s32 y2, s32 z2, s32 x3, s32 y3, s32 z3, u32 color16Addr);

//extern "C" void setSpritePalette(u32 paletteSourceAddr, u32 palletLength = 256, u8 paletteDestinationIndex = 0);
//extern "C" void setSpriteSheet(u32 spriteSheetSourceAddr, u32 spriteCount = 256, u8 spriteDestinationIndex = 0);

// Wrappers for easy compatibility between mode 3 and 5.
static inline void drawRectFromCenter(u32 graphicsAddr, u32 x, u32 y, u32 halfWidth, u32 halfHeight, u32 color32Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawRectFromCenter(graphicsAddr, x, y, halfWidth, halfHeight, color32Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawRectFromCenter(graphicsAddr, y, x / 2, halfHeight, halfWidth / 2, color32Addr);
    #endif
}

static inline void drawRectFromCorner(u32 graphicsAddr, u32 x, u32 y, u32 width, u32 height, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawRectFromCorner(graphicsAddr, x, y, width, height, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawRectFromCorner(graphicsAddr, y, x / 2, height, width / 2, color16Addr);
    #endif
}

static inline void drawRectEmpty(u32 graphicsAddr, u32 x, u32 y, u32 width, u32 height, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawRectEmpty(graphicsAddr, x, y, width, height, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawRectEmpty(graphicsAddr, y, x / 2, height, width / 2, color16Addr);
    #endif
}

static inline void drawCircle(u32 graphicsAddr, u32 x, u32 y, u32 radius, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawCircle(graphicsAddr, x, y, radius, color16Addr);
    #elif GRAPHICS_MODE == 5
    //TODO m5_drawCircle, currently draws an ellipse
    m3_drawCircle(graphicsAddr, y, x / 2, radius, color16Addr);
    #endif
}

static inline void drawCircleEmpty(u32 graphicsAddr, u32 x, u32 y, u32 radius, u16 color) 
{
    #if GRAPHICS_MODE == 3
    m3_drawCircleEmpty(graphicsAddr, x, y, radius, color);
    #elif GRAPHICS_MODE == 5
    //TODO m5_drawCircleEmpty, currently draws an ellipse
    m3_drawCircleEmpty(graphicsAddr, y, x / 2, radius, color);
    #endif
}

static inline void mirrorScreenHorz(u32 graphicsAddr) 
{
    #if GRAPHICS_MODE == 3
    m3_mirrorScreenHorz(graphicsAddr);
    #elif GRAPHICS_MODE == 5
    m3_mirrorScreenVert(graphicsAddr);
    #endif
}

static inline void mirrorScreenVert(u32 graphicsAddr)
{
    #if GRAPHICS_MODE == 3
    m3_mirrorScreenVert(graphicsAddr);
    #elif GRAPHICS_MODE == 5
    m3_mirrorScreenHorz(graphicsAddr);
    #endif
}

static inline void mirrorScreenDiag(u32 graphicsAddr)
{
    //TODO flips differently in mode 5 than in 3. Will potentially never get fixed as it would lose the speed benefit of using this functions.
    m3_mirrorScreenDiag(graphicsAddr);
}