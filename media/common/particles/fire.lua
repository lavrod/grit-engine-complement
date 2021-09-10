-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- must have particle definition check material exists
-- OR do not use regular materials for particles

flame_alpha = flame_alpha or 1

flame_counter = 0
flame_counter_max = 30

local function flame_behaviour (particle, elapsed)

    local dim = particle.dimensions

    local root = particle.position - vector3(0,0,dim.y/2)
    local l = particle.light

    particle.age = particle.age + elapsed
    if particle.age > particle.life then 
        if l then l:destroy() end
        flame_counter = flame_counter - 1
        return false
    end

    -- ray-based particle-breeding
    -- if the fire is mature enough, and lady luck satisfies
    -- if we haven't exceeded the life limit of this group of flame
    -- if max flames hasn't been reached
    if dim.y > 0.0 and math.random() < 0.001
       and particle.age < particle.fertileLife
       and flame_counter < flame_counter_max then

        -- breed
        local hit = 0
        for children=1,10 do
            if hit >= 2 then break end
            local dir = random_vector3_sphere()
            local cast_origin = root+vector3(0,0,dim.x/2)
            local cast_ray = particle.spreadDist*dim.y/2 * dir
            local dist, victim, normal, physmat = physics_cast(cast_origin, cast_ray, true, 0)
            --emit_debug_marker(particle.position, vector3(1,0,0), 1, 0.3)
            if dist ~= nil then
                local hit_pos = cast_origin + dist * cast_ray
                --emit_debug_marker(hit_pos, vector3(0,1,0), 1, 0.3)
                local n2 = normal * vector3(1,1,0) * dim.x/4
                hit_pos = hit_pos + n2
                --emit_debug_marker(hit_pos, vector3(0,0,1), 1, 0.4)
                victim = victim.owner -- from rbody to object
                --create new particle on the next tick
                gge_future_event(0, function()
                    -- victim might be dead by now
                    if not victim.destroyed and victim.activated then
                        victim:ignite(particle.name, hit_pos, physmat, particle.fertileLife-particle.age)
                    end
                end)
                hit = hit + 1
            end
            if hit==2 then
                -- if made 2 children, die on the next tick     
                --particle.age = particle.life
            end 
        end
    end

    if math.random() < 0.01 then
        -- grow
        if dim.y < 3 then
            dim = dim * vector3(1.1, 1.1, 1)
        end
    end

    if math.random() < 0.05 then
        -- hop a small amount in a random direction
        root = root + 0.05 * math.random() * dim.x * random_vector3_plane_z()
    end

    -- slowly fade alpha down until end of life
    particle.alpha = flame_alpha * clamp(10 - 10*particle.age / particle.life, 0, 1)

    -- origin is in centre
    local ppos = root + vector3(0,0,dim.y / 2)
    particle.position = ppos

    dim = vector3(dim.x, dim.y, dim.x/4)

    -- animate (random intervals)
    local old_frame = particle.frame
    local new_frame = math.mod(old_frame + math.random()*0.5, 7*7)
    if old_frame ~= new_frame then
        particle.frame = new_frame
        local col = vector3(1,1,1) - vector3(0, 0, math.random()*0.2)
        particle.emissive = 4*col * particle.alpha

        if l then
            local light_col = 0.2 * col * col
            l.diffuseColour = light_col
            l.specularColour = light_col
        end
    end
    if l then
        l.localPosition = ppos
        l.range = dim.y * 10
    end

    particle.dimensions = dim

end

local function engine_flame_behaviour (particle, elapsed)

    local dim = particle.dimensions

    local root = particle.position - vector3(0,0,dim.y/2)
    local l = particle.light

    particle.age = particle.age + elapsed
    if particle.age > particle.life then 
        if l then l:destroy() end
        flame_counter = flame_counter - 1
        return false
    end

    -- ray-based particle-breeding
    -- if the fire is mature enough, and lady luck satisfies
    -- if we haven't exceeded the life limit of this group of flame
    -- if max flames hasn't been reached
    if dim.y > 0.0 and math.random() < 0.001
       and particle.age < particle.fertileLife
       and flame_counter < flame_counter_max then

        -- breed
        local hit = 0
        for children=1,10 do
            if hit >= 2 then break end
            local dir = random_vector3_sphere()
            local cast_origin = root+vector3(0,0,dim.x/2)
            local cast_ray = particle.spreadDist*dim.y/2 * dir
            local dist, victim, normal, physmat = physics_cast(cast_origin, cast_ray, true, 0)
            --emit_debug_marker(particle.position, vector3(1,0,0), 1, 0.3)
            if dist ~= nil then
                local hit_pos = cast_origin + dist * cast_ray
                --emit_debug_marker(hit_pos, vector3(0,1,0), 1, 0.3)
                local n2 = normal * vector3(1,1,0) * dim.x/4
                hit_pos = hit_pos + n2
                --emit_debug_marker(hit_pos, vector3(0,0,1), 1, 0.4)
                victim = victim.owner -- from rbody to object
                --create new particle on the next tick
                gge_future_event(0, function()
                    -- victim might be dead by now
                    if not victim.destroyed and victim.activated then
                        victim:ignite(particle.name, hit_pos, physmat, particle.fertileLife-particle.age)
                    end
                end)
                hit = hit + 1
            end
            if hit==2 then
                -- if made 2 children, die on the next tick     
                --particle.age = particle.life
            end 
        end
    end

    if math.random() < 0.01 then
        -- grow
        if dim.y < 3 then
            dim = dim * vector3(1.1, 1.1, 1)
        end
    end

    if math.random() < 0.05 then
        -- hop a small amount in a random direction
        root = root + 0.05 * math.random() * dim.x * random_vector3_plane_z()
    end

    -- slowly fade alpha down until end of life
    particle.alpha = flame_alpha * clamp(10 - 10*particle.age / particle.life, 0, 1)

    -- origin is in centre
    local ppos = root + vector3(0,0,dim.y / 2)
    particle.position = ppos

    dim = vector3(dim.x, dim.y, dim.x/4)

    -- animate (random intervals)
    local old_frame = particle.frame
    local new_frame = math.mod(old_frame + math.random()*0.5, 7*7)
    if old_frame ~= new_frame then
        particle.frame = new_frame
        local col = vector3(1,1,1) - vector3(0, 0, math.random()*0.2)
        particle.emissive = 4*col * particle.alpha

        if l then
            local light_col = 0.2 * col * col
            l.diffuseColour = light_col
            l.specularColour = light_col
        end
    end
    if l then
        l.localPosition = ppos
        l.range = dim.y * 10
    end

    particle.dimensions = dim

end

particle `EngineFire` {
	map = `flames_anim2.png`;
    frames = particle_grid_frames(146,146, 0,0, 6,6),
	frame = 0;
    behaviour = engine_flame_behaviour;
    initialVolume = 0.003;
    endVolume = 0.006;
    age = 0;
    life = 1;
	angle = 0;
	diffuse = vec(0, 0, 0);
	spreadDist = 1;
    colourCurve = gge_PlotV3 {
        [0.00] = vector3(0.40, 0.18, 0.14);
        [0.10] = vector3(1.00, 0.44, 0.26);
        [0.42] = vector3(1.00, 0.45, 0.24);
        [0.75] = vector3(0.64, 0.31, 0.15);
        [1.00] = vector3(0.00, 0.00, 0.00);
    }
}

engine_fire_counter = 0
engine_fire_max = 5

function emit_engine_fire (pos)

    local off = vector3(math.random(-80,80)/1000, math.random(-80,80)/1000, 0)
    local vel = 2*off + vector3(0,0,2.0)

    local l
    if  false and math.random() < 0.1 then
        l = gfx_light_make()
        l.coronaColour = V_ZERO
        l.localPosition = pos + off
        l.range = 2
    end
	
	local rand_colour = 0.7*vector3(1,1,1)

    local size = 0.7 + math.random()*0.1
	if engine_fire_counter + 1 < engine_fire_max then
    gfx_particle_emit(`EngineFire`, pos + off, {
                      velocity = vel;
                      light = l;
                      frame = math.random(5)-1,
					  initialColour = rand_colour,
                      life = 1,
                      dimensions = vector3(size,size,size),
					  fertileLife = 10
                     })
	engine_fire_counter = engine_fire_counter + 1
	else
		engine_fire_counter = engine_fire_counter - 0.01
	end

end

particle `Flame` {
    map = `flames_anim2.png`;
    frames = particle_grid_frames(146,146, 0,0, 6,6) ; frame = 0;
    behaviour = flame_behaviour;
    life = 3;
    age = 0;
    dimensions = vector3(0.2, 0.3, 0.2);
    spreadDist = 1;
}

function cast_flame (pname)
    pname = pname or `Flame`
    local size = 0.2 + 0.3 * math.random()
    local width = size
    local height = size * 1.5
    local pos = pick_pos(main.camPos, main.camQuat, width/4)
    if pos == nil then return end
    pos = pos - vector3(0,0,-width/4)
    create_flame_raw(pos, width, height, pname, 60)
end

function flame_ignite (pname, pos, mat, fertile_life)
    if math.random() < physics:getMaterial(mat).flammable then
        local size = 0.2 + 0.3 * math.random()
        local width = size
        local height = size * 1.5
        create_flame_raw(pos+vector3(0,0,height/2), width, height, pname, fertile_life)
    end
end

--pos: position where flame starts (root)
--size: height of flame
--pname: name of particle definition to use for flame
--fertile_life: time after which this flame and its children no longer reproduce
function create_flame_raw (pos, width, height, pname, fertile_life)

    if flame_counter > flame_counter_max then return end

    local l = gfx_light_make()
    l.coronaColour = vector3(0,0,0)

    local centre = pos + vector3(0,0,height/2)

    gfx_particle_emit(pname, pos, { fertileLife = fertile_life, life = 5 + 10*math.random(), dimensions=vector3(width,height,width), light = l })

    flame_counter = flame_counter + 1

end

if gge_resource_exists(`gta4_flames.png`) then
    particle `Flame2` {
        map = `gta4_flames.png`;
        frames = particle_grid_frames(73,73, 0,0, 6,6) ; frame = 0;
        behaviour = flame_behaviour;
        life = 3;
        age = 0;
        dimensions = vector3(0.2, 0.3, 0.2);
        spreadDist = 1;
    }
    function cast_flame2 ()
        cast_flame(`Flame2`)
    end
end
