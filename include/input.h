#pragma once
#include "./utils/delcs.h"
#include "./types.h"

extern u16 _keyInputCur, _keyInputPrev;

static inline void keyPoll()
{
    _keyInputPrev = _keyInputCur;
    _keyInputCur = ~(*(volatile u16*)(ADDR_IO | KEY_INPUT)) & KEY_MASK;
}

static inline u32 keyGetCurState()      { return _keyInputCur; }
static inline u32 keyGetPrevState()     { return _keyInputPrev; }
static inline u32 keyIsDown(u32 key)    { return  _keyInputCur & key; }
static inline u32 keyIsUp(u32 key)      { return ~_keyInputCur & key; }
static inline u32 keyWasDown(u32 key)   { return  _keyInputPrev & key; }
static inline u32 keyWasUp(u32 key)     { return ~_keyInputPrev & key; }
static inline u32 keyHasChanged(u32 key){ return (_keyInputCur ^ _keyInputPrev) & key; }
static inline u32 keyIsHeld(u32 key)    { return (_keyInputCur & _keyInputPrev) & key; }
static inline u32 keyIsPressed(u32 key) { return ( _keyInputCur &~ _keyInputPrev) & key; }
static inline u32 keyIsReleased(u32 key){ return (~_keyInputCur & _keyInputPrev) & key; }