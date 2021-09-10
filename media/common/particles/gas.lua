-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- only first 2 params are mandatory
function particle_grid_frames (w, h, sx, sy, ex, ey)

    sx = sx or 0
    sy = sy or 0
    ex = ex or 0
    ey = ey or 0
    

    local r = { }

    local counter = 1
    for y = sy*h, ey*h, h do
        for x = sx*w, ex*w, w do
            r[counter+0] = x
            r[counter+1] = y
            r[counter+2] = w 
            r[counter+3] = h 
            counter = counter + 4
        end 
    end

    return r

end


function particle_behaviour_alpha_gas_ball_emissive (tab, elapsed)
    tab.age = tab.age + elapsed/tab.life
    if tab.age > 1 then
        if tab.light then tab.light:destroy() end
        return false
    end
    if tab.frameRate then tab.frame = tab.frame + tab.frameRate * elapsed end
    if tab.velocity then
        local vel = tab.velocity
        if tab.convectionCurve then vel = vel + tab.convectionCurve[tab.age] end
        tab.position = tab.position + vel * elapsed
        tab.velocity = math.pow(0.01, elapsed) * tab.velocity
    end

    tab.volume = lerp(tab.initialVolume, tab.maxVolume, tab.age)
    local radius = math.pow(tab.volume/math.pi*3/4, 1/3) -- sphere: V = 4/3πr³
    tab.dimensions = (2*radius) * vector3(1,1,0.5)

    local alpha = tab.alpha or 1
    if tab.alphaCurve then
        alpha = tab.alphaCurve[tab.age]
        tab.alpha = alpha
    end
    tab.alpha = tab.alpha / tab.initialVolume
    if tab.colourCurve then
        local light_colour = tab.colourCurve[tab.age]
        tab.emissive = light_colour * alpha

        if tab.light then
            -- if the gas ball has a light attached to it then keep it in sync with the particle's emissive
            tab.light.diffuseColour = light_colour
            tab.light.specularColour = light_colour
        end
    else
        -- colour is constant, but attenuate it with alpha
        tab.initialEmissive = tab.initialEmissive or tab.emissive
        tab.emissive = tab.initialEmissive * alpha
    end
end

function particle_behaviour_alpha_gas_ball_diffuse (tab, elapsed)
    tab.age = tab.age + elapsed/tab.life
    if tab.age > 1 then
        return false
    end
    if tab.frameRate then tab.frame = tab.frame + tab.frameRate * elapsed end
    if tab.velocity then
        local vel = tab.velocity
        if tab.convectionCurve then vel = vel + tab.convectionCurve[tab.age] end
        tab.position = tab.position + vel * elapsed
        tab.velocity = math.pow(0.01, elapsed) * tab.velocity
    end

    tab.volume = lerp(tab.initialVolume, tab.maxVolume, tab.age)
    local radius = math.pow(tab.volume/math.pi*3/4, 1/3) -- sphere: V = 4/3πr³
    tab.dimensions = (2*radius) * vector3(1,1,0.5)

    local alpha = tab.alpha or 1
    if tab.alphaCurve then
        alpha = tab.alphaCurve[tab.age]
        tab.alpha = alpha
    end
    if tab.colourCurve then
        local light_colour = tab.colourCurve[tab.age]
        tab.diffuse = light_colour * alpha
    else
        -- colour is constant, but attenuate it with alpha
        tab.initialDiffuse = tab.initialDiffuse or tab.diffuse
        tab.diffuse = tab.initialDiffuse * alpha
    end
end

particle_convection_curve = PlotV3 {
    [0] = vector3(0,0,.25);
    [0.25] = vector3(0,0,.25);
    [1] = vector3(0,0,0);
}


particle `DebugMarker` {
    map = `GenericParticleSheet.dds`;
    frames = { 960,960, 64, 64, }; frame = 0;
    behaviour = function(particle, elapsed)
        particle.age = particle.age + elapsed
        if particle.age > particle.life then
            return false
        end
    end;
}       

function emit_debug_marker (pos, colour, life, size)
    pos = pos or pick_pos()
    if pos == nil then return end
    colour = colour or vector3(1,0,0)
    life = life or 10
    size = size or 1
    gfx_particle_emit(`DebugMarker`, pos, {
        life = life;
        emissive = colour;
        diffuse = vec(0, 0, 0);
        age = 0;
        dimensions = size*vector3(1,1,1);
    })
end 
    



--[[
function particle_behaviour_standard (tab, elapsed)
    tab.life = tab.life - elapsed
    if tab.life <= 0 then return false end
    tab.position = tab.position + tab.velocity * elapsed
    if tab.accel then tab.velocity = tab.velocity + tab.accel * elapsed end
    if tab.angleRate then tab.angle = tab.angle + tab.angleRate * elapsed end
    if tab.widthRate then tab.width = tab.width * math.pow(tab.widthRate, elapsed) end
    if tab.heightRate then tab.height = tab.height * math.pow(tab.heightRate, elapsed) end
    if tab.colourRate then tab.colour = tab.colour + tab.colourRate * elapsed end
    if tab.alphaRate then tab.alpha = tab.alpha + tab.alphaRate * elapsed end
    if tab.frameRate then tab.frame = tab.frame + tab.frameRate * elapsed end
end

particle `Explosion3` {
    map = `GenericParticleSheet.dds`; blending = "ALPHA";
    frames = {
                  0,384,   128, 128,
                128,384,   128, 128,
                256,384,   128, 128,
                384,384,   128, 128,
                512,384,   128, 128,
                640,384,   128, 128,
                768,384,   128, 128,
                896,384,   128, 128,
                  0,512,   128, 128,
                128,512,   128, 128,
                256,512,   128, 128,
                384,512,   128, 128,
                512,512,   128, 128,
             },
    frame = 0;
    frameRate = 30;
    life = 13/30;
    width = 1;
    height = 1;
    widthRate = 1.5;
    heightRate = 1.5;
    behaviour = particle_behaviour_standard;
}   

particle `Explosion4` {
    map = `GenericParticleSheet.dds`;
    blending = "ADD";
    frames = {
                  0,256,   128, 128,
                128,256,   128, 128,
                256,256,   128, 128,
                384,256,   128, 128,
                512,256,   128, 128,
                640,256,   128, 128,
                768,256,   128, 128,
                896,256,   128, 128,
             },
    frame = 0;
    frameRate = 30;
    life = 8/30;
    width = 1;
    height = 1;
    widthRate = 1.5;
    heightRate = 1.5;
    behaviour = particle_behaviour_standard;
}   
]]--

