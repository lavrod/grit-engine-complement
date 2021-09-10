-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

V_ZERO  = vector3(0, 0, 0)
V_ID    = vector3(1, 1, 1)
V_NORTH = vector3(0, 1, 0)
V_SOUTH = vector3(0, -1, 0)
V_EAST  = vector3(1, 0, 0)
V_WEST  = vector3(-1, 0, 0)
V_UP    = vector3(0, 0, 1)
V_DOWN  = vector3(0, 0, -1)

V_FORWARDS  = V_NORTH
V_BACKWARDS = V_SOUTH
V_ABOVE     = V_UP
V_BELOW     = V_DOWN
V_LEFT      = V_WEST
V_RIGHT     = V_EAST

Q_ID = quat(1, 0, 0, 0)

-- Quaternions are orientation *changes*, just like vectors are really position
-- *changes*.  As such, to use a quaternion as an orientation, we need a base
-- direction, just like we need a base vector vector3(0,0,0) to use vectors for
-- position data.  For everything grit-specific the base direction is V_NORTH.

Q_NORTH = quat(V_NORTH, V_NORTH)
Q_SOUTH = quat(V_NORTH, V_SOUTH)
Q_EAST  = quat(V_NORTH, V_EAST)
Q_WEST  = quat(V_NORTH, V_WEST)
Q_UP    = quat(V_NORTH, V_UP)
Q_DOWN  = quat(V_NORTH, V_DOWN)

Q_FORWARDS  = Q_NORTH
Q_BACKWARDS = Q_SOUTH
Q_ABOVE     = Q_UP
Q_BELOW     = Q_DOWN
Q_LEFT      = Q_WEST
Q_RIGHT     = Q_EAST

function euler (x, y, z)
        return quat(z, V_UP) * quat(y, V_NORTH) * quat(x, V_EAST)
end

function tensor (q)
    -- q.axis returns an error if the axis is degenerative
    local axis = vec(q.x, q.y, q.z)
    local axis_len = #axis
    if axis_len > 0 then
        local angle = q.angle
        if angle > 180 then
            angle = angle - 360
        end
        return angle * axis / axis_len
    end
    return vec(0, 0, 0)
end

METRES_PER_MILE = 1609

RESET = "\027[0m"
BOLD = "\027[1m"
NOBOLD = "\027[22m"
UNDERLINE = "\027[4m"
NOUNDERLINE = "\027[24m"
REVERSE = "\027[6m"
NOREVERSE = "\027[27m"
BLACK = "\027[30m"
RED = "\027[31m"
GREEN = "\027[32m"
YELLOW = "\027[33m"
BLUE = "\027[34m"
MAGENTA = "\027[35m"
CYAN = "\027[36m"
WHITE = "\027[37m"

function echo (...)
    gge_print(...)
    gge_print(BOLD..CYAN.."echo() is deprecated.  Please use gge_print() instead.  Use print_stdout() for the old Lua gge_print.")
end

function none_one_or_all(tab, f)
        if tab == nil then return end
        if type(tab)=="table" then
                for _,se in ipairs(tab) do f(se) end
        else    
                f(tab)
        end
end

--gge_print = gge_print


function time(f,...)
        local before = gge_seconds()
        f(...)
        local after = gge_seconds()
        return after - before
end

function time_micros(f, ...)
        local before = gge_micros()
        f(...)
        local after = gge_micros()
        return after - before
end

function gc()
    collectgarbage("collect")
end


function rgb (r,g,b) return vector3(r,g,b)/255 end
function srgb(r,g,b) return rgb(r,g,b) ^ 2.2 end

function gamma_encode(x) return x ^ (1/2.2) end
function gamma_decode(x) return x ^ 2.2 end

function colour_norm (r,g,b)
        local luminance = math.max(math.max(r,g),b)
        return r/luminance, g/luminance, b/luminance
end
function colour_desaturate (r,g,b, amt)
        local luminance = (r+g+b)/3
        local r1,g1,b1 = luminance,luminance,luminance
        return lerp(r1,r,amt), lerp(g1,g,amt), lerp(b1,b,amt)
end

function tone_map (v)
    v = v * gfx_global_exposure()
    return gfx_colour_grade_look_up(gamma_encode(v / (1 + v)))
end

function tone_map_val (v)
    local c = RGBtoHSV(v)
    return HSVtoRGB(vector3(c.x, c.y, c.z/(1+c.z)))
end

function colour_ensure_vector3 (t) 
        if type(t) == "table" then
                return vector3(t[1], t[2], t[3])
        elseif type(t) == "number" then -- 0xRRGGBB
                local b = t % 256
                t = (t - b)/256
                local g = t % 256
                t = (t - g)/256
                local r = t % 256
                t = (t - r)/256
                return rgb(r,g,b)
        end
        return t
end

function do_nothing() end


function random_colour()
    return vector3(math.random(),math.random(),math.random())
end 

function random_vector3_plane_z()
    local a = math.random()*math.pi*2
    local x = math.cos(a)
    local y = math.sin(a)
    return vector3(x,y,0)
end 

function random_vector3_box(min, max)
    min = min or vector3(-1,-1,-1)
    max = max or vector3(1,1,1)
    return vector3(min.x+math.random()*(max.x-min.x), min.y+math.random()*(max.y-min.y), min.z+math.random()*(max.z-min.z))
end 

function random_vector3_sphere()
        while true do
                local r = random_vector3_box()
                local l = #r
                if l <= 1 then return r/l end
        end
end 


function yaw(x, y)
        return math.deg(math.atan2(x,y))
end

function pitch (z)
        return math.deg(math.asin(z))
end

function yaw_pitch (v)
        if type(v) == 'quat' then
            v = v * vec(0, 1, 0)
        end
        local yaw = math.deg(math.atan2(v.x, v.y))
        local pitch = math.deg(math.asin(v.z))
        return yaw, pitch
end


function clamp(v,bot,top)
        if v < bot then return bot end
        if v > top then return top end
        return v
end

function invlerp(v0, v1, vb)
    return (vb - v0)/(v1 - v0)
end

function lerp(v0, v1, a)
        return (1-a)*v0 + a*v1
end

function lerp2(v00, v01, v10, v11, a)
        return lerp(lerp(v00, v01, a.x), lerp(v10, v11, a.x), a.y)
end

function lerp3(v000, v001, v010, v011, v100, v101, v110, v111, a)
        local a2 = vector2(a.x, a.y)
        return lerp(lerp2(v000, v001, v010, v011, a2), lerp2(v100, v101, v110, v111, a2), a.z)
end

function nonzero(v)
        return v==0 and 1 or v
end

function between(v,here1,here2)
        local bot, top = math.min(here1,here2), math.max(here1,here2)
        return v >= bot and v <= top 
end

function sign(v)
        if v==0 then return 0 end
        return v<0 and -1 or 1
end


function table.clone(tab)
        local r = {}
        for k,v in pairs(tab or {}) do r[k] = v end
        return r
end

function find(haystack, needle)
    for k, v in pairs(haystack) do
        if v == needle then
            return k
        end
    end
end

function filter(tab,c)
        local r = {}
        for _,v in ipairs(tab) do
                if c(v) then
                        table.insert(r,v)
                end
        end
        return r
end

function tabmap(tab,f)
        local r = {}
        for k,v in pairs(tab) do
                local k2, v2 = f(k,v)
                r[k2] = v2
        end
        return r
end

function map(tab,f)
        local r = {}
        for _,v in ipairs(tab) do
                table.insert(r,f(v))
        end
        return r
end

function foreach(tab,f)
        if tab==nil then return end
        for k,v in ipairs(tab) do
                f(v,k)
        end
end

function swapeach(tab,f)
        for k,v in ipairs(tab) do
                tab[k] = f(v)
        end
end

function isarray(tab)
        local sz = #tab
        local count = 0
        for k,_ in pairs(tab) do
                if type(k)~="number" then return false end
                if k < 1 then return false end
                if k > sz then return false end
                count = count + 1
        end
        return count == sz
end

-- NOTE: This function is called by C code.
function dump(obj,colour,n,d,ind)
        n = n or 100
        d = d or 0
        if colour == nil then colour = true end
        local t = type(obj)
        if t == 'string' then
                return '\"'..obj..'\"'
        elseif t == 'table' then
                if d == 4 then return tostring(t) end
                local mt = getmetatable(obj)
                if mt and mt.__dump then
                        return mt.__dump(obj, colour, n, d+1, ind)
                else
                        return table.dump(obj, n, d+1, ind, colour)
                end
        else
                return tostring(obj)
        end
end

function table.keys(tab, limit)
        limit = limit or 100
        local keys = {}
        local max_key_len = 0
        local counter = 0
        for k,v in spairs(tab) do
            if limit ~= true and counter >= limit then
                return keys, counter, max_key_len
            end
            keys[#keys+1] = k
            local key_len = #tostring(k)
            if max_key_len < key_len then
                max_key_len = key_len
            end
            counter = counter + 1
        end
        return keys, counter, max_key_len
end

function table.dump(tab, n, d, ind_level, colour)
    assert(tab ~= nil)
    d = d or 0
    ind_level = ind_level or 0
    if colour == nil then colour = true end
    local new_ind_level = ind_level + 2
    n = n or 100
    local r = ""
    local ind = (" "):rep(ind_level)
    local ind2 = (" "):rep(new_ind_level)
    if isarray(tab) then
        if #tab == 0 then
            return '{}'
        end
        if #tab <= 20 then
            r = r .. '{'
            local sep = ' '
            for _,v in ipairs(tab) do
                r = r .. sep .. dump(v, colour, n, d, ind_level)
                sep = ', '
            end
            r = r .. ' }'
        else
            r = r .. '{\n'
            for _,v in ipairs(tab) do
                r = r .. ind2 .. dump(v, colour, n, d, new_ind_level) .. ',\n'
            end
            r = r .. ind .. '}'
        end
    else
        local keys, counter, max_key_len = table.keys(tab, n)
        table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)
        r = r .. '{'
        local key_counter = 1
        for k, v in ipairs(keys) do
            r = r.."\n"..ind2
            local key
            if type(v) == 'number' then
                if key_counter == v then
                    key = nil
                else 
                    key = '[' .. tostring(v) .. ']'
                end
            else
                if string.match(v, '^[A-Za-z_][A-Za-z0-9_]*$') then
                    key = tostring(v)
                else
                    key = '["' .. tostring(v) .. '"]'
                end
            end
            key_counter = key_counter + 1
            local val = dump(tab[v], colour, n, d, new_ind_level)
            if key ~= nil then
                r = r..(colour and GREEN or "")..key..(colour and RESET or "")..(colour and BOLD or "")
                r = r..(" "):rep(max_key_len-#key)
                r = r.." = "..(colour and NOBOLD or "")
            end
            r = r..val..','
        end
        if n ~= true and counter > n then
            r = r.."\n"..ind2.."(and "..tostring(counter-n).." more...)"
        end
        r = r .. '\n' .. ind .. '}'
    end
    return r
end

function table.unique (tab)
        local r = { }
        for _,v in ipairs(tab) do
                r[v] = true
        end
        local r2 = { }
        for k,_ in pairs(r) do
                r2[#r2+1] = k
        end
        return r2
end

function pretty_matrix (...)
        return string.format("╭                                     ╮\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "│ % 8.4f % 8.4f % 8.4f % 8.4f │\n"..
                             "╰                                     ╯", ...)
end

function format_time (secs)
    secs = secs or 0
    return string.format("%02d:%02d:%02d", math.mod(math.floor(secs/60/60),24),
                                           math.mod(math.floor(secs/60),60),
                                           math.mod(secs,60))
end

function parse_time (str)
    local function throw() gge_error("Invalid time: \""..str.."\"", 1) end
    if #str ~= 8 then throw() end
    for i=1,8 do
        local char = str:sub(i,i)
        if i==3 or i==6 then
            if char ~= ":" then throw() end
        else
            if char ~= "0" and
               char ~= "1" and
               char ~= "2" and
               char ~= "3" and
               char ~= "4" and
               char ~= "5" and
               char ~= "6" and
               char ~= "7" and
               char ~= "8" and
               char ~= "9" then
                throw()
            end
        end
    end
    local iter = str:gmatch("[^:]+")
    local hours = tonumber(iter())
    local mins = tonumber(iter())
    local secs = tonumber(iter())
    if hours >= 24 then throw() end
    if mins >= 60 then throw() end
    if secs >= 60 then throw() end
    return (hours * 60 + mins) * 60 + secs
end


-- thanks rici!
function memoize(func, t)
        return setmetatable(t or {}, {__index = function(t, k)
                local v = func(k);
                t[k] = v;
                return v;
        end })
end

-- thanks ToxicFrog!
function string.split(s, pat) 
        local i, result = 1, {} 
        if not pat or pat == "" then return s end 
        while i do 
                local b, e = s:find(pat, i) 
                if b then b = b - 1 end 
                table.insert(result, s:sub(i, b)) 
                i = e 
                if i then i = i + 1 end 
        end 
        return result
end 

-- Iterate over the key/pairs in the table, sorted by key.
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys, function(a, b)
            local a_t = type(a) == 'number' and 0 or 1
            local b_t = type(b) == 'number' and 0 or 1
            if a_t ~= b_t then return a_t < b_t end
            return a < b
        end)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--[[
function check_args(types,...)
        if #types~=#{...} then
                gge_error("Expected "..#types.." args, got "..#{...}..".",3)
        end
        for k,v in ipairs({...}) do
                if type(v) ~= types[k] then
                        gge_error("Argument "..k.." expected "..types[k].." got "..type(v)..".")
                end
        end
        return ...
end
--]]

if fresh_counter == nil then
        fresh_counter = 0
end
function fresh ()
        local tmp = fresh_counter
        fresh_counter = fresh_counter + 1
        return tmp
end

function extends (parent)
        return function(child)
                for k,v in pairs(parent) do
                        if child[k] == nil then
                                child[k] = v
                        end
                end
                return child
        end
end

function extends_keep_existing(existing, parent)
    return function (child)
        if existing == nil then
            existing = child
        end
        for k,v in pairs(parent) do
                if child[k] == nil then
                        existing[k] = v
                end
        end
        return existing
    end
end

function make_instance_mt(class,fr,fw,fts)
        if type(fts) ~= "function" then fts = function() return fts end end
        if fr == nil and fw == nil then
                -- Optimized case.
                return {
                        __index = function(t,k) 
                                return class[k]
                        end,
                        __newindex = function(t,k,v)
                                if class[k] ~= nil then
                                        class[k] = v
                                else
                                        rawset(t,k,v)
                                end
                        end,
                        __tostring = fts
                }
        end
        fr = fr or function() return nil end
        fw = fw or function() return nil end
        return {
                __index = function(t,k) 
                        local use,value = fr(k) 
                        if use then return value end
                        return class[k]
                end,
                __newindex = function(t,k,v)
                        if class[k] ~= nil then
                                class[k] = v
                        else
                                if fw(k,v)==nil then
                                        rawset(t,k,v)
                                end
                        end
                end,
                __tostring = fts
        }
end

function make_instance(obj,class,fr,fw,fts)
        return setmetatable(obj, make_instance_mt(class,fr,fw,fts))
end

function safe_destroy(obj)
        if obj==nil then return end
        if type(obj)~="userdata" and type(obj)~="table" then return end
        local d = obj.destroy
        if d == nil then return end
        d(obj)
end




-- mapping from name (string) to function
CallbackReg = { } 
-- can't use varags because they cannot be captured in closures
-- use executeExtended if 4 params is not enough
function CallbackReg:execute (p1, p2, p3, p4)
        local broken_callbacks
        for _,record in ipairs(self.callBacks) do
                local _, cb = unpack(record)
                local status, continue = xpcall(function() return cb(p1, p2, p3, p4) end, gge_error_handler)
                if status then
                        broken_callbacks = broken_callbacks or { }
                        broken_callbacks[#broken_callbacks] = record
                end
                if continue == false then return false end
        end
        if broken_callbacks then
                for _,v in ipairs(broken_callbacks) do
                        self:removeByName(record[1])
                end
        end
        return true
end
function CallbackReg:executeExtended (f,...)
        for _,record in ipairs(self.callBacks) do
                local name, cb = unpack(record)
                local continue = f(name,cb,...)
                if continue == false then return false end
        end
end
function CallbackReg:clear(...)
        self.callBacks = {}
end
function CallbackReg:removeByName(name,...)
        local tab = {}
        for _,record in ipairs(self.callBacks) do
                if record[1]~=name then
                        table.insert(tab,record)
                else
                        record[2] = function () end
                end
        end
        self.callBacks = tab
end
function CallbackReg:getIndex(name,...)
        for k,v in ipairs(self.callBacks) do
                if v[1] == name then
                        return k
                end
        end
end
function CallbackReg:getIndexSafe(name,...)
        local tmp = self:getIndex(name)
        if tmp==nil then
                gge_error("Couldn't find a callback called \""..name.."\"",3)
        end
        return tmp
end
function CallbackReg:insert(name,cb,pos)
        pos = pos or #self.callBacks+1
        table.insert(self.callBacks,pos,{name,cb})
end
function CallbackReg.new()
        local self = {}
        self.callBacks = {} --initially empty
        make_instance(self,CallbackReg)
        return self
end


RunningStats = {}
function RunningStats:calcMin()
        local max
        for _,v in ipairs(self.recordedValues) do
                max = max or v
                max = math.min(v,max)
        end     
        return max
end
function RunningStats:calcMax()
        local max
        for _,v in ipairs(self.recordedValues) do
                max = max or v
                max = math.max(v,max)
        end     
        return max
end
function RunningStats:calcAverage()
        local total = 0
        for _,v in ipairs(self.recordedValues) do
                total = total + v
        end     
        return total / #self.recordedValues
end
function RunningStats:add(v)
        table.remove(self.recordedValues)
        table.insert(self.recordedValues,1,v)
end
function RunningStats.new(n)
        local self = { recordedValues = {} }
        for i=1,n do
                self.recordedValues[i] = 0
        end
        return make_instance(self,RunningStats)
end

function killobj(x)
        if x.destroyed then return end
        local near = x.near
        local far = x.far
        x:destroy()
        if x.near then
                killobj(x)
        end
        if x.far then
                killobj(x)
        end
end


function verify_input(v, spec, level)
        level = level and (level+1) or 2
        local simple_types = {
            ['string'] = true,
            ['number'] = true,
            ['vector2'] = true,
            ['vector3'] = true,
            ['vector4'] = true,
            ['quat'] = true,
        }
        if spec[1] == "one of" then
                for i=2,#spec do
                        if v == spec[i] then return end
                end
                local str ="\""..tostring(v).."\" unacceptable, try "
                local sep = ""
                for i=2,#spec do
                        str = str..sep..tostring(spec[i])
                        sep = ", "
                        if i==#spec-1 then
                                sep = sep.."or "
                        end
                end
                gge_error(str,level)
        elseif spec[1] == "range" then
                verify_input(v, {"number"}, level+1)
                local low, high = spec[2], spec[3]
                if v < low or v > high then
                        local str ="\""..tostring(v).."\" unacceptable, must be inside "..low.." to "..high
                        gge_error(str,level)
                end
        elseif spec[1] == "int range" then
                verify_input(v, {"int"}, level+1)
                local low, high = spec[2], spec[3]
                if v < low or v > high then
                        local str ="\""..tostring(v).."\" unacceptable, must be inside "..low.." to "..high
                        gge_error(str,level)
                end
        elseif simple_types[spec[1]] ~= nil then
                if type(v) ~= spec[1] then
                        local str ="\""..tostring(v).."\" unacceptable, must be a '" .. spec[1]
                        gge_error(str,level)
                end
        elseif spec[1] == "int" then
                verify_input(v, {"number"}, level+1)
                if math.floor(v) ~= v then
                        local str ="\""..tostring(v).."\" unacceptable, must be an integer"
                        gge_error(str, level)
                end
        elseif spec[1] == "table" then
                local size = spec[2]
                if type(v) ~= "table" then
                        local str ="\""..tostring(v).."\" unacceptable, must be a table"
                        gge_error(str,level)
                end
                if #v ~= size then
                        local str ="array unacceptable, must have exactly "..size.." elements"
                        gge_error(str,level)
                end
                for i=1,size do
                        if spec[2+i] then
                                verify_input(v[i], spec[2+i], level+1)
                        end
                end
        else
                gge_error("Unrecognised specification: "..tostring(spec[1]))
        end
end


-- Makes tab into an "active table".
--
-- An active table is one where modifying fields causes automatic changes to wider engine.  A key
-- feature of the active table is the autoUpdate field, which allows the batching of changes.  For
-- example if two changes both force recompilation of shaders, which takes time, we would like to be
-- able to change both settings and then recompile the shaders.  To accomplish this, use the
-- following pattern:
--
-- active_table.autoUpdate = false
-- active_table.setting1 = 'foo'
-- active_table.setting2 = 'bar'
-- active_table.autoUpdate = true
--
-- Internally, the settings are stored in two tables 'committed' and 'proposed'.  When a change is
-- made with autoUpdate is on, or when autoUpdate is turned on after some changes, the values in
-- 'proposed' are copied into 'committed' and put into effect via calling the 'commit' function.
-- Since autoUpdate is initially false, it must be set to true in order to bootstrap the settings
-- and set the initial (default) configuration (passed via 'tab').
--
-- While autoUpdate is false, you can call :abort() on the table to undo the changes, which also
-- sets autoUpdate back to true.
--
-- Additionally, the veritication table gives a specification for what values are allowed for each
-- setting.  This is checked on every assignment (even if autoUpdate is false).
function make_active_table(tab, verification, commit)

    local committed = { autoUpdate = false }
    local proposed = { }

    for k, v in pairs(tab) do
        proposed[k] = v
    end

    for k, _ in pairs(tab) do
        tab[k] = nil
    end

    tab.committed = committed
    tab.proposed = proposed
    tab.spec = verification
    tab.commit = commit

    tab.abort = function(self)
        for k, v in pairs(tab.committed) do
            if k ~= 'autoUpdate' then
                tab.proposed[k] = tab.committed[k]
            end
        end
        tab.autoUpdate = true
    end

    tab.reset = function(self)
        self.commit(self.committed, self.proposed, true)
    end

    setmetatable(tab, {
        __index = function (self, k)
            local v = self.committed[k]
            if v == nil then gge_error('No such setting: "' .. k .. '"', 2) end
            return v
        end,

        __newindex = function (self, k, v)
            if k == 'autoUpdate' then
                verify_input(v, { 'one of', false, true })
                self.committed[k] = v
            else
                local spec = self.spec[k]
                if spec == nil then gge_error('No such setting: "' .. k .. '"', 2) end
                verify_input(v, spec, 2)
                self.proposed[k] = v
            end
            if not self.committed.autoUpdate then return end
            self.commit(self.committed, self.proposed)
        end,

        __dump = function(self, ...)
            return dump(self.committed, ...)
        end
    })

end


-- their days are numbered
function ensure_array(v, size)
        verify_input(v,{"array", size},2)
end

function ensure_number(v, level)
        verify_input(v,{"number"},2)
end

function ensure_range(v, low, high)
        verify_input(v,{"range", low, high},2)
end

function ensure_int(v, level)
        verify_input(v,{"int"},level+1)
end

function ensure_int_range(v, low, high)
        verify_input(v,{"int range", low, high},2)
end

function ensure_one_of(v, allowed)
        verify_input(v,{"one of", unpack(allowed)},2)
end


local running_map = nil

function map_ghost_spawn(pos, quat)
    if running_map ~= gge_current_dir() then
		main.camPos = pos
		main.camQuat = quat or Q_ID
        --warp(pos, quat or Q_ID) --Not sure what to do here, it was removed when player_ctrl was removed so I just added in the new way above.
        running_map = gge_current_dir()
        return true
    end
end

function valid_object(obj) if obj and obj.instance and not obj.destroyed then return true else return false end end

dialogObjects = {}

function showDialog(subject, message, options, functioncall)--showDialog("Subject", "Grit Engine", {"Red","Green","Blue"}, gge_print)
	if subject == nil then subject = "Dialog" end
	if message ~= nil and functioncall ~= nil then
		local dialogsToDelete = {}
		local dialogWindowID = #dialogObjects+1
		dialogObjects[dialogWindowID] = gui.window(subject, vec2(-1000,-1000), false, vec2(600, 200))
		table.insert(dialogsToDelete, dialogWindowID)
		local dialogTextID = #dialogObjects+1
		dialogObjects[dialogTextID] = hud_object `../common/hud/Label` {
			value = message;
			size = vec(600, 150);
			colour = 0.25 * vec(1, 1, 1);
			parent = dialogObjects[dialogWindowID].contentArea;
			position = vec2(0, 25);
		}
		table.insert(dialogsToDelete, dialogTextID)
		if options ~= nil then
			for i=1,#options do
					local dialogButtonID = #dialogObjects+1
					dialogObjects[dialogButtonID] = hud_object `../common/hud/Button` {
						caption = options[i];
						parent = dialogObjects[dialogWindowID].contentArea;
						size = vec(600/#options, 50);
						position = vec(-600+(600/#options/2+((i)*600/#options)),-75);
						functiontocall = functioncall;
						pressedCallback = (function (self) 
							dialogObjects[dialogWindowID].position = vec2(-1000,-1000)
							dialogObjects[dialogButtonID].functiontocall(i) 
							dialogsToDelete = dialogsToDelete
							for i=1,#dialogsToDelete do
								dialogObjects[i] = nil
								dialogsToDelete[i] = nil
							end
						end);
					}
					table.insert(dialogsToDelete, dialogButtonID)
			end
		end
		dialogObjects[dialogWindowID].position = vec2(0,0)
		dialogObjects[dialogWindowID].zOrder = 7
	else
		gge_print("Dialog message is not valid!")
	end
end

-- all tab2 keys are copied to tab1
function table.concatto(tab1, tab2)
	if tab1 == nil and tab2 ~= nil then return tab2 end
	if tab2 == nil and tab1 ~= nil then return tab1 end

	for k, v in pairs(tab2) do
		if type(k) == "number" then
			tab1[#tab1+1] = v
		else
			tab1[k] = v
		end
	end
   return tab1
end

-- returns a combination of all tab1 and tab2 keys (tab2 overwrite tab1 keys)
function table.extends(tab1, tab2)
	if tab1 == nil and tab2 ~= nil then return tab2 end
	if tab2 == nil and tab1 ~= nil then return tab1 end

	local ntb = {}
	
	for k, v in pairs(tab1) do
		if type(k) == "number" then
			ntb[#ntb+1] = v
		else
			ntb[k] = v
		end
	end
	for k, v in pairs(tab2) do
		if type(k) == "number" then
			ntb[#ntb+1] = v
		else
			ntb[k] = v
		end
	end	
	
   return ntb
end

function get_extension(str)
   return str:match("[^.]+$")
end

function quatPitch(q)
	return math.deg(math.atan2(2*(q.y*q.z + q.w*q.x), q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z))
end

function mouse_pick_pos(bias, safe)
	local cast_ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
	local dist = physics_cast(main.camPos, cast_ray, true, 0)
	if dist then
		return (main.camPos + cast_ray * dist)
	end
end

function dirname(file)
    return file:match('^(.*)/[^/]*$')
end

-- Get a path from one file to another.
function get_relative_path(from_here, to_here)
    local dir = dirname(from_here) .. '/'
    if to_here:sub(1, #dir) == dir then
        return to_here:sub(#dir + 1)
    else
        return to_here
    end
end

function assert_path(path)
    assert(path:sub(1, 1) == '/', ('"%s" did not begin with /'):format(path))
end

function assert_path_file_type(path, file_type)
    assert_path(path)
    assert(path:sub(-1 - #file_type, -1) == '.'..file_type, ('"%s" did not end in .%s'):format(path, file_type))
end
