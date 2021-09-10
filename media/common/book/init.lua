new_class `Turret` {

    renderingDistance = 100;
    rotateSpeedRpm = 30;
    initialBarrelAngle = 0;
    
    init = function (self)
        print("Initialising " + self)
        self:addDiskResource(`Base.gcol`)
        self:addDiskResource(`Base.mesh`)
        self:addDiskResource(`Barrel.mesh`)
    end;

    destroy = function (self)
        print("Destroying " + self)
    end;

    activate = function (self, instance)
        print("Activating " + self)
        self.needsStepCallbacks = true
        instance.barrelAngle = self.initialBarrelAngle
        instance.gfxBase = gfx_body_make(`Base.mesh`)
        instance.gfxBarrel = gfx_body_make(`Barrel.mesh`)
        --1.2 z offset
        --3 degrees angle up
        instance.physicsBase = physics_body_make(`Base.gcol`)
        instance.gfxLight = gfx_light_make()
    end;

    deactivate = function (self)
        print("Deactivating " + self)
        self.needsStepCallbacks = false
    end;

    stepCallback = function (self, elapsed)
        -- Rotate the barrel
        local instance = self.instance
        local degrees_per_sec = self.rotateSpeedRpm * 360 / 60
        local degrees_per_step = degrees_per_sec * elapsed
        instance.barrelAngle = (instance.barrelAngle + degrees_per_step) % 360
        instance.gfxBarrel.localOrientation = quat(vec(0, 0, 1), instance.barrelAngle)
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
