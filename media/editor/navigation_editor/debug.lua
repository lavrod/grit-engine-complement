
hud_class `Debug` `/common/gui/Window` {
    init = function (self)
        WindowClass.init(self)
        self.toolsel = gui.boxsizer(true, "vertical", self.contentArea)
        self.toolsel.zOrder = 5
        self.toolsel.alpha = 0

        self.checkboxes = {}

        self.checkboxes[0] = gui.checkbox({ caption = "Enable debug",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("enabled", true) end,
            onUncheck= function(self) gge_navigation_debug_option("enabled", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("enabled")
        })
        self.toolsel:addChild(self.checkboxes[0])
        
        self.checkboxes[1] = gui.checkbox({ caption = "Show navmesh",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("navmesh", true) end,
            onUncheck= function(self) gge_navigation_debug_option("navmesh", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("navmesh")
        })
        self.toolsel:addChild(self.checkboxes[1])
        
        self.checkboxes[2] = gui.checkbox({ caption = "Navmesh use tile colours",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("navmesh_use_tile_colours", true) end,
            onUncheck= function(self) gge_navigation_debug_option("navmesh_use_tile_colours", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("navmesh_use_tile_colours")
        })
        self.toolsel:addChild(self.checkboxes[2])
        
        self.checkboxes[3] = gui.checkbox({ caption = "Show agent cylinder",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("agent", true) end,
            onUncheck= function(self) gge_navigation_debug_option("agent", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("agent")
        })
        self.toolsel:addChild(self.checkboxes[3])
        
        self.checkboxes[4] = gui.checkbox({ caption = "Show agent speed",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("agent_arrows", true) end,
            onUncheck= function(self) gge_navigation_debug_option("agent_arrows", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("agent_arrows")
        })
        self.toolsel:addChild(self.checkboxes[4])
        
        self.checkboxes[5] = gui.checkbox({ caption = "Show bounds",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("bounds", true) end,
            onUncheck= function(self) gge_navigation_debug_option("bounds", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("bounds")
        })
        self.toolsel:addChild(self.checkboxes[5])
        
        self.checkboxes[6] = gui.checkbox({ caption = "Show tiling grid",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("tiling_grid", true) end,
            onUncheck= function(self) gge_navigation_debug_option("tiling_grid", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("tiling_grid")
        })
        self.toolsel:addChild(self.checkboxes[6])
        
        self.checkboxes[7] = gui.checkbox({ caption = "Show obstacles",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("obstacles", true) end,
            onUncheck= function(self) gge_navigation_debug_option("obstacles", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("obstacles")
        })
        self.toolsel:addChild(self.checkboxes[7])
        
        self.checkboxes[8] = gui.checkbox({ caption = "Show Offmesh connections",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("offmesh_connections", true) end,
            onUncheck= function(self) gge_navigation_debug_option("offmesh_connections", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("offmesh_connections")
        })
        self.toolsel:addChild(self.checkboxes[8])
        
        self.checkboxes[9] = gui.checkbox({ caption = "Show convex volumes",
            parent = self.toolsel,
            onCheck = function(self) gge_navigation_debug_option("convex_volumes", true) end,
            onUncheck= function(self) gge_navigation_debug_option("convex_volumes", false) end,
            align = vec(-1, 0),
            offset =  vec(10, 0),
            checked = gge_navigation_debug_option("convex_volumes")
        })
        self.toolsel:addChild(self.checkboxes[9])
    end;

    destroy = function (self)
        WindowClass.destroy(self)
    end;
    
    buttonCallback = function(self, ev)
        WindowClass.buttonCallback(self, ev)
    end;
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        WindowClass.mouseMoveCallback(self, local_pos, screen_pos, inside)
    end;
}

