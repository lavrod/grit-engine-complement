
unload_icons = false

particle `LampIcon` {
    map = `icons/lamp_icon.png`;
    frames = { 0,0, 128, 128, }; frame = 0;
    behaviour = function(particle, elapsed)
        if unload_icons then
            return false
        end
    end;
}       

function emit_lamp_icon (pos, colour, size)
    pos = pos or pick_pos(nil, true)
    if pos == nil then return end
    colour = colour or vector3(3,3,3)

    size = size or 1
    gge_gfx_particle_emit(`LampIcon`, pos, {
        emissive = colour;
        diffuse = vec(0, 0, 0);
        dimensions = size*V_ID;
    })
end 

-- for k, v in ipairs(object_all()) do
    -- if v and not v.destroyed and v.instance and v.instance.audio then
        -- qw = v
    -- end
-- end
