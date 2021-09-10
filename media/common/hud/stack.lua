-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- The classes in this file are intended to be used together to define a hierarchy layout of HUD
-- objects.  The HUD objects must be statically sized, and the parents expand to accomodate the
-- children.  This works well for static forms and the like.


-- StackY takes a list of statically-sized HUD objects and positions them vertically.
--
-- The stack also resizes itself to wrap the objects, essentially turning them into a single
-- object.
--
-- The elements are separated by padding, the amount of which can be overridden.
--
-- By putting in a vec2 as an element, more space can be added.
--
-- By default the stack is aligned CENTRE, but this can be modified by inserting
-- { align = 'LEFT' } or 'RIGHT' into the list, which affects all subsequent elements.
hud_class `StackY` {

    padding = 0,

    init = function(self)
        self.alpha = 0
        self.contents = { }
        self.alignment = { }
        self.expandX = { }
        self.expandY = { }
        local default_alignment = 0
        local default_expand_x = false
        local default_expand_y = false
        local counter = 1
        local expanding = false
        for k, v in ipairs(self.table) do
            local content = nil
            local alignment = nil
            local expand_x = nil
            local expand_y = nil
            if type(v) == "table" then
                content = nil
                for mk, mv in pairs(v) do
                    if mk == "align" then
                        if mv == "LEFT" then
                            alignment = -1
                        elseif mv == "CENTRE" then
                            alignment = 0
                        elseif mv == "RIGHT" then
                            alignment = 1
                        else
                            gge_error("Unrecognised horizontal alignment: \""..tostring(mv).."\"")
                        end
                    elseif mk == 'content' then
                        content = mv
                    elseif mk == 'expandX' then
                        expand_x = mv
                    elseif mk == 'expandY' then
                        expand_y = mv
                    else
                        gge_error("Unrecognised modifier: "..tostring(mk))
                    end
                end
                v = content
                if v == nil then
                    -- Overriding defaults.
                    if alignment ~= nil then
                        default_alignment = alignment
                    end
                    if expand_x ~= nil then
                        default_expand_x = expand_x
                    end
                    if expand_y ~= nil then
                        default_expand_y = expand_y
                    end
                end
            end
            if type(v) == "vector2" then
                -- Make it look like a hud_object.
                v = { bounds=v }
            end
            if alignment == nil then
                alignment = default_alignment
            end
            if expand_x == nil then
                expand_x = default_expand_x
            end
            if expand_y == nil then
                expand_y = default_expand_y
            end
            if v then
                self.contents[counter] = v
                self.alignment[counter] = alignment
                self.expandX[counter] = expand_x
                if expand_y then
                    self.expandY[counter] = v.bounds.y
                end
                if expand_x or expand_y then
                    expanding = true
                end
                counter = counter + 1
                v.parent = self
            end
        end

        -- Calculate the min width and height of the stack.
        local w, h = 0, 0
        for k, v in ipairs(self.contents) do
            if k > 1 then
                h = h + self.padding
            end
            h = h + v.bounds.y
            w = math.max(w, v.bounds.x)
        end
        self.minSize = vec(w, h)
        self.size = vec(w, h)
        self:updateChildren(w)
        self.needsResizedCallbacks = expanding
    end,

    updateChildren = function(self)
        local num_expanders = 0
        -- Update expandable contents:
        for k, v in ipairs(self.contents) do
            if self.expandY[k] then
                num_expanders = num_expanders + 1
            end
        end
        local extra_space = self.size.y - self.minSize.y
        local extra_space_per_expander = 0
        if num_expanders > 0 then
            extra_space_per_expander = extra_space / num_expanders
        end
        for k, v in ipairs(self.contents) do
            local curr_size = v.bounds
            if self.expandX[k] then
                curr_size = vec(self.size.x, curr_size.y)
            end
            if self.expandY[k] then
                curr_size = vec(curr_size.x, self.expandY[k] + extra_space_per_expander)
            end
            if self.expandX[k] or self.expandY[k] then
                v.size = curr_size
            end
        end

        -- Update positions.
        local y = self.size.y / 2  -- Start at the top
        for k, v in ipairs(self.contents) do
            v.position = vec(self.alignment[k] * (self.size.x - v.bounds.x)/2, y - v.bounds.y/2)
            y = y - (v.bounds.y + self.padding)
        end
    end,

    resizedCallback = function(self)
        if self.size.x < self.minSize.x then
            -- Not wide enough, override width.
            self.size = vec(self.minSize.x, self.size.y)
            return
        end
        if self.size.y < self.minSize.y then
            -- Not tall enough, override height.
            self.size = vec(self.size.x, self.minSize.y)
            return
        end
        self:updateChildren()
    end,

    -- Recursively execute the same function on all nodes of the tree, if that function exists.
    callAll = function(self, funcname, ...)
        for k,v in ipairs(self.contents or { }) do
            local func = v[funcname]
            if func ~= nil then
                func(v, ...)
            else
                if v.callAll ~= nil then
                    v:callAll(funcname, ...)
                end
            end
        end
    end,

    destroy = function(self)
    end,
}


-- StackX takes a list of statically-sized HUD objects and positions them horizontally.
--
-- The stack also resizes itself to wrap the objects, essentially turning them into a single
-- object.
--
-- The elements are separated by padding, the amount of which can be overridden.
-- By putting in a vec2 as an element, more space can be added.
-- By default the stack is aligned CENTRE, but this can be modified by inserting
-- { align = 'TOP' } or 'BOTTOM' into the list, which affects all subsequent elements.
hud_class `StackX` {

    padding = 0,

    init = function(self)
        self.alpha = 0
        self.contents = { }
        self.alignment = { }
        self.expandX = { }
        self.expandY = { }
        local default_alignment = 0
        local default_expand_x = false
        local default_expand_y = false
        local counter = 1
        local expanding = false
        for k,v in ipairs(self.table) do
            local content = nil
            local alignment = nil
            local expand_x = nil
            local expand_y = nil
            if type(v) == "table" then
                for mk, mv in pairs(v) do
                    if mk == "align" then
                        if mv == "TOP" then
                            alignment = 1
                        elseif mv == "CENTRE" then
                            alignment = 0
                        elseif mv == "BOTTOM" then
                            alignment = -1
                        else
                            gge_error("Unrecognised vertical alignment: \""..tostring(mv).."\"")
                        end
                    elseif mk == 'content' then
                        content = mv
                    elseif mk == 'expandX' then
                        expand_x = mv
                    elseif mk == 'expandY' then
                        expand_y = mv
                    else
                        gge_error("Unrecognised modifier: "..tostring(mk))
                    end
                end
                v = content
            end
            if type(v) == "vector2" then
                v = { bounds=v }
            end
            if v == nil then
                -- Overriding defaults.
                if alignment ~= nil then
                    default_alignment = alignment
                end
                if expand_x ~= nil then
                    default_expand_x = expand_x
                end
                if expand_y ~= nil then
                    default_expand_y = expand_y
                end
            end
            if alignment == nil then
                alignment = default_alignment
            end
            if expand_x == nil then
                expand_x = default_expand_x
            end
            if expand_y == nil then
                expand_y = default_expand_y
            end
            if v then
                self.contents[counter] = v
                self.alignment[counter] = alignment
                if expand_x then
                    self.expandX[counter] = v.bounds.x
                end
                self.expandY[counter] = expand_y
                if expand_x or expand_y then
                    expanding = true
                end
                counter = counter + 1
                v.parent = self
            end
        end

        -- Calculate the min width and height of the stack.
        local h, w = 0, 0
        for k, v in ipairs(self.contents) do
            if k > 0 then
                w = w + self.padding
            end
            w = w + v.bounds.x
            h = math.max(h, v.bounds.y)
        end
        self.minSize = vec(w, h)
        self.size = vec(w, h)
        self:updateChildren()

        self.needsResizedCallbacks = expanding
    end,

    -- Set position of contents
    updateChildren = function(self)
        local num_expanders = 0
        -- Update expandable contents:
        for k, v in ipairs(self.contents) do
            if self.expandX[k] then
                num_expanders = num_expanders + 1
            end
        end
        local extra_space = self.size.x - self.minSize.x
        local extra_space_per_expander = 0
        if num_expanders > 0 then
            extra_space_per_expander = extra_space / num_expanders
        end

        for k, v in ipairs(self.contents) do
            local curr_size = v.bounds
            if self.expandX[k] then
                curr_size = vec(self.expandX[k] + extra_space_per_expander, curr_size.y)
            end
            if self.expandY[k] then
                curr_size = vec(curr_size.x, self.size.y)
            end
            if self.expandX[k] or self.expandY[k] then
                v.size = curr_size
            end
        end

        -- Update positions
        local x = -self.size.x / 2  -- Start at the left
        for k, v in ipairs(self.contents) do
            v.position = vec(x + v.bounds.x/2, self.alignment[k] * (self.size.y - v.bounds.y)/2)
            x = x + (v.bounds.x + self.padding)
        end
    end,

    resizedCallback = function(self)
        if self.size.x < self.minSize.x then
            -- Not wide enough, override width.
            self.size = vec(self.minSize.x, self.size.y)
            return
        end
        if self.size.y < self.minSize.y then
            -- Not tall enough, override height.
            self.size = vec(self.size.x, self.minSize.y)
            return
        end

        self:updateChildren()
    end,

    -- Recursively execute the same function on all nodes of the tree, if that function exists.
    callAll = function(self, funcname, ...)
        for k,v in ipairs(self.contents or { }) do
            local func = v[funcname]
            if func ~= nil then
                func(v, ...)
            else
                if v.callAll ~= nil then
                    v:callAll(funcname, ...)
                end
            end
        end
    end,

    destroy = function(self)
    end,
}


-- Border puts a border around a single object.  It introduces a bit of extra padding.
hud_class `Border` {

    padding = vec(4, 4),
    texture = `CornerTextures/Border02.png`,
    size = vec(1, 1),
    cornered = true,
    expand = false,

    init = function(self)
        self.child.parent = self
        self.size = self.child.bounds + 2 * self.padding
        self.minSize = self.size
        self.needsResizedCallbacks = self.expand
    end,

    resizedCallback = function(self)
        if self.size.x < self.minSize.x then
            -- Not wide enough, override width.
            self.size = vec(self.minSize.x, self.size.y)
            return
        end
        if self.size.y < self.minSize.y then
            -- Not tall enough, override height.
            self.size = vec(self.size.x, self.minSize.y)
            return
        end
        self.child.size = self.size - vec(2, 2) - 2 * self.padding
    end,

    callAll = function(self, funcname, ...)
        local func = self.child[funcname]
        if func ~= nil then
            func(self.child, ...)
        else
            if self.child.callAll ~= nil then
                self.child:callAll(funcname, ...)
            end
        end
    end,

    destroy = function(self)
    end,
}

