#pragma once
#include "../types.h"
#include "../delcs.h"

struct GameObject
{
    s16 data;               // First bit is the active flag.
    s16 x, y, z;            // Position.
    u32 updateMethodAddr;   // Update method address. Should take care of updating and rendering.
};
extern "C" GameObject GAMEOBJECT_BUFFER[GAMEOBJECT_BUFFER_SIZE];

extern "C" void pushGameObject(s16 data, s16 x, s16 y, s16 z, u32 updateAddr);
extern "C" void popGameObject();
extern "C" void updateGameObjects();

extern "C" void updateEnemy(s16& x, s16& y, s16& z, bool& active);
//void updateGameObject(s16& x, s16& y, s16& z, bool& active);