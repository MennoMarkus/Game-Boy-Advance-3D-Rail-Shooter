#pragma once
#include "./delcs.h"
#include "./types.h"

// The buffer in RAM memory that functions as a graphics buffer in mode 3 dubble buffering.
#if GRAPHICS_MODE == 3 && DUBBLE_BUFFER == 1
extern "C" const u16 GRAPHICS_BUFFER[CANVAS_HEIGHT][CANVAS_WIDTH];
#endif

// The memory address of the start of a buffer where graphics data can be written for rendering to the screen.
// The initial address changes depending the settings, but the the address can/will also be changed during runtime.
#if GRAPHICS_MODE == 3 && DUBBLE_BUFFER == 1
    u32 g_GraphicsAddr = (u32)(&GRAPHICS_BUFFER);
#elif GRAPHICS_MODE == 5 && DUBBLE_BUFFER == 1
    u32 g_GraphicsAddr = ADDR_VRAM ^ 0xa000;
#else
    u32 g_GraphicsAddr = ADDR_VRAM;
#endif

// Declerations for the assembly graphics functions.
extern "C" void initGraphics();
//Available clear modes - (0, none,  clears entire screen)
//                      - (1, top,   clears top half for vert/diag mirroring)
//                      - (2, left,  clears left side for horz mirroring)
extern "C" void clearScr(u32 graphicsAddr, u32 colorAddr, u32 clearMode = 0);
extern "C" u32 startDraw(u32 graphicsAddr);

extern "C" void m3_drawPixel(u32 graphicsAddr, u32 x, u32 y, u16 color);
extern "C" void m3_drawLine(u32 graphicsAddr, u32 x, u32 y, u32 x2, u32 y2, u16 color);
extern "C" void m3_drawHorzLine(u32 graphicsAddr, u32 x, u32 y, s32 width, u32 color16Addr);
extern "C" void m3_drawVertLine(u32 graphicsAddr, u32 x, u32 y, s32 height, u32 color16Addr);
extern "C" void m3_drawRectFromCenter(u32 graphicsAddr, u32 x, u32 y, u32 halfWidth, u32 halfHeight, u32 color32Addr);
extern "C" void m3_drawRectFromCorner(u32 graphicsAddr, u32 x, u32 y, u32 width, u32 height, u32 color16Addr);
extern "C" void m3_drawRectEmpty(u32 graphicsAddr, u32 x, u32 y, u32 width, u32 height, u32 color16Addr);
extern "C" void m3_drawCircle(u32 graphicsAddr, u32 x, u32 y, u32 radius, u32 color16Addr);
extern "C" void m3_drawCircleEmpty(u32 graphicsAddr, u32 x, u32 y, u32 radius, u16 color);
extern "C" void m3_mirrorScreenHorz(u32 graphicsAddr);
extern "C" void m3_mirrorScreenVert(u32 graphicsAddr);
extern "C" void m3_mirrorScreenDiag(u32 graphicsAddr);
extern "C" void m3_draw3DModel(u32 graphicsAddr, u32 modeladdr, u32 triangleCount, s32 camX, s32 camY, s32 camZ);
extern "C" void m3_drawTriangleClipped(u32 graphicsAddr, s32 x1, s32 y1, s32 x2, s32 y2, s32 x3, s32 y3, u32 color16Addr);
extern "C" void m3_drawTriangle3D(u32 graphicsAddr, s32 x1, s32 y1, s32 z1, s32 x2, s32 y2, s32 z2, s32 x3, s32 y3, s32 z3, u32 color16Addr);

extern "C" void setSpritePalette(u32 paletteSourceAddr, u32 palletLength = 256, u8 paletteDestinationIndex = 0);
extern "C" void setSpriteSheet(u32 spriteSheetSourceAddr, u32 spriteCount = 256, u8 spriteDestinationIndex = 0);

// Wrappers for easy compatibility between mode 3 and 5.
static inline void drawPixel(u32 graphicsAddr, u32 x, u32 y, u16 color) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawPixel(graphicsAddr, x, y, color); 
    #elif GRAPHICS_MODE == 5 
    m3_drawPixel(graphicsAddr, y, x / 2, color); 
    #endif
}

static inline void drawLine(u32 graphicsAddr, u32 x, u32 y, u32 x2, u32 y2, u16 color) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawLine(graphicsAddr, x, y, x2, y2, color); 
    #elif GRAPHICS_MODE == 5 
    m3_drawLine(graphicsAddr, y, x / 2, y2, x2 / 2, color); 
    #endif
}

static inline void drawHorzLine(u32 graphicsAddr, u32 x, u32 y, s32 width, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawHorzLine(graphicsAddr, x, y, width, color16Addr); 
    #elif GRAPHICS_MODE == 5 
    m3_drawVertLine(graphicsAddr, y, x / 2, width / 2, color16Addr); 
    #endif
}

static inline void drawVertLine(u32 graphicsAddr, u32 x, u32 y, s32 height, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawVertLine(graphicsAddr, x, y, height, color16Addr); 
    #elif GRAPHICS_MODE == 5 
    m3_drawHorzLine(graphicsAddr, y, x / 2, height, color16Addr); 
    #endif
}

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

static inline void drawTriangle(u32 graphicsAddr, s32 x1, s32 y1, s32 x2, s32 y2, s32 x3, s32 y3, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawTriangleClipped(graphicsAddr, x1, y1, x2, y2, x3, y3, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawTriangleClipped(graphicsAddr, y1, x1 / 2, y2, x2 / 2, y3, x3 / 2, color16Addr);
    #endif
}

static inline void drawTriangle3D(u32 graphicsAddr, s32 x1, s32 y1, s32 z1, s32 x2, s32 y2, s32 z2, s32 x3, s32 y3, s32 z3, u32 color16Addr)
{
    #if GRAPHICS_MODE == 3
    m3_drawTriangle3D(graphicsAddr, x1, y1, z1, x2, y2, z2, x3, y3, z3, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawTriangle3D(graphicsAddr, y1, x1 / 2, z1, y2, x2 / 2, z2, y3, x3 / 2, z3, color16Addr);
    #endif
}