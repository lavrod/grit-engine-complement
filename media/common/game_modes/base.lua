BaseGameMode = BaseGameMode or {
    name = 'Unnamed',
    description = 'No description',
    previewImage = `/common/hud/LoadingScreen/GritLogo.png`,
    map = `/editor/default_map/defaultmap.gmap`,
    spawnPos = vec(0, 0, 0),
    spawnRot = Q_ID,
}

-- Define them outside of the object to allow re-reading the file to hot-swap out functions.

--[[
BaseGameMode provides some very basic features:
- Control playing_binds
- Relative mouse movement, that populates camYaw/camPitch fields and lastMouseMoveTime
- Routines to force load the map at a particular point and display a progress bar
- Boom length control (boom not used anywhere)
- debugText that just prints
- Stub implementations of the other methods needed by a game mode
]]

function BaseGameMode:init()

    playing_binds.enabled = true
    playing_binds.mouseCapture = true
    
    main.audioCentreVel = vec(0, 0, 0)
    main.audioCentreQuat = self.spawnRot
    self.camYaw = 0
    self.camPitch = 0
    self.lastMouseMoveTime = gge_seconds()

    -- Integer in range [0, 3]
    -- Actual boom length is a function of this.
    -- Zoom operations inc / dec the notch by 1.
    self.boomNotch = 2

    main.camPos = self.spawnPos
    main.camQuat = self.spawnRot

    self:loadMap()
end

function BaseGameMode:loadMap()
    loading_screen:setMapName(self.name)
    loading_screen:setStatus('Loading resources...')
    print(self.map)
    include_map(self.map)
end

function BaseGameMode:loadAtLocation()
    streamer_centre_full(self.spawnPos)

    if gge_get_in_queue_size() == 0 then
        -- Everything loaded so don't bother with the loading screen.
        return
    end

    -- Use loading screen while we go back to spawn pos
    loading_screen.enabled = true
    loading_screen:setProgress(0)

    loading_screen:pump()

    local to_go = gge_get_in_queue_size()
    local init_to_go = to_go
    while to_go > 0 do
        to_go = gge_get_in_queue_size()
        loading_screen:setProgress((init_to_go - to_go) / init_to_go)
        loading_screen:pump()
        gge_give_queue_allowance(1 + to_go)
    end
    loading_screen:setProgress(1)
    loading_screen:setStatus('Activating objects')
    loading_screen:pump()
    streamer_centre_full(self.spawnPos)

    loading_screen:setStatus('All done')
    loading_screen:pump()
    loading_screen.enabled = false
end

function BaseGameMode:setPause(v)
    main.physicsEnabled = not v
end

function BaseGameMode:boomIn()
    self.boomNotch = math.max(self.boomNotch - 1, 0)
end

function BaseGameMode:boomOut()
    self.boomNotch = math.min(self.boomNotch + 1, 3)
end

function BaseGameMode:boomLength(boom_min, boom_max)
    -- Somewhere between the min and max, according to notch.
    -- Do it in logarithmic space as this is more natural given perspective correction.
    return math.exp(lerp(math.log(boom_min), math.log(boom_max), self.boomNotch / 3))
end

-- Manages the camera / audio orientation and updates some useful variables.
function BaseGameMode:mouseMove(rel)
    local sens = user_cfg.mouseSensitivity
    
    local rel2 = sens * rel * vec(1, user_cfg.mouseInvert and -1 or 1)
    
    self.camYaw = (self.camYaw + rel2.x) % 360
    self.camPitch = clamp(self.camPitch + rel2.y, -90, 90)
    self.playerCamPitch = self.camPitch
        
    main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
    main.audioCentreQuat = main.camQuat

    self.lastMouseMoveTime = gge_seconds()
end

function BaseGameMode:debugText(i, str)
    gge_print(i, str)
end

function BaseGameMode:receiveButton(button, state)
end

function BaseGameMode:frameCallback(elapsed_secs)
end

function BaseGameMode:stepCallback(elapsed_secs)
end

function BaseGameMode:destroy()
end
