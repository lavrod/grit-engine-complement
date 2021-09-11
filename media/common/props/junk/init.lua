-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

material `PizzaBox` {
    diffuseMap = `PizzaBox.dds`,
}

-- TODO: make a proper pbr map for these

material `TrashCanShite` {
    diffuseMap=`TrashCanShite_d.dds`,
    -- specularFromDiffuseAlpha=true,
}

-- TODO: Needs to clamp the diffuseMap
material `WineBottle` {

    diffuseMap = `WineBottle_d.dds`,
    -- specularFromDiffuseAlpha=true,
}

material `Money` { diffuseMap = `Money_d.dds` }
material `Brick` { diffuseMask = srgb(128,0,0) }

class `TrashCanShiteBody` (ColClass) {
    renderingDistance = 90,
    castShadows = true,
    placementZOffset = 0.36,
    placementRandomRotation = true
}
class `TrashCanShiteLid` (ColClass) {
    renderingDistance = 90,
    castShadows = true,
    placementZOffset = 0.05, 
    placementRandomRotation = true
}

gge_include `classes.lua`

pile `TrashCanShite` {
    renderingDistance = 100;
    object `TrashCanShiteBody` (0,0,0.3617) { };
    object `TrashCanShiteLid` (0,0,0.7425) { };
}

class `Money` (ColClass) {
    renderingDistance = 50.0;
    castShadows = false;
    placementZOffset = 0.014999999664723873;
    placementRandomRotation = true;
    lights={
        { range=.3, diff=7 * vec(.65, 1, .4) }
    }
}

class `BrickWall` (ProcPileClass) {
    spawnObjects = function(self, spawn)
        local brick_class = self.brickClass
        local x_min = self.xMin
        local x_max = self.xMax
        local height = self.height
        for z=0,height-1 do
            local x_min_, x_max_ = x_min, x_max
            if z % 2 == 1 then
                x_min_, x_max_ =x_min+1, x_max-1
            end
            for x=x_min_,x_max_,2 do
                local pos = vector3(.105*x, 0, 0.06*z+gge_class_get(brick_class).placementZOffset)
                spawn(brick_class, pos, {rot=Q_EAST})
            end
        end
    end,
    renderingDistance = 110,
    xMin = -16,
    xMax = 16,
    height = 30,
    brickClass = `Brick`,
}
