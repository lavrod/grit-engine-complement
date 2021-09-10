-- (c) Alexey "Razzeeyy" Shmakov 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

MoveSpinClass = extends (ColClass) {
    spinSpeed = 45; -- in degrees
    spinAxis = V_UP;

    moveSpeed = 1; -- in meters per second, I guess...
    moveAxis = V_UP;
    moveBothWays = false; -- if true the object will move back and forth at specified vector, usefull for moving platforms
    moveBothWaysLength = 5; -- the length object should travel before changing to opposite moving velocity
}

function MoveSpinClass.activate(self, instance)
    ColClass.activate(self, instance)
    
    instance.body.angularVelocity = math.rad(self.spinSpeed) * self.spinAxis
    
    instance.body.linearVelocity = self.moveSpeed * self.moveAxis
    if self.moveBothWays and self.moveBothWaysLength ~= 0 then
        self.needsStepCallbacks = true
        instance.startPos = instance.body.worldPosition
        instance.moveAxis = self.moveAxis
    end

    if instance.body.mass ~= 0 then -- converting to static object if not already
        instance.body.mass = 0
    end
end

function MoveSpinClass.deactivate(self)
    self.needsStepCallbacks = false
    ColClass.deactivate(self)
end

function MoveSpinClass.stepCallback(self, elapsed)
    local instance = self.instance
    local body = instance.body
    if #(instance.startPos - body.worldPosition) > self.moveBothWaysLength then
        instance.startPos = instance.body.worldPosition
        instance.moveAxis = -instance.moveAxis
        body.linearVelocity = self.moveSpeed * instance.moveAxis
    end
end
