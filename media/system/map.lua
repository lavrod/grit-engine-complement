-- Copyright (c) The Grit Game Engine authors 2016 (MIT license)

--[[
A Grit map is a data only (no computation) format for storing maps (collections of object
placements) on disk.  It should be possible for a machine to read and output the map again, hence
being a data only format.  Being data-only, it is analogous to JSON, but in the Lua syntax.

On disk, a grit map has the following structure:

return { ... }

Where the table is structured like the table returned by map_build_empty below:
]]

function map_build_empty()
    return {
        -- Version code to allow breaking compatability.
        version     = 5,

        -- Metadata.
        properties  = {
            author      = "Insert author here",
            description = "Insert description here",
            name        = "Insert name here",
        },

      -- Position when spawning in the Grit Editor.
        editor = {
            cam_pos  = vec(0, 0, 0),
            cam_quat = quat(1, 0, 0, 0),
        },

        -- Paths to environmental lighting cubemaps.
        -- Set all to nil for no environmental lighting.
        -- Set all but one to nil for no env cycle.
        env_cubes = {
            dawn = `env_cube_dawn.envcube.tiff`,
            noon = `env_cube_noon.envcube.tiff`,
            dusk = `env_cube_dusk.envcube.tiff`,
            dark = `env_cube_dark.envcube.tiff`,
        },

        environment = {
            clock_rate = 0,  -- Rate of passage of time.
            time = 43200,  -- Seconds past midnight.
            env_cycle_file = nil,  -- Or a filename to use that file.
            sky = {
                sky = { `SkyCube.mesh`, 180 },
                moon = { `SkyMoon.mesh`, 120 },
                clouds = { `SkyClouds.mesh`, 60 },
            },
        },

        -- The objects in the map.
        -- Keys hold the object name:
        -- ["name1"] = { 'classname', vec(0, 0, 0), { ... } },
        -- ["name2"] = { 'classname', vec(0, 0, 0), { ... } },
        objects = {},
    }
end


-- Includes include_path in a context where object() is replaced with a trap that saves object
-- instantiation parameters into a table, then prints a gmap to filename containing those objects.
function map_convert_from_include(include_path, filename)
    assert_path_file_type(include_path, 'lua')
    assert_path_file_type(filename, 'gmap')

    local file = io.open(filename:sub(2), 'w')
    if file == nil then gge_error('Could not save to file: ' .. filename) end

    local map = map_build_empty()
    map.editor.cam_pos = main.camPos
    map.editor.cam_quat = main.camQuat
    map.env_cubes.dawn = env_cube_dawn
    map.env_cubes.noon = env_cube_noon
    map.env_cubes.dusk = env_cube_dusk
    map.env_cubes.dark = env_cube_dark
    map.environment.time = env.secondsSinceMidnight
    map.environment.clockRate = env.clockRate

    local counter = 0
    local obj_off = vec(0, 0, 0)
    local old_offset_exec = offset_exec
    function offset_exec (off, f, ...)
        obj_off = obj_off + off
        f(...)
        obj_off = obj_off - off
    end
    local old_object = object
    function object (class_name)
        return function (x, y, z)
            local obj_pos
            if type(x) == 'vector3' then
                obj_pos = obj_off + x
            else
                obj_pos = obj_off + vec(x, y, z)
            end
            return function(body)
                local name = body.name
                if name == nil then
                    name = ('unnamed_%d'):format(counter)
                    counter = counter + 1
                end
                body.name = nil
                map.objects[name] = {class_name, obj_pos, body}
            end
        end
    end
    gge_include(include_path)
    object = old_object
    offset_exec = old_offset_exec
    
    map_write_to_file(map, filename)
end


-- Take the map and instantiate all the objects.  Useful mainly to call from the console or at game
-- mode initialization time.
function include_map(mapfile)
    local map = gge_include(mapfile)
    local objects = map.objects or {}
    for name, object in pairs(objects) do
        local class_name, obj_pos, tab = object[1], object[2], object[3] or {}
        tab.name = name
        local hid = object_add(class_name, obj_pos, tab)
        local lod = class_get(class_name).lod
        if lod == true then
            if class_name:find("/") then
                -- Insert at the beginning of the filename (ignoring the dir path).
                lod = class_name:reverse():gsub("/", "_dol/", 1):reverse()
            else
                lod = "lod_" .. class_name
            end
        end
        if lod then
            if class_get(lod) then
                tab.near = hid
                if tab.name then tab.name = tab.name .. "_lod" end
                object_add(lod, obj_pos, tab)
            else
                gge_error(('Class "%s" referred to a lod class "%s" that does not exist.'):format(class_name, lod))
            end
        end

    end

    env_cube_dawn = map.env_cubes.dawn
    env_cube_noon = map.env_cubes.noon
    env_cube_dusk = map.env_cubes.dusk
    env_cube_dark = map.env_cubes.dark
    env.clockRate = map.environment.clock_rate
    env.secondsSinceMidnight = map.environment.time
    env_cycle = gge_include(map.environment.env_cycle_file or `/system/env_cycle.lua`)
    for name, def in pairs(map.environment.sky) do
        env_sky[name] = gfx_sky_body_make(def[1], def[2])
    end
    env_recompute()
end

local function quoted_or_nil(v)
    if v == nil then
        return "nil"
    else
        return ("%q"):format(v)
    end
end


-- Writes a file that if included would return a value that is equivalent to 'map'.
function map_write_to_file(map, filename)
    assert_path_file_type(filename, 'gmap')

    local file = io.open(filename:sub(2), 'w')
    if file == nil then gge_error('Could not save to file: ' .. filename) end

    file:write('-- Map file generated by Grit Editor.\n')
    file:write('return {\n')
    file:write(('    version = %d,\n'):format(map.version))
    file:write('    properties = {\n')
    file:write(('        name = %q,\n'):format(map.properties.name))
    file:write(('        author = %q,\n'):format(map.properties.author))
    file:write(('        description = %q,\n'):format(map.properties.description))
    file:write('    },\n')
    file:write('    editor = {\n')
    file:write(('        cam_pos = vec(%f, %f, %f),\n'):format(unpack(map.editor.cam_pos)))
    file:write(('        cam_quat = %s,\n'):format(map.editor.cam_quat))
    file:write('    },\n')
    file:write('    env_cubes = {\n')
    file:write(("        dawn = %s,\n"):format(quoted_or_nil(map.env_cubes.dawn)))
    file:write(("        noon = %s,\n"):format(quoted_or_nil(map.env_cubes.noon)))
    file:write(("        dusk = %s,\n"):format(quoted_or_nil(map.env_cubes.dusk)))
    file:write(("        dark = %s,\n"):format(quoted_or_nil(map.env_cubes.dark)))
    file:write('    },\n')
    file:write('    environment = {\n')
    file:write(('        time = %s,\n'):format(map.environment.time))
    file:write(('        clock_rate = %s,\n'):format(map.environment.clock_rate))
    if map.environment.env_cycle_file then
        file:write('        env_cycle_file = `%s`,\n' % get_relative_path(filename, map.environment.env_cycle_file))
    else
        file:write('        env_cycle_file = nil,\n')
    end
    file:write('        sky = {\n')
    for name, body in pairs(env_sky) do
        file:write('            %s = { `%s`, %d },\n' % {name, get_relative_path(filename, body.meshName), body.zOrder})
    end
    file:write('        },\n')
    file:write('    },\n')
    file:write('    objects = {\n')

    -- A canonical order is important for diffs and version control merges.
    for name, object in spairs(map.objects or {}) do
        local class_name, obj_pos, body = object[1], object[2], object[3] or {}
        file:write(('        ["%s"] = {\n'):format(name))
        file:write(('            `%s`,\n'):format(get_relative_path(filename, class_name)))
        file:write(('            vec(%f, %f, %f),\n'):format(unpack(obj_pos)))
        file:write('            ')
        file:write(table.dump(body, true, 0, 12, false))
        file:write('\n')
        file:write('        },\n')
    end
    file:write('    },\n')
    file:write('}\n')
    file:close()
end
