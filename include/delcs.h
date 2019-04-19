#define GRAPHICS_MODE 3

#define ADDR_EWRAM  0x2000000
#define ADDR_IWRAM  0x3000000
#define ADDR_IO     0x4000000
#define ADDR_PAL    0x5000000
#define ADDR_VRAM   0x6000000
#define ADDR_OAM    0x7000000
#define ADDR_ROM    0x8000000
#define ADDR_SRAM   0xE000000

//GENERAL
#define PREPROCESSED_DATA 0
#define LUT_DIVISION_SIGNED_FIX 0 // Fixes an issues where / 1 or / 2 with the lut is incorrect at the cost of 3 more cycles

//GRAPHICS
#if GRAPHICS_MODE == 3
#define CANVAS_WIDTH 240
#define CANVAS_HEIGHT 160
#define PIXEL_COUNT 0x9600

#elif GRAPHICS_MODE == 5
#define CANVAS_WIDTH 160
#define CANVAS_HEIGHT 120
#define PIXEL_COUNT 0x4B00

#endif

#define SCREEN_WIDTH 240
#define SCREEN_HEIGHT 160
#define DUBBLE_BUFFER 0
#define BPP 2
#define BPP_POW 1

#define FOV_POW 7
#define NEAR_PLANE 20
#define BACKFACE_CULLING 0 //TODO broken with clipping
#define TRI_LOOP_UNROLL 0,1,2,3,4,5,6,7,8,9 // How many times should the for loop unroll

#define WIREFRAME 1 // Only used for initial startup state
#define WIREFRAME_THICK_LINES 0 // Only used for initial startup state
#define WIREFRAME_RUNTIME_SWITCH 1

//DMA OFFSETS
#define DMA0_SRC 0xB0
#define DMA0_DST 0xB4
#define DMA0_CNT 0xB8

#define DMA1_SRC 0xBC
#define DMA1_DST 0xC0
#define DMA1_CNT 0xC4

#define DMA2_SRC 0xC8
#define DMA2_DST 0xCC
#define DMA2_CNT 0xD0

#define DMA3_SRC 0xD4
#define DMA3_DST 0xD8
#define DMA3_CNT 0xDC

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

//GAMEOBJECT
#define GAMEOBJECT_SIZE 0xC
#define GAMEOBJECT_BUFFER_SIZE 0x5

//DEBUG
#define DEBUG 1
#define BREAK __asm ("mov r11, r11");
#define ASM_BREAK mov r11, r11
#define TODO 