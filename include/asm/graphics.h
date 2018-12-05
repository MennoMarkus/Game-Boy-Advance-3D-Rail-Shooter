#pragma once
#include "./delcs.h"
#include "./types.h"

extern "C" void initGraphics();
extern "C" void clearScr(u32 vramAdress, u32 colorAdress);
extern "C" u32 startDraw(u32 vramAdress);

extern "C" void m3_drawPixel(u32 vramAdress, u32 x, u32 y, u16 color);
extern "C" void m3_drawLine(u32 vramAdress, u32 x, u32 y, u32 x2, u32 y2, u16 color);
extern "C" void m3_drawHorzLine(u32 vramAdress, u32 x, u32 y, s32 width, u32 color16Addr);
extern "C" void m3_drawVertLine(u32 vramAdress, u32 x, u32 y, s32 height, u32 color16Addr);
extern "C" void m3_drawRectFromCenter(u32 vramAdress, u32 x, u32 y, u32 halfWidth, u32 halfHeight, u32 color32Addr);
extern "C" void m3_drawRectFromCorner(u32 vramAdress, u32 x, u32 y, u32 width, u32 height, u32 color16Addr);
extern "C" void m3_drawRectEmpty(u32 vramAdress, u32 x, u32 y, u32 width, u32 height, u32 color16Addr);
extern "C" void m3_drawCircle(u32 vramAdress, u32 x, u32 y, u32 radius, u32 color16Addr);
extern "C" void m3_drawCircleEmpty(u32 vramAdress, u32 x, u32 y, u32 radius, u16 color);
extern "C" void m3_drawTriangle(u32 vramAdress, u32 x1, u32 y1, u32 x2, u32 y2, u32 x3, u32 y3, u32 color16Addr);
extern "C" void m3_drawTriangleClipped(u32 vramAdress, s32 x1, s32 y1, s32 x2, s32 y2, s32 x3, s32 y3, u32 color16Addr);
extern "C" void m3_drawTriangleClipped3D(u32 vramAdress, s32 x1, s32 y1, s32 z1, s32 x2, s32 y2, s32 z2, s32 x3, s32 y3, s32 z3, u32 color16Addr);

static inline void drawPixel(u32 vramAdress, u32 x, u32 y, u16 color) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawPixel(vramAdress, x, y, color); 
    #elif GRAPHICS_MODE == 5 
    m3_drawPixel(vramAdress, y, x / 2, color); 
    #endif
}

static inline void drawLine(u32 vramAdress, u32 x, u32 y, u32 x2, u32 y2, u16 color) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawLine(vramAdress, x, y, x2, y2, color); 
    #elif GRAPHICS_MODE == 5 
    m3_drawLine(vramAdress, y, x / 2, y2, x2 / 2, color); 
    #endif
}

static inline void drawHorzLine(u32 vramAdress, u32 x, u32 y, s32 width, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawHorzLine(vramAdress, x, y, width, color16Addr); 
    #elif GRAPHICS_MODE == 5 
    m3_drawVertLine(vramAdress, y, x / 2, width / 2, color16Addr); 
    #endif
}

static inline void drawVertLine(u32 vramAdress, u32 x, u32 y, s32 height, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3 
    m3_drawVertLine(vramAdress, x, y, height, color16Addr); 
    #elif GRAPHICS_MODE == 5 
    m3_drawHorzLine(vramAdress, y, x / 2, height, color16Addr); 
    #endif
}

static inline void drawRectFromCenter(u32 vramAdress, u32 x, u32 y, u32 halfWidth, u32 halfHeight, u32 color32Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawRectFromCenter(vramAdress, x, y, halfWidth, halfHeight, color32Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawRectFromCenter(vramAdress, y, x / 2, halfHeight, halfWidth / 2, color32Addr);
    #endif
}

static inline void drawRectFromCorner(u32 vramAdress, u32 x, u32 y, u32 width, u32 height, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawRectFromCorner(vramAdress, x, y, width, height, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawRectFromCorner(vramAdress, y, x / 2, height, width / 2, color16Addr);
    #endif
}

static inline void drawRectEmpty(u32 vramAdress, u32 x, u32 y, u32 width, u32 height, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawRectEmpty(vramAdress, x, y, width, height, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawRectEmpty(vramAdress, y, x / 2, height, width / 2, color16Addr);
    #endif
}

static inline void drawCircle(u32 vramAdress, u32 x, u32 y, u32 radius, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawCircle(vramAdress, x, y, radius, color16Addr);
    #elif GRAPHICS_MODE == 5
    //TODO m5_drawCircle
    m3_drawCircle(vramAdress, y, x / 2, radius, color16Addr);
    #endif
}

static inline void drawCircleEmpty(u32 vramAdress, u32 x, u32 y, u32 radius, u16 color) 
{
    #if GRAPHICS_MODE == 3
    m3_drawCircleEmpty(vramAdress, x, y, radius, color);
    #elif GRAPHICS_MODE == 5
    //TODO m5_drawCircleEmpty
    m3_drawCircleEmpty(vramAdress, y, x / 2, radius, color);
    #endif
}

static inline void drawTriangle(u32 vramAdress, u32 x1, u32 y1, u32 x2, u32 y2, u32 x3, u32 y3, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawTriangle(vramAdress, x1, y1, x2, y2, x3, y3, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawTriangle(vramAdress, y1, x1 / 2, y2, x2 / 2, y3, x3 / 2, color16Addr);
    #endif
}

static inline void drawTriangleClipped(u32 vramAdress, s32 x1, s32 y1, s32 x2, s32 y2, s32 x3, s32 y3, u32 color16Addr) 
{
    #if GRAPHICS_MODE == 3
    m3_drawTriangleClipped(vramAdress, x1, y1, x2, y2, x3, y3, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawTriangleClipped(vramAdress, y1, x1 / 2, y2, x2 / 2, y3, x3 / 2, color16Addr);
    #endif
}

static inline void drawTriangleClipped3D(u32 vramAdress, s32 x1, s32 y1, s32 z1, s32 x2, s32 y2, s32 z2, s32 x3, s32 y3, s32 z3, u32 color16Addr)
{
    #if GRAPHICS_MODE == 3
    m3_drawTriangleClipped3D(vramAdress, x1, y1, z1, x2, y2, z2, x3, y3, z3, color16Addr);
    #elif GRAPHICS_MODE == 5
    m3_drawTriangleClipped3D(vramAdress, x1, y1, z1, x2, y2, z2, x3, y3, z3, color16Addr);
    #endif
}