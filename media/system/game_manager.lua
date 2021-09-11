-- (c) David Cunningham 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

if system_binds ~= nil then system_binds:destroy() end
system_binds = gge_InputFilter(2, `system_binds`)

if menu_binds ~= nil then menu_binds:destroy() end
menu_binds = gge_InputFilter(5, `menu_binds`)


if playing_binds ~= nil then playing_binds:destroy() end
playing_binds = gge_InputFilter(170, `playing_binds`)

if playing_actor_binds ~= nil then playing_actor_binds:destroy() end
playing_actor_binds = gge_InputFilter(171, `playing_actor_binds`)

if playing_vehicle_binds ~= nil then playing_vehicle_binds:destroy() end
playing_vehicle_binds = gge_InputFilter(172, `playing_vehicle_binds`)


if editor_binds ~= nil then editor_binds:destroy() end
editor_binds = gge_InputFilter(45, `editor_binds`)

if editor_edit_binds ~= nil then editor_edit_binds:destroy() end
editor_edit_binds = gge_InputFilter(46, `editor_edit_binds`)

if editor_cam_binds ~= nil then editor_cam_binds:destroy() end
editor_cam_binds = gge_InputFilter(47, `editor_cam_binds`)

if editor_object_binds ~= nil then editor_object_binds:destroy() end
editor_object_binds = gge_InputFilter(48, `editor_object_binds`)

if editor_debug_binds ~= nil then editor_debug_binds:destroy() end
editor_debug_binds = gge_InputFilter(49, `editor_debug_binds`)

if editor_debug_play_binds ~= nil then editor_debug_play_binds:destroy() end
editor_debug_play_binds = gge_InputFilter(50, `editor_debug_play_binds`)


function reset_binds()
    playing_binds.enabled = false
    playing_binds.mouseCapture = true
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = false

    editor_binds.enabled = false
    editor_edit_binds.enabled = false
    editor_cam_binds.enabled = false
    editor_object_binds.enabled = false
    editor_debug_binds.enabled = false
    editor_debug_play_binds.enabled = false
end


--[[
A game mode needs the following things:
:init()
:destroy()
:setPause(boolean)
:frameCallback(elapsed_secs)
:stepCallback(elapsed_secs)
:receiveButton(button, state)
:mouseMove(rel)
:debugText(index, str)
--]]

game_manager = {
    gameModes = { };
    currentMode = nil;

    register = function (self, mode)
        self.gameModes[mode.name] = mode
    end;

    enter = function (self, name)
        local new_mode = self.gameModes[name]
        if new_mode == nil then
            gge_error('No such game mode: "' .. name .. '"')
        end

        gge_core_option("FOREGROUND_WARNINGS", false)
        if self.currentMode ~= nil then
            self:exit()
        end
        self.currentMode = make_instance({}, new_mode)
        self.currentMode:init()
        self:setPause(false)
        gge_core_option("FOREGROUND_WARNINGS", true)
        menu_show(nil)
    end;

    exit = function (self)
        if self.currentMode ~= nil then
            
            self.currentMode:destroy();
            self.currentMode = nil
            gge_object_all_del()
            reset_everything()
            -- A lot of objects should now be unreachable, a good time to garbage collect.
            gc()
            menu_show('main')
        end
    end;

    frameUpdate = function (self, elapsed_secs)
        if self.currentMode ~= nil then
            if not xpcall(self.currentMode.frameCallback, gge_error_handler, self.currentMode, elapsed_secs) then
                gge_print('During game mode\'s frameCallback, exiting gamemode')
                self:exit()
            end
        end
    end;

    stepUpdate = function (self, elapsed_secs)
        if self.currentMode ~= nil then
            if not xpcall(self.currentMode.stepCallback, gge_error_handler, self.currentMode, elapsed_secs) then
                gge_print('During game mode\'s stepCallback, exiting gamemode')
                self:exit()
            end
        end
    end;

    receiveButton = function (self, button, state)
        if button == "menu" then
            if state == '+' then
                menu_show('pause')
            end
        else
            if self.currentMode ~= nil then
                self.currentMode:receiveButton(button, state)
            end
        end
    end;

    mouseMove = function (self, rel)
        if self.currentMode ~= nil then
            self.currentMode:mouseMove(rel)
        end
    end;

    setPause = function (self, v)
        self.currentMode:setPause(v)
    end;

    debugText = function (self, i, str, ...)
        self.currentMode:debugText(i, str % {...})
    end,
}

playing_binds.mouseMoveCallback = function (rel)
    game_manager:mouseMove(rel)
end
