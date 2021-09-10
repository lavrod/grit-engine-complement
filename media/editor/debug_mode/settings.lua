hud_class `Settings` `/common/gui/Window` {

    closeClicked = function(self)
        game_manager.currentMode:setInDebugModeSettings(false)
    end,

    init = function (self)
        WindowClass.init(self)
        
        self.content = gui.notebook(self.contentArea)

        -- GENERAL
        self.content.general_panel = gui.notebookpanel()
        self.content.general_panel.warp = gui.checkbox({
            caption = "Walk through walls",
            checked = editor_cfg.warp,
            parent = self.content.general_panel,
            align = vec(-1, 1);
            offset = vec(10, -7),
            onCheck = function(self)
                gge_print(GREEN.."TODO")
            end,
            onUncheck = function(self)
                gge_print(GREEN.."TODO")
            end,
        })
        self.content.general_panel.teleport = gui.text({
            value = "Teleport to: ",
            parent = self.content.general_panel,
            align = vec(-1, 1);
            offset = vec(10, -25);        
        })
        self.content.general_panel.X = hud_object `/common/gui/window_editbox` {
            parent = self.content.general_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = function(self)
                
            end;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -45);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(1, 0, 0);
        }
        self.content.general_panel.Y = hud_object `/common/gui/window_editbox` {
            parent = self.content.general_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = function(self)
                
            end;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10+55, -45);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(0, 1, 0);
        }
        self.content.general_panel.Z = hud_object `/common/gui/window_editbox` {
            parent = self.content.general_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = function(self)
                
            end;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10+110, -45);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(0, 0, 1);
        } 
        self.content.general_panel.button = gui.button({
            caption = "Teleport";
            parent = self.content.general_panel;
            offset = vec(10+165, -45);
            align = vec(-1, 1);
            expand_x = false;
            expand_offset = vec(-20, 0);
            pressedCallback = function(self)
                main.camPos = vec(tonumber(self.parent.X.value), tonumber(self.parent.Y.value), tonumber(self.parent.Z.value))
            end;
            padding = vec(5, 2);
        })
        self.content.general_panel.pe = gui.checkbox({
            caption = "Physics enabled",
            checked = main.physicsEnabled,
            parent = self.content.general_panel,
            align = vec(-1, 1);
            offset = vec(10, -70),
            onCheck = function(self)
                main.physicsEnabled = true
            end,
            onUncheck = function(self)
                main.physicsEnabled = false
            end,
        })
        self.content.general_panel.poto = gui.checkbox({
            caption = "Physics one-to-one",
            checked = main.physicsOneToOne,
            parent = self.content.general_panel,
            align = vec(-1, 1);
            offset = vec(10, -90),
            onCheck = function(self)
                main.physicsOneToOne = true
            end,
            onUncheck = function(self)
                main.physicsOneToOne = false
            end,
        })


        
        -- DEBUG
        self.content.debug_panel = gui.notebookpanel()
        
        self.content.debug_panel.fov = gui.text({
            value = "FOV: ",
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -5);        
        })        
        local fovcb = function(self) gfx_option("FOV", tonumber(self.value)) end
        self.content.debug_panel.foved = hud_object `/common/gui/window_editbox` {
            parent = self.content.debug_panel;
            value = tostring(gfx_option("FOV"));
            alignment = "LEFT";
            enterCallback = fovcb;
            onStopEditing = fovcb;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(50, -5);
        }

        self.content.debug_panel.farc = gui.text({
            value = "Far Clip: ",
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -95);        
        })        
        
        local fccb =  function(self) gfx_option("FAR_CLIP", tonumber(self.value)) end
        self.content.debug_panel.farced = hud_object `/common/gui/window_editbox` {
            parent = self.content.debug_panel;
            value = tostring(gfx_option("FAR_CLIP"));
            alignment = "LEFT";
            enterCallback = fccb;
            onStopEditing = fccb;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(70, -95);
        }
        
        --[[
        self.content.debug_panel.fcol = gui.checkbox({
            caption = "Distance Fog",
            checked = debug_cfg.fog,
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -120),
            onCheck = function(self)
                debug_cfg.fog = true
            end,
            onUncheck = function(self)
                debug_cfg.fog = false
            end,
        })
        self.content.debug_panel.pdw = gui.checkbox({
            caption = "Physics debug world",
            checked = debug_cfg.physicsDebugWorld,
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -220),
            onCheck = function(self)
                debug_cfg.physicsDebugWorld = true
            end,
            onUncheck = function(self)
                debug_cfg.physicsDebugWorld = false
            end,
        })
        self.content.debug_panel.pw = gui.checkbox({
            caption = "Physics wireframe",
            checked = debug_cfg.physicsWireFrame,
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -240),
            onCheck = function(self)
                debug_cfg.physicsWireFrame = true
            end,
            onUncheck = function(self)
                debug_cfg.physicsWireFrame = false
            end,
        })        
        ]]

        self.content.debug_panel.plmod = gui.text({
            value = "Polygon Mode: ",
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -260);        
        })
        --[[
        self.content.debug_panel.plmodsel = gui.selectbox({
            parent = self.content.debug_panel;
            choices = {
                "SOLID";
                "SOLID_WIREFRAME";
                "WIREFRAME";
            };
            selection = 0;
            align = vec(-1, 1);
            offset = vec(110, -260);
            size = vec(200, 22);
        })
        self.content.debug_panel.plmodsel:select(tostring(debug_cfg.polygonMode))
        self.content.debug_panel.plmodsel.onSelect = function(self)
            debug_cfg.polygonMode = self.selected.name
        end;
        
        self.content.debug_panel.sc = gui.checkbox({
            caption = "Shadow cast",
            checked = debug_cfg.shadowCast,
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -310),
            onCheck = function(self)
                debug_cfg.shadowCast = true
            end,
            onUncheck = function(self)
                debug_cfg.shadowCast = false
            end,
        })
        self.content.debug_panel.sr = gui.checkbox({
            caption = "Shadow receive",
            checked = debug_cfg.shadowReceive,
            parent = self.content.debug_panel,
            align = vec(-1, 1);
            offset = vec(10, -330),
            onCheck = function(self)
                debug_cfg.shadowReceive = true
            end,
            onUncheck = function(self)
                debug_cfg.shadowReceive = false
            end,
        })
        ]]

        local function clearAllPlaced()
            for _, obj in ipairs(object_all()) do
                if obj.destroyed then 
                    -- Skip
                elseif obj.debugObject == true then
                    safe_destroy(obj)
                else
                    obj:deactivate()
                    obj.skipNextActivation = false
                end
            end        
        end
        
        -- PLACEMENT GUN
        self.content.placement_panel = gui.notebookpanel()
        self.content.placement_panel.theme = gui.text({
            value = "Class: ",
            parent = self.content.placement_panel,
            align = vec(-1, 1);
            offset = vec(10, -5);        
        })
        
        local cbcb = function(self) WeaponCreate.class = self.value end;
        
        self.content.placement_panel.classb = hud_object `/common/gui/window_editbox` {
            parent = self.content.placement_panel;
            value = `/common/veg/Tree_aelm`;
            alignment = "LEFT";
            enterCallback = cbcb;
            onStopEditing = cbcb;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -25);
            expand_x = true;
            expand_offset = vec(-20, 0);
        }
        self.content.placement_panel.offsett = gui.text({
            value = "Additional ground offset: ",
            parent = self.content.placement_panel,
            align = vec(-1, 1);
            offset = vec(10, -45);        
        })
        local ofcb =  function(self) WeaponCreate.additionalOffset = tonumber(self.value) or 0 end
        self.content.placement_panel.offset = hud_object `/common/gui/window_editbox` {
            parent = self.content.placement_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = ofcb;
            onStopEditing = ofcb;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -65);
        }
        
        self.content.placement_panel.button1 = gui.button({
            caption = "Clear last placed object";
            parent = self.content.placement_panel;
            offset = vec(10, -95);
            align = vec(-1, 1);
            pressedCallback = function(self)
                if WeaponCreate.lastPlaced then
                    safe_destroy(WeaponCreate.lastPlaced)
                    WeaponCreate.lastPlaced = nil
                end
            end;
        })
        self.content.placement_panel.button2 = gui.button({
            caption = "Clear all placed obejcts";
            parent = self.content.placement_panel;
            offset = vec(10, -130);
            align = vec(-1, 1);
            pressedCallback = clearAllPlaced;
        })

        -- OBJECT FIRING GUN
        self.content.object_panel = gui.notebookpanel()
        self.content.object_panel.theme = gui.text({
            value = "Class: ",
            parent = self.content.object_panel,
            align = vec(-1, 1);
            offset = vec(10, -5);        
        })
        local cbcb2 = function(self) WeaponCreate.class = self.value end
        self.content.object_panel.classb = hud_object `/common/gui/window_editbox` {
            parent = self.content.object_panel;
            value = `/common/veg/Tree_aelm`;
            alignment = "LEFT";
            enterCallback = cbcb2;
            onStopEditing = cbcb2;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -25);
            expand_x = true;
            expand_offset = vec(-20, 0);
        }
        self.content.object_panel.vel = gui.text({
            value = "Velocity (m/s): ",
            parent = self.content.object_panel,
            align = vec(-1, 1);
            offset = vec(10, -45);        
        })        
        self.content.object_panel.velt = hud_object `/common/gui/window_editbox` {
            parent = self.content.object_panel;
            value = "1";
            alignment = "LEFT";
            enterCallback = do_nothing;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -65);
        }
        self.content.object_panel.teleport = gui.text({
            value = "Spin: ",
            parent = self.content.object_panel,
            align = vec(-1, 1);
            offset = vec(10, -90);        
        })
        local wpscbx = function(self)
                WeaponCreate.spin = self.value
                gge_print(GREEN.."TODO")
            end
        self.content.object_panel.X = hud_object `/common/gui/window_editbox` {
            parent = self.content.object_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = wpscbx;
            onStopEditing = wpscbx;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -110);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(1, 0, 0);
        }
        local wpscby = function(self)
                WeaponCreate.spin = self.value
                gge_print(GREEN.."TODO")
            end        
        self.content.object_panel.Y = hud_object `/common/gui/window_editbox` {
            parent = self.content.object_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = wpscby;
            onStopEditing = wpscby;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10+55, -110);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(0, 1, 0);
        }
        local wpscbz = function(self)
                WeaponCreate.spin = self.value
                gge_print(GREEN.."TODO")
            end        
        self.content.object_panel.Z = hud_object `/common/gui/window_editbox` {
            parent = self.content.object_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = wpscbz;
            onStopEditing = wpscbz;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10+110, -110);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(0, 0, 1);
        }
        self.content.object_panel.button1 = gui.button({
            caption = "Clear last placed object";
            parent = self.content.object_panel;
            offset = vec(10, -140);
            align = vec(-1, 1);
            pressedCallback = function(self)
                if WeaponCreate.lastPlaced then
                    safe_destroy(WeaponCreate.lastPlaced)
                    WeaponCreate.lastPlaced = nil
                end
            end;
        })
        self.content.object_panel.button2 = gui.button({
            caption = "Clear all placed obejcts";
            parent = self.content.object_panel;
            offset = vec(10, -175);
            align = vec(-1, 1);
            pressedCallback = function(self)
                clearAllPlaced()
            end;
        })

        self.content.particles_panel = gui.notebookpanel()
        self.content.particles_panel.theme = gui.text({
            value = "Class: ",
            parent = self.content.particles_panel,
            align = vec(-1, 1);
            offset = vec(10, -5);        
        })
        local cbcb3 = function(self)
                WeaponFlame.class = self.value
        end
        self.content.particles_panel.classb = hud_object `/common/gui/window_editbox` {
            parent = self.content.particles_panel;
            value = `/common/particles/Flame`;
            alignment = "LEFT";
            enterCallback = cbcb3;
            onStopEditing = cbcb3;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -25);
            expand_x = true;
            expand_offset = vec(-20, 0);
        }
        self.content.particles_panel.button1 = gui.button({
            caption = "Clear all particles";
            parent = self.content.particles_panel;
            offset = vec(10, -55);
            align = vec(-1, 1);
            pressedCallback = function(self)
                gge_print(GREEN.."TODO")
            end;
        })        
        
        
        self.content.prod_panel = gui.notebookpanel()
        
        self.content.prod_panel.warp = gui.checkbox({
            caption = "Push away",
            checked = true,
            parent = self.content.prod_panel,
            align = vec(-1, 1);
            offset = vec(10, -7),
            onCheck = function(self)
                gge_print(GREEN.."TODO")
                
                self.parent.direction.text.alpha = 0.5
                self.parent.X.alpha = 0.5
                self.parent.Y.alpha = 0.5
                self.parent.Z.alpha = 0.5
                self.parent.X:setGreyed(true)
                self.parent.Y:setGreyed(true)
                self.parent.Z:setGreyed(true)
            end,
            onUncheck = function(self)
                gge_print(GREEN.."TODO")
            
                self.parent.direction.text.alpha = 1
                self.parent.X.alpha = 1
                self.parent.Y.alpha = 1
                self.parent.Z.alpha = 1
                self.parent.X:setGreyed(false)
                self.parent.Y:setGreyed(false)
                self.parent.Z:setGreyed(false)
            end,
        })        
        
        self.content.prod_panel.direction = gui.text({
            value = "Direction:",
            parent = self.content.prod_panel,
            align = vec(-1, 1);
            offset = vec(10, -25);
        })

        self.content.prod_panel.X = hud_object `/common/gui/window_editbox` {
            parent = self.content.prod_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = function(self)
                gge_print(GREEN.."TODO")
            end;
            onStopEditing = function(self)
                gge_print(GREEN.."TODO")
            end;
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10, -45);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(1, 0, 0);
        }

        self.content.prod_panel.Y = hud_object `/common/gui/window_editbox` {
            parent = self.content.prod_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = function(self)
                gge_print(GREEN.."TODO")
            end;
            onStopEditing = function(self)
                gge_print(GREEN.."TODO")
            end;            
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10+55, -45);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(0, 1, 0);
        }        
        
        self.content.prod_panel.Z = hud_object `/common/gui/window_editbox` {
            parent = self.content.prod_panel;
            value = "0";
            alignment = "LEFT";
            enterCallback = function(self)
                gge_print(GREEN.."TODO")
            end;
            onStopEditing = function(self)
                gge_print(GREEN.."TODO")
            end;
            
            size = vec(50, 20);
            align = vec(-1, 1);
            offset = vec(10+110, -45);
            expand_x = false;
            expand_offset = vec(-20, 0);
            colour = vec(0, 0, 1);
        }
        
        self.content.prod_panel.direction.text.alpha = 0.5
        self.content.prod_panel.X.alpha = 0.5
        self.content.prod_panel.Y.alpha = 0.5
        self.content.prod_panel.Z.alpha = 0.5
        self.content.prod_panel.X:setGreyed(true)
        self.content.prod_panel.Y:setGreyed(true)
        self.content.prod_panel.Z:setGreyed(true)

        
        self.content.prod_panel.force = gui.text({
            value = "Force to push at:",
            parent = self.content.prod_panel,
            align = vec(-1, 1);
            offset = vec(10, -65);        
        })        
        
        -- TODO
        
        
        -- self.content.grab_panel = gui.notebookpanel()
        
        self.content:addPage(self.content.general_panel, "General")
        self.content:addPage(self.content.debug_panel, "Debug Config")
        self.content:addPage(self.content.placement_panel, "Placement Gun")
        self.content:addPage(self.content.object_panel, "Object Firing Gun")
        -- self.content:addPage(self.content.delete_panel, "Delete Gun")
        self.content:addPage(self.content.particles_panel, "Particle Gun")
        self.content:addPage(self.content.prod_panel, "Prod Gun")
        -- self.content:addPage(self.content.grab_panel, "Grab Gun")
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
