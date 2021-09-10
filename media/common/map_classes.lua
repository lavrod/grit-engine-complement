-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

verbose_receive_damage = false

function light_from_table (l, tab)
        if tab.pos then l.localPosition = tab.pos end
        local sz
        if tab.diff then
            sz = math.max(math.max(math.max(1, tab.diff.x), tab.diff.y), tab.diff.z)
            l.diffuseColour = tab.diff
        end
        if tab.spec then l.specularColour = tab.spec end
        if tab.diff and not tab.spec then
            l.specularColour = tab.diff
        end
        local csz
        if sz then csz = sz / 16 end
        if tab.range then
            l.range = tab.range
            if csz then csz = csz * tab.range end
        end
        if tab.iangle then l.innerAngle = tab.iangle end
        if tab.oangle then l.outerAngle = tab.oangle end
        if tab.ciangle then l.coronaInnerAngle = tab.ciangle end
        if tab.coangle then l.coronaOuterAngle = tab.coangle end
        if tab.aim then l.localOrientation = tab.aim end
        if tab.coronaSize or csz then l.coronaSize = tab.coronaSize or csz end
        if tab.coronaColour then
            l.coronaColour = tab.coronaColour
        else
            if sz then
                l.coronaColour = tab.diff / sz 
            end
        end
        l.coronaLocalPosition = tab.coronaPos or vec(0,0,0)
        return l
end

BaseClass = {
        renderingDistance=400;
        init = function (self)
            local class_name = self.className
            local gfxMesh = self.gfxMesh or class_name..".mesh"
            self:addDiskResource(gfxMesh)
            if self.extraResources == nil then return end
            for _,v in ipairs(self.extraResources) do
                self:addDiskResource(v)
            end
        end;
        activate=function (self, instance)
            if self.skipNextActivation then
                self.skipNextActivation = nil
                instance.activationSkipped = true
                return true
            end
            --print("Activating: "..self.name.." ("..self.className..")")
            local gfxMesh = self.gfxMesh or self.className..".mesh"
            local mm
            if self.materialMap then
                mm = mm or {}
                for k,v in pairs(self.materialMap) do
                    mm[k] = v
                end
            end
            if instance.materialMap then -- allows subclasses to add to the material map
                mm = mm or {}
                for k,v in pairs(instance.materialMap) do
                    mm[k] = v
                end
            end
            instance.gfx = gfx_body_make(gfxMesh, mm)
            instance.gfx.castShadows = not (self.castShadows == false)
            if instance.gfx.numBones > 0 and instance.gfx:getAllAnimations() == nil then instance.gfx:setAllBonesManuallyControlled(true) end
            instance.gfx.localPosition = self.spawnPos
            instance.gfx.localOrientation = self.rot or quat(1,0,0,0)
            
            local lights = self.lights
            if lights then
                instance.lights = {}
                instance.lightCallbacks = {}
                instance.lightFlickedOff = {}
                instance.lightTimeOff = {}
                for k,tab in ipairs(lights) do
                    local l = light_from_table(gfx_light_make(), tab)
                    instance.lights[k] = l
                    l.parent = instance.gfx
                    if tab.flickering then
                        -- simulate a broken flourescent tube
                        future_event(0, function()
                            if l.destroyed then return end
                            local off = math.random() < 0.33
                            instance.lightFlickedOff[k] = off
                            l.enabled = not instance.lightFlickedOff[k] and not instance.lightTimeOff[k]
                            none_one_or_all(tab.emissiveMaterials, function(x)
                                instance.gfx:setEmissiveEnabled(x, l.enabled)
                            end)
                            return math.random() * 0.2
                        end)
                    end
                    if tab.onTime and tab.offTime then
                        local on_time = parse_time(tab.onTime)
                        local off_time = parse_time(tab.offTime)
                        local on_during_night = on_time > off_time
                        local first_time = on_during_night and off_time or on_time
                        local last_time = on_during_night and on_time or off_time
                        if tab.timeOnOffRandomness then
                            local random_secs = parse_time(tab.timeOnOffRandomness)
                            first_time = first_time + math.random()*random_secs
                            last_time = last_time + math.random()*random_secs
                        end
                        local cb = function()
                            local off
                            if env.secondsSinceMidnight < first_time then
                                off = not on_during_night
                            elseif env.secondsSinceMidnight < last_time then
                                off = on_during_night
                            else
                                off = not on_during_night
                            end
                            instance.lightTimeOff[k] = off
                            l.enabled = not instance.lightFlickedOff[k] and not instance.lightTimeOff[k]
                            none_one_or_all(tab.emissiveMaterials, function(x)
                                instance.gfx:setEmissiveEnabled(x, l.enabled)
                            end)
                        end
                        instance.lightCallbacks[k] = cb
                        --env:addClockCallback(cb)
                        env.tickCallbacks:insert(("lights_callback_"..k), cb)
                        cb(env.secondsSinceMidnight)
                    end
                end
            end

            if self.colourSpec then
                self:setRandomColour()
            end
        end;
        setRandomColour=function(self)
            if not self.activated then error("not activated") end
            local cs = self.colourSpec
            local prob_total = 0
            for k,v in ipairs(cs) do
                prob_total = prob_total + (v.probability or 1)
            end
            local r = math.random() * prob_total
            prob_total = 0
            for k,v in ipairs(cs) do
                prob_total = prob_total + (v.probability or 1)
                if r < prob_total then
                    self:setRandomColourFromSet(v)
                    return
                end
            end
        end;
        setRandomColourFromSet=function(self, colset, indexes)
            if not self.activated then error("not activated") end
            local cs = self.colourSpec
            if type(colset) == "number" then
                    colset = cs[colset]
            end
            local cols = {}
            for i=1,4 do -- 4 colours to choose
                if colset[i] == nil or #colset[i] == 0 then
                    cols[i] = "white"
                else
                    local set = {}
                    local function incorporate_all (tab)
                        for _,v in ipairs(tab) do
                            if type(v) == "string" and v:sub(1,1) == "*" then
                                incorporate_all(carcol_groups[v:sub(2)])
                            else
                                set[#set+1] = v
                            end
                        end
                    end
                    incorporate_all(colset[i])
                    cols[i] = set[indexes and indexes[i] or math.random(#set)]
                end
            end
            self:setColour(cols)
        end;
        setColour=function(self, cols)
            if not self.activated then error("not activated") end
            assert(type(cols)=="table")
            for i=1,4 do -- 4 colours to choose
                local col = cols[i]
                if col ~= nil then
                    if type(col) ~= "table" and type(col) ~= "string" then
                        error("Expecting table or string for coloured part "..i..", class \""..self.className.."\"")
                    end
                    while type(col) == "string" do
                        local col2 = carcols[col]
                        if col2==nil then
                            error("Class \""..self.className.."\" could not find colour \""..col.."\"")
                        end
                        if type(col2) ~= "table" and type(col2) ~= "string" then
                            error("Expecting table or string looking up car colour table with name\""..col.."\"")
                        end
                        col = col2
                    end
                    local diff = colour_ensure_vector3(col[1])
                    local met = col[2] or 0.5
                    local gloss = col[3] or 1
                    local spec = col[4] or 1
                    self.instance.gfx:setPaintColour(i-1, diff, met, gloss, spec)
                end
            end
        end;
        setFade=function(self, fade)
            local instance = self.instance
            if instance.gfx then
                    instance.gfx.fade = fade
            end
            if instance.lights then
                for k,v in pairs(instance.lights) do
                    v.fade = fade
                end
            end
        end;
        deactivate=function(self)
            local instance = self.instance
            --print("Deactivating: "..self.name.." ("..self.className..")")
            self.pos = self.spawnPos
            instance.gfx = safe_destroy(instance.gfx)
            if instance.lights then
                for k,v in pairs(instance.lights) do
                    instance.lights[k] = safe_destroy(v)
                    if instance.lightCallbacks[k] then
                        --env:removeClockCallback(instance.lightCallbacks[k])
                        env.tickCallbacks:removeByName(("lights_callback_"..k))
                        instance.lightCallbacks[k] = nil
                    end
                end
            end
        end;
        reload=function(self)
            self:reloadDiskResources();
        end;
        ignite=function() end;

        getStatistics = function (self)
            local instance = self.instance
            local gfx = instance.gfx

            local tot_triangles, tot_batches = gfx.triangles, gfx.batches

            print("Mesh: "..gfx.meshName)

            print(" Triangles: "..gfx.triangles)
            print(" Batches: "..gfx.batches)

            return tot_triangles, tot_batches
        end;

}


-----------------------
-- REGULAR CHASE CAM --
-----------------------

-- to use these functions, self must have a boomLengthMin and Max fields.
-- instance must have boomLengthSelected initialised to something sensible.
-- self must be at least of type ColClass
-- 

-- TODO(dcunnin): This function is out of date.  Is it obsolete?  Can we remove it?
function regular_chase_cam_update(self)

    local instance = self.instance

    local body = instance.body

    local vehicle_bearing, vehicle_pitch = yaw_pitch(body.worldOrientation * V_FORWARDS)
    local vehicle_vel = body.linearVelocity
    local vehicle_vel_xy_speed = #(vehicle_vel * vector3(1,1,0))

    -- modify the player_ctrl.camPitch and player_ctrl.camYaw to track the direction a vehicle is travelling
    if user_cfg.vehicleCameraTrack and self.cameraTrack and seconds() - player_ctrl.lastMouseMoveTime > 1  and vehicle_vel_xy_speed > 5 then
    
        player_ctrl.camPitch = lerp(player_ctrl.camPitch, player_ctrl.playerCamPitch + vehicle_pitch, 0.1)
        
        -- test avoids degenerative case where x and y are both 0 
        -- if we are looking straight down at the car then the yaw doesn't really matter
        -- you can't see where you are going anyway
        if math.abs(player_ctrl.camPitch) < 60 then
                --local new_cam_rel = self.camFocus - last_cam_pos
                local ideal_yaw = yaw(vehicle_vel.x, vehicle_vel.y)
                local current_yaw = player_ctrl.camYaw
                if math.abs(ideal_yaw - current_yaw) > 180 then
                    if ideal_yaw < current_yaw then
                        ideal_yaw = ideal_yaw + 360
                    else
                        current_yaw = current_yaw + 360
                    end 
                end 
                local new_yaw = lerp(player_ctrl.camYaw, ideal_yaw, 0.1) % 360
                    
                player_ctrl.camYaw = new_yaw
        end     
        player_ctrl.camDir = quat(player_ctrl.camYaw,V_DOWN) * quat(player_ctrl.camPitch,V_EAST)
    end 
    
    player_ctrl.camFocus = instance.camAttachPos
    local boom_length = math.max(self.boomLengthMin, cam_box_ray(player_ctrl.camFocus, player_ctrl.camDir, instance.boomLengthSelected, player_ctrl.camDir*V_BACKWARDS, body))
    player_ctrl.camPos = player_ctrl.camFocus + player_ctrl.camDir * vector3(0, -boom_length, 0)
end

-- TODO(dcunnin): This function is out of date.  Is it obsolete?  Can we remove it?
function top_down_cam_update(self)
    --this is a pure top down camera, always facing down
    local instance = self.instance
    local body = instance.body
    local vehicle_point = body.worldOrientation * V_FORWARDS
    
      local vehicle_dir = quat(V_FORWARDS, vehicle_point*vector3(1,1,0))
    
    if vehicle_point.x == 0 or vehicle_point.y == 0 then
        return
    end
    
    
    player_ctrl.camPos = instance.camAttachPos + V_UP*instance.boomLengthSelected
    player_ctrl.camFocus = instance.camAttachPos
    
    player_ctrl.speedoPos = instance.camAttachPos
    player_ctrl.speedoSpeed = #body.linearVelocity
    
    player_ctrl.camDir = vehicle_dir*Q_DOWN
end

-- TODO(dcunnin): This function is out of date.  Is it obsolete?  Can we remove it?
function top_angled_cam_update(self)
    --this is a locked pitch angle camera pretty much similar to regular_chase_cam
    player_ctrl.camPitch = -45
    player_ctrl.lastMouseMoveTime = 0 --this makes camera always adjusting it's yaw rotation, disregarding mouse movements
    regular_chase_cam_update(self)
end

ColClass = extends (BaseClass) {
        camAttachPos = vec(0, 0, 0);
        receiveImpulse = function (self, impulse, wpos)
            if self.health and self.impulseDamageThreshold then
                --if impulse > 0 then
                --        --print(self.name, impulse, pos, poso)
                --        if (not other.owner.destroyed) and other.owner.className == "/vehicles/Evo" then
                --                --print("BOUNCE!", impulse, norm, poso)
                --                --other:impulse(-impulse * norm, pos)
                --                self:receiveDamage(20000)
                --        end
                --end
                local damage = #impulse
                if damage > self.impulseDamageThreshold then
                    local volume = damage / self.impulseDamageThreshold - 1
                    audio_play("/common/sounds/collisions/collision_soft.wav", volume, 1+math.random()*0.3, wpos, 3, 1)
                    self:receiveDamage(damage)
                end
            end
        end;
        init = function (self)
            local class_name = self.className
            local colMesh = self.colMesh or class_name..".gcol"
            self:addDiskResource(colMesh)
            BaseClass.init(self)
        end;
        activate=function (self,instance)
                if BaseClass.activate(self,instance) then
                    return true
                end
                local colMesh = self.colMesh or self.className..".gcol"
                --print("adding: "..tostring(self).." with "..colMesh)
                local rot = self.rot or quat(1,0,0,0)
                local body = physics_body_make(
                    colMesh,
                    self.spawnPos,
                    rot
                )
                body.owner = self;
                instance.body = body
                instance.camAttachPos = self.spawnPos + rot * self.camAttachPos
                -- this causes an alloc so do them here where the code is cold
                body.updateCallback = function (p,q)
                    instance.camAttachPos = p + q * self.camAttachPos
                    instance.gfx.localPosition = p
                    instance.gfx.localOrientation = q
                    self.pos = p
                end
                self.instance.health = self.health
                --self.health = self.health or 10000000000
                --self.impulseDamageThreshold = self.impulseDamageThreshold or 10000
                if self.instance.health and self.impulseDamageThreshold then
                    body.collisionCallback = function (life, impulse, other, m, mo,
                                                       pen, pos, poso, norm)
                        self:receiveImpulse(impulse * norm, pos)
                    end
                end
                local pobjs = nil -- will hold the procedural objects (if any)
                local pobjs_counter = 1
                for _,pmatname in ipairs(body.procObjMaterials) do
                    local pmat = physics:getMaterial(pmatname)
                    if pmat ~= nil and pmat.proceduralObjects ~= nil then
                        for _, proc_obj_name in ipairs(pmat.proceduralObjects) do
                            local proc_obj = physics:getProceduralObjectClass(proc_obj_name)
                            if proc_obj == nil then
                                    error ("Physical material \""..pmatname.."\" references unknown procedural object \""..proc_obj_name.."\"")
                            end
                            local t = body:scatter(
                                pmatname,
                                proc_obj.density,
                                proc_obj.minSlope,
                                proc_obj.maxSlope,
                                proc_obj.minElevation,
                                proc_obj.maxElevation,
                                proc_obj.noZ,
                                proc_obj.rotate,
                                proc_obj.alignSlope,
                                proc_obj.seed or math.random(100000)
                            )
                            local n = #t
                            if n > 0 then pobjs = pobjs or { } end -- create a table only if we have to
                            local ocl = class_get(proc_obj.class)
                            local zoff = ocl.placementZOffset or 0
                            for k=0,(n/7-1) do    
                                local x,y,z       = t[k*7+1], t[k*7+2], t[k*7+3]
                                local qw,qx,qy,qz = t[k*7+4], t[k*7+5], t[k*7+6], t[k*7+7]
                                pobjs[pobjs_counter] = object (proc_obj.class) (x,y,z+zoff) { rot=quat(qw,qx,qy,qz) }
                                pobjs_counter = pobjs_counter + 1
                            end
                        end
                    end
                end
                instance.pobjs = pobjs
                local pbats = nil -- will hold the procedural objects (if any)
                local pbats_counter = 1
                for _,pmatname in ipairs(body.procObjMaterials) do
                    local pmat = physics:getMaterial(pmatname)
                    if pmat == nil then
                        error("Could not find physical material: \""..pmatname.."\"")
                    end
                    if pmat.proceduralBatches ~= nil then
                        for i, proc_bat_name in ipairs(pmat.proceduralBatches) do
                            pbats = pbats or { } -- create a table only if we have to
                            local pbat = pbats[proc_bat_name]
                            local proc_bat = physics:getProceduralBatchClass(proc_bat_name)
                            if pbat == nil then
                                pbat = gfx_ranged_instances_make(proc_bat.mesh)
                                pbat.castShadows = proc_bat.castShadows
                                pbats[proc_bat_name] = pbat
                            end
                            body:rangedScatter(
                                pmatname,
                                pbat,
                                proc_bat.density,
                                proc_bat.minSlope,
                                proc_bat.maxSlope,
                                proc_bat.minElevation,
                                proc_bat.maxElevation,
                                proc_bat.noZ,
                                proc_bat.rotate,
                                proc_bat.alignSlope,
                                proc_bat.seed or math.random(100000)
                            )
                        end
                    end
                end
                instance.pbats = pbats
        end;
        deactivate=function(self)
            local instance = self.instance
            if instance.body then
                if instance.body.mass > 0 and #(self.spawnPos - main.streamerCentre) < self.renderingDistance then
                    -- avoid it respawning directly in front of the camera
                    self.skipNextActivation = true
                end
            end
                            
            instance.body = safe_destroy(instance.body)
            local pobjs = instance.pobjs
            if pobjs ~= nil then
                for _,v in pairs(pobjs) do
                    if not v.destroyed then v:destroy() end
                end
            end
            instance.pobjs = nil
            local pbats = instance.pbats
            if pbats ~= nil then
                for k, v in pairs(pbats) do
                    safe_destroy(v)
                end
            end
            instance.pbats = nil
            BaseClass.deactivate(self, instance)
            return self.temporary -- don't respawn if it was from a pile
        end;

        getStatistics = function (self)
            local tot_triangles, tot_batches = BaseClass.getStatistics(self)
            
            local instance = self.instance

            if instance.pbats then
                for proc_bat_name, pbat in pairs(instance.pbats) do
                    print("  Procedural batch: "..proc_bat_name)
                    print("    Instances: "..pbat.instances)
                    print("    Triangles: "..pbat.triangles)
                    print("    Batches: "..pbat.batches)
                    tot_triangles = tot_triangles + pbat.triangles
                    tot_batches = tot_batches + pbat.batches
                end
            end

            return tot_triangles, tot_batches
        end;

        getSpeed = function (self)
            if not self.activated then error("Not activated: "..self.self.name) end
            local rb = self.instance.body
            return #rb.linearVelocity
        end;
        toggleProceduralBatches = function (self)
            if not self.activated then error("Not activated: "..self.name) end
            local pbats = self.instance.pbats
            if pbats == nil then return end
            print("Procedural batches of \""..tostring(self).."\" toggled ")
            for k,pbat in pairs(pbats) do
                pbat.enabled = v
            end
        end;
        special=function(self)
        end;
        beingFired=function(self)
        end;
        receiveDamage=function(self, damage)
            local new_health = self.instance.health - damage
            if self.instance.health <= 0 then return end
            if verbose_receive_damage then
                print(self.name.." says OW! "..damage.." ["..new_health.." / "..self.health.." = "..math.floor(100*new_health/self.health).."%]")
            end
            self.instance.health = new_health
            if self.instance.health <= 0 then
                self:noHealthLeft()
            end
        end;
        receiveBlast = function (self, impulse, wpos, damage_impulse)
            --print(self.name.." caught in explosion", impulse, wpos)
            damage_impulse = damage_impulse or impulse
            self.instance.body:impulse(impulse, wpos)
            self:receiveImpulse(damage_impulse, wpos)
        end;
        receiveHeat = function (self, wpos, amount)
        end;
        onExplode = function (self)
            local xi = self.explodeInfo
            if xi and xi.deactivate then self:deactivate() end
        end;
        explode = function (self)
            local instance = self.instance
            if instance.exploded then return end
            local xi = self.explodeInfo
            if xi then
                instance.exploded = true
                if instance.health and instance.health > 0 then instance.health = 0 end
                explosion(self.pos + (xi.offset or vector3(0,0,0)), xi.radius or 4, xi.force)
                self:onExplode()
            end
        end;
        noHealthLeft = function(self)
            if self.explodeInfo then self:explode() end
        end;
        ignite=function(self, pname, pos, mat, fertile_life)
            --print("igniting: "..tostring(self))
            if self.instance.body.mass==0 then
                flame_ignite(pname, pos, mat, fertile_life)
            end
        end;
}

PileClass = {
    renderingDistance=400;
    init = function (self)
        -- iterate over the guys i will spawn to see what their "advance prepares" should be
        --print("Initialising: "..self.name.." ("..self.className..")")
    end;
    activate=function (self, instance)
        --print("Activating: "..self.name.." ("..self.className..")")
        instance.children = {}
        for k,v in ipairs(self.class.dump) do
            local oclass, opos, otab = unpack(v)
            if self.rot then
                opos = self.rot * opos
                otab.rot = self.rot * (otab.rot or Q_ID)
            end
            otab.temporary = true
            opos = self.spawnPos + opos
            instance.children[k] = object_add(oclass,opos,otab)
        end
    end;
    deactivate=function(self)
        --print("Deactivating: "..self.name.." ("..self.className..")")
        -- nothing to do i think
        local instance = self.instance
        for k,v in ipairs(instance.children) do
            if not v.activated then
                v:destroy()
            end
        end
    end;
}

ProcPileClass = {
    renderingDistance=400;
    init = function (self)
        -- iterate over the guys i will spawn to see what their "advance prepares" should be
        --print("Initialising: "..self.name.." ("..self.className..")")
    end;
    spawnObjects = function() end;
    activate=function (self, instance)
        --print("Activating: "..self.name.." ("..self.className..")")
        instance.children = {}
        local counter = 1
        self:spawnObjects(function(oclass,opos,otab)
            if self.rot then
                opos = self.rot * opos
                otab.rot = self.rot * (otab.rot or Q_ID)
            end
            otab.temporary = true
            opos = self.spawnPos + opos
            instance.children[counter] = object_add(oclass,opos,otab)
            counter = counter + 1
        end)
    end;
    deactivate=function(self)
        --print("Deactivating: "..self.name.." ("..self.className..")")
        -- nothing to do i think
        local instance = self.instance
        for k,v in ipairs(instance.children) do
            if not v.activated then
                v:destroy()
            end
        end
    end;
}

function dump_object_line(self)
    local x,y,z = unpack(self.spawnPos)
    return ("object \"%s\" (%f,%f,%f) {name=\"%s\", rot=%s}"):format(self.className, x,y,z, self.name, tostring(self.rot))
end

