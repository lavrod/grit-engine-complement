-- (c) Augusto P. Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- MATERIALS
-- the plane
material `face` {
    diffuseMask = vec(1, 0.5, 0),
    backfaces = true,
    alphaMask = 0.0,
    sceneBlend = "ALPHA",
}
-- the plane dragging
material `face_dragging` {
    diffuseMask = vec(1, 1, 0),
    backfaces = true,
    alphaMask = 0.5,
    sceneBlend = "ALPHA",
}
-- plane line 1
material `line_1` {
    diffuseMask = vec(0, 1, 0),
    emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}
-- plane line 2
material `line_2` {
    diffuseMask = vec(1, 0, 0),
    emissiveMask = vec(1, 0, 0),
    additionalLighting = true,
}
-- all arrows line material
material `line` {
    diffuseMask = vec(0, 1, 0),
    emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}

material `yellow` {
    diffuseMask = vec(1, 1, 0),
    emissiveMask = vec(1, 1, 0),
    additionalLighting = true,
}
-- all arrows `arrow` material
material `arrow` {
    diffuseMask = vec(0, 1, 0),
    emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}

material `green` {
    diffuseMask = vec(0, 1, 0),
    emissiveMask = vec(0, 1, 0),
    additionalLighting = true,
}

material `red` {
    diffuseMask = vec(1, 0, 0),
    emissiveMask = vec(1, 0, 0),
    additionalLighting = true,
}

material `blue` {
    diffuseMask = vec(0, 0, 1),
    emissiveMask = vec(0, 0, 1),
    additionalLighting = true,
}

--[[
-- These Ogre materials no-longer exist, we will have to figure out another way of rendering on top.
get_material(`green`):setDepthBias(0, 0, 50000, 50000)
get_material(`red`):setDepthBias(0, 0, 50000, 50000)
get_material(`blue`):setDepthBias(0, 0, 50000, 50000)

get_material(`arrow`):setDepthBias(0, 0, 50000, 50000)
get_material(`line`):setDepthBias(0, 0, 50000, 50000)

get_material(`face`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_1`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_2`):setDepthBias(0, 0, 50000, 50000)
get_material(`line_dragging`):setDepthBias(0, 0, 50000, 50000)
]]

Widget = {

    axisColours = {
        x = `red`,
        y = `green`,
        z = `blue`,
    },

    planeColours = {
        xy = { `green`, `red` },
        xz = { `red`, `blue` },
        yz = { `blue`, `green` },
    },

    new = function(pos, rot)
        local self = make_instance({}, Widget)
        self:updateArrows(rot)
        self:updatePivot(pos, rot)
        return self
    end,

    -- (Re)creates the objects representing individual parts of the widget.
    -- Call this every time widget_manager.mode updates.
    -- The positions of the objects should then be controlled via updatePivot.
    updateArrows = function(self, pivot_or)

        local orientations = {
            x = euler(0, 0, -90),
            y = euler(0, 0, 0),
            z = euler(90, 0, -90),
        }

        for _, component in ipairs{'x', 'y', 'z'} do
            safe_destroy(self[component])
            self[component] = gfx_body_make((`arrow_%s.mesh`):format(widget_manager.mode))
            self[component].castShadows = false
            self[component].localOrientation = pivot_or * orientations[component]
            self[component]:setMaterial(`arrow`, self.axisColours[component])
        end

        local plane_orientations = {
            xy = euler(0, 0, 0),
            xz = euler(0, -90, -90),
            yz = euler(90, 0, 90),
        }

        for _, component in ipairs{'xy', 'xz', 'yz'} do
            safe_destroy(self[component])
            if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
                self[component] = gfx_body_make(`dummy_plane.mesh`)
                self[component].castShadows = false
                self[component].localOrientation = pivot_or * plane_orientations[component]
            else
                self[component] = nil
            end
        end
    end,

    destroy = function(self)
        safe_destroy(self.x)
        safe_destroy(self.y)
        safe_destroy(self.z)
        safe_destroy(self.xy)
        safe_destroy(self.xz)
        safe_destroy(self.yz)
    end,


    -- Call whenever the camera moves or self.widgetPosition is updated.
    updatePivotScale = function(self)

        local scale = ((2 * math.tan(math.rad(gfx_option("FOV")) / 2)) * #(main.camPos - self.widgetPosition))*0.025
        local scale3 = scale * vec(1, 1, 1)
        self.scale = scale
        self.x.localScale = scale3
        self.y.localScale = scale3
        self.z.localScale = scale3

        if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
            self.xy.localScale = scale3
            self.xz.localScale = scale3
            self.yz.localScale = scale3
        end
    end,

    -- Call when the pivot is moved to a new location due to changes in selection, dragging, etc.
    updatePivot = function(self, new_position, new_orientation)

        self.x.localPosition = new_position
        self.y.localPosition = new_position
        self.z.localPosition = new_position
        
        self.x.localOrientation = new_orientation * euler(0, 0, -90)
        self.y.localOrientation = new_orientation
        self.z.localOrientation = new_orientation * euler(90, 0, -90)
        
        
        if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
            self.xy.localPosition = new_position
            self.xz.localPosition = new_position
            self.yz.localPosition = new_position
        end

        self.widgetPosition = new_position
        self.widgetOrientation = new_orientation

        self:updatePivotScale()
    end,

    -- Choose which component should be highlighted (nil for none).
    highlight = function(self, highlighted_component)

        if widget_manager.mode == "translate" or widget_manager.mode == "scale" then
            for _, component in ipairs{'xy', 'xz', 'yz'} do
                local line1, line2 = component:sub(1, 1), component:sub(2, 2)
                if highlighted_component == component then
                    self[component]:setMaterial(`line_1`, `yellow`)
                    self[component]:setMaterial(`line_2`, `yellow`)
                    self[component]:setMaterial(`face`, `face_dragging`)
                    self[line1]:setMaterial(`line`, `yellow`)
                    self[line2]:setMaterial(`line`, `yellow`)
                else
                    self[component]:setMaterial(`line_1`, self.planeColours[component][1])
                    self[component]:setMaterial(`line_2`, self.planeColours[component][2])
                    self[component]:setMaterial(`face`, `face`)
                    self[line1]:setMaterial(`line`, self.axisColours[line1])
                    self[line2]:setMaterial(`line`, self.axisColours[line2])
                end
            end
        end

        for _, component in ipairs{'x', 'y', 'z'} do
            if highlighted_component == component then
                self[component]:setMaterial(`line`, `yellow`)
            else
                self[component]:setMaterial(`line`, self.axisColours[component])
            end
        end
    end,
}
