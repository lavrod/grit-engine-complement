-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- use globals to avoid memory allocation and subsequent GC overhead when creating a closure
local curried_name
local pile_curried_name

local class_ext
local function new_class3 (tab)
    return class_add(curried_name, class_ext or {}, tab)
end
local function new_class2 (ext)
    if type(ext) == "table" then
        return class_add(curried_name, {}, ext)
    else
        class_ext = ext
        return new_class3
    end
end
function new_class (name)
    curried_name = name
    return new_class2
end
        
-- Deprecated
local function old_class3 (tab)
    return class_add(curried_name, class_ext or {}, tab)
end
local function old_class2 (ext)
    class_ext = ext
    return old_class3
end
function old_class (name)
    curried_name = name
    return old_class2
end

class = old_class

        
local function hud_class2 (tab)
    local super = nil
    if type(tab) == 'string' then
        super = hud_class_get(tab)
    elseif type(tab) == 'userdata' then
        super = tab
    end
    if super ~= nil then
        return function (tab)
            return hud_class_add(curried_name, extends(super.dump)(tab))
        end
    else
        return hud_class_add(curried_name, tab)
    end
end
function hud_class (name)
    curried_name = name
    return hud_class2
end
        
local inside_pile = false
local function pile2 (tab)
    inside_pile = false
    return class_add(pile_curried_name,PileClass,tab)
end
function pile (name)
    pile_curried_name = name
    inside_pile = true
    return pile2
end

local obj_off = vec(0, 0, 0)
local obj_pos
local function object3 (tab)
    if not class_has(curried_name) then
        gge_error("Trying to create an object using non-existent class \""..curried_name.."\"",2)
    end
    if inside_pile then
        return { curried_name, obj_pos, tab }
    end
    local hid = object_add(curried_name, obj_pos, tab)
    local lod = class_get(curried_name).lod
    if lod == true then
        if curried_name:find("/") then
            lod = curried_name:reverse():gsub("/","_dol/",1):reverse()
        else
            lod = "lod_"..curried_name
        end
    end
    if lod then
        if class_get(lod) then
            tab.near = hid
            if tab.name then tab.name = tab.name.."_lod" end
            object_add(lod, obj_pos, tab)
        else
            gge_error("Class \""..curried_name.."\" referred to a lod class \""..lod.."\" that does not exist.")
        end
    end
    return hid
end
local function object2 (x,y,z)
    if type(x) == "vector3" then
        obj_pos = obj_off + x
    else
        obj_pos = obj_off + vector3(x,y,z)
    end
    return object3
end
function object (class)
    curried_name = class
    return object2
end
function offset_exec (off, f, ...)
    obj_off = obj_off + off
    f(...)
    obj_off = obj_off - off
end
function offset_include (x,y,z, str) offset_exec(vec(x,y,z),gge_include,str) end
        
local function physical_material2 (tab) 
    local mat = { }
    return physics:setMaterial(curried_name, tab)
end
function physical_material (name)
    curried_name = name
    return physical_material2
end

local function procedural_batch2 (tab) 
    local tab2 = { }
    for k,v in pairs(tab) do
        tab2[k] = v
    end
    return physics:setProceduralBatchClass(curried_name, tab2)
end
function procedural_batch (name)
    curried_name = name
    return procedural_batch2
end

local function procedural_object2 (tab) 
        return physics:setProceduralObjectClass(curried_name, tab)
end
function procedural_object (name)
    curried_name = name
    return procedural_object2
end

local function sky_material2(tab)
    local name = curried_name
    gfx_register_sky_material(name,tab)
end
function sky_material(name)
    curried_name = name
    return sky_material2
end

local function shader2(tab)
    local name = curried_name
    tab = tab or {}
    gfx_register_shader(name, tab)
end
function shader(name)
    curried_name = name
    return shader2
end

function uniform_texture_1d(r, g, b, a)
    a = a or 1
    local tab2 = {
        uniformKind = "TEXTURE1D";
        defaultColour = vec(r, g, b);
        defaultAlpha = a;
    }
    return tab2
end

function uniform_texture_2d(r, g, b, a)
    a = a or 1
    local tab2 = {
        uniformKind = "TEXTURE2D";
        defaultColour = vec(r, g, b);
        defaultAlpha = a;
    }
    return tab2
end

function uniform_texture_3d(r, g, b, a)
    a = a or 1
    local tab2 = {
        uniformKind = "TEXTURE3D";
        defaultColour = vec(r, g, b);
        defaultAlpha = a;
    }
    return tab2
end

function uniform_texture_cube(r, g, b, a)
    a = a or 1
    local tab2 = {
        uniformKind = "TEXTURE_CUBE";
        defaultColour = vec(r, g, b);
        defaultAlpha = a;
    }
    return tab2
end

function uniform_float(...)
    local tab = { ... }
    tab.uniformKind = "PARAM"
    tab.valueKind = "FLOAT"
    return tab
end

function static_float(...)
    local tab = { ... }
    tab.static = true
    tab.uniformKind = "PARAM"
    tab.valueKind = "FLOAT"
    return tab
end

local function material2(tab)
    local name = curried_name
    tab = tab or {}
    register_material(name,tab)
end
function material(name)
    curried_name = name
    return material2
end

local function particle2(tab)
    local name = curried_name
    local tab2 = {}
    for k,v in pairs(tab) do
        tab2[k] = v
    end
    gfx_particle_define(name,tab2)
end
function particle(name)
    curried_name = name
    return particle2
end

function hud_object(name)
    -- Has to support nesting, so do not use curried_name global.
    return function (tab)
        return hud_object_add(name, tab)
    end
end
