-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `base.lua`

include `line.lua`

include `stack.lua`

include `LoadingScreen/init.lua`
include `button.lua`
include `enum_button.lua`
include `check_box.lua`
include `label.lua`
include `editbox.lua`
include `scale.lua`
include `EnvCycleEditor/init.lua`
include `ColourPicker/init.lua`
include `controls/init.lua`
include `console/init.lua`
include `menu/init.lua`
include `system_layer.lua`

include `LensFlare/init.lua`
include `Compass/init.lua`
include `speedo.lua`
include `clock.lua`
include `stats.lua`

include `MusicPlayer/init.lua`

loading_screen = loading_screen or nil
ticker = ticker or nil
console = console or nil
console_frame = console_frame or nil
ch = ch or nil
music_player = music_player or nil
compass = compass or nil
clock = clock or nil
stats = stats or nil
env_cycle_editor = env_cycle_editor or nil
lens_flare = lens_flare or nil
system_layer = system_layer or nil

function common_hud_reset()

    -- Loading Screen
    if loading_screen ~= nil then
        loading_screen:destroy()
    end
    loading_screen = hud_object `LoadingScreen` { zOrder=14}
    loading_screen.enabled = false

    -- Ticker (But keep the content of the previous ticker).
    local buffer
    local other_buffer
    if ticker ~= nil then
        buffer = ticker.buffer
        other_buffer = ticker.timeBuffer
        safe_destroy(ticker)
    end
    ticker = hud_object `console/Ticker` {buffer=buffer, timeBuffer=other_buffer, shadow=vec(1,-1), zOrder=10}

    -- Console (but keep buffer)
    local console_focused = true
    if console ~= nil then
        console_focused = hud_focus == console
        buffer = console.buffer
        other_buffer = console.cmdBuffer
        safe_destroy(console)
    else
        buffer = nil
        other_buffer = nil
    end
    console = hud_object `console/Console` {buffer=buffer, cmdBuffer=other_buffer, shadow=vec(1,-1)}
    console_frame = hud_object `Stretcher` {
        child=console, zOrder=15, position=vec(500, 300);
        calcRect = function (self, psize)
            return 40, psize.y * 0.6, psize.x, psize.y
        end;
    }
    if console_focused then
        hud_focus_grab(console)
    end

    -- Crosshair
    safe_destroy(ch)
    ch = hud_object `Rect` {texture=`CrossHair.png`, parent=hud_centre}

    -- Music player
    safe_destroy(music_player)
    music_player = hud_object `MusicPlayer` {parent=hud_bottom_left, zOrder=6}
    music_player.position = music_player.size / 2 + vec(50,10)

    -- Compass / Pos / Speedo
    safe_destroy(compass)
    compass = hud_object `Compass` {parent=hud_top_right, position=vec(-64, -64)}

    -- Clock
    safe_destroy(clock)
    clock = hud_object `Clock` { parent=hud_top_right, size=vec(190,50) }
    clock.position = -clock.size/2 - vec(130, 4)

    -- Stats
    safe_destroy(stats)
    stats = hud_object `Stats` {
        width = 440,
        parent = hud_bottom_right,
        stats = {
            fps = function ()
                local max_ft = nonzero(main.gfxFrameTime:calcMax())
                local avg_ft = nonzero(main.gfxFrameTime:calcAverage())
                local min_ft = nonzero(main.gfxFrameTime:calcMin())
                local text = string.format("FPS min / avg / max: %3.0f / %3.0f / %3.0f",1/max_ft,1/avg_ft,1/min_ft)
                local fail = 0.015 / min_ft -- 15ms is frame max time
                local green = clamp(fail,0,1)
                local red = clamp(1-fail,0,1)
                local colour = vec(red, green, 0)
                return text, colour
            end;

            micros = function()
                local max_ft = nonzero(1000000*main.gfxFrameTime:calcMax())
                local avg_ft = nonzero(1000000*main.gfxFrameTime:calcAverage())
                local min_ft = nonzero(1000000*main.gfxFrameTime:calcMin())
                return string.format("Frame micros min / avg / max: %3.0f / %3.0f / %3.0f",min_ft,avg_ft,max_ft)
            end;

            streamer = function()
                return string.format("Classes / Objects / Activated: %6.0f / %6.0f / %6.0f", class_count(), object_count(), object_count_activated())
            end;

            mem = function()
                return string.format(
                        "HRAM | GRAM || QI | HO | GO: %d/%dMB | %d/%dMB || I:%d | HO:%d | GO:%d",
                        host_ram_used(),
                        host_ram_available(),
                        gfx_gpu_ram_used(),
                        gfx_gpu_ram_available(),
                        get_in_queue_size(),
                        get_out_queue_size_host(),
                        get_out_queue_size_gpu());
            end;
            
            shadow = function()
                local shadow_bats, shadow_tris = main:gfxAllShadowStats()
                return string.format("Shad Tris / Bats: %d / %d", shadow_tris, shadow_bats)
            end;
            gbuffer = function()
                return string.format("Gbuf Tris / Bats: %d / %d", main.gfxLeft.gbuffer[2], main.gfxLeft.gbuffer[1])
            end;
            deferred = function()
                return string.format("Deff Tris / Bats: %d / %d", main.gfxLeft.deferred[2], main.gfxLeft.gbuffer[1])
            end;
            total = function()
                local shadow_bats, shadow_tris = main:gfxAllShadowStats()
                local total_tris = shadow_tris + main.gfxLeft.gbuffer[2] + main.gfxLeft.deferred[2] + main.gfxRight.gbuffer[2] + main.gfxRight.deferred[2]
                local total_bats = shadow_bats + main.gfxLeft.gbuffer[1] + main.gfxLeft.deferred[1] + main.gfxRight.gbuffer[1] + main.gfxRight.deferred[1]
                return string.format("Total Tris / Bats: %d / %d", total_tris, total_bats)
            end;

            lua = function ()
                return string.format(
                        "Lua: %.1fMB (%dK) (G+%d) (P+%d) (U+%d)",
                        collectgarbage("count")/1024,
                        main.gfxCount/1000,
                        main.gfxAllocs,
                        main and main.physicsAllocs or 0,
                        main.gfxUnacctAllocs)
            end;
                    
        };
        keys = { "fps" };
        minimal = true;
        onClick = function (self)
            if self.minimal then
                self:setSelection{"fps", "micros", "streamer", "mem", "shadow", "gbuffer", "deferred", "total", "lua" }
            else
                self:setSelection{"fps"}
            end
            self.minimal = not self.minimal
        end;
    }

    -- Env cycle editor
    if env_cycle_editor ~= nil and not env_cycle_editor.destroyed then
        safe_destroy(env_cycle_editor)
    end
    env_cycle_editor = hud_object `EnvCycleEditor` { zOrder=6 }
    env_cycle_editor.position = env_cycle_editor.size/2 + vec(50, 10)
    env_cycle_editor.enabled = false

    -- Lens flare
    safe_destroy(lens_flare)
    lens_flare = hud_object `LensFlare` {parent=hud_centre}

    -- System layer, but preserve UI state
    local selected_pane = nil
    local console_enabled = true
    local last_enabled = false
    if system_layer ~= nil then
        selected_pane = system_layer.selectedPane
        console_enabled = system_layer.consoleEnabled
        last_enabled = system_layer.enabled
        safe_destroy(system_layer)
    end
    system_layer = hud_object `SystemLayer` {
        console = console;
        consoleEnabled = console_enabled;
        selectedPane = selected_pane;
        buttonDescs = {
            {
                name = "Music Player";
                panel = music_player;
            },
        };
    }
    system_layer:setEnabled(last_enabled)
end

