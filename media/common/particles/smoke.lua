-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

do
    particle `Smoke` {
        map = `GenericParticleSheet.dds`;
        frames = { 640,512, 128, 128, };  frame = 0;
        initialVolume = 10; maxVolume = 200; life = 2;
        behaviour = particle_behaviour_alpha_gas_ball_diffuse;
        alphaCurve = gge_Plot{[0]=0.0,[0.5]=0.25,[1]=0};
        convectionCurve = particle_convection_curve;
    }

    particle `TexturedSmoke` {
        map = `GenericParticleSheet.dds`;
        frames = { 896,640, 128, 128, };  frame = 0;
        initialVolume = 10; maxVolume = 200; life = 2;
        behaviour = particle_behaviour_alpha_gas_ball_diffuse;
        alphaCurve = gge_Plot{[0]=1,[0.2]=0.3,[0.5]=0.1,[1]=0};
        convectionCurve = particle_convection_curve;
    }
end


function emit_smoke (pos, vel, start_size, end_size, colour, life)
    start_size = start_size or 0.3
    end_size = end_size or 1
    colour = colour or vec(1, 1, 1)
    life = life or 3
    local r1 = start_size/2
    local r2 = end_size/2
    gfx_particle_emit(`Smoke`, pos, {
        angle = 360*math.random();
        velocity = vel;
        initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
        maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
        life = life;
        diffuse = colour;
        age = 0;
    })
end

tire_smoke_counter = 0
tire_smoke_max = 50

function emit_textured_smoke (pos, vel, start_size, end_size, colour, life)
    start_size = start_size or 0.3
    end_size = end_size or 1
    colour = colour or vec(1, 1, 1)
    life = life or 3
    local r1 = start_size/2
    local r2 = end_size/2
    if tire_smoke_counter + 1 < tire_smoke_max then
        gfx_particle_emit(`TexturedSmoke`, pos, {
            angle = 360*math.random();
            velocity = vel;
            initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
            maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
            life = life;
            diffuse = colour;
            initialColour = colour;
            age = 0;
        })
        tire_smoke_counter = tire_smoke_counter + 1
    else
        tire_smoke_counter = tire_smoke_counter - 0.1
    end
end


function puff_textured(pos, colour)
    local radius = 5
    local time = 3
    for i=1,5 do
        -- 4 compass directions and up, plus a bit of randomness and V_UP
        local dir = i==5 and V_UP or quat(i*90,V_UP) * V_NORTH
        dir = radius * dir 
        dir = dir + random_vector3_sphere() + V_UP
        -- colour works best if all particles are the same colour
        local rand_colour = colour or 0.7 * vec(1, 1, 1)
        local r1 = radius/3
        local r2 = 4*radius
        gfx_particle_emit(`TexturedSmoke`, pos, {
            angle = 360*math.random();
            velocity = 4*dir;
            initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
            maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
            life = time;
            diffuse = rand_colour;
            initialColour = rand_colour;
            age = 0;
        })
    end
end




function emit_tyre_smoke (cp, qty)
    emit_textured_smoke(cp + 0.25 * V_UP,
        random_vector3_box(vector3(-0.2, -0.2, 0.6), vector3(0.2, 0.2, 0.7)),
        0.5,
        2.5,
        qty * (1 - math.random() / 3),
        vector3(0, 0, 0),
        2
    )
end





particle `EngineSmoke` {
    map = `GenericParticleSheet.dds`;
    frames = { 640,512, 128, 128, };  frame = 0;
    behaviour = function (tab, elapsed)

        -- age ranges from 0 (new) to 1 (dead)
        tab.age = tab.age + elapsed / tab.life
        if tab.age > 1 then
            return false
        end

        tab.position = tab.position + (tab.velocity + vector3(math.random(-100,100)/100,math.random(-100,100)/100,0)) * elapsed

        tab.volume = lerp(tab.initialVolume, tab.endVolume, tab.age)
        local radius = math.pow(tab.volume/math.pi*3/4, 1/3) -- sphere: V = 4/3πr³
        tab.dimensions = (2*radius) * vector3(1,1,1)

        tab.alpha = 0.3*math.pow(1-tab.age, 3)
        tab.diffuse = tab.initialColour * tab.alpha

    end;
    initialVolume = 0.003;
    endVolume = 0.006;
    age = 0;
    life = 1;
}

-- damage is from 0 to 1
local engine_smoke_colour = gge_Plot {
    [0.00] = 1.0;
    [0.30] = 0.5;
    [0.70] = 0.1;
    [1.00] = 0.0;
};

engine_smoke_counter = 0
engine_smoke_max = 50

function emit_engine_smoke (damage, pos)
    local off = vector3(math.random(-80,80)/1000, math.random(-80,80)/1000, 0)
    local vel = (damage * 3*off + vector3(0,0,1*damage)) + vector3(0, 0, 2.0)
	if engine_smoke_counter + 1 < engine_smoke_max then
    gfx_particle_emit(`EngineSmoke`, pos + off, {
                      velocity = vel,
                      initialVolume = (math.random()*0.03 + 0.03) * clamp(damage, 0.1, 1),
                      endVolume = (math.random()*0.3 + 0.3) * clamp(damage, 0.1, 1),
                      initialColour = 0.05*clamp(engine_smoke_colour[damage] + math.random()*0.08, 0, 1) * vector3(1,1,1),
                      life = clamp(damage, 0.5, 1);
                     })
		engine_smoke_counter = engine_smoke_counter + 1
	else
		engine_smoke_counter = engine_smoke_counter - 0.5
	end
end





local exhaust_smoke_alpha = gge_Plot{
    [0] = 0.3;
    [10] = 0.2;
    [20] = 0.1;
    [30] = 0;
}

particle `ExhaustSmoke` {
    map = `GenericParticleSheet.dds`;
    frames = {
                640,512, 128, 128,
                640,640, 128, 128,
             };
    frame = 0;

    behaviour = function (particle, elapsed)
        particle.age = particle.age + elapsed
        if particle.age > particle.life then
            return false
        end
        
        local vel
        if particle.speed < 1 then
            vel = particle.velocity
        else
            vel = V_UP * (0.05 * particle.speed)
        end
        
        particle.position = particle.position + (vel + vector3(math.random(-100,100)/100,math.random(-100,100)/100,math.random(-100,100)/100)) * elapsed
        
        local sz = 0.15 + particle.age
        particle.dimensions = sz*vector3(1, 1, 1)
        
        particle.alpha = clamp(exhaust_smoke_alpha[particle.speed] - (particle.life), 0,1)
        particle.diffuse = particle.initialColour * particle.alpha
    end;
}

local exhaust_smoke_life = gge_Plot{
    [0] = 0.3;
    [1] = 0.25;
    [5] = 0.1;
    [20] = 0.05;
    [30] = 0;
}
local exhaust_smoke_color = gge_Plot{
    [0] = 0.2;
    [03] = 0.2;
    [10] = 0;
}

function emit_exhaust_smoke (speed, pos, vel)
    if speed > 10 then return end
    gfx_particle_emit(`ExhaustSmoke`, pos, {
        velocity = vel,
        initialColour = exhaust_smoke_color[speed] * vector3(1,1,1);
        life = exhaust_smoke_life[speed];
        age = 0;
        speed = speed;
        frame = math.random(0,1);
    })
end

particle `RocketExhaustSmoke` {
    map = `GenericParticleSheet.dds`;
    frames = {
        640, 512, 128, 128,
        640, 640, 128, 128,
    };
    frame = 0;
    startWidth = 1;
    
    behaviour = function (particle, elapsed)
        particle.life = particle.life - elapsed
        if particle.life <= 0 then
            return false
        end
        
        particle.position = particle.position + (particle.velocity + vector3(math.random(-100,100)/100,math.random(-100,100)/100,math.random(-100,100)/100)) * elapsed
        
        particle.width = particle.startWidth - math.pow(particle.life, 3)
        particle.height = particle.width
        particle.alpha = clamp(0.6 - 0.1/particle.life, 0,1)
        particle.colour = lerp(vector3(1,0,0),vector3(1,0.3,0), clamp(particle.width, 0, 0.75)) * particle.alpha
    end;
}

function emit_rocket_smoke(pos, vel, width)
    gfx_particle_emit(`RocketExhaustSmoke`, pos, {
        velocity = vel,
        --startWidth = width;
        diffuse = vector3(1,0,0);
        life = 0.25;
        startWidth = width;
        frame = math.random(0,1);
    })
end

