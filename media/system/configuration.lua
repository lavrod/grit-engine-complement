-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

gge_safe_include `/user_cfg.lua`


-- Sanitize "given" table, apply default values.
local function process_user_table(name, given, default)
    for k, v in pairs(given) do
        if default[k] == nil then
            gge_print(("%s contained unrecognised field \"%s\", ignoring."):format(name, k))
            given[k] = nil
        end
    end
    for k, v in pairs(default) do
        if given[k] == nil then
            given[k] = default[k]
        end
    end
end


---------------------------
-- GENERAL CONFIGURATION --
---------------------------

user_cfg = user_cfg or { }
local user_cfg_default = {
    fullscreen = false;
    res = vec(800, 600);
    visibility = 1;
    graphicsRAM = 512;
    screenshotFormat = "png";
    mouseInvert = true;
    mouseSensitivity = 0.06;
    vsync = true;
    lowPowerMode = false;
    metricUnits = false;
    audioMasterVolume = 1;
    vehicleCameraTrack = true;
}
process_user_table("user_cfg", user_cfg, user_cfg_default)

local user_cfg_doc = {
    fullscreen = "as opposed to windowed mode";
    res = "desktop resolution when fullscreened";
    visibility = "factor on draw distance";
    graphicsRAM = "Size of textures+mesh cache to maintain";
    screenshotFormat = "format in which to store textures";
    mouseInvert = "whether forward motion should look down";
    mouseSensitivity = "how easy it is to turn with mouse";
    vsync = "avoid corruption due to out of sync monitor updates";
    lowPowerMode = "Reduce FPS and physics accuracy";
    metricUnits = "Use the km/h units instead of mph units for HUD";
    audioMasterVolume = "Master audio volume";
    vehicleCameraTrack = "Camera automatically follows vehicles";
}

local user_cfg_spec = {
    res = { "vector2" };
    fullscreen = { "one of", false, true };
    visibility = { "range", 0, 5 }; 
    graphicsRAM = { "int range", 0, 2048 };
    screenshotFormat = { "one of", "png", "tga" };
    mouseInvert = { "one of", false, true };
    mouseSensitivity = { "range", 0, 1 };
    vsync = { "one of", false, true };
    lowPowerMode = { "one of", false, true };
    metricUnits = { "one of", false, true };
    audioMasterVolume =  { "range", 0, 1 }; 
    vehicleCameraTrack = { "one of", false, true };
}
            
local function commit(committed, proposed, force)

    gfx_option("AUTOUPDATE",false)
    physics_option("AUTOUPDATE",false)
    gge_core_option("AUTOUPDATE",false)
    gge_audio_option("AUTOUPDATE",false)

    for k, v in pairs(proposed) do
        if force or committed[k] ~= v then
            committed[k] = v
    
            if k == "res" then
                gfx_option("FULLSCREEN_WIDTH",v.x)
                gfx_option("FULLSCREEN_HEIGHT",v.y)
            elseif k == "fullscreen" then
                gfx_option("FULLSCREEN",v)
            elseif k == "visibility" then
                gge_core_option("VISIBILITY",v)
        
            elseif k == "graphicsRAM" then
                gfx_option("RAM",v)
                --set_texture_budget(v*1024*1024)
                --set_mesh_budget(0)
            elseif k == "lockMemory" then
                if v then gge_mlockall() else gge_munlockall() end

            elseif k == "physicsWireFrame" then
                gge_print("Physics wire frame: "..(v and "on" or "off"))
                physics_option("DEBUG_WIREFRAME", v)
            elseif k == "physicsDebugWorld" then
                gge_print("Physics debug world: "..(v and "on" or "off"))
                main.physicsDebugWorld = v
            elseif k == "mouseSensitivity" then
                -- next mouse movement picks this up
            elseif k == "mouseInvert" then
                -- next mouse movement picks this up
            elseif k == "vsync" then
                gfx_option("VSYNC",v)
            elseif k == "screenshotFormat" then
                -- nothing to do, next screenshot will pick this up
            elseif k == "lowPowerMode" then
                -- next frame render picks this up too
                if v then
                    physics_option("STEP_SIZE", 0.05)
                    physics_option("SOLVER_ITERATIONS", 4)
                else
                    physics_option("STEP_SIZE", 0.005)
                    physics_option("SOLVER_ITERATIONS", 15)
                end
            elseif k == "metricUnits" then
                --
            elseif k == "audioMasterVolume" then
                gge_audio_option("MASTER_VOLUME",v)
            elseif k == "vehicleCameraTrack" then
            else
                gge_error("Unexpected: "..k)
            end
        end
    end

    gfx_option("AUTOUPDATE",true)
    physics_option("AUTOUPDATE",true)
    gge_core_option("AUTOUPDATE",true)
    gge_audio_option("AUTOUPDATE",true)

end

make_active_table(user_cfg, user_cfg_spec,  commit)

user_cfg.autoUpdate = true

function configuration_reset()
    physics_option_reset()
    gge_core_option_reset()
    gfx_option_reset()
    gge_audio_option_reset()
    user_cfg:reset()
end


--------------
-- BINDINGS --
--------------

-- Takes the map of bindings and binds the given func to every bind.  The function takes the name of
-- the binding and the event: '+' '-' or '='.
local function process_bindings(bindings, func, input_filter)
    local function bind_it(name, key)
        input_filter:bind(
            key,
            function () func(name, '+') end,
            function () func(name, '-') end,
            function () func(name, '=') end)
    end
    for name, key_or_keys in pairs(bindings) do
        if type(key_or_keys) == "table" then
            for _,key in ipairs(key_or_keys) do
                bind_it(name, key)
            end
        else
            bind_it(name, key_or_keys)
        end
    end
end


user_system_bindings = user_system_bindings or { }
local default_user_system_bindings = {
    console = "Tab";
    screenShot = "F12";
}
process_user_table("user_system_bindings", user_system_bindings, default_user_system_bindings)
local function system_receive_button(button, state)
    if button == "console" and state == '+' then
        if gge_input_filter_pressed("Ctrl") then
            system_layer:setEnabled(true)
            system_layer:selectConsole(true)
            hud_focus_grab(console)
        else
            system_layer:setEnabled(not system_layer.enabled)
        end
    elseif button == "screenShot" and state == '+' then
        capturer:singleScreenShot()
    end
end
process_bindings(user_system_bindings, system_receive_button, system_binds)


local function game_manager_receive_button(button, state)
    game_manager:receiveButton(button, state)
end

user_playing_bindings = user_playing_bindings or { }
local default_user_playing_bindings = {
    menu = "Escape";
}
process_user_table("user_playing_bindings", user_playing_bindings, default_user_playing_bindings)
process_bindings(user_playing_bindings, game_manager_receive_button, playing_binds)

user_drive_bindings = user_drive_bindings or { }
local default_user_drive_bindings = {
    driveForwards = "w";
    driveBackwards = "s";
    driveLeft = "a";
    driveRight = "d";
    driveSpecialLeft = "q";
    driveSpecialRight = "e";
    driveSpecialUp = "PageUp";
    driveSpecialDown = {"PageDown", 'c'};
    driveAltUp = "Up";
    driveAltDown = "Down";
    driveAltLeft = "Left";
    driveAltRight = "Right";
    driveAbandon = "f";
    driveHandbrake = "Space";
    driveLights = "l";
    driveZoomIn = {"up","S+v"};
    driveZoomOut = {"down","v"};
    driveCamera = "x";
    driveSpecialToggle = "BackSpace";
}
process_user_table("user_drive_bindings", user_drive_bindings, default_user_drive_bindings)
process_bindings(user_drive_bindings, game_manager_receive_button, playing_vehicle_binds)

user_foot_bindings = user_foot_bindings or { }
local default_user_foot_bindings = {
    walkForwards = "w";
    walkBackwards = "s";
    walkLeft = "a";
    walkRight = "d";
    walkBoard = "f";
    walkJump = "Space";
    walkCrouch = "c";
    walkRun = "Shift";
    walkZoomIn = {"up","S+v"};
    walkZoomOut = {"down","v"};
    walkCamera = "c";
}
process_user_table("user_foot_bindings", user_foot_bindings, default_user_foot_bindings)
process_bindings(user_foot_bindings, game_manager_receive_button, playing_actor_binds)


-- The editor has 4 modes:
-- 1) Editing objects
-- 2) Editing camera (i.e. moving around)
-- 3) Debug (moving camera around)
-- 4) Debug (controlling object)
-- 5) Debug (including when no mouse capture)

-- Available in (1) (2) (3) (4) (5)
user_editor_bindings = user_editor_bindings or { }
local default_user_editor_bindings = {
    debug = "F5";
}
process_user_table("user_editor_bindings", user_editor_bindings, default_user_editor_bindings)
process_bindings(user_editor_bindings, game_manager_receive_button, editor_binds)

-- Available in (1) (2)
user_editor_edit_bindings = user_editor_edit_bindings or { }
local default_user_editor_edit_bindings = {
    mouseCapture = "right";
}
process_user_table("user_editor_edit_bindings", user_editor_edit_bindings, default_user_editor_edit_bindings)
process_bindings(user_editor_edit_bindings, game_manager_receive_button, editor_edit_binds)

-- Available in (2) (3)
user_editor_cam_bindings = user_editor_cam_bindings or { }
local default_user_editor_cam_bindings = {
    forwards = "w";
    backwards = "s";
    strafeLeft = "a";
    strafeRight = "d";
    ascend = "Space";
    descend = "c";
    faster = "Shift";
}
process_user_table("user_editor_cam_bindings", user_editor_cam_bindings, default_user_editor_cam_bindings)
process_bindings(user_editor_cam_bindings, game_manager_receive_button, editor_cam_binds)

-- Available in (1)
user_editor_object_bindings = user_editor_object_bindings or { }
local default_user_editor_object_bindings = {
    delete = "Delete";
    duplicate = "C+d";
    cut = "C+x";
    copy = "C+c";
    paste = "C+v";
    undo = "C+z";
    redo = "C+y";
    unselectAll = "C+S+a";
    selectModeTranslate = "1";
    selectModeRotate = "2";
}
process_user_table("user_editor_object_bindings", user_editor_object_bindings, default_user_editor_object_bindings)
process_bindings(user_editor_object_bindings, game_manager_receive_button, editor_object_binds)

-- Available in (3) (4) (5)
user_editor_debug_bindings = user_editor_debug_bindings or { }
local default_user_editor_debug_bindings = {
    toggleDebugModeSettings = "F1";
    pausePhysics = "F2";
    singleStepPhysics = "F3";
}
process_user_table("user_editor_debug_bindings", user_editor_debug_bindings, default_user_editor_debug_bindings)
process_bindings(user_editor_debug_bindings, game_manager_receive_button, editor_debug_binds)

-- Available in (3) (4)
user_editor_debug_play_bindings = user_editor_debug_play_bindings or { }
local default_user_editor_debug_play_bindings = {
    board = "f";
    weaponPrimary = "left";
    weaponSecondary = "right";
    weaponSwitchUp = {"e", "up"};
    weaponSwitchDown = {"q", "down"};
}
process_user_table("user_editor_debug_play_bindings", user_editor_debug_play_bindings, default_user_editor_debug_play_bindings)
process_bindings(user_editor_debug_play_bindings, game_manager_receive_button, editor_debug_play_binds)


--------------------
-- SAVING TO DISK --
--------------------

function save_user_cfg(filename)
    filename = filename or 'user_cfg.lua'
    local f = io.open(filename, 'w')
    f:write([[
gge_print('Reading user_cfg.lua')

-- This file is output automatically by Grit.
-- You may edit it, but stick to the basic format.
-- Any clever Lua code will be lost.
--
-- WARNING:  If you are changing from a default value
-- to a custom value, don't forget to uncomment the line
-- (remove the leading -- ) otherwise it will not be
-- processed and your changes will be lost.

]])

    local function write_table(table_name, tab, defaults, docs)
        f:write(table_name.." = {\n")
        local names, num, max_name_len = table.keys(tab,100)
        table.sort(names)
        for _,name in ipairs(names) do
            local val = tab[name]
            local dval = defaults[name]
            local doc = docs[name]
            local line = ''
            if val == dval then
                line = line .. "--"
            end
            line = line.."    "..tostring(name)..(" "):rep(max_name_len-#name).." = "..dump(val,false)..";"
            if doc ~= nil then
                local len_so_far = #line
                line = line..(" "):rep(50-len_so_far).."  -- "
                if val ~= dval then
                    line = line .. "DEFAULT: "..dump(dval,false).."  "
                end
                line = line.."("..doc..")"
            end
            f:write(line.."\n")
        end
        f:write("}\n\n")
    end

    -- Use proposed rather than committed settings, to avoid writing out the autoUpdate header.
    write_table("user_cfg", user_cfg.proposed, user_cfg_default, user_cfg_doc)
    write_table("user_system_bindings", user_system_bindings, default_user_system_bindings, {})

    write_table("user_playing_bindings", user_playing_bindings, default_user_playing_bindings, {})
    write_table("user_drive_bindings", user_drive_bindings, default_user_drive_bindings, {})
    write_table("user_foot_bindings", user_foot_bindings, default_user_foot_bindings, {})

    write_table("user_editor_bindings", user_editor_bindings, default_user_editor_bindings, {})
    write_table("user_editor_edit_bindings", user_editor_edit_bindings, default_user_editor_edit_bindings, {})
    write_table("user_editor_cam_bindings", user_editor_cam_bindings, default_user_editor_cam_bindings, {})
    write_table("user_editor_object_bindings", user_editor_object_bindings, default_user_editor_object_bindings, {})
    write_table("user_editor_debug_bindings", user_editor_debug_bindings, default_user_editor_debug_bindings, {})

    f:close()
end
