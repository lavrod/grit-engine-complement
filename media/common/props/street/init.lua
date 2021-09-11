-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

gge_include `classes.lua`

material `Cone` {
    glossMask = .5,
    diffuseMap = `TrafficCone.dds`,
}

material `barrier3` {
    glossMask = .5,
    diffuseMap = `barrier3.jpg`,
}

material `barrierS` {
    glossMask = .5,
    diffuseMap = `barrierS.jpg`,
}

-- TODO: glossFromSpecularAlpha no-longer exists.  Texture needs updating?
material `RoadBarrel` {
    diffuseMap = `RoadBarrel.png`,
    --glossFromSpecularAlpha = true,
    glossMask = 30,
}

class `Barrier1` (ColClass) {
    renderingDistance = 100,
    castShadows = true,
    placementZOffset = 0.5
}


-- jost, fix your shit!
material `DEFAULT` { }

class `floodlight` (ColClass) {
    renderingDistance = 250;
    lights = {
        {
            pos=vector3(0.0,0.016,1.163), diff=5*vector3(0.89,1,1),
            range=10, iangle=20, oangle=32.5, aim=quat(-30,V_RIGHT)
        };
    };
}

local streetlamp_light_colour=vector3(1,0.81,0.45)
material `Lamp` {
    diffuseMap = `Lamp.dds`,
}
material `LampBulb` {
    diffuseMap = `Lamp.dds`,
    emissiveMap = `Lamp.dds`,
    emissiveMask = 10 * streetlamp_light_colour,
    additionalLighting = true,
}

local lamp_light =  {   
    emissiveMaterials=`LampBulb`;
    pos=vector3(0,-1.7,4.85); aim=quat(-110,V_RIGHT);
    range=20; diff=3*streetlamp_light_colour; spec=3*streetlamp_light_colour;
    coronaColour=streetlamp_light_colour;
    coronaSize = 4;
    iangle=40; oangle=75;
    ciangle=50; coangle=90;
    onTime="19:01:00"; offTime="07:01:00"; timeOnOffRandomness="00:01:00";
}
class `Lamp` (ColClass) {
    castShadows=true; renderingDistance=200; placementZOffset=3;
    health=10000; impulseDamageThreshold=10000;
    lights={ lamp_light };
}

local flickering_lamp_light = extends (lamp_light) { flickering=true; }
class `LampFlickering` (ColClass) {
    gfxMesh=`Lamp.mesh`; colMesh=`Lamp.gcol`;
    castShadows=true; renderingDistance=200; placementZOffset=3;
    health=10000; impulseDamageThreshold=10000;
    lights={ flickering_lamp_light };
}

function reset_street_lamps()
    foreach(gge_object_all_activated(), function(o)
        if o.className == `/common/props/street/Lamp` or o.className == `/common/props/street/LampFlickering` then
            local l = o.instance.lights[1];
            light_from_table(o.instance.lights[1], lamp_light)
        end
    end)
end


class `RoadBarrel` (ColClass) { castShadows=true, renderingDistance=150, placementZOffset=0.38, placementRandomRotation=true }
