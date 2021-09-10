-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `sky.lua`


function env_recompute()

    local secs = env.secondsSinceMidnight
    
    if secs < env_cube_dawn_time then
        gfx_env_cube(0, env_cube_dark)
        gfx_env_cube(1, env_cube_dawn)
        gfx_env_cube_cross_fade(invlerp(0, env_cube_dawn_time, secs))
    elseif secs < env_cube_noon_time then
        gfx_env_cube(0, env_cube_dawn)
        gfx_env_cube(1, env_cube_noon)
        gfx_env_cube_cross_fade(invlerp(env_cube_dawn_time, env_cube_noon_time, secs))
    elseif secs < env_cube_dusk_time then
        gfx_env_cube(0, env_cube_noon)
        gfx_env_cube(1, env_cube_dusk)
        gfx_env_cube_cross_fade(invlerp(env_cube_noon_time, env_cube_dusk_time, secs))
    elseif secs < env_cube_dark_time then
        gfx_env_cube(0, env_cube_dusk)
        gfx_env_cube(1, env_cube_dark)
        gfx_env_cube_cross_fade(invlerp(env_cube_dusk_time, env_cube_dark_time, secs))
    end
    
    -- We need to manage the:
    -- * Orientation of space around the player (to position the sky map), which defaults to Y being
    -- the normal of the ecliptic plane in the north(ish) direction, and Z being away from the
    -- sun in winter.
    -- * Orientation of the Moon around the player.  The moon by default is in the Z direction.
    -- Therefore by default there is a full moon.
    -- * Direction vectors of the sun and moon in world space, for lighting purposes.

    --[[
                                 Y
            ---                  ^
          /XXXXX\                |
         |X Sun X|              (E) -> Z
          \XXXXX/
            ---

        Z is towards the sun.
        Y is the normal of the orbital plane.
        The X axis is therefore out of the screen.

        At midnight during winter at latitude 0, you would be standing on the far side of the earth
        somewhere in the -Z and -Y direction.
    --]]

    -- First rotate space by X to account for the tilt of the earth.  Now Y points to the true north
    -- pole.  X is the same (i.e. east).  Z points slightly away from where it used to.
    -- Then rotate by Y to account for time.  Now Y still points north and Z points up into the sky
    -- at the point around the earth where we are at this time.
    -- X has changed but is still east because we have moved around the earth.
    -- Now account for latitude by rotating by X.

    -- sun_adjusted_time includes season because the Earth rotates about its axis relative to the
    -- stars once every 23 hours 56 minutes.  I.e. because of the rotation of the earth around the
    -- sun, the period between when the sun is at its highest point in the sky is slightly longer
    -- than the actual rotation of the earth.  The sun appears to "chase" the earth relative to the
    -- starfield background.
    local sun_adjusted_time = math.mod(secs / 60 / 60 / 24 * 360 - env.season + 360, 360)
    local space_orientation = quat(env.latitude, V_EAST) *
                              quat(sun_adjusted_time, V_SOUTH) *
                              quat(env.earthTilt, V_EAST)
    local moon_orientation = space_orientation * quat(env.moonPhase, V_SOUTH)
    local moon_body_orientation = space_orientation * quat(env.moonPhase + 180, V_SOUTH)
    local sky_ent = env_sky['sky']
    local moon_ent = env_sky['moon']

    -- procedural from time
    if sky_ent ~= nil then
        sky_ent.orientation = space_orientation
    end
    if moon_ent ~= nil then 
        moon_ent.orientation = moon_body_orientation
    end
    
    -- Account for the apparent movement of the Sun around the Earth due to seasons.
    local sun_direction =   (space_orientation * quat(env.season, V_SOUTH)) * V_DOWN
    local moon_direction =  moon_orientation * V_DOWN

    local next_env, current_env, slider
    do 
        local found = false
        for _,some_env in ipairs(env_cycle) do
            current_env = next_env
            next_env = some_env
            if some_env.time*60*60 > secs then
                found = true
                break
            end
        end
        if not found then
            -- wrap-around case
            current_env = env_cycle[#env_cycle]
            next_env = env_cycle[1]
            slider = (secs/60/60 - current_env.time) / (next_env.time+24 - current_env.time)
        else
            slider = (secs/60/60 - current_env.time) / (next_env.time - current_env.time)
        end
    end

    -- sunlight_direction is the parameter to the lighting equation that is used to light the scene
    local sunlight_direction
    if current_env.lightSource == "MOON" then
        gfx_sunlight_direction(-norm(moon_direction))
    elseif current_env.lightSource == "SUN" then
        gfx_sunlight_direction(-norm(sun_direction))
    end

    -- interpolated from env_cycle
    local function lerp3(a, b, slider, na, nb)
        na = na or 1; nb = nb or 1
        return lerp(a[na+0], b[nb+0], slider),
               lerp(a[na+1], b[nb+1], slider),
               lerp(a[na+2], b[nb+2], slider)
    end
    local function lerp4(a, b, slider, na, nb)
        na = na or 1; nb = nb or 1
        return lerp(a[na+0], b[nb+0], slider),
               lerp(a[na+1], b[nb+1], slider),
               lerp(a[na+2], b[nb+2], slider),
               lerp(a[na+3], b[nb+3], slider)
    end
    local fog_colour = lerp(current_env.fogColour, next_env.fogColour, slider)

    -- sky
    gfx_sun_direction(sun_direction)
    gfx_hell_colour(fog_colour)
    gfx_sun_size(lerp(current_env.sunSize, next_env.sunSize, slider))
    gfx_sun_falloff_distance(lerp(current_env.sunFalloff, next_env.sunFalloff, slider))

    local mixed_sun_colour = lerp(current_env.sunColour, next_env.sunColour, slider)
    gfx_sun_colour(mixed_sun_colour.xyz)
    gfx_sun_alpha(mixed_sun_colour.w)

    gfx_sky_cloud_colour(lerp(current_env.cloudColour, next_env.cloudColour, slider))
    gfx_sky_cloud_coverage(lerp(current_env.cloudCoverage, next_env.cloudCoverage, slider))

    gfx_sky_divider(0, 5)
    gfx_sky_divider(1, 10)
    gfx_sky_divider(2, 15)
    gfx_sky_divider(3, 25)

    gfx_sky_glare_sun_distance(lerp(current_env.sunGlare, next_env.sunGlare, slider))
    gfx_sky_glare_horizon_elevation(lerp(current_env.horizonGlare, next_env.horizonGlare, slider))
    for i=1,6 do
        local mixed_gradient = lerp(current_env["grad"..i], next_env["grad"..i], slider)
        gfx_sky_colour(i-1, mixed_gradient.xyz)
        gfx_sky_alpha(i-1, mixed_gradient.w)
    end
    for i=1,5 do
        local mixed_gradient = lerp(current_env["sunGrad"..i], next_env["sunGrad"..i], slider)
        gfx_sky_sun_colour(i-1, mixed_gradient.xyz)
        gfx_sky_sun_alpha(i-1, mixed_gradient.w)
    end

    -- environment properties
    gfx_particle_ambient(vector3(lerp(current_env.particleLight, next_env.particleLight, slider)))
    gfx_global_saturation(env_saturation_mask * lerp(current_env.saturation, next_env.saturation, slider))
    gfx_fog_colour(fog_colour)
    gfx_fog_density(lerp(current_env.fogDensity, next_env.fogDensity, slider))
    gfx_sunlight_diffuse(lerp(current_env.diffuseLight, next_env.diffuseLight, slider))
    gfx_sunlight_specular(lerp(current_env.specularLight, next_env.specularLight, slider))

end


if not env then
    env = {
        -- current values
        c = {
            autoUpdate = false;
        };

        -- proposed values
        p = {
        };
        
        tickCallbacks = CallbackReg.new();
    }
else
    setmetatable(env,nil)
    main.frameCallbacks:removeByName("Environment")
end


setmetatable(env, {
    __index = function (self, k)
        local v = self.c[k]
        if v == nil then
            error('No such setting: "%s"' % k, 2)
        end
        return v
    end,

    __newindex = function (self, k, v)
        if k == "autoUpdate" then
            ensure_one_of(v,{false,true})
            self.c[k] = v
        elseif k == "secondsSinceMidnight" then
            ensure_number(v)
            self.p[k] = v
        elseif k == "latitude" then
            ensure_range(v,-90,90)
            self.p[k] = v
        elseif k == "season" then
            ensure_range(v,0,360)
            self.p[k] = v
        elseif k == "earthTilt" then
            ensure_range(v,-90,90)
            self.p[k] = v
        elseif k == "clockRate" then
            ensure_range(v,-50000,50000)
            self.p[k] = v
        elseif k == "clockTicking" then
            ensure_one_of(v,{false,true})
            self.p[k] = v
        elseif k == "moonPhase" then
            ensure_range(v,0,360)
            self.p[k] = v
        else
            error("Unrecognised env setting: "..tostring(k))
        end

        if not self.c.autoUpdate then return end

        local reset = false

        for k,v in pairs(self.p) do
            if self.c[k] ~= v then
                self.c[k] = v
                reset = true
            end
        end

        if reset then
            env_recompute()
        end
    end
})


local last_time = seconds()

main.frameCallbacks:insert("Environment", function()
    local clock_rate = env.clockRate

    local curr_time = seconds()
    local elapsed = curr_time - last_time
    last_time = curr_time
    
    if env.clockTicking then
        env.secondsSinceMidnight = math.mod(env.secondsSinceMidnight + elapsed * env.clockRate, 24*60*60)
        env.tickCallbacks:execute(env.secondsSinceMidnight)
    end
end)


-- Declaring them in global scope.  They are initialised by env_reset().
env_cycle = env_cycle or nil
env_saturation_mask = env_saturation_mask or nil
env_cube_dawn_time = env_cube_dawn_time or nil
env_cube_noon_time = env_cube_noon_time or nil
env_cube_dusk_time = env_cube_dusk_time or nil
env_cube_dark_time = env_cube_dark_time or nil
env_cube_dawn = env_cube_dawn or nil
env_cube_noon = env_cube_noon or nil
env_cube_dusk = env_cube_dusk or nil
env_cube_dark = env_cube_dark or nil

env_sky = env_sky or nil

function env_reset()
    env_cycle = include `env_cycle.lua`

    env_saturation_mask = 1

    env_cube_dawn_time = 6*60*60
    env_cube_noon_time = 12*60*60
    env_cube_dusk_time = 18*60*60
    env_cube_dark_time = 24*60*60
        
    -- Overidden by gmap files.
    env_cube_dawn = nil
    env_cube_noon = nil
    env_cube_dusk = nil
    env_cube_dark = nil

    gfx_env_cube(0, env_cube_noon)
    gfx_env_cube(1, env_cube_noon)
    gfx_global_exposure(1)
    gfx_option("BLOOM_ITERATIONS",1)
    gfx_colour_grade(`standard.lut.png`)

    if env_sky then
        for name, body in pairs(env_sky) do
            body:destroy()
        end
    end
    env_sky = {}

    env.autoUpdate = false
    env.latitude = 41; 
    env.secondsSinceMidnight = 12*60*60;  -- Midday.
    env.season = 0;  -- Winter, stored as angle in degrees.
    env.earthTilt = -23.44;
    env.clockRate = 30;
    env.clockTicking = false;
    env.moonPhase = 200;  -- Between sun and earth when moonPhase == 0.
    env.autoUpdate = true
end
