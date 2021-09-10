hud_class `Settings` `/common/gui/Window` {

    init = function (self)
        WindowClass.init(self)
        
        -- self.close_btn.pressedCallback = function (self)
            -- safe_destroy(self.parent.parent.parent)
        -- end;
        
        self.content = gui.notebook(self.contentArea)

        self.content.general_panel = gui.notebookpanel()
        
        self.content.general_panel.openstartupmap_checkbox = gui.checkbox({
            caption = "Load startup map",
            checked = editor_cfg.load_startup_map,
            parent = self.content.general_panel,
            align = vec(-1, 1);
            offset = vec(10, -7),
            onCheck = function(self)
                editor_cfg.load_startup_map = true
                editor_interface.map_editor_page.windows.settings.content.general_panel.openstartupmap_editbox:setGreyed(false)
            end,
            onUncheck = function(self)
                editor_cfg.load_startup_map = false
                editor_interface.map_editor_page.windows.settings.content.general_panel.openstartupmap_editbox:setGreyed(true)
            end,
        })
        
        self.content.general_panel.openstartupmap_editbox = hud_object `/common/gui/window_editbox` {
            parent = self.content.general_panel;
            value = editor_cfg.startup_map;
            alignment = "LEFT";
            enterCallback = function(self)
                editor_cfg.startup_map = self.value
            end;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(5, -30);
            expand_x = true;
            expand_offset = vec(-20, 0);
        }
        self.content.general_panel.openstartupmap_editbox:setGreyed(not editor_cfg.load_startup_map)

        self.content.themes_panel = gui.notebookpanel()
        self.content.themes_panel.theme = gui.text({
            value = "Theme: ",
            parent = self.content.themes_panel,
            align = vec(-1, 1);
            offset = vec(10, -5);        
        })

        local theme_items = {}
        for k in pairs(editor_themes) do
            theme_items[#theme_items+1] = k
        end
        
        self.content.themes_panel.theme_selectbox = gui.selectbox({
            parent = self.content.themes_panel;
            choices = theme_items;
            selection = 0;
            align = vec(-1, 1);
            offset = vec(10, -25);
            size = vec(200, 22);
        })
        if editor_themes[editor_interface_cfg.theme] ~= nil then
            self.content.themes_panel.theme_selectbox:select(editor_interface_cfg.theme)
        else
            self.content.themes_panel.theme_selectbox:select("dark")
        end
        
        self.content.themes_panel.theme_selectbox.onSelect = function(self)
            _current_theme = editor_themes[self.selected.name]
            game_manager.currentMode:saveEditorInterface()
            restart_editor_gui()
        end;
        
        self.content.system_panel = gui.notebookpanel()

        self.content.system_panel.game_mode = gui.text({
            value = "Default Game Mode: ",
            parent = self.content.system_panel,
            align = vec(-1, 1);
            offset = vec(10, -5);        
        })

        local gamemodes_items = {}
        
        for k in pairs(game_manager.gameModes) do
            if k ~= "Map Editor" then
                gamemodes_items[#gamemodes_items+1] = k
            end
        end
        
        if next(gamemodes_items) then
            self.content.system_panel.game_mode_selectbox = gui.selectbox({
                parent = self.content.system_panel;
                choices = gamemodes_items;
                selection = 0;
                align = vec(-1, 1);
                offset = vec(10, -25);
                size = vec(200, 22);
            })
            
            self.content.system_panel.game_mode_selectbox:select(editor_cfg.default_game_mode)
            
            self.content.system_panel.game_mode_selectbox.onSelect = function(self)
                editor_cfg.default_game_mode = self.selected.name
                game_manager.currentMode:saveEditorConfig()
                -- game_manager.currentMode.playGameMode = self.selected.name
            end;
        end
        self.content:addPage(self.content.general_panel, "General")
        self.content:addPage(self.content.themes_panel, "Themes")
        self.content:addPage(self.content.system_panel, "System")
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
