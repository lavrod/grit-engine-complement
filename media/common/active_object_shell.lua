ActiveObjectShell = extends (ColClass) {

    renderingDistance = 50;
    additionalState = "DefaultClassState";

    init = function (self)
        ColClass.init(self)
        gge_print("Creating "..self.name.." of class "..self.className.." with additionalState="..self.additionalState)
    end;

    activate = function (self, instance)
        -- initialise the super class state (basic physics)
        if ColClass.activate (self, instance) then
                -- if superclass returns true, skipping activation (this can happen if player is too close to spawn point)
                return true
        end

        gge_print("Activating "..self.name)

        -- initialise any state for streamed in object here (this state does not persist when streamed out)
        instance.timeSinceActivation = 0

        -- set this if you want a drivable vehicle, e.g. car, hovercraft, etc
        instance.canDrive = true

        -- request that stepCallback be called every physics tick
        self.needsStepCallbacks = true

    end;

    stepCallback = function (self, elapsed)

        -- This following line means the stepCallback can only be called on an activated object
        local instance = self.instance

        -- this was initialised by ColClass.activate, cache it in a local var for performance
        local body = instance.body

        -- keep track of the total time that has occured
        instance.timeSinceActivation = instance.timeSinceActivation + elapsed

        -- after every half second, apply a force
        if instance.timeSinceActivation >= 0.5 then

            -- reset the timer
            instance.timeSinceActivation = 0


            -- apply an impulsep
            local impulse_vector = body.mass * random_vector3_sphere()
            local apply_pos = body.worldPosition + 0.05*random_vector3_sphere()

            -- use :force for continuous forces (thrusts), measured in newtons, applied every frame
            -- use :impulse for instantaneous changes in momentum (shocks)
            body:impulse(impulse_vector, apply_pos)

        end

    end;

    deactivate = function (self)
        local instance = self.instance
        gge_print("Deactivating "..self.name)

        -- request that stepCallback be called every physics tick
        self.needsStepCallbacks = false

        -- clean up any local state here
        -- (only things like additional physics objects, graphics objects, callbacks with env system, etc)

        -- ColClass cleans up everything that ColClass.activate added
        return ColClass.deactivate (self)

    end;

    -- these are needed if you set instance.canDrive = true
    setPush = function (self, v)
        gge_print(self.name..":  push set to "..tostring(v))
    end;
    setPull = function (self, v)
        gge_print(self.name..":  pull set to "..tostring(v))
    end;
    setShouldSteerLeft = function (self, v)
        gge_print(self.name..":  steer left set to "..tostring(v))
    end;
    setShouldSteerRight = function (self, v)
        gge_print(self.name..":  steer right set to "..tostring(v))
    end;
    setHandbrake = function (self, v)
        gge_print(self.name..":  handbrake right set to "..tostring(v))
    end;
    setSpecialUp = function (self, v)
        gge_print(self.name..":  special up set to "..tostring(v))
    end;
    setSpecialDown = function (self, v)
        gge_print(self.name..":  special down set to "..tostring(v))
    end;
    setSpecialLeft = function (self, v)
        gge_print(self.name..":  special left set to "..tostring(v))
    end;
    setSpecialRight = function (self, v)
        gge_print(self.name..":  special right set to "..tostring(v))
    end;
    setAltUp = function (self, v)
        gge_print(self.name..":  alt up set to "..tostring(v))
    end;
    setAltDown = function (self, v)
        gge_print(self.name..":  alt down set to "..tostring(v))
    end;
    setAltLeft = function (self, v)
        gge_print(self.name..":  alt left set to "..tostring(v))
    end;
    setAltRight = function (self, v)
        gge_print(self.name..":  alt right set to "..tostring(v))
    end;
    special = function (self)
        gge_print(self.name..":  special pressed")
    end;

}

class `TestObjectShell1` (ActiveObjectShell) {
    gfxMesh=`/common/props/junk/Brick.mesh`;
    colMesh=`/common/props/junk/Brick.gcol`;
}

class `TestObjectShell2` (ActiveObjectShell) {
    gfxMesh=`/common/props/junk/Brick.mesh`;
    colMesh=`/common/props/junk/Brick.gcol`;
    additionalState = "TestObjectShell2 state";
}

object `TestObjectShell1` (1,0,1) {
    name="Shell1:obj1";
}

object `TestObjectShell1` (2,0,1) {
    name="Shell1:obj2";
    additionalState = "Object state overridden";
}

object `TestObjectShell2` (3,0,1) {
    name="Shell2:obj1";
}

object `TestObjectShell2` (4,0,1) {
    name="Shell2:obj2";
    additionalState = "Object state overridden again";
}
