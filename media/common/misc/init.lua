-- (c) Simon Kolciter 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

ClockHandsClass = {

    timeOffset = 0; -- for clocks that are not accurately 'set'
    renderingDistance = 400;

    init = function (self)
        self:addDiskResource(self.secondHandMesh)
        self:addDiskResource(self.minuteHandMesh)
        self:addDiskResource(self.hourHandMesh)
    end;
            
    activate = function (self,instance)

        instance.gfx = gfx_body_make()
        instance.gfx.localPosition = self.spawnPos
        instance.gfx.localOrientation = self.rot or quat(1,0,0,0)
        
        local class_name = self.class.name
        instance.secondHand = instance.gfx:makeChild(self.secondHandMesh)
        instance.minuteHand = instance.gfx:makeChild(self.minuteHandMesh)
        instance.hourHand   = instance.gfx:makeChild(self.hourHandMesh)

        instance.secondHand.castShadows = self.castShadows == true
        instance.minuteHand.castShadows = self.castShadows == true
        instance.hourHand.castShadows = self.castShadows == true        
        
        instance.secondHand.localScale = self.secondHandScale
        instance.minuteHand.localScale = self.minuteHandScale
        instance.hourHand.localScale = self.hourHandScale
        
        instance.envCallback = function () self:updateHands() end
        env:addClockCallback(instance.envCallback)
    end;
    
    deactivate = function (self)
        env:removeClockCallback(self.instance.envCallback)
    end;
    
    -- rotates the hands according to current time
    -- hands point to Z by default and face Y

    updateHands = function (self)
    
        local inst = self.instance
        
        local current = math.mod(env.secondsSinceMidnight+self.timeOffset, 60*60*12)
        
        local secAngle = 360*(math.mod(current,60)/60)
        inst.secondHand.localOrientation = quat(secAngle,V_BACKWARDS)
        
        local minuteAngle = 360*(math.mod(current/60,60)/60)
        inst.minuteHand.localOrientation = quat(minuteAngle,V_BACKWARDS)
        
        local hourAngle = 360*(math.mod(current/60/60,12)/12)
        inst.hourHand.localOrientation = quat(hourAngle,V_BACKWARDS)
    end;
}   

class `ClockHands` (ClockHandsClass)
{
    secondHandMesh = `ClockHand.mesh`,
    minuteHandMesh = `ClockHand.mesh`,
    hourHandMesh = `ClockHand.mesh`,

    hourHandScale = vector3(1,1,0.55),
    minuteHandScale = vector3(0.95,0.95,0.95),
    secondHandScale = vector3(0.5,0.5,1),
}   

object `ClockHands` (0, 5, 12.5) {name="ClockNorth"}
object `ClockHands` (-5, 0, 12.5) {name="ClockWest",rot=quat(90,V_UP)}
object `ClockHands` (0, -5, 12.5) {name="ClockSouth",rot=quat(180,V_UP)}
object `ClockHands` (5, 0, 12.5) {name="ClockEast",rot=quat(270,V_UP)}

env.clockRate = 1
