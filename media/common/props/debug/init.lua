-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `crates/init.lua`

include `classes.lua`

material `Black` {
    diffuseMask = vec(.01,.01,.01),
}
class `CannonBall` (ColClass) {
    renderingDistance = 100,
    castShadows = true,
    placementZOffset = 0.15,
    lights = {
        {
            range = 1,
            diff = vector3(0.75,0,0),
            spec = vector3(0.75,0,0),
            coronaColour = V_ZERO,
        },
    },
}

material `JengaBrick` {
    diffuseMap = `JengaBrick.dds`,
}

class `JengaStack` (extends(ProcPileClass) {
    spawnObjects = function(self, spawn)
        for level=0,self.height do
            for b=-1,1 do
                local pos = vector3(0, b * 0.3, (.5+level)*.24)
                local rot = level%2==0 and Q_FORWARDS or Q_RIGHT
                spawn(`JengaBrick`, rot*pos, {rot=rot})
            end
        end
    end;
}) {
    renderingDistance = 60;
    height = 10;
}

