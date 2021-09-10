-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

gge_include `gas.lua`
gge_include `debris.lua`

gge_include `fire.lua`
gge_include `explosion.lua`
gge_include `smoke.lua`

function pick_explosion(sz)
    local pos = pick_pos(0.5, true)
    if pos == nil then return end
    explosion(pos, sz)
end

--[[
common_binds:bind("-", function() cast_flame() end, null, true)
common_binds:bind("C+-", function() cast_flame2() end, null, true)
common_binds:bind("=", function() pick_explosion() end, nil, true)
common_binds:bind("C+=", function() pick_explosion(15) end, nil, true)
common_binds:bind("A+=", function() pick_explosion(3) end, nil, true)
common_binds:bind("C+F2",function() puff_textured() end, nil, true)
]]
