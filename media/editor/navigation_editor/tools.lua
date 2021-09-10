
hud_class `Tools` `/common/gui/Window` {
    init = function (self)
        WindowClass.init(self)
        self.tool = {}    
    end;

    show_temp_obstacle_tool = function(self)
        safe_destroy(self.tool)
        self.tool = gui.object({ parent = self.contentArea, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align = vec(0, 1), expand_x = true })
        -- self.tool.title = gui.text({
            -- value = "Create :";
            -- font = `/common/fonts/ArialBold12`;
        -- })

        self.tool.button = gui.button({
            caption = "Remove All",
            parent = self.tool,
            offset = vec(0, -10),
            align = vec(0, 1),
            expand_x = true,
            expand_offset = vec(-20, 0),
            pressedCallback = function(self)
                
            end,
        })
        self.tool.size = vec(self.tool.size.x, self.tool.button.size.y *2)
        self.size = self.size
        
        --playing_binds:bind("middle", function() local pos = mouse_pick_pos() if pos then navigation_add_obstacle(pos) end end)
        game_manager.currentMode.leftMouseClick = function() local pos = mouse_pick_pos() if pos then navigation_add_obstacle(pos) end end;
    end;
    
    show_offmesh_tool = function(self)
        safe_destroy(self.tool)
        self.tool = gui.object({ parent = self.contentArea, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align = vec(0, 1), expand_x = true })
        self.tool.radiobuttons = {}
        
        self.points = {}
        
        local offmeshclick = function()
            if editor_interface.navigation_editor.windows.tools.points[1] == nil then
                local pos = mouse_pick_pos()
                if pos then
                    editor_interface.navigation_editor.windows.tools.points[1] = pos
                end
            elseif editor_interface.navigation_editor.windows.tools.points[2] == nil then
                local pos = mouse_pick_pos()
                if pos then
                    editor_interface.navigation_editor.windows.tools.points[2] = pos
                end
                navigation_add_offmesh_connection(
                    editor_interface.navigation_editor.windows.tools.points[2],
                    editor_interface.navigation_editor.windows.tools.points[1],
                    (editor_interface.navigation_editor.windows.tools.tool.bxsz.radiobuttons.selected.caption == "Bidirecional" and true or false)
                )
                editor_interface.navigation_editor.windows.tools.points = {}            
            end
        end
        
        -- playing_binds:bind("middle", offmeshclick)
        game_manager.currentMode.leftMouseClick = function() offmeshclick() end;
        
        self.tool.bxsz = gui.boxsizer(true, "vertical", self.tool)
        self.tool.bxsz.zOrder = 5
        
        self.tool.radiobuttons[0] = gui.radiobutton({caption = "One way", parent = self.tool, onSelect = function(self)  end, align = vec(-1, 0), offset =  vec(10, 0)})
        self.tool.bxsz:addChild(self.tool.radiobuttons[0])
        
        self.tool.radiobuttons[1] = gui.radiobutton({caption = "Bidirecional", parent = self.tool, onSelect = function(self)  end, align = vec(-1, 0), offset =  vec(10, 0)})
        self.tool.bxsz:addChild(self.tool.radiobuttons[1])
        self.tool.radiobuttons[1]:select()
        
        self.tool.size = vec(self.tool.size.x, #self.tool.radiobuttons*(self.tool.radiobuttons[1].size.y *2))
        self.size = self.size        
    end;    
    
    show_convex_tool = function(self)
        safe_destroy(self.tool)
        self.tool = gui.object({ parent = self.contentArea, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align = vec(0, 1), expand_x = true })
        -- playing_binds:bind("middle", function() end)
        game_manager.currentMode.leftMouseClick = function()  end;
    end;    
    
    show_crowd_tool = function(self)
        safe_destroy(self.tool)
        self.tool = gui.object({ parent = self.contentArea, size = vec(100, 100), alpha = 0, colour = vec(1, 0, 1), align = vec(0, 1), expand_x = true })
        self.tool.radiobuttons = {}
        
        self.tool.bxsz = gui.boxsizer(true, "vertical", self.tool)
        self.tool.bxsz.zOrder = 5
        
        self.tool.radiobuttons[0] = gui.radiobutton({caption = "Create Agents",
            parent = self.tool,
            onSelect = function(self)
                -- playing_binds:bind("middle", function() local pos = mouse_pick_pos() if pos then agent_add(pos) end end)
                game_manager.currentMode.leftMouseClick = function() local pos = mouse_pick_pos() if pos then gge_agent_make(pos) end end;
            end,
            align = vec(-1, 0),
            offset =  vec(10, 0)
        })
        self.tool.bxsz:addChild(self.tool.radiobuttons[0])
        self.tool.radiobuttons[0]:select()
        
        self.tool.radiobuttons[1] = gui.radiobutton({caption = "Move Target",
            parent = self.tool,
            onSelect = function(self)
                -- playing_binds:bind("middle", function() local pos = mouse_pick_pos() if pos then crowd_move_to(pos) end end)
                game_manager.currentMode.leftMouseClick = function() local pos = mouse_pick_pos() if pos then crowd_move_to(pos) end end;
            end,
            align = vec(-1, 0),
            offset =  vec(10, 0)
        })        
        self.tool.bxsz:addChild(self.tool.radiobuttons[1])
        
        self.tool.radiobuttons[2] = gui.radiobutton({caption = "Select Agent",
            parent = self.tool,
            onSelect = function(self)
                -- playing_binds:bind("middle", function() end)
                game_manager.currentMode.leftMouseClick = function()  end;
            end,
            align = vec(-1, 0),
            offset =  vec(10, 0)
        })        
        self.tool.bxsz:addChild(self.tool.radiobuttons[2])
        
        self.tool.size = vec(self.tool.size.x, #self.tool.radiobuttons*(self.tool.radiobuttons[1].size.y *2))
        self.size = self.size
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
