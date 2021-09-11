ThirdPersonGameMode = extends_keep_existing(ThirdPersonGameMode, BaseGameMode) {

    seaLevel = -6,
    -- Subclasses must initialize this, then call playerRespawn.
    protagonist = nil,
}

function ThirdPersonGameMode:init()
    BaseGameMode.init(self)

    main.speedoPos = main.camPos
    main.speedoSpeed = 0

    safe_destroy(self.speedo)
    self.speedo = hud_object `/common/hud/Speedo` { parent = hud_top_right }
    self.speedo.position = vec(-64, -128 - self.speedo.size.y/2)

    self.centreNotify = gge_hud_text_add(`/common/fonts/Impact50`)
    self.centreNotify.text = ''
    self.centreNotify.position = vec(0, 100)
    self.centreNotify.parent = hud_centre
    self.centreNotify.shadow = vec(6, -3)
    self.centreNotify.colour = vec(1, .7, .3)
end

function ThirdPersonGameMode:destroy()
    BaseGameMode.destroy(self)
    safe_destroy(self.centreNotify)
    safe_destroy(self.speedo)
end

function ThirdPersonGameMode:playerRespawn()

    self.centreNotify.text = ''

    for _, obj in ipairs(object_all()) do
        obj:deactivate()
        obj.skipNextActivation = false
    end

    self.protagonist.spawnPos = self.spawnPos
    self.protagonist.pos = self.spawnPos
    self.protagonist.rot = self.spawnRot
    main.camPos = self.spawnPos

    self.vehicle = nil
    self.playerDeathTimer = nil
    env_saturation_mask = 1

    playing_actor_binds.enabled = true
    playing_vehicle_binds.enabled = false

    self:loadAtLocation(self.spawnPos)

    main.camQuat = self.spawnRot
    main.audioCentreVel = self.spawnPos
    main.audioCentreQuat = self.spawnRot
    self.camYaw = 90;
    self.camPitch = 0;
    self.playerCamPitch = 0;  -- Without vehicle pitch offset
    self.lastMouseMoveTime = gge_seconds()

    self:mouseMove(vec(0, 0))
    self:stepCallback(0)
    self:frameCallback(0)
end

function ThirdPersonGameMode:playerKill()
    self.playerDeathTimer = 0
    self.centreNotify.text = 'WASTED!'
    if self.vehicle then
      self.vehicle = nil
    end
    if main and main.controlObj then
       main.controlObj = nil       
    end
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = false
end

function ThirdPersonGameMode:mouseMove(rel)
    if self.playerDeathTimer then return end
    BaseGameMode.mouseMove(self, rel)
end

function ThirdPersonGameMode:scanForBoard()
    local radius = 3
    local player_body = self.protagonist.instance.body
    local player_pos = player_body.worldPosition
    local best_score = 0
    local best_found_vehicle = nil
    gge_physics_test(radius, player_pos, true, function(body, num, lpos, wpos, normal, penetration, mat)
        local found_vehicle = body.owner
        if found_vehicle == nil then return end
        if found_vehicle.controllable ~= "VEHICLE" then return end
        local from_player = player_body:worldToLocal(wpos)
        local angle = math.deg(math.acos(norm(from_player).y))
        if angle > 45 then return end
        local score = penetration
        if score > best_score then
            best_score = score
            best_found_vehicle = found_vehicle
        end
    end)
    if best_found_vehicle == nil then return end
    self:board(best_found_vehicle)
end

function ThirdPersonGameMode:board(veh)
    self.vehicle = veh
    playing_actor_binds.enabled = false
    playing_vehicle_binds.enabled = true
    self.protagonist:enterVehicle()
    veh:controlBegin()
    
    main.controlObj = veh
    
    -- When boarding a vehicle we want to keep the same effective pitch (otherwise it's jarring for the user).
    -- So we calculate the playerCamPitch necessary for that.
    local v_pitch = pitch((veh.instance.body.worldOrientation * V_FORWARDS).z)
    self.playerCamPitch = self.playerCamPitch - v_pitch
end

function ThirdPersonGameMode:abandonControlObj()
    -- Disable binds before settings vehicle to nil, ensures steering, acceleration etc is reset
    local veh = self.vehicle

    -- Disable the binds first so that no more vehicle control events are processed (and fail
    -- because self.vehicle is nil).
    playing_vehicle_binds.enabled = false

    self.vehicle = nil
    self.protagonist:exitVehicle(veh.instance.body:localToWorld(veh.driverExitPos), veh.instance.body.worldOrientation * veh.driverExitQuat)
    veh:controlAbandon()
    
    main.controlObj = nil
    
    playing_actor_binds.enabled = true

    -- When on foot there is no vehicle pitch.
    local v_pitch = pitch((veh.instance.body.worldOrientation * V_FORWARDS).z)
    self.playerCamPitch = self.playerCamPitch + v_pitch
end

function ThirdPersonGameMode:receiveButton(button, state)
    if state == '=' then return end
    local pressed = state ~= '-'

    local prot = self.protagonist
    local cobj = self.vehicle

    if button == 'walkForwards' then    
        prot:setForwards(pressed)
    elseif button == 'walkBackwards' then
        prot:setBackwards(pressed)
    elseif button == 'walkLeft' then
        prot:setLeft(pressed)
    elseif button == 'walkRight' then
        prot:setRight(pressed)
    elseif button == 'walkBoard' then
        if state == '+' then
            self:scanForBoard()
        end
    elseif button == 'walkJump' then
        prot:setJump(pressed)
    elseif button == 'walkRun' then
        prot:setRun(pressed)
    elseif button == 'walkCrouch' then
        prot:setCrouch(pressed)
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
    end
end

function ThirdPersonGameMode:frameCallback(elapsed_secs)
    BaseGameMode.frameCallback(self, elapsed_secs)
    local obj = self.vehicle or self.protagonist
    local instance = obj.instance
    local body = instance.body

    local boom_length

    if self.playerDeathTimer then
        self.playerDeathTimer = self.playerDeathTimer + elapsed_secs

        local stage = self.playerDeathTimer / 4

        if stage > 1 then
            self:playerRespawn()
            return
        end
        env_saturation_mask = (1 - stage) * (1 - stage)

        self.camYaw = self.camYaw + elapsed_secs * 60
        self.camPitch = math.max(-90, self.camPitch - elapsed_secs * 60)
        main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)
        local curr_dist = #(main.camPos - instance.camAttachPos)
        boom_length = curr_dist + elapsed_secs * 2
    else

        local vehicle_bearing, vehicle_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
        local vehicle_vel = body.linearVelocity
        local vehicle_vel_xy_speed = #(vehicle_vel * vector3(1,1,0))

        -- modify the self.camPitch and self.camYaw to track the direction a vehicle is travelling
        if user_cfg.vehicleCameraTrack and obj.cameraTrack and gge_seconds() - self.lastMouseMoveTime > 1  and vehicle_vel_xy_speed > 5 then

            self.camPitch = lerp(self.camPitch, self.playerCamPitch + vehicle_pitch, elapsed_secs * 2)

            -- test avoids degenerative case where x and y are both 0 
            -- if we are looking straight down at the car then the yaw doesn't really matter
            -- you can't see where you are going anyway
            if math.abs(self.camPitch) < 60 then
                local ideal_yaw = yaw(vehicle_vel.x, vehicle_vel.y)
                local current_yaw = self.camYaw
                if math.abs(ideal_yaw - current_yaw) > 180 then
                    if ideal_yaw < current_yaw then
                        ideal_yaw = ideal_yaw + 360
                    else
                        current_yaw = current_yaw + 360
                    end
                end
                local new_yaw = lerp(self.camYaw, ideal_yaw, elapsed_secs * 2) % 360

                self.camYaw = new_yaw
            end
        end

        main.camQuat = quat(self.camYaw, V_DOWN) * quat(self.camPitch, V_EAST)

        main.speedoPos = instance.camAttachPos
        main.speedoSpeed = #vehicle_vel
        if self.vehicle ~= nil then
            self.protagonist:updateDriven(instance.camAttachPos, Q_ID)
        end

        -- TODO(dcunnin): If reducing this to 0 worked then remove it.
        local ray_skip = 0
        local ray_dir = main.camQuat * V_BACKWARDS
        local ray_start = instance.camAttachPos + ray_skip * ray_dir
        if obj.boomLengthMin == nil or obj.boomLengthMax == nil then
            gge_error('Controlling %s of class %s, needed boomLengthMin and boomLengthMax, got: %s, %s'
                  % {obj, obj.className, obj.boomLengthMin, obj.boomLengthMax})
        end
        local ray_len = self:boomLength(obj.boomLengthMin, obj.boomLengthMax) - ray_skip
        local ray_hit_len = cam_box_ray(ray_start, main.camQuat, ray_len, ray_dir, body)
        boom_length = math.max(obj.boomLengthMin, ray_hit_len)
    end

    main.camPos = instance.camAttachPos + main.camQuat * vector3(0, -boom_length, 0)
    main.streamerCentre = instance.camAttachPos
    main.audioCentrePos = main.camPos
end

function ThirdPersonGameMode:stepCallback(elapsed_secs)
    BaseGameMode.stepCallback(self, elapsed_secs)
    if self.playerDeathTimer then
        -- Already dead.
        return
    end
    if self.vehicle ~= nil and self.vehicle.instance.exploded then
        -- In vehicle that exploded.
        self:playerKill()
    end
    if self.protagonist.pos.z < self.seaLevel then
        -- Drowned.
        self:playerKill()
    end
end
