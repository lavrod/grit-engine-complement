------------------------------------------------------------------------------
--  This is the widget manager class, creates and manages the widget object
--
--  (c) 2014-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO:
-- Select objects without collision
-- Select sounds, particles

local dummy_bounds = vec(2, 2, 0.2)
local arrow_bounds = vec(1, 8, 1)

widget_manager = {
    clipboard = {},
    widget = nil,
    dragComponent = nil,  -- nil if we're not currently dragging, otherwise the axis / plane
    mode = "translate",  -- 'global', 'rotate'
    spaceMode = "global",  -- "global", "local"
    pivotPoint = "centre point",  -- "individual origins", "active object" or "centre point"
    gridSize = 0.5,  -- When using grid snap, what to snap to.
}

-- reference: math_geom.c from Blender
local function isect_line_plane(line_a, line_b, plane_pos, plane_normal)
    local u = line_b - line_a
    local dot_p = dot(plane_normal, u)

    if math.abs(dot_p) > 1e-6 then
        local w = line_a - plane_pos
        local fac = -dot(plane_normal, w) / dot_p
        u = u * fac
        return line_a + u
    else -- parallel to plane
        return
    end
end

function widget_manager:updateWidget()
    local editor = game_manager.currentMode

    if editor.mapFile:selectionEmpty() then
        if self.widget ~= nil then
            self.widget = safe_destroy(self.widget)
        end
        self.setEditorToolbar("Selected: none")
        self.widgetPos = nil
        self.widgetOrt = nil
        return
    end

    -- Compute average position.
    local selected = editor.mapFile:allSelected()
    self.widgetPos = vec(0, 0, 0)
    for i, obj_name in ipairs(selected) do
        local obj = editor.mapFile:getCurrentObject(obj_name)
        self.widgetPos = self.widgetPos + obj[2]
    end
    self.widgetPos = self.widgetPos / #selected
    
    self.widgetOrt = Q_ID
    if self.spaceMode == "local" then
        local obj = editor.mapFile:getCurrentObject(selected[#selected])
        self.widgetOrt = (obj[3] or {}).rot or Q_ID
    end

    if self.widget == nil then
        self.widget = Widget.new(self.widgetPos, self.widgetOrt)
    else
        self.widget:updateArrows(self.widgetOrt)
        self.widget:updatePivot(self.widgetPos, self.widgetOrt)
    end

    if #selected > 1 then
        self.setEditorToolbar("Selected: multiple")
    else
        self.setEditorToolbar("Selected: " .. selected[1])
    end

end

function widget_manager:setSpaceMode(space_mode)
    self.spaceMode = space_mode
    self:updateWidget()
end

function widget_manager:setMode(mode)
    self.mode = mode
    self:updateWidget()
end

function widget_manager:setPivotPoint(v)
    self.pivotPoint = v
end

function widget_manager:setEditorToolbar(str)
    if editor_interface.map_editor_page.statusbar ~= nil then
        editor_interface.map_editor_page.statusbar:setText(tostring(str))
    end
end

function widget_manager:unselectAll()
    local editor = game_manager.currentMode
    editor.mapFile:unselectAll()
    self:updateWidget()
end

function widget_manager:getObjectUnderCursor()
    local editor = game_manager.currentMode

    local ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
    local _, b = gge_physics_cast(main.camPos, ray, true, 0)
    -- local b2 = self:selectNonPhysicalObjects()
    
    -- if b2 then
        -- if b and b.owner then
            -- if b.owner.instance and b.owner.instance then
                -- if #(main.camPos - b.owner.instance.body.worldPosition) > #(main.camPos - b2.pos) then
                
                -- end
            -- end
        -- end
    -- end
    if b == nil then
        return nil
    end

    return b.owner.name
end

-- If you click on a widget component, then starts dragging.
-- Otherwise, modifies the set of selected objects.
function widget_manager:select(multi)
    local editor = game_manager.currentMode

    -- Are we clicking on the widget itself?
    local widget_component = nil
    if self.widget ~= nil then
        widget_component = self:rayCastToWidget()
    end
    if widget_component then
        self:startDragging(widget_component)
    else
        -- Missed the widget, check objects...
        local target_obj = self:getObjectUnderCursor()

        if multi then
            if target_obj == nil then
                -- Do nothing.
                return
            end
            -- Toggle selected status.
            editor.mapFile:setSelected(target_obj, not editor.mapFile:isSelected(target_obj))
        else
            editor.mapFile:unselectAll()
            if target_obj == nil then
                -- Leave with nothing selected.
                self:updateWidget()
                return
            end
            editor.mapFile:setSelected(target_obj, true)
        end

        self:updateWidget()
    end
end

function widget_manager:startDragging(widget_component)
    if self.widget == nil then return end
    self.dragComponent = widget_component
    self.absMouseBeforeDrag = mouse_pos_abs
end

function widget_manager:stopDragging()
    if self.dragComponent == nil then
        -- Wasn't actually dragging anything, silently return.
        return
    end
    local editor = game_manager.currentMode
    editor.mapFile:applyChange()
    self:updateWidget()
    self.dragComponent = nil
end

function widget_manager:deleteSelected()
    local editor = game_manager.currentMode
    editor.mapFile:delete(table.clone(editor.mapFile:allSelected()))
    self:updateWidget()
end

function widget_manager:copySelectedToClipboard()
    local editor = game_manager.currentMode
    self.clipboard = {}
    for _, obj_name in ipairs(editor.mapFile:allSelected()) do
        self.clipboard[obj_name] = editor.mapFile:getCurrentObject(obj_name)
    end
end

function widget_manager:uniqueName(orig_name)
    local editor = game_manager.currentMode
    if editor.mapFile:getCurrentObject(orig_name) == nil then
        return orig_name
    end
    local base, counter = orig_name:match('(.*)_([0-9]+)')
    if base == nil then
        base = orig_name
        counter = 1
    else
        counter = tonumber(counter) + 1
    end
    while true do
        local new_name = ("%s_%d"):format(base, counter)
        if editor.mapFile:getCurrentObject(new_name) == nil then
            return new_name
        end
        counter = counter + 1
    end
end

function widget_manager:paste()
    local editor = game_manager.currentMode
    local new_selection = {}
    for orig_name, obj_decl in pairs(self.clipboard) do
        local name = self:uniqueName(orig_name)
        local class_name, pos, data = obj_decl[1], obj_decl[2], obj_decl[3]
        -- Putting objects directly on top of other objects is not a good idea.
        pos = pos + vec(1, 1, 0)
        editor.mapFile:add(name, class_name, pos, data)
        new_selection[#new_selection + 1] = name
    end
    editor.mapFile:applyChange()
    editor.mapFile:unselectAll()
    for _, name in ipairs(new_selection) do
        editor.mapFile:setSelected(name, true)
    end
    self:updateWidget()
end

function widget_manager:duplicateSelected()
    local saved_clipboard = self.clipboard
    self:copySelectedToClipboard()
    self:paste()
    self.clipboard = saved_clipboard
end

-- Reference: http://gamedev.stackexchange.com/questions/18436/most-efficient-aabb-vs-ray-collision-algorithms by Jeroen Baert
local function intersectRayAABoxV(origin, direction, p1, p2)
    local t1, t2 = {}, {}
    local t_near, t_far = -1000, 1000

    -- we test slabs in every direction
    local axis = { "x", "y", "z" }
    local i = axis[1]
    
    for j = 1, 3 do
        i = axis[j]
        -- ray parallel to planes in this direction
        if (direction[i] == 0) then
            if ((origin[i] < p1[i]) or (origin[i] > p2[i])) then
                return false -- parallel and outside box: no intersection possible
            end
        else
            -- ray not parallel to planes in this direction
            t1[i] = (p1[i] - origin[i]) / direction[i]
            t2[i] = (p2[i] - origin[i]) / direction[i]

            -- we want t1 to hold values for intersection with near plane
            if(t1[i] > t2[i]) then
                local tmpv = t1
                t1 = t2
                t2 = tmpv
            end
            if (t1[i] > t_near) then
                t_near = t1[i]
            end
            if (t2[i] < t_far) then
                t_far = t2[i]
            end
            if( (t_near > t_far) or (t_far < 0) ) then
                return false
            end
        end
    end

    return true, t_near, t_far
end

-- a bounding box ray tracer
function widget_manager:bbMouseSelect(pos, rot, scale)
    local iq = inv(rot)
    -- move our stuff to origin to calculate it properly
    local deltapos = main.camPos - pos
    -- rotates the camera position around using the widget orientation
    local ppos =  (iq*deltapos)+pos
    -- new camera orientation rotated by the widget orientation
    local rrot =  iq * main.camQuat

    local dir = 1000 * gfx_screen_to_world(ppos, rrot, mouse_pos_abs)
    local bmin, bmax = pos -scale/2, pos+scale/2
    return intersectRayAABoxV(ppos, dir, bmin, bmax)
end

--[[
function widget_manager:selectNonPhysicalObjects()
    local obj = nil

    for k, v in ipairs(object_all()) do
        if v and v.instance and not v.destroyed()  then
            if v.instance.body == nil then
                local found = nil
                if v.instance.gfx then
                    -- found = self:bbMouseSelect(v.pos, v.instance.gfx.localOrientation, v.instance.gfx.bb)
                elseif v.instance.audio then
                    found = self:bbMouseSelect(v.pos, Q_ID, vec(1, 1, 1))
                end
                
                if found then
                    if obj == nil then
                        obj = v
                    elseif (#(main.camPos - v.pos) < #(main.camPos - obj.pos)) then
                        obj = v
                    end
                end
            end
        end
    end
    return obj
end
]]

function widget_manager:rayCastToWidget()
    local obj = nil
    local lastdistance = nil
    if self.widget == nil then return end
    local scale = self.widget.scale
    
    local wi = self.widget
    local axm = { "x", "y", "z" }
    local dxm = { "xy", "xz", "yz" }

    for i = 1, 3 do
        local pos, orient
        local offset
        
        -- arrows
        pos, orient  = wi[axm[i]].localPosition, wi[axm[i]].localOrientation
        offset = orient * (4 * scale * V_FORWARDS)
        
        local kq, kna = self:bbMouseSelect(pos + offset, orient, arrow_bounds * scale)

        if kq and (lastdistance == nil or kna < lastdistance)  then
            obj = i == 1 and "x" or i == 2 and "y" or i == 3 and "z"
            lastdistance = kna
        end
        
        -- dummies
        if wi[dxm[i]] ~= nil then
            pos, orient  = wi[dxm[i]].localPosition, wi[dxm[i]].localOrientation

            offset =  ((orient * V_RIGHT) + (orient * V_FORWARDS)) * scale
            
            local _, knd = self:bbMouseSelect(pos + offset, orient, dummy_bounds * scale)
            
            if knd and (lastdistance == nil or knd < lastdistance) then
                obj = i == 1 and "xy" or i == 2 and "xz" or i == 3 and "yz"
                lastdistance = knd
            end
        end
    end
    
    return obj
end

function widget_manager:frameCallback(elapsed_secs)

    if self.widget == nil then
        return
    end
    
    if self.dragComponent == nil then
        local widget_component = self:rayCastToWidget()
        -- Resets highlight if nil.
        self.widget:highlight(widget_component)
        return
    end

    -- Dragging implemented here.

    local component_gfx_body = self.widget[self.dragComponent]

    if self.mode == "translate" then

        -- We can translate along either a plane or a line.  In the case of the plane, the z axis of
        -- the plane component is the normal.  In the case of a line, the y axis of the line
        -- component is the direction of travel.  Since the y axis of the line component lies within
        -- the plane defined by its z axis, it is safe to transform the mouse movement to that plane
        -- in both cases, and then in the case of the line, further restrict it to the line in a
        -- later step.

        local initial_mouse_on_plane = isect_line_plane(
            main.camPos,
            main.camPos + gfx_screen_to_world(main.camPos, main.camQuat, self.absMouseBeforeDrag),
            self.widgetPos,
            component_gfx_body.localOrientation * V_UP
        )
        
        local current_mouse_on_plane = isect_line_plane(
            main.camPos,
            main.camPos + gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs),
            self.widgetPos,
            component_gfx_body.localOrientation * V_UP
        )

        local translation = current_mouse_on_plane - initial_mouse_on_plane
        if #self.dragComponent == 1 then
            -- Constrain to the line.
            local dir = component_gfx_body.localOrientation * V_NORTH
            translation = dot(dir, translation) * dir
        end

        -- Don't snap the widget?
        self.widget:updatePivot(self.widgetPos + translation, self.widgetOrt)

        if gge_input_filter_pressed("Ctrl") then
            translation = math.floor(translation / self.gridSize) * self.gridSize
        end

        local editor = game_manager.currentMode
        for i, obj in ipairs(editor.mapFile:allSelected()) do
            editor.mapFile:proposePosition(obj, editor.mapFile:getPosition(obj) + translation)
        end

    elseif self.mode == "rotate" then

        -- TODO: Copy Blender UI.
        local mouse_delta = mouse_pos_abs - self.absMouseBeforeDrag
        local rotation_amount = mouse_delta.x + mouse_delta.y

        local axis
        if self.dragComponent == "y" then
            axis = vec(0, 1, 0)
        elseif self.dragComponent == "z" then
            axis = vec(0, 0, 1)
        elseif self.dragComponent == "x" then
            axis = vec(1, 0, 0)
        end                

        if self.spaceMode == "local" then
            axis = self.widgetOrt * axis
        end

        local transform = quat(rotation_amount, axis)

        local editor = game_manager.currentMode

        self.widget:updatePivot(self.widgetPos, transform * self.widgetOrt)
        for i, obj in ipairs(editor.mapFile:allSelected()) do

            local origin
            if self.pivotPoint == 'individual origins' then
                origin = editor.mapFile:getPosition(obj)
            elseif self.pivotPoint == 'active object' then
                origin = editor.mapFile:getPosition(self.selectedObjs[#self.selectedObjs])
            elseif self.pivotPoint == 'centre point' then
                origin = self.widgetPos
            else
                gge_error('Unrecognised pivotPoint: ' .. self.pivotPoint)
            end

            editor.mapFile:proposeOrientation(obj, transform * editor.mapFile:getOrientation(obj))
            local new_pos = transform * (editor.mapFile:getPosition(obj) - origin) + origin
            editor.mapFile:proposePosition(obj, new_pos)
        end

    end
end
