#define GRAPHICS_MODE 5

#define ADDR_EWRAM  0x2000000
#define ADDR_IWRAM  0x3000000
#define ADDR_IO     0x4000000
#define ADDR_PAL    0x5000000
#define ADDR_VRAM   0x6000000
#define ADDR_OAM    0x7000000
#define ADDR_ROM    0x8000000
#define ADDR_SRAM   0xE000000

//GRAPHICS
#if GRAPHICS_MODE == 3
#define CANVAS_WIDTH 240
#define CANVAS_HEIGHT 160
#define PIXEL_COUNT 0x9600

#elif GRAPHICS_MODE == 5
#define CANVAS_WIDTH 160
#define CANVAS_HEIGHT 120
#define PIXEL_COUNT 0x5000

#endif

#define SCREEN_WIDTH 240
#define SCREEN_HEIGHT 160
#define PAGE_FLIP_SIZE 0xa000
#define BPP 2
#define BPP_POW 1

//DMA OFFSETS
#define DMA0_SRC 0xb0
#define DMA0_DST 0xb4
#define DMA0_CNT 0xb8

#define DMA1_SRC 0xbc
#define DMA1_DST 0xc0
#define DMA1_CNT 0xc4

#define DMA2_SRC 0xc8
#define DMA2_DST 0xcc
#define DMA2_CNT 0xd0

#define DMA3_SRC 0xd4
#define DMA3_DST 0xd8
#define DMA3_CNT 0xdc

//KEY INPUT
#define KEY_INPUT 0x130
#define KEY_MASK 0x3FF

#define KEY_A       0x001
#define KEY_B       0x002
#define KEY_SELECT  0x004
#define KEY_START   0x008
#define KEY_RIGHT   0x010
#define KEY_LEFT    0x020
#define KEY_UP      0x040
#define KEY_DOWN    0x080
#define KEY_R       0x100
#define KEY_L       0x200
#define KEY_ANY     0x3FF

//DEBUG
#define BREAK __asm ("mov r11, r11");
#define ASM_BREAK mov r11, r11
#define TODO 