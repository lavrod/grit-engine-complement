/* Copyright (c) David Cunningham and the Grit Game Engine project 2010
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

extern "C" {
        #include "lua.h"
}

#include "Mouse.h"
#include "Keyboard.h"
#include "BackgroundMeshLoader.h"
#include "CentralisedLog.h"
#include "BulletDebugDrawer.h"
#include "lua_userdata_dependency_tracker.h"
#include "HUD.h"

extern CentralisedLog clog;
extern bool clicked_close;
extern Mouse *mouse;
extern Keyboard *keyboard;
extern lua_State *core_L;
extern UserDataTables user_data_tables;
extern Streamer *streamer;
extern BulletDebugDrawer *debug_drawer;
extern HUD::RootPtr hud;

std::string poll_gfx_msg_buffer (void);
