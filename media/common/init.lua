-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `paint_shader.lua`
include `heightmap_texture_blend_shader.lua`

include `map_classes.lua`
include `sound_emitter_class.lua`
include `MoveSpinClass.lua`

include `game_modes/init.lua`

include `fonts/init.lua`
include `sounds/init.lua`

include `hud/init.lua`
include `gui/init.lua`

include `particles/init.lua`

include `pmat/init.lua`

include `mat/init.lua`

include `weapons/init.lua`

include `decals/init.lua`

include `carcols.lua`

include `props/init.lua`
include `veg/init.lua`
include `ramps/init.lua`


--[=[
-- Object placement bindings...

local tab = {
--[[
    -- can be accessed through simple menu
    ["1"] = `props/nature/Log1`;
    ["2"] = `props/debug/crates/Big`;
    ["3"] = `props/junk/Brick`;
    ["4"] = `props/debug/CannonBall`;
    ["5"] = `props/bowling/Ball`;
    ["6"] = `props/nature/rock`;
    ["7"] = `props/debug/JengaBrick`;
    ["8"] = `props/street/TrafficCone`;
    ["9"] = `props/junk/WineBottle1`;
    ["0"] = `props/junk/WineBottle2`;
--]]
    ["t"] = `props/junk/Money`;
    ["y"] = `props/race_track/Tyre`;
    ["u"] = `props/junk/PizzaBox`;
    ["i"] = `props/furniture/WorkBench`;
    ["o"] = `/vehicles/Taxi`;
    ["p"] = `/vehicles/Scarman`;
    ["["] = `/vehicles/Gallardo`;
    ["]"] = `/vehicles/Focus`;
    ["m"] = `/vehicles/Bonanza`;
    ["g"] = `props/industry/OilBarrel`;
    ["b"] = `props/street/RoadBarrel`;
}

if common_binds ~= nil then common_binds:destroy() end
common_binds = InputFilter(100, `common_binds`)


for k,v in pairs(tab) do
    common_binds:bind(k, function() print(v) ; introduce_obj(v) end, nil, function() print(v) ; introduce_obj(v,true) end)
end

common_binds:bind("k", function() place(`ramps/Small`) end)
common_binds:bind("C+k", function() place(`ramps/Large`) end)
common_binds:bind("A+k", function() place(`ramps/HalfPipeSmall`) end)
common_binds:bind("C+A+k", function() place(`ramps/HalfPipeLarge`) end)

common_binds:bind(".", function() place(`veg/TropPlant1`, nil, true) end)
common_binds:bind("C+.", function() place(`veg/GrassTuft1`, nil, true) end)
common_binds:bind("A+.", function() place(`veg/TinyPalmT`, nil, true) end)
common_binds:bind("C+A+.", function() place(`veg/GrassMesh`, nil, true) end)

common_binds:bind(",", function() place(`veg/Tree_aelm`) end)
common_binds:bind("C+,", function() place(`veg/prxtree`) end)


common_binds:bind("j", function() place(`props/junk/TrashCanShite`) end)
common_binds:bind("C+j", function() place(`props/street/Lamp`) end)

]=]
