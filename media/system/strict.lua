-- Sourced from the Lua project

--
-- strict.lua
-- checks uses of undeclared global variables
-- All global variables must be 'declared' through a regular assignment
-- (even assigning nil will do) in a main chunk before being used
-- anywhere or assigned to inside a function.
--

do

        local mt = getmetatable(_G)
        if mt == nil then
                mt = {}
                setmetatable(_G, mt)
        end

        -- holds a list of all declared global variables
        mt.__declared = {}

        -- initialise it with existing global variables
        for k,v in pairs(_G) do
                mt.__declared[k] = true
        end

        -- if you attempt to write to a new global variable, and you are not in
        -- the main chunk of a lua file, and you are not in C code, then give
        -- an error
        mt.__newindex = function (t, n, v)
                if not mt.__declared[n] then
                        local w = (debug.getinfo(2, "S") or {}).what
                        if w ~= "main" and w ~= "C" then
                                gge_error("assign to undeclared variable '"..tostring(n).."'", 2)
                        end
                        mt.__declared[n] = true
                end
                rawset(_G, n, v)
        end
          
        -- if you attempt to read from a non-existant global variable, you get an error
        mt.__index = function (t, n)
                if not mt.__declared[n] then
                        local w = (debug.getinfo(2, "S") or {}).what
                        if w ~= "main" and w ~= "C" then
                                gge_error("variable '"..tostring(n).."' is not declared", 2)
                        end
                end
                return rawget(_G, n)
        end

end

