-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

--[[
dynamics: restitution, friction, tyre_grip, all_terrain_tyre_grip, wet_factor
graphics: skidmarks, sparks, footprints, foot dust, wheelprints, skid marks, wheel dust, wheelspin smoke, bullet_dust
props: list of various props with flags and whatever
character_controller: camera_collision, max_incline, can_run, hard fall, simulating stairs with a slope (don't tilt player),
sound: footsteps, bangs, scrapes, bullet_ricochets,
gameplay: bullets_penetrate, flammability,
]]--

-- Interaction groups -- define master materials that have friction and restitution
FrictionlessGroup = 0
StickyGroup = 1
SmoothHardGroup = 2
SmoothSoftGroup = 3
RoughGroup = 4 
DeformGroup = 5
SlipperyGroup = 6

local n_a = 0.0 -- only half the square needs to be populated

local friction = { 0.0, n_a, n_a, n_a, n_a, n_a, n_a,
                   0.0, 1.0, n_a, n_a, n_a, n_a, n_a,
                   0.0, 1.0, 0.3, n_a, n_a, n_a, n_a,
                   0.0, 1.0, 0.3, 0.2, n_a, n_a, n_a,
                   0.0, 1.0, 0.5, 0.6, 1.0, n_a, n_a,
                   0.0, 0.3, 0.3, 0.2, 0.3, 0.3, n_a,
                   0.0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };

local restitution = { 0.0, n_a, n_a, n_a, n_a, n_a, n_a,
                      0.0, 0.2, n_a, n_a, n_a, n_a, n_a,
                      0.0, 0.2, 0.5, n_a, n_a, n_a, n_a,
                      0.0, 0.1, 0.3, 0.0, n_a, n_a, n_a,
                      0.0, 0.1, 0.3, 0.0, 0.0, n_a, n_a,
                      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, n_a,
                      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };

physics_set_interaction_groups(friction, restitution)


-- The user can add more of these if they want
procedural_batch `PinkFlowers` {
    mesh = `../veg/PinkFlowers.mesh`,
    density = 0.01,
    minSlope = 0, maxSlope = 20,
    rotate = true,
    seed = 1232134,
    tangents = true,
    triangles = 15000,
    castShadows = true,
}

procedural_batch `YellowFlowers` {
    mesh = `../veg/YellowFlowers.mesh`,
    density = 0.01,
    minSlope = 0, maxSlope = 20,
    rotate = true,
    seed = 123412,
    tangents = true,
    triangles = 15000,
    castShadows = true,
}

procedural_batch `GrassMesh` {
    mesh = `../veg/grass_patch_small.mesh`,
    density = .1,
    minSlope = 0, maxSlope = 50,
    rotate = true,
    alignSlope = true,
    noZ = true,
    renderingDistance = 30,
    castShadows = false,
    triangles = 15000,
}

procedural_batch `TropPlant1` {
    mesh = `../veg/TropPlant1.mesh`,
    density = 0.01,
    minSlope = 0, maxSlope = 20,
    rotate = true,
    seed = 483274,
    renderingDistance = 70,
    tangents = true,
    castShadows = true,
    triangles = 20000,
}
procedural_batch `TinyPalmT` {
    mesh = `../veg/TinyPalmT.mesh`,
    density = 0.01,
    minSlope = 0, maxSlope = 20,
    rotate = true,
    seed = 483265,
    renderingDistance = 70,
    tangents = true,
    castShadows = true,
    triangles = 20000,
}


physics:setDefaultMaterial {
    interactionGroup = FrictionlessGroup,
    roadTyreFriction = 0,
    offRoadTyreFriction = 0,
    flammable = 0.5,
}

-- The user can add more of these if they want
physical_material `Frictionless` {
}


-- There are two kinds of particle tyre interactions
-- * tyreSmoke -- when you brake suddenly and the tyres get very hot, producing smoke
-- * tyreDust -- when you are driving normally and the rolling alone is kicking up dust

-- the tyre friction values should be just below one, consider it a debilitating factor for poor grip surfaces

local kicked_up_mud = {
    behaviour = function (time, interval, cp, temp, fw, forward_speed)
        local speed = math.abs(forward_speed);
        time = time + interval * speed
        if time > 0 then
            time = time - 0.4
            if temp <= 0 then return time end
            local vel = random_vector3_box(vector3(-0.2,-0.2,0.6), vector3(0.2,0.2,0.7))
            emit_debris(cp + 0.1*V_UP, vel, math.random(16,19), 0.4) --originaly 12 - 19 frame
        end
        return time
    end;
}

local hot_tyre_smoke = {
    behaviour = function (time, interval, cp, temp, fw, forward_speed)
        local speed = math.abs(forward_speed);
        time = time + interval * speed
        if time > 0 then
            time = time - 0.4
            if temp <= 0 then return time end
            local vel = random_vector3_box(vector3(-0.2,-0.2,0.6), vector3(0.2,0.2,0.7))
            emit_textured_smoke(cp + 0.1*V_UP,
                   vel,
                   0.5,
                   1.1,
                   --qty * (1-math.random()/3),
                   0.01*vector3(1,1,1),
                   0.3
            )
        end
        return time
    end;
}

-- if it's raining, the dust should stop
function dust (colour) 
    return {
        behaviour = function (time, interval, cp, temp, fw, forward_speed)
            local speed = math.abs(forward_speed);
            time = time + interval * speed
            if time > 0 then
                time = time - 0.5
                local affray = clamp(speed/20, 0, 1)
                local sz = 0.4 + affray/2
                emit_textured_smoke(cp,
                           vector3(0,0,0),
                           sz, sz+1,
                           colour,
                           1.5 - affray
                )
            end
            return time
        end
    }
end
local brown_dust = dust(vector3(102,74,47)/255)
local grey_dust = dust(vector3(75,75,75)/255)

physical_material `Rubber` {
    interactionGroup = StickyGroup,
    roadTyreFriction = 1,
    offRoadTyreFriction = 0.8,
    tyreSmoke = hot_tyre_smoke,
    flammable = 1,
}

physical_material `Metal` {
    interactionGroup = SmoothSoftGroup,
    roadTyreFriction = 0.8,
    offRoadTyreFriction = 0.6,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.25,
}

physical_material `Plastic` {
    interactionGroup = StickyGroup,
    roadTyreFriction = 0.7,
    offRoadTyreFriction = 0.6,
    tyreSmoke = hot_tyre_smoke,
    flammable = 1,
}

physical_material `PolishedWood` {
    interactionGroup = SmoothHardGroup,
    roadTyreFriction = 0.6,
    offRoadTyreFriction = 0.6,
    tyreSmoke = hot_tyre_smoke,
    flammable = 1,
}

physical_material `PolishedStone` {
    interactionGroup = SmoothHardGroup,
    roadTyreFriction = 0.8,
    offRoadTyreFriction = 0.6,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.25,
}

physical_material `Wood` {
    interactionGroup = RoughGroup,
    roadTyreFriction = 0.7,
    offRoadTyreFriction = 0.8,
    flammable = 1,
}

physical_material `Stone` {
    interactionGroup = RoughGroup,
    roadTyreFriction = 1.0,
    offRoadTyreFriction = 0.8,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.5,
}

physical_material `Mud` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.3333,
    offRoadTyreFriction = 1,
    --tyreDust = kicked_up_mud,
    tyreDust = brown_dust,
    flammable = 1,
}

physical_material `Gravel` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.5,
    offRoadTyreFriction = 1,
    tyreDust = grey_dust,
    flammable = 0.5,
}

physical_material `Sand` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.3333,
    offRoadTyreFriction = 1,
    tyreDust = brown_dust,
    flammable = 0.5,
}

physical_material `GrassPlain` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.5,
    offRoadTyreFriction = 1,
    tyreDust = kicked_up_mud,
    flammable = 1,
}

physical_material `Grass` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.5,
    offRoadTyreFriction = 1,
    proceduralBatches = { `GrassMesh`,  `TinyPalmT`, `PinkFlowers`, `YellowFlowers` },
    tyreSmoke = kicked_up_mud,
    tyreDust = kicked_up_mud,
    flammable = 1,
}

physical_material `Grassbush` {
    interactionGroup = DeformGroup,
    roadTyreFriction = 0.5,
    offRoadTyreFriction = 0.9,
    proceduralBatches = { `GrassMesh`,  `TinyPalmT`, `TropPlant1`, `PinkFlowers`, `YellowFlowers` },
    tyreSmoke = kicked_up_mud,
    flammable = 1,
}

physical_material `StoneTest` {
    interactionGroup = RoughGroup,
    roadTyreFriction = 1,
    offRoadTyreFriction = 0.8,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.5,
}

physical_material `Asphalt` {
    interactionGroup = RoughGroup,
    roadTyreFriction = 1,
    offRoadTyreFriction = 0.8,
    tyreSmoke = hot_tyre_smoke,
    flammable = 0.5,
}

