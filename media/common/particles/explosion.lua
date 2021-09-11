-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

do
    local colour_base = 4*vector3(1,1,1)
    local colour_curve = gge_PlotV3 {
        [0]    = colour_base;
        [0.05] = colour_base;
        [0.15] = colour_base*vector3(1,0.8,0.8);
        [0.35] = 0.8*colour_base*vector3(1,0.6,0.6);
        [1]    = 0.1*colour_base*vector3(1,0.4,0.3);
    }
    local alpha_curve = gge_Plot {
        [0] = 1;
        [0.3] = 0.3;
        [0.5] = 0.2;
        [1] = 0;
    }
    particle `Explosion` {
        map = `GenericParticleSheet.dds`;
        frames = particle_grid_frames(256,256); frame = 0;
        initialVolume = 10; maxVolume = 200; life = 1.2;
        behaviour = particle_behaviour_alpha_gas_ball_emissive;
        diffuse = vec(0, 0, 0);
        colourCurve = colour_curve;
        alphaCurve = alpha_curve;
        convectionCurve = particle_convection_curve;
    }

    --[[
    particle "Explosion2" {
        map = "GenericParticleSheet.dds";
        frames = particle_grid_frames(256,256); frame = 0;
        initialVolume = 10; maxVolume = 200; life = 2;
        behaviour = particle_behaviour_alpha_gas_ball_emissive;
        diffuse = vec(0, 0, 0);
        colourCurve = colour_curve;
        alphaCurve = alpha_curve;
        convectionCurve = particle_convection_curve;
    }

    particle "Explosion3" {
        map = "GenericParticleSheet.dds";
        frames = { 256,0, 256, 256 }; frame = 0;
        initialVolume = 10; maxVolume = 200; life = 2;
        behaviour = particle_behaviour_alpha_gas_ball_emissive;
        diffuse = vec(0, 0, 0);
        colourCurve = colour_curve;
        alphaCurve = alpha_curve;
        convectionCurve = particle_convection_curve;
    }
    ]]--

end


function explosion_graphics (pos, radius)
end

function explosion_physics (pos, radius, force)
end

function explosion (pos, radius, force, num_flames)
    radius = radius or 5
    force = force or radius * radius * 800
    num_flames = num_flames or 6

    local volume = radius * radius * radius * 4/3 * math.pi
    local num_sprites1 = 4
    local num_debris = 4
    local l = gge_gfx_light_make()
    l.coronaColour = V_ZERO
    l.localPosition = pos + V_UP*radius
    l.range = radius * 5
    for i=1,num_sprites1 do
        local offset = random_vector3_plane_z()
        local position = pos + offset
        local velocity = radius*(1*offset + vector3(0,0,1.5));
        gge_gfx_particle_emit(`Explosion`, position, {
            velocity = velocity,
            light = l,
            angle = (i+math.random())/num_sprites1*360,
            maxVolume = 10*volume,
            age = 0,
        })
        l = nil
    end
    
    local pitch = 5/radius
    local volume = radius / 5
    gge_audio_play(`/common/sounds/explosion.wav`, volume, pitch, pos, radius*3, 0.75)

    
    for i=1,num_debris do
        local dir = math.random()*radius*random_vector3_plane_z() +  math.random()*V_UP
        emit_debris(pos+norm(dir), 4*dir, math.random(12)-1, 1)
    end

    -- emit smoke cloud
    do
        local colour = 0.05*vector3(1,0.85,0.7)
        for i=1,1 do
            --local dir = random_vector3_sphere()
            --if dir.z < 0 then dir = dir * vector3(1,1,-1) end
            --local dist = math.random()
            --dist = dist * 0.5*radius
            --emit_textured_smoke(pos+dist*dir * vector3(1,1,0.5), dir*vector3(1,1,4), radius/2, radius*3, colour, 3)
            emit_textured_smoke(pos+vector3(0,0,0), V_ZERO, 0.1*radius, 5*radius, colour, 4)
        end
    end


    -- physics
    gge_physics_test(radius, pos, true, function(body, num, lpos, wpos, norm, penetration, mat)
        -- penetration is a number from 0 to radius
        local r = radius - penetration
        local impulse_scalar = force / r / r;
        local impulse_scalar_capped = math.min(impulse_scalar, body.mass*10) / num
        local impulse = -impulse_scalar_capped*norm
        local damage_impulse = -impulse_scalar*norm
        local owner = body.owner
        local impact_time = r/1000
        gge_future_event(impact_time, function ()
            if owner.destroyed then return end
            if not owner.activated then return end
            if owner.instance.activationSkipped then return end
            owner:receiveBlast(impulse, wpos, damage_impulse)
        end)
    end)

    -- shrapnel

    -- fire
    for i=1,num_flames do
        local dir = random_vector3_sphere()
        local dist, victim, normal, physmat = gge_physics_cast(pos, dir * radius/5, true, 0)
        if dist ~= nil then
            local hit_pos = pos + dist * (radius/5 * dir)
            victim = victim.owner -- from rbody to object
            if victim ~= nil then
                victim:ignite(`Flame`, hit_pos, physmat, 30)
            end
        end
    end

end

