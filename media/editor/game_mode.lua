------------------------------------------------------------------------------
--  This is the core of Grit Editor, all common functions are here
--
--  (c) 2014-2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

function open_map_dialog()
    gui.open_file_dialog({
        title = "Open Map";
        parent = hud_centre;
        position = vec(0, 0);
        resizeable = true;
        size = vec2(560, 390);
        minSize = vec2(470, 290);
        colour = _current_theme.colours.window.background;
        alpha = 1;
        choices = { "Grit Map (*.gmap)", "Lua Script (*.lua)" };
        callback = function(self, str)
            str = '/' .. str
            if gge_resource_exists(str) then
                local status, msg = pcall(game_manager.currentMode.openMap, game_manager.currentMode, str)
                if status then
                    notify("Loaded!", vec(0, 0.5, 1), V_ID)
                    -- gge_error('wat')
                    return true
                else
                    gge_error_handler(msg)
                    notify("Error: Could not open map file!", vec(1, 0, 0), V_ID)
                end
            else
                notify("Error: Map file not found!", vec(1, 0, 0), V_ID)
            end
            return false
        end;    
    })
end

function save_map_dialog()
    gui.save_file_dialog({
        title = "Save Map";
        parent = hud_centre;
        position = vec(0, 0);
        resizeable = true;
        size = vec2(560, 390);
        minSize = vec2(470, 290);
        colour = _current_theme.colours.window.background;
        alpha = 1;
        choices = { "Grit Map (*.gmap)", "Lua Script (*.lua)" };
        callback = function(self, str)
            str = '/' .. str
            if gge_resource_exists(str) then
                local save_overwrite = function (number)
                    if number == 1 then
                        local status, msg = pcall(game_manager.currentMode.saveCurrentMapAs, game_manager.currentMode, str)
                        if status then
                            notify("Saved!", vec(0, 1, 0), V_ID)
                            self:destroy()
                        else
                            gge_error_handler(msg)
                            notify("Error!", vec(1, 0, 0), V_ID)
                        end
                    end
                end;
				--Usage: The 3rd variable is now a table allowing as many buttons as you want and returns the number in the displayed error. 
				--Example {"1","blue","tree"} 
				--"1" will return 1, "blue" will return 2, "tree" will return 3, ETC...
                showDialog("SAVE", "Would you like to overwrite "..str.."?", {"Yes","No"}, save_overwrite) 
                return false
            else
                local status, msg = pcall(game_manager.currentMode.saveCurrentMapAs, game_manager.currentMode, str)
                if status then
                    notify("Saved!", vec(0, 1, 0), V_ID)
                    return true
                else
                    gge_error_handler(msg)
                    notify("Error!", vec(1, 0, 0), V_ID)
                    return false
                end
            end
        end;    
    })
end


-- The editor is a special kind of game mode.  This is the root of the editor state.  Ultimately,
-- everything is initialized and managed from here.

Editor = extends_keep_existing(Editor, BaseGameMode) {
    name = 'Map Editor',


    selectionEnabled = true;
    

    -- holds editor camera position and rotation to get back when stop playing
    camera = {
        pos = {},
        rot = {},
    };

    directory = "editor";
    
    map_dir = "map_templates";
    
    game_data_dir = "editor";
    playGameMode = "fpsgame";
}


function Editor:toggleBoard(mobj)
    if self.controlObj ~= nil then
        -- Currently controlling an object.  Exit it.
        playing_actor_binds.enabled = false
        playing_vehicle_binds.enabled = false
        editor_cam_binds.enabled = true

        self.controlObj:controlAbandon()
        -- When on foot there is no vehicle pitch.
        local v_yaw, v_pitch = yaw_pitch(main.camQuat)
        self.camYaw = v_yaw
        self.camPitch = v_pitch
        self:mouseMove(vec(0, 0))

        self.controlObj = nil

    else
        -- Board object being pointed at, if possible.
        local obj = mobj or pick_obj()
        if obj == nil then return end
        if obj.controllable == "VEHICLE" then
            playing_vehicle_binds.enabled = true
        elseif obj.controllable == "ACTOR" then
            playing_actor_binds.enabled = true
        else
            gge_print("Cannot board object: " .. tostring(obj))
            return
        end
        editor_cam_binds.enabled = false
        obj:controlBegin()
        self.controlObj = obj
        gge_print('controlObj now '..tostring(obj))
        -- When boarding a vehicle we want to keep the same effective pitch (otherwise it's jarring for the user).
        -- So we calculate the camPitch necessary for that.
        local v_pitch = pitch((obj.instance.body.worldOrientation * V_FORWARDS).z)
        self.camPitch = self.camPitch - v_pitch
    end
end

-- if the widget is under mouse cursor, then start dragging, otherwise select an object
function Editor:leftMouseClick()
    if self.selectionEnabled then
        local multi = gge_input_filter_pressed("Shift")
        widget_manager:select(multi)
    end
end

function Editor:stopDraggingObj()
    widget_manager:stopDragging()
end

function Editor:unselectAll()
    widget_manager:unselectAll()
end

function Editor:deleteSelected()
    widget_manager:deleteSelected()
end

function Editor:duplicateSelected()
    widget_manager:duplicateSelected()
end

local function ghost_cast (pos, ray, scale)
    local fraction, _, n = gge_physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end

function Editor:frameCallback(elapsed_secs)
    widget_manager:frameCallback(elapsed_secs)

    if self.controlObj ~= nil and not self.controlObj.activated then
        self:toggleBoard()
    end

    if self.controlObj ~= nil then
        -- Chase cam
        local obj = self.controlObj
        local instance = obj.instance
        local body = instance.body

        local obj_bearing, obj_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
        local obj_vel = body.linearVelocity
        local obj_vel_xy_speed = #(obj_vel * vector3(1,1,0))

        if self.cameraVehicleLock then
            main.camQuat = body.worldOrientation * quat(self.camPitch, vec(1, 0, 0))
        else
            main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
        end

        main.speedoPos = instance.camAttachPos
        main.speedoSpeed = obj:getSpeed()

        local ray_dir = main.camQuat * V_BACKWARDS
        local ray_start = instance.camAttachPos
        if obj.boomLengthMin == nil or obj.boomLengthMax == nil then
            gge_error('Controlling %s of class %s, needed boomLengthMin and boomLengthMax, got: %s, %s'
                  % {obj, obj.className, obj.boomLengthMin, obj.boomLengthMax})
        end
        local ray_len = self:boomLength(obj.boomLengthMin, obj.boomLengthMax)
        local ray_hit_len = cam_box_ray(ray_start, main.camQuat, ray_len, ray_dir, body)
        local boom_length = math.max(obj.boomLengthMin, ray_hit_len)
        main.camPos = instance.camAttachPos + main.camQuat * vector3(0, -boom_length, 0)

    else
        -- Ghosting around
        local right = self.right - self.left
        local forwards = self.forwards - self.backwards
        local ascend = self.ascend - self.descend

        local active_speed = self.fast and self.speedFast or self.speedSlow

        local dist = active_speed * elapsed_secs

        local cam_pos = main.camPos

        -- we now know how far to move (dist)
        -- but not in which directions

        local d = main.camQuat * vec3(dist*right, dist*forwards, 0) + vec3(0, 0, dist*ascend)
        

        if not self.noClip then
            local fraction, n = ghost_cast(cam_pos, d, 1)

            if fraction ~= nil then
                local n = norm(n)
                d = d - dot(d,n) * n
                local fraction2, n2 = ghost_cast(cam_pos, d, .95)
                if fraction2 ~= nil then
                    n2 = norm(n2)
                    d = d - dot(d,n2) * n2
                    local fraction3, n3 = ghost_cast(cam_pos, d, .9)
                    if fraction3 ~= nil then
                        return 0
                    end
                end
            end
        end
        -- splendid, now let's move
        cam_pos = cam_pos + d
        main.camPos = cam_pos

        main.speedoPos = main.camPos
        main.speedoSpeed = #d / elapsed_secs
    end

    main.streamerCentre = main.camPos
    main.audioCentrePos = main.camPos
    main.audioCentreVel = vec(0, 0, 0);
end

function Editor:stepCallback(elapsed_secs)
    if self.debugMode then
        WeaponEffectManager:stepCallback(elapsed_secs, main.camPos, main.camQuat)
    end
end

function Editor:setMouseCapture(v)
    self.mouseCapture = v
    ch.enabled = v
    playing_binds.mouseCapture = v
    editor_cam_binds.enabled = v
end

function Editor:setDebugMode(v)
    -- Detach any object we may be controlling
    
    if widget_manager then
        widget_manager:unselectAll()
    end
    
    if not v then
        if self.controlObj ~= nil then
            self:toggleBoard()
        end
    end

    game_manager.currentMode.debug_mode_text.enabled = v
    
    editor_interface.enabled = not v
    
    self.debugMode = v
    main.physicsEnabled = v
    clock.enabled = v
    compass.enabled = v
    for i = 1, 4 do
        self.debug_label[i].enabled = v
    end
    stats.enabled = v
    self.speedo.enabled = v
    editor_edit_binds.enabled = not v
    editor_object_binds.enabled = not v
    editor_debug_binds.enabled = v

    if editor_interface.map_editor_page ~= nil then
        if v then
            editor_interface.map_editor_page:unselect()
        else
            editor_interface.map_editor_page:select()
        end
    end
    
    if v then
        self:setInDebugModeSettings(false)
        notify("Press F5 to return to the editor", vec(1, 0.5, 0), vec(1, 1, 1))
    else
        editor_debug_play_binds.enabled = false
        self:setMouseCapture(false)

        for _, obj in ipairs(gge_object_all()) do
            -- TODO(dcunnin):  This does not reset persistent state.  Put code in map.lua to do
            -- a full reset by destroying and recreating all objects.
            if obj.destroyed then 
                -- Skip
            elseif obj.debugObject == true then
                safe_destroy(obj)
            else
                obj:deactivate()
                obj.skipNextActivation = false
            end
        end
    end
end

function Editor:createDebugModeSettingsWindow()
end

function Editor:toggleDebugMode()
    self:setDebugMode(not self.debugMode)
end

function Editor:generateEnvCube(pos)
    self.mapFile:generateEnvCube(pos)
end

function Editor:newMap()
    gge_gfx_option("RENDER_SKY", true)
    
    gge_navigation_reset()
    
    -- no fog and a smooth background colour
    env_cycle = gge_include `editor_env_cycle.lua`
    env_recompute()
    
    widget_manager:unselectAll()
    
    self.mapFile:reset()
    -- if update_map_properties ~= nil then
        -- update_map_properties()
    -- end
end

function Editor:openMap(map_file)
    if map_file == nil then
        open_map_dialog()
        return
    end

    widget_manager:unselectAll()

    -- you can create a new map and include a lua that cointains object placements
    gge_gfx_option("RENDER_SKY", true)
    
    gge_navigation_reset()
    
    self.mapFile:open(map_file)
    main.camPos, main.camQuat = self.mapFile:getEditorCamPosOrientation()
    self.camPitch = quatPitch(main.camQuat)
    self.camYaw = cam_yaw_angle()

    
    -- if update_map_properties ~= nil then
        -- update_map_properties()
    -- end
end

-- save current map, if have a "file_name" specified
function Editor:saveCurrentMap()
    if self.mapFile.filename then
        self.mapFile:setEditorCamPosOrientation(main.camPos, main.camQuat)
        self.mapFile:save()
    else
        self:saveCurrentMapAs()
    end
end

function Editor:saveCurrentMapAs(name)
    if name == nil then
        save_map_dialog()
        return false
    else
        self.mapFile:setEditorCamPosOrientation(main.camPos, main.camQuat)
        return self.mapFile:saveAs(name)
    end
end

-- turn the toolbar icons as selected and change mode
function Editor:setWidgetMode(mode)
    widget_manager:setMode(mode)
end

-- save editor interface windows
function Editor:saveEditorInterface()
    editor_interface_cfg = {
      content_browser   =   {
        opened   = (editor_interface.map_editor_page.windows.content_browser == nil and false or true) or not editor_interface.map_editor_page.windows.content_browser.destroyed;
        position = { editor_interface.map_editor_page.windows.content_browser.position.x, editor_interface.map_editor_page.windows.content_browser.position.y };
        size     = { editor_interface.map_editor_page.windows.content_browser.size.x, editor_interface.map_editor_page.windows.content_browser.size.y };
      };
      level_properties  =   {
        opened   = editor_interface.map_editor_page.windows.level_properties.enabled;
        position = { editor_interface.map_editor_page.windows.level_properties.position.x, editor_interface.map_editor_page.windows.level_properties.position.y };
        size     = { editor_interface.map_editor_page.windows.level_properties.size.x, editor_interface.map_editor_page.windows.level_properties.size.y };
      };
      material_editor   =   {
        opened   = editor_interface.map_editor_page.windows.material_editor.enabled;
        position = { editor_interface.map_editor_page.windows.material_editor.position.x, editor_interface.map_editor_page.windows.material_editor.position.y };
        size     = { editor_interface.map_editor_page.windows.material_editor.size.x, editor_interface.map_editor_page.windows.material_editor.size.y };
      };
      -- object_editor     =   {
        -- opened   = editor_interface.map_editor_page.windows.object_editor.enabled;
        -- position = { editor_interface.map_editor_page.windows.object_editor.position.x, editor_interface.map_editor_page.windows.object_editor.position.y };
        -- size     = { editor_interface.map_editor_page.windows.object_editor.size.x, editor_interface.map_editor_page.windows.object_editor.size.y };
      -- };
      object_properties =   {
        opened   = editor_interface.map_editor_page.windows.object_properties.enabled;
        position = { editor_interface.map_editor_page.windows.object_properties.position.x, editor_interface.map_editor_page.windows.object_properties.position.y };
        size     = { editor_interface.map_editor_page.windows.object_properties.size.x, editor_interface.map_editor_page.windows.object_properties.size.y };
      };
      outliner          =   {
        opened   = editor_interface.map_editor_page.windows.outliner .enabled;
        position = { editor_interface.map_editor_page.windows.outliner .position.x, editor_interface.map_editor_page.windows.outliner .position.y };
        size     = { editor_interface.map_editor_page.windows.outliner .size.x, editor_interface.map_editor_page.windows.outliner .size.y };
      };
      settings          =   {
        opened   = editor_interface.map_editor_page.windows.settings.enabled;
        position = { editor_interface.map_editor_page.windows.settings.position.x, editor_interface.map_editor_page.windows.settings.position.y };
        size     = { editor_interface.map_editor_page.windows.settings.size.x, editor_interface.map_editor_page.windows.settings.size.y };
      };
      size              = { gge_gfx_window_size().x, gge_gfx_window_size().y };
      theme             = editor_interface.map_editor_page.windows.settings.content.themes_panel.theme_selectbox.selected.name;
    }    

    local file = io.open("editor/config/interface.lua", "w")

    if file == nil then gge_error("Could not open file", 1) end

    file:write(
[[-- file auto generated by Grit Editor, be careful when modifying this manually
-- this file stores all editor interface configuration, like windows sizes, positions,
-- interface customizations, etc.
]]
)
    file:write("\neditor_interface_cfg = ")
    file:write(dump(editor_interface_cfg, false))

    file:close()
end

-- save editor config
function Editor:saveEditorConfig()
    local file = io.open("editor/config/config.lua", "w")

    if file == nil then gge_error("Could not open file", 1) end

    file:write(
[[-- file auto generated by Grit Editor, be careful when modifying this manually
-- this file stores all editor configurations.
]]
)
    file:write("\neditor_cfg = ")
    file:write(dump(editor_cfg, false))

    file:close()
end

function Editor:undo()
    self.mapFile:undo()
    widget_manager:updateWidget()
end

function Editor:redo()
    self.mapFile:redo()
    widget_manager:updateWidget()
end

function Editor:cutSelected()
    widget_manager:copySelectedToClipboard()
    widget_manager:deleteSelected()
end

function Editor:copySelected()
    widget_manager:copySelectedToClipboard()
end

function Editor:paste()
    widget_manager:paste()
end

function Editor:init()
    BaseGameMode.init(self)
    gge_navigation_reset()


    self.debugMode = false
    self.inDebugModeSettings = false
    self.noClip = false
    self.fast = false
    self.mouseCapture = false
    self.speedSlow = 3
    self.speedFast = 100
    self.forwards = 0
    self.backwards = 0
    self.left = 0
    self.right = 0
    self.ascend = 0
    self.descend = 0
    self.camYaw = 0
    self.camPitch = 0
    self.lastMouseMoveTime = 0
    self.controlObj = nil
    self.cameraVehicleLock = true

    -- Do not use self.map because the BaseGameMode already defines it as a string.
    self.mapFile = EditorMap.new()
    main.camPos, main.camQuat = self.mapFile:getEditorCamPosOrientation()
    self.camPitch = quatPitch(main.camQuat)
    self.camYaw = cam_yaw_angle()

    -- Avoid it interfering with menu and tool bar.
    ticker:setOffset(vec(40, 58))
    -- Avoid distracting text while we load the HUD.
    ticker:clear()

    main.speedoPos = main.camPos
    main.speedoSpeed = 0
    safe_destroy(self.speedo)
    self.speedo = hud_object `/common/hud/Speedo` { parent = hud_top_right }
    self.speedo.position = vec(-64, -128 - self.speedo.size.y/2)
    self.speedo.enabled = false

    gge_gfx_option("WIREFRAME_SOLID", true) -- i don't know why but when selecting a object it just shows wireframe, so TEMPORARY?

    -- Turn bloom off as it can be distracting.
    gge_gfx_option("BLOOM_THRESHOLD", 0)
    gge_gfx_option("BLOOM_ITERATIONS", 0)

    self.debug_mode_text = gge_hud_text_add(`/common/fonts/Verdana12`)
    self.debug_mode_text.parent = hud_bottom_left
    self.debug_mode_text.text = "Mouse left: Use Weapon\nMouse Scroll: Change Weapon\nF: Control Object\nTab: Console\nF1: Open debug mode menu (TODO)\nF5: Return Editor"
    self.debug_mode_text.position = vec(self.debug_mode_text.size.x/2+10, self.debug_mode_text.size.y)
    
    self.debug_label = {}
    for i = 1, 4 do
        self.debug_label[i] = hud_object `/common/hud/Label` {
            parent = hud_top_right,
            size = vec(128, 32),
            position = vec(-64, -128 - 32 - 32 * i),
            alignment = 'LEFT',
            colour = vec(0, 0, 0),
            font = `/common/fonts/misc.fixed`,
            enabled = false,
        }
    end

    make_editor_interface()

    self.debugModeSettingsWindow = hud_object `debug_mode/Settings` {
        title = "Debug Mode Settings",
        parent = hud_centre,
        position = vec(0, 0),
        resizeable = true,
        size = vec(620, 500),
        minSize = vec2(620, 500),
        -- colour = _current_theme.colours.window.background;
        alpha = 1,
        enabled = false,
    }
    _windows[#_windows+1] = self.debugModeSettingsWindow

    playing_binds.enabled = true
    playing_binds.mouseCapture = false
    editor_binds.enabled = true
    editor_edit_binds.enabled = true
    editor_object_binds.enabled = true
    editor_debug_binds.enabled = false
    editor_debug_play_binds.enabled = false

    self.lastMouseMoveTime = gge_seconds()

    -- set default values/update values for window content
    editor_init_windows()
    
    if editor_cfg.load_startup_map then
        self:openMap(editor_cfg.startup_map)
    else
        self:newMap()
    end
    
    notify("The editor is very unstable, we are working on it", vec(1, 0, 0))
    self:setDebugMode(false)
    
    env.clockRate = 0
end

function Editor:debugText(i, str)
    self.debug_label[i]:setValue(str)
end

function Editor:setInDebugModeSettings(v)
    self.inDebugModeSettings = v
    self:setMouseCapture(not v)
    self.debugModeSettingsWindow.enabled = v
    editor_debug_play_binds.enabled = not v
end

function Editor:loadMap()
    -- Override BaseGameMode's behavior since we load maps differently in the editor.
end

function Editor:setPause(v)
    -- Do nothing, pause controlled elsewhere.
end

function Editor:receiveButton(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end
    if not hud_focus then
        local cobj = self.controlObj

        if button == "debug" then
            if state == '+' then
                self:toggleDebugMode()
            end

        elseif button == "forwards" then
            self.forwards = on_off

        elseif button == "backwards" then
            self.backwards = on_off

        elseif button == "strafeLeft" then
            self.left = on_off

        elseif button == "strafeRight" then
            self.right = on_off

        elseif button == "ascend" then
            self.ascend = on_off
        elseif button == "descend" then
            self.descend = on_off
        elseif button == "faster" then
            if state == '+' then
                self.fast = true
            elseif state == '-' then
                self.fast = false
            end
        elseif button == "delete" then
            if state == '+' then
                self:deleteSelected()
            end

        elseif button == "cut" then
            if state == '+' then
                self:cutSelected()
            end

        elseif button == "copy" then
            if state == '+' then
                self:copySelected()
            end

        elseif button == "paste" then
            if state == '+' then
                self:paste()
            end

        elseif button == "undo" then
            if state == '+' then
                self:undo()
            end

        elseif button == "redo" then
            if state == '+' then
                self:redo()
            end

        elseif button == "duplicate" then
            if state == '+' then
                self:duplicateSelected()
            end

        elseif button == "unselectAll" then
            if state == '+' then
                self:unselectAll()
            end

        elseif button == "board" then
            if state == '+' then
                self:toggleBoard()
            end

        elseif button == "walkBoard" then
            if state == '+' then
                self:toggleBoard()
            end

        elseif button == "driveAbandon" then
            if state == '+' then
                self:toggleBoard()
            end

        elseif button == "mouseCapture" then
            if state == '+' then
                if gge_hud_ray(mouse_pos_abs) == nil then
                    self:setMouseCapture(true)
                end
            elseif state == '-' then
                self:setMouseCapture(false)
            end

        elseif button == "toggleDebugModeSettings" then
            if state == '+' then
                self:setInDebugModeSettings(not self.inDebugModeSettings)
            end

        elseif button == "selectModeTranslate" then
            self:setWidgetMode("translate")
        elseif button == "selectModeRotate" then
            self:setWidgetMode("rotate")
        elseif button == "weaponPrimary" then
            if state == '+' then
                WeaponEffectManager:primaryEngage(main.camPos, main.camQuat)
            elseif state == '-' then
                WeaponEffectManager:primaryDisengage()
            end
        elseif button == "weaponSecondary" then
            if state == '+' then
                WeaponEffectManager:secondaryEngage(main.camPos, main.camQuat)
            elseif state == '-' then
                WeaponEffectManager:secondaryDisengage()
            end
        elseif button == "weaponSwitchUp" then
            if state == '+' then
                WeaponEffectManager:select(WeaponEffectManager:getNext())
            end

        elseif button == "weaponSwitchDown" then
            if state == '+' then
                WeaponEffectManager:select(WeaponEffectManager:getPrev())
            end

        elseif button == "pausePhysics" then
            if state == '+' then
                main.physicsEnabled = not main.physicsEnabled
            end
        elseif button == "singleStepPhysics" then
            if state == '+' then
                physics__step(gge_physics_option("STEP_SIZE"))
            end
        else
            local pressed = state ~= '-'
            if state == '=' then return end

            if button == 'walkForwards' then
                cobj:setForwards(pressed)
            elseif button == 'walkBackwards' then
                cobj:setBackwards(pressed)
            elseif button == 'walkLeft' then
                cobj:setLeft(pressed)
            elseif button == 'walkRight' then
                cobj:setRight(pressed)
            elseif button == 'walkBoard' then
                if state == '+' then
                    self:scanForBoard()
                end
            elseif button == 'walkJump' then
                cobj:setJump(pressed)
            elseif button == 'walkRun' then
                cobj:setRun(pressed)
            elseif button == 'walkCrouch' then
                cobj:setCrouch(pressed)
            elseif button == 'walkZoomIn' then
                if pressed then
                    self:boomIn()
                end
            elseif button == 'walkZoomOut' then
                if pressed then
                    self:boomOut()
                end
            elseif button == 'walkCamera' then
                -- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

            elseif button == 'driveForwards' then
                cobj:setForwards(pressed)
            elseif button == 'driveBackwards' then
                cobj:setBackwards(pressed)
            elseif button == 'driveLeft' then
                cobj:setLeft(pressed)
            elseif button == 'driveRight' then
                cobj:setRight(pressed)
            elseif button == 'driveZoomIn' then
                if pressed then
                    self:boomIn()
                end
            elseif button == 'driveZoomOut' then
                if pressed then
                    self:boomOut()
                end
            elseif button == 'driveCamera' then
                -- toggle between regular_chase_cam_update, top_down_cam_update, top_angled_cam_update

            elseif button == 'driveSpecialUp' then
                cobj:setSpecialUp(pressed)
            elseif button == 'driveSpecialDown' then
                cobj:setSpecialDown(pressed)
            elseif button == 'driveSpecialLeft' then
                cobj:setSpecialLeft(pressed)
            elseif button == 'driveSpecialRight' then
                cobj:setSpecialRight(pressed)
            elseif button == 'driveAltUp' then
                cobj:setAltUp(pressed)
            elseif button == 'driveAltDown' then
                cobj:setAltDown(pressed)
            elseif button == 'driveAltLeft' then
                cobj:setAltLeft(pressed)
            elseif button == 'driveAltRight' then
                cobj:setAltRight(pressed)
            elseif button == 'driveAbandon' then
                if state == '+' then
                    self:abandonControlObj()
                end
            elseif button == 'driveHandbrake' then
                cobj:setHandbrake(pressed)
            elseif button == 'driveLights' then
                if state == '+' then
                    cobj:setLights()
                end
            elseif button == 'driveSpecialToggle' then
                if state == '+' then
                    cobj:special()
                end
            else
                gge_error("Editor has no binding for button: "..button)
            end
        end
    end
end

function Editor:destroy()
    widget_manager:unselectAll()
    
    self:saveEditorConfig()
    -- self:saveEditorInterface()

    self.debugModeSettingsWindow:destroy()
    
    safe_destroy(self.speedo)

    editor_interface.map_editor_page:destroy()
    editor_interface:destroy()
    gge_navigation_reset()
    BaseGameMode.destroy(self)
end

game_manager:register(Editor)
