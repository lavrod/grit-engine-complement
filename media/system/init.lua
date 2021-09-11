-- (c) David Cunningham 2011, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--lua5.2 it's so amazingly compatible
math.mod = math.fmod

-- Allow Python-style string formatting with % operator.
getmetatable("").__mod = function(str, n)
    if type(n) == 'table' then
        return str:format(unpack(n))
    else
        return str:format(n)
    end
end
function printf(str, ...)
    gge_print(str % {...})
end


-- Disable them as we boot the engine.
gge_core_option("FOREGROUND_WARNINGS", false)


gge_print("Initialising script...")
io.stdout:setvbuf("no") -- no output buffering
collectgarbage("setpause",110) -- begin a gc cycle after blah% increase in ram use
collectgarbage("setstepmul",150) -- collect at blah% the rate of new object creation

gge_gfx_shadow_pcf_noise_map `HiFreqNoiseGauss.64.png`
gge_gfx_fade_dither_map `stipple.png`
gge_gfx_env_cube(0, `env_cube_noon.envcube.tiff`)

gge_include `strict.lua` 

gge_include `abbrev.lua` 

gge_include `util.lua` 

gge_include `unicode_test_strings.lua` 

main = {
    shouldQuit = false;
    frameCallbacks = CallbackReg.new();
    frameTime = gge_seconds();

    streamerCentre = vec(0, 0, 0);

    camQuat = quat(1, 0, 0, 0);
    camPos = vec(0, 0, 0);
    audioCentrePos = vec(0, 0, 0);
    audioCentreVel = vec(0, 0, 0);
    audioCentreQuat = quat(1, 0, 0, 0);

    controlObj = nil;  -- Recognized by the speedo, set by game modes.

    physicsLeftOver = 0;
    physicsSpeed = 1;
    physicsOneToOne = false;
    physicsEnabled = true;
    physicsMaxSteps = 50;
    physicsAllocs = 0;

    gfxFrameTime = RunningStats.new(20);
    gfxCount = 0;
    gfxUnacctAllocs = 0;
    gfxAllocs = 0;
    gfxShadow1 = {0, 0, 0};
    gfxShadow2 = {0, 0, 0};
    gfxShadow3 = {0, 0, 0};
    gfxLeft = {gbuffer = {0, 0, 0}, deferred = {0, 0, 0}};
    gfxRight = {gbuffer = {0, 0, 0}, deferred = {0, 0, 0}};
    gfxAllShadowStats = function (self)
        return self.gfxShadow1[1] + self.gfxShadow2[1] + self.gfxShadow3[1],
               self.gfxShadow1[2] + self.gfxShadow2[2] + self.gfxShadow3[2],
               self.gfxShadow1[3] + self.gfxShadow2[3] + self.gfxShadow3[3]
    end;
}

function yaw_angle(q)
    local dir1 = q * V_FORWARDS
    local dir2 = q * V_UP
    local v1 = dir1.xy
    local v2 = dir2.xy
    if #v1 < 0.5 then
        return math.deg(math.atan2(v2.x, v2.y))
    else
        return math.deg(math.atan2(v1.x, v1.y))
    end
end

function cam_yaw_angle()
    return yaw_angle(main.camQuat)
end

function cam_yaw_quat()
    return quat(cam_yaw_angle(), V_DOWN);
end

function cam_box_ray(pos, cam_q, dist, dir, ...)
    local rect = gge_gfx_window_size_in_scene()
    local tolerance = 0.05 -- this is the distance that we use to account for differences between colmesh and gfx mesh, as well as inaccuracies in the algorithm itself
    local box = vector3(rect.x + tolerance, tolerance, rect.y + tolerance) -- y is the direction of the ray
    local fraction = gge_physics_sweep_box(box, cam_q, pos, (dist-tolerance/2)*dir, true, 1, ...) or 1
    return dist * fraction + tolerance/2 + gge_gfx_option("NEAR_CLIP")
end


function quit()
    main.shouldQuit = true
end

mouse_pos_rel = V_ZERO
mouse_pos_abs = V_ZERO


function physics__step (elapsed_secs)
    local _, initial_allocs = gge_get_alloc_stats()

    gge_object_do_step_callbacks(elapsed_secs)
    game_manager:stepUpdate(elapsed_secs)
    gge_physics_update()

    gge_gfx_tracer_body_pump(elapsed_secs)
    gge_gfx_particle_pump(elapsed_secs)

    local _, final_allocs = gge_get_alloc_stats()
    main.physicsAllocs = final_allocs - initial_allocs
end

function physics__maybe_step (elapsed_secs)
    if main.physicsEnabled then
        physics__step(elapsed_secs)
    end
    gge_do_events(elapsed_secs)
end

function physics__frame_step (step_size, elapsed_secs)
    local elapsed_secs = main.physicsLeftOver + elapsed_secs * main.physicsSpeed
    local iterations = 0
    while elapsed_secs >= step_size do
        if iterations >= main.physicsMaxSteps then
            -- no more processing, throw away remaining time
            elapsed_secs = 0
            break
        end
        elapsed_secs = elapsed_secs - step_size
        physics__maybe_step(step_size)
        iterations = iterations + 1
    end

    main.physicsLeftOver = elapsed_secs
end

function main:run (...)

    -- execute cmdline arguments on console
    local arg = ""
    for i=2, select('#', ...) do
        arg = arg .. " " .. select(i,...)
    end
    if #arg > 0 then
        console:exec(arg:sub(2))
    end

    local last_focus = true

    local failName = {}

    -- rendering loop
    while not gge_clicked_close() and not main.shouldQuit do

        local curr_time = gge_seconds()
        local elapsed_secs = curr_time - main.frameTime
        main.frameTime = curr_time


        -- INPUT
        if last_focus ~= gge_have_focus() then
            last_focus = gge_have_focus()
            gge_input_filter_flush()
        end

        local presses = gge_get_keyb_presses()
        local moved,buttons,x,y,rel_x,rel_y = gge_get_mouse_events()
        mouse_pos_abs = vec(x, y)
        mouse_pos_rel = vec(rel_x, rel_y)

        if moved then
            gge_input_filter_trickle_mouse_move(mouse_pos_rel, mouse_pos_abs)
        end

        for _,key in ipairs(presses) do
            if gge_get_keyb_verbose() then gge_print("Lua key event: "..key) end
            gge_input_filter_trickle_button(key)
        end

        for _,button in ipairs(buttons) do
            if gge_get_keyb_verbose() then gge_print("Lua mouse event: "..button) end
            gge_input_filter_trickle_button(button)
        end

        -- PHYSICS (and game logic)
        local step_size = gge_physics_option("STEP_SIZE")
        if main.physicsOneToOne then
            main.physicsLeftOver = 0
            physics__maybe_step(step_size)
        else
            physics__frame_step(step_size, elapsed_secs)
            -- NAVIGATION
            gge_navigation_update(elapsed_secs)				
        end

        -- INTERPOLATED GRAPHICS and FRAME UPDATES
        if gge_gfx_window_active() then
            local left_over_time = main.physicsEnabled and main.physicsLeftOver or 0
            gge_physics_update_graphics(left_over_time)
            gge_gfx_tracer_body_set_left_over_time(left_over_time)
            gge_physics_draw()
        end
        game_manager:frameUpdate(elapsed_secs)
        gge_object_do_frame_callbacks(elapsed_secs)

		-- NAVIGATION DEBUG
		gge_navigation_update_debug(elapsed_secs)		

        -- AUDIO
        gge_audio_update(main.audioCentrePos, main.audioCentreVel, main.audioCentreQuat)


        -- STREAMING
        gge_give_queue_allowance(1 + 1*gge_get_in_queue_size())
        gge_streamer_centre(main.streamerCentre)


        if gge_gfx_window_active() then
            main.gfxFrameTime:add(elapsed_secs)
        end

        do -- render a frame
            if user_cfg.lowPowerMode then
                --gge_sleep_seconds(0.2 - elapsed_secs)
                gge_sleep(math.floor(1000000*(0.2 - elapsed_secs)))
                --gge_print("Total frame time: "..elapsed_secs)
            end
            main.gfxCount, main.gfxUnacctAllocs = gge_get_alloc_stats()
            gge_reset_alloc_stats()
            gge_gfx_render(elapsed_secs, main.camPos, main.camQuat)
            main.gfxCount, main.gfxAllocs = gge_get_alloc_stats()
            gge_reset_alloc_stats()
        end
        --local post_frame_time = gge_seconds()
        --gge_print("Frame render time: "..(post_frame_time - curr_time))

        main.gfxShadow1[1], main.gfxShadow1[2], main.gfxShadow1[3],
        main.gfxShadow2[1], main.gfxShadow2[2], main.gfxShadow2[3],
        main.gfxShadow3[1], main.gfxShadow3[2], main.gfxShadow3[3],
        main.gfxLeft.gbuffer[1], main.gfxLeft.gbuffer[2], main.gfxLeft.gbuffer[3],
        main.gfxLeft.deferred[1], main.gfxLeft.deferred[2], main.gfxLeft.deferred[3],
        main.gfxRight.gbuffer[1], main.gfxRight.gbuffer[2], main.gfxRight.gbuffer[3],
        main.gfxRight.deferred[1], main.gfxRight.deferred[2], main.gfxRight.deferred[3] = gge_gfx_last_frame_stats()


        xpcall(function ()
            failName.name = nil
            main.frameCallbacks:executeExtended(function (name, cb, ...)
                failName.name = name
                --t:reset()
                if cb == nil then
                        --gge_print(RED.."Callback was nil: "..name)
                        return true
                end
                local result = cb(...)
                --local us = t.us
                --if us>5000 and name~="GFX.frameCallback" then
                --        gge_print("callback \""..name.."\" took "..us/1000 .."ms ")
                --end
                return result
            end)
            failName.name = nil

        end,gge_error_handler)

        if failName.name then
            gge_print("Removed frameCallback: " .. failName.name)
            main.frameCallbacks:removeByName(failName.name)
        end

        if not gge_gfx_window_active() then
            --gge_sleep_seconds(0.2)
            gge_sleep(200000)
        end

    end

	game_manager:exit()
	
    save_user_cfg()
end


gge_include `game_manager.lua` 

gge_include `default_shader.lua` 

gge_include `map.lua`

gge_include `directory_list.lua`

gge_include `configuration.lua` 

gge_include `physical_materials.lua` 
gge_include `procedural_objects.lua` 
gge_include `procedural_batches.lua` 

gge_include `pid_ctrl.lua` 

gge_include `capturer.lua` 

gge_include `env.lua` 

gge_include `audio.lua` 

gge_include `net.lua` 

gge_include `navigation_system.lua`

gge_include `weapon_effect_manager.lua`

gge_include `digital_control.lua`

gge_include `/common/init.lua` 

function reset_everything()
    configuration_reset()
    env_reset()
    common_hud_reset()
    reset_binds()
end

reset_everything()




-- Should probably move to common at this point...
-- gge_include `/common/characters/init.lua`


-- Game modes
gge_safe_include `/editor/init.lua`
--gge_safe_include `/sponza/init.lua`
gge_safe_include `/navigation/init.lua`
gge_safe_include `/games/assets/vehicles/init.lua`
gge_safe_include `/games/playground/init.lua`
--gge_safe_include `/detached/init.lua`
--gge_safe_include `/wipeout/init.lua`

gge_include `welcome_msg.lua`

function debug_mode(map)
    game_manager:enter('Map Editor')
    if map ~= nil then
        game_manager.currentMode:openMap(map)
    end
    game_manager.currentMode:toggleDebugMode()
    menu_show(nil)
end

menu_show('main')

gge_safe_include `/user_script.lua`

-- Re-enable now we're in the rendering loop.
gge_core_option("FOREGROUND_WARNINGS", true)
main:run(...)
