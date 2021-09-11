local GameMode = extends_keep_existing (game_manager.gameModes['Navigation Demo'], BaseGameMode) {
    name = 'Navigation Demo',
    description =  "Strategic Companion's Game Demo",
    previewImage = `GameMode.png`,
    map = `navmap.gmap`,
	spawnPos = vec3(-21, -22, 27),
	spawnRot = quat(0.86, -0.3, 0.13, -0.37),

	debugMode = false,
	noClip = false,
	fast = false,
	speedSlow = 3,
	speedFast = 100,
	forwards = 0,
	backwards = 0,
	left = 0,
	right = 0,
	ascend = 0,
	descend = 0,	
}

function GameMode:playerRespawn()

    -- Use loading screen while we go back to spawn pos
    self:loadAtLocation(self.spawnPos)

	main.camPos = self.spawnPos
    main.camQuat = self.spawnRot
    main.audioCentreVel = vec(0, 0, 0);
    main.audioCentreQuat = quat(1, 0, 0, 0);

    self.camYaw = cam_yaw_angle();
    self.camPitch = quatPitch(main.camQuat);
    self.playerCamPitch = 0;
    self.lastMouseMoveTime = gge_seconds()

    env.secondsSinceMidnight = 12 * 60 * 60
	env.clockRate = 0
	
    -- TODO(dcunnin): Use disk I/O subsystem for this.
    if gge_navigation_load_navmesh("./navigation/navmap.navmesh") then
        for i, aichar in ipairs(self.aicharacters) do
            if not aichar.destroyed then
                aichar:activate()
                aichar:restartAgent()
            end
        end
	end

    self:mouseMove(vec(0,0))
    self:stepCallback(0)
    self:frameCallback(0)

end

function GameMode:init()
    BaseGameMode.init(self)

	gge_navigation_reset()

	gge_navigation_debug_option("navmesh_use_tile_colours", true)
	gge_navigation_debug_option("enabled", true)

    self.aicharacters = { }
    for _, obj in ipairs(object_all_of_class(`RobotHeavy`)) do
        self.aicharacters[#self.aicharacters+1] = obj
    end
    for _, obj in ipairs(object_all_of_class(`RobotMed`)) do
        self.aicharacters[#self.aicharacters+1] = obj
    end
    for _, obj in ipairs(object_all_of_class(`RobotScout`)) do
        self.aicharacters[#self.aicharacters+1] = obj
    end
	
	playing_actor_binds.enabled = true

	playing_binds.mouseCapture = false

	playing_binds:bind("right", function() playing_binds.mouseCapture = true end, function() playing_binds.mouseCapture = false end)
	
	playing_binds:bind("left", function() local pos = mouse_pick_pos() if pos then pos = gge_navigation_nearest_point_on_navmesh(pos) end if pos then crowd_move(pos) end end)

	clock.enabled = false
	compass.enabled = false
	

    self:playerRespawn()

	gge_gfx_option("RENDER_SKY", false)
	
	gge_gfx_option("BLOOM_THRESHOLD", 1.5)

	self.info = gui.text({value = "=== Compagnion's ===\nMouse:\n<Left-Click> Move Crowd\n\n=== Yourself: First Person Viewer ===\nMouse:\n<Right-Click> Rotate\n\nKeyboard:\n<space> Ascend\n<c>Descend\n<a> Move Left\n<d> Move Right\n<w>Zoom In\n<s>Zoom out\n<shift> Faster\n<esc> Pause Menu", parent = hud_bottom_left, position = vec(200, 200)})
	
end

function GameMode:receiveButton(button, state)
    local on_off
    if state == "+" or state == '=' then on_off = 1 end
    if state == "-" then on_off = 0 end

    if button == "walkForwards" then
        self.forwards = on_off
    elseif button == "walkBackwards" then
        self.backwards = on_off
    elseif button == "walkLeft" then
        self.left = on_off
    elseif button == "walkRight" then
        self.right = on_off
    elseif button == "walkJump" then
        self.ascend = on_off
    elseif button == "walkCrouch" then
        self.descend = on_off
	elseif button == 'walkRun' then
		self.fast = (state == "+" or state == '=')
	end
end

local function ghost_cast (pos, ray, scale)
    local fraction, _, n = gge_physics_sweep_sphere(scale*.15, pos, ray, true, 1)
    return fraction, n
end


function GameMode:frameCallback(elapsed_secs)

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


    main.streamerCentre = main.camPos
    main.audioCentrePos = main.camPos
    main.audioCentreVel = vec(0, 0, 0);
end

function GameMode:destroy()
    BaseGameMode.destroy(self)

	playing_binds:unbind("right")
	playing_binds:unbind("left")
	
	gge_navigation_debug_option("enabled", false)	
	gge_navigation_reset()
end

game_manager:register(GameMode)

function crowd_move(pos)
    for i, aichar in ipairs(game_manager.currentMode.aicharacters) do
        if not aichar.destroyed and aichar.activated and aichar.instance.agentID ~= -1 then
            aichar:updateDestination(pos, false)
        end
    end
end

