-- (c) David Cunningham 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php


WeaponEffectManager = {

    weapons = { };
    selectedName = nil;

    primaryEngaged = false;
    secondaryEngaged = false;

    set = function (self, name, weapon)
        self.weapons[name] = weapon
    end;

    get = function (self, name)
        return self.weapons[name]
    end;

    getSelected = function (self)
        return self.weapons[self.selectedName]
    end;

    getNext = function (self)
        local w = next(self.weapons, self.selectedName)
        if w == nil then return (next(self.weapons, nil)) end
        return w
    end;

    getPrev = function (self)
        local last = nil
        for k, v in pairs(self.weapons) do
            if k == self.selectedName then
                if last ~= nil then
                    return last
                end
            end
            last = k
        end
        return last
    end;

    select = function (self, name)
        local w = self:get(name)
        if w == nil then gge_error("No such weapon: " .. name) end
        self:primaryDisengage()
        self:secondaryDisengage()
        self.selectedName = name
        gge_print("Current weapon: " .. name)
    end;

    stepCallback = function (self, elapsed_secs, src, quat)
        local w = self:getSelected()
        if w == nil then return end
        if self.primaryEngaged then
            w:primaryStepCallback(elapsed_secs, src, quat)
        end
        if self.secondaryEngaged then
            w:secondaryStepCallback(elapsed_secs, src, quat)
        end
    end;

    primaryEngage = function (self, src, quat)
        src = src or main.camPos
        quat = quat or main.camQuat
        local w = self:getSelected()
        if w == nil then return end
        w:primaryEngage(src, quat)
        self.primaryEngaged = true
    end;
   
    primaryDisengage = function (self)
        local w = self:getSelected()
        if w == nil then return end
        if not self.primaryEngaged then return end
        w:primaryDisengage()
        self.primaryEngaged = false
    end;
   

    secondaryEngage = function (self, src, quat)
        src = src or main.camPos
        quat = quat or main.camQuat
        local w = self:getSelected()
        if w == nil then return end
        w:secondaryEngage(src, quat)
        self.secondaryEngaged = true
    end;
   
    secondaryDisengage = function (self)
        local w = self:getSelected()
        if w == nil then return end
        if not self.secondaryEngaged then return end
        w:secondaryDisengage()
        self.secondaryEngaged = false
    end;
   
}

-- Push things around
WeaponEffectManager:set("Prod", {
    accelFast = 30;
    accelSlow = 3;

    stepCallbackAux = function (self, elapsed_secs, src, quat, accel)
        local dir = quat * V_FORWARDS
        local ray = 8000 * dir
        local dist, body = gge_physics_cast(src, ray, true, 0)
        if dist~= nil then
            local pos = src + dist * ray
            body:impulse(elapsed_secs * accel * body.mass * dir, pos)
        end
    end;

    primaryEngage = function (self, src, quat)
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        self:stepCallbackAux(elapsed_secs, src, quat, self.accelSlow)
    end;
    primaryDisengage = function (self)
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
        self:stepCallbackAux(elapsed_secs, src, quat, self.accelFast)
    end;
    secondaryDisengage = function (self)
    end;
})


function directed_ray(p, q)
    local d,b,n,m = gge_physics_cast(p, q * (8000 * V_FORWARDS), true, 0)
    if d == nil then return nil end
    return d * 8000, b, n, m
end

function cam_ray()
    return directed_ray(main.camPos, main.camQuat)
end

function pick_pos(p, q, bias)
    p = p or main.camPos
    q = q or main.camQuat
    local dist,_,normal = directed_ray(p, q)
    if dist == nil then return nil end
    local r = p + q * (dist*V_FORWARDS)
    if bias then r = r + bias * normal end
    return r
end

function pick_obj()
    local _, body = directed_ray(main.camPos, main.camQuat)
    if body == nil then return nil end
    return body.owner
end

-- Create particles
WeaponFlame = {
    class = `/common/particles/Flame`;

    makeFlame = function (self, size, src, quat)
        local width = size
        local height = size * 1.5
        local pos = pick_pos(src, quat, width/4)
        if pos == nil then return end
        pos = pos - vector3(0,0,-width/4)
        create_flame_raw(pos, width, height, self.class, 60)
    end;

    primaryEngage = function (self, src, quat)
        self:makeFlame(0.2 + 0.3 * math.random(), src, quat)
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    primaryDisengage = function (self)
    end;

    secondaryEngage = function (self, src, quat)
        self:makeFlame(1 + 1 * math.random(), src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    secondaryDisengage = function (self)
    end;
}
WeaponEffectManager:set("Flame", WeaponFlame)


-- Create objects
WeaponCreate = {
    class = `/games/assets/vehicles/Scarman`;
    rotation = 'ALIGNED';  -- Or 'FIXED' or 'RANDOM'
    fireSpeed = 40;
    fireSpin = 0;
	lastPlaced = nil;
	additionalOffset = 0;
	
    getRotation = function (self, q)
        if self.rotation == 'ALIGNED' then
            local no_z = vec(1, 1, 0) * (q * V_FORWARDS)
            return quat(V_FORWARDS, no_z)
        elseif self.rotation == 'RANDOM' then
            return quat(math.random(360), V_UP)
        elseif self.rotation == 'FIXED' then
            return Q_ID
        else
            gge_error('Unknown rotation value "' .. self.rotation .. '"')
        end
    end;

    primaryEngage = function (self, src, q)

        local cl = gge_class_get(self.class)
        local height = cl.placementZOffset or 0
        local p = pick_pos(src, q)
        if p == nil then return end
        local x, y, z = unpack(p)

        local rot = self:getRotation(q)
        self.lastPlaced = object (self.class) (x,y,z+height+self.additionalOffset) {rot=rot, debugObject=true}
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    primaryDisengage = function (self)
    end;

    secondaryEngage = function (self, src, q)
        local rot = self:getRotation(q)
        local x,y,z = unpack(src)
        local o = object (self.class) (x,y,z) {rot=rot, debugObject=true}
        o:activate() -- need this so we can add the linear velocity
        if o.activated then
            -- There was not an error during activation
            o.instance.body.linearVelocity = rot * vector3(0, self.fireSpeed, 0)
            o.instance.body.angularVelocity = rot * vec(0, 0, self.fireSpin)
            o:beingFired()
        end
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    secondaryDisengage = function (self)
    end;
}
WeaponEffectManager:set("Create", WeaponCreate)


-- Delete fired / placed objects
WeaponEffectManager:set("Delete", {
    primaryEngage = function (self, src, quat)
        local dir = quat * V_FORWARDS
        local ray = 8000 * dir
        local dist, body = gge_physics_cast(src, ray, true, 0)
        if dist == nil then return end
        local o = body.owner
        if o.debugObject then
            o:destroy()
        end
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    primaryDisengage = function (self)
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    secondaryDisengage = function (self)
    end;
})


-- Pick things up and move them
WeaponGrab = {
    object = nil;
    grabDist = 0;
    localGrabPos = vec(0, 0, 0);
    lastDeviation = 0;
    accDeviation = 0;
    accDeviationMax = 10;
    pidParam1 = -100;
    pidParam2 = -20;
    pidParam3 = -1;

    -- For controlling rotation
    lastOrientationDeviation = Q_ID;
    pidOrientationParam1 = -0.3;
    pidOrientationParam2 = -0.3;

    primaryEngage = function (self, src, quat)
        local len = 8000
        local dir = quat * V_FORWARDS
        local ray = len * dir
        local dist, body = gge_physics_cast(src, ray, true, 0)
        if dist ~= nil then
            self.grabDist = dist * len
            self.object = body.owner
            self.localGrabPos = body:worldToLocal(src + dist * ray)
            self.lastDeviation = 0
            self.lastOrientationDeviatoin = Q_ID
        end
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        local obj = self.object
        if obj == nil then return end
        if not obj.activated then return end
        local body = obj.instance.body
        if body == nil then return end

        -- Use a PID loop to control position of grabbed object
        local measured_pos = body:localToWorld(self.localGrabPos)
        local target_pos = main.camPos + self.grabDist * (main.camQuat * V_FORWARDS)

        local deviation = measured_pos - target_pos
        local deviation_rate = (deviation - self.lastDeviation) / elapsed_secs
        self.lastDeviation = deviation
        local acc_deviation = self.accDeviation + deviation
        if #acc_deviation > self.accDeviationMax then
            acc_deviation =  norm(acc_deviation) * self.accDeviationMax
        end
        self.accDeviation = acc_deviation

        local acc = deviation * self.pidParam1 + deviation_rate * self.pidParam2 + acc_deviation * self.pidParam3

        body:force(acc * body.mass, measured_pos)
    end;
    primaryDisengage = function (self)
        self.object = nil
    end;

    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
        local obj = self.object
        if obj == nil then return end
        if not obj.activated then return end
        local body = obj.instance.body
        if body == nil then return end

        -- use PD loop to control orientation of grabbed object
        local target_orientation = main.camQuat
        local measured_orientation = body.worldOrientation

        local deviation = norm(measured_orientation * inv(target_orientation))
        local deviation_tensor = tensor(deviation)

        local deviation_change = (deviation * inv(self.lastOrientationDeviation))
        local deviation_rate_tensor = tensor(deviation_change) / elapsed_secs
        self.lastOrientationDeviation = deviation

        local acc = deviation_tensor * self.pidOrientationParam1 + deviation_rate_tensor * self.pidOrientationParam2

        body:torque(acc * body.inertia)
        --body.angularVelocity = V_ZERO
        --body.worldOrientation = slerp(body.worldOrientation, main.camQuat, 0.01)
    end;
    secondaryDisengage = function (self)
    end;
}

WeaponEffectManager:set("Grab", WeaponGrab)


WeaponEffectManager:select("Grab")
