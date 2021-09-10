-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local menu_alpha = 0.7
local menu_bg = vec(0.1, 0.1, 0.1)
local menu_fg = vec(0.5, 0.5, 0.5)
local menu_greyed = vec(0.2, 0.2, 0.2)
local menu_hover = vec(1, 1, 1)
local menu_keyboard_hover = vec(1, 0.6, 0.3)
local menu_click = vec(1, 0.6, 0.3)
local menu_font = `/common/fonts/Verdana18`;
infos_font = `/common/fonts/misc.fixed`

local function menu_button(tab)
    local tab2 = {
        size = vec(230,40);

        alpha = menu_alpha;
        backgroundTexture = false;
        backgroundPassiveColour = menu_bg;
        backgroundHoverColour = menu_bg;
        backgroundClickColour = menu_bg * vec(1, 1, 0);
        backgroundGreyedColour = menu_bg;

        borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`;
        borderPassiveColour = menu_fg;
        borderHoverColour = menu_hover;
        borderClickColour = menu_click;
        borderGreyedColour = menu_greyed;

        captionFont = menu_font;
        captionPassiveColour = menu_fg;
        captionHoverColour = menu_hover;
        captionClickColour = menu_click;
        captionGreyedColour = menu_greyed;

    }
    for k, v in pairs(tab) do
        tab2[k] = v
    end
    return hud_object `/common/hud/Button` (tab2)
end

-- For a simple menu, override stackMenu to return a list of buttons.
-- For a custom menu, override buildChildren to build whatever GUI you want.
hud_class `MenuPage` {

    colour = vec(0.2, 0.2, 0.2),

    texture = `background.dds`,

    init = function (self)
        self:buildChildren()
        self.needsInputCallbacks = true
    end,

    stackMenu = function (self)
        -- Subclasses override this.
    end,

    buildChildren = function(self)
        self.stack = hud_object `/common/hud/StackY` {
            parent = self,
            padding = 10,
            hud_object `/common/hud/Rect` {
                size = vec(300, 150);
                texture = `/common/hud/LoadingScreen/GritLogo.png`;
            }, 
            vec(0, 20),
            self:stackMenu()
        }
    end,

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
    end,

    buttonCallback = function (self, ev)
        if ev == "+Escape" then
            self:escapePressed()
        end
    end,

    escapePressed = function (self)
    end,
}

menu_pages = {
    main = function()
        return hud_object `MenuPage` {
            stackMenu = function(self)
                return
                menu_button {
                    caption = "Projects";
                    pressedCallback = function() 
                        menu_show("projects")
                    end
                },
                menu_button {
                    caption = "Debug Mode";
                    pressedCallback = function() 
                        debug_mode()
                    end
                },
                menu_button {
                    caption = "Editor";
                    pressedCallback = function() 
                        game_manager:enter("Map Editor")
                    end
                },
                menu_button {
                    caption = "Settings";
                    pressedCallback = function() 
                        menu_show("settings", "main")
                    end
                },
                menu_button {
                    caption = "Help";
                    pressedCallback = function() 
                        menu_show("help", "main")
                    end
                },
                menu_button {
                    caption = "Exit";
                    pressedCallback = quit
                }
            end;
        }
    end;

    settings = function(last_menu)
        return hud_object `MenuPage` {
            changePage = function(self, dir)
                -- dir is 1 or -1
                self.pages[self.currentPage].enabled = false
                self.currentPage = math.clamp(1, self.currentPage + dir, #self.pages)
                self.pages[self.currentPage].enabled = true
                self.pagePrevButton:setGreyed(self.currentPage == 1)
                self.pageNextButton:setGreyed(self.currentPage == #self.pages)
            end;
            buildChildren = function(self)

                user_cfg.autoUpdate = false

                self.settings = { }
                for key, typ in pairs(user_cfg.spec) do
                    self.settings[key] = hud_object `SettingEdit` {
                        colour = menu_bg,
                        foregroundColour = menu_fg,
                        hoverColour = menu_hover,
                        clickColour = menu_click,
                        alpha = menu_alpha,
                        font = `/common/fonts/Verdana18`,
                        settingName = key,
                        settingType = typ,
                        settingValue = user_cfg[key],
                        settingChangedCallback = function (self2, v)
                            user_cfg[key] = v
                            self.applyButton:setGreyed(false)
                            self.resetButton:setGreyed(false)
                        end,
                    }
                end

                -- TODO(dcunnin): Replace this with an actual scroll area.
                self.pages = { }
                local page = { }
                for key, typ in spairs(user_cfg.spec) do
                    page[#page + 1] = self.settings[key]
                    if #page == 10 then
                        self.pages[#self.pages + 1] = hud_object `/common/hud/StackY` {
                            parent = self,
                            enabled = false,
                            padding = 0,
                            unpack(page)
                        }
                        page = { }
                    end
                end
                if #page > 0 then
                    while #page < 10 do
                        page[#page + 1] = vec(40, 40)
                    end
                    self.pages[#self.pages + 1] = hud_object `/common/hud/StackY` {
                        parent = self,
                        enabled = false,
                        padding = 0,
                        unpack(page),
                    }
                    page = { }
                end

                self.pages[1].enabled = true
                self.currentPage = 1

                self.pagePrevButton = menu_button {
                    parent = self,
                    caption = "<";
                    position = vec(240, 240);
                    size = vec(40, 40);
                    greyed = true;
                    pressedCallback = function() 
                        self:changePage(-1)
                    end
                }
                
                self.pageNextButton = menu_button {
                    parent = self,
                    caption = ">";
                    position = vec(280, 240);
                    size = vec(40, 40);
                    pressedCallback = function() 
                        self:changePage(1)
                    end
                }
                
                self.backButton = menu_button {
                    parent = self,
                    caption = "<";
                    position = vec(-280, 240);
                    size = vec(40, 40);
                    pressedCallback = function() 
                        user_cfg:abort()
                        menu_show(last_menu)
                    end
                }

                self.applyButton = menu_button {
                    parent = self,
                    greyed = true,
                    caption = "Apply",
                    position = vec(-200, 240);
                    size = vec(80, 40);
                    pressedCallback = function(self2)
                        user_cfg.autoUpdate = true
                        user_cfg.autoUpdate = false
                        self.resetButton:setGreyed(true)
                        self.applyButton:setGreyed(true)
                    end
                }

                self.resetButton = menu_button {
                    parent = self,
                    greyed = true,
                    caption = "Reset",
                    position = vec(-110, 240);
                    size = vec(80, 40);
                    pressedCallback = function(self2)
                        user_cfg:abort()
                        for key, typ in spairs(user_cfg.spec) do
                            self.settings[key]:setValue(user_cfg[key])
                        end
                        self.resetButton:setGreyed(true)
                        self.applyButton:setGreyed(true)
                    end
                }

            end,

            escapePressed = function (self)
                user_cfg:abort()
                menu_show(last_menu)
            end,
        }
    end;

    projects = function()
        return hud_object `MenuPage` {
            buildChildren = function(self)
                local image = hud_object `/common/hud/Rect` {
                    -- texture = `/common/hud/LoadingScreen/GritLogo.png`;
                    colour = vec(0.5, 0.5, 0.5);
                    size = vec(400, 200);
                }
                local description = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTRE";
                    value = "Select a project"; 
                    alpha = 1;
                    enabled = true;
                }
                local game_mode_buttons = {}
                for key, game_mode in spairs(game_manager.gameModes) do
                    if key ~= "Map Editor" then
                        game_mode_buttons[#game_mode_buttons + 1] = menu_button {
                            caption = key,
                            pressedCallback = function(self)
                                game_manager:enter(key)
                            end;
                            stateChangeCallback = function (self, old_state, new_state)
                                if new_state == "HOVER" then
                                    description:setValue(game_mode.description)
                                    image.texture = game_mode.previewImage
                                    image.colour = vec(1, 1, 1)
                                end
                            end;
                        }
                    end
                end
                self.stack = hud_object `/common/hud/StackX` {
                    parent = self,
                    padding = 40,
                    { align = "TOP" },
                    menu_button {
                        caption = "<";
                        size = vec(40, 40);
                        pressedCallback = function() 
                            menu_show('main')
                        end
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 10,
                        table.unpack(game_mode_buttons),
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        image,
                        description,
                    },
                }
            end,
            escapePressed = function (self)
                menu_show('main')
            end,
        }
    end;

    system  = function(last_menu,previous_menu)
        return hud_object `MenuPage` {
            buildChildren = function(self)
                local orange = menu_keyboard_hover; --vec(0.8,.17,0.03);
                local thumbs_size = vec(200, 150);
                local infos_size = vec(200, 100);
                local keyboard_image = hud_object `/common/hud/Rect` {
                    size = vec(200, 100);
                    texture = `/common/hud/HelpScreen/jean_victor_balin_icon_console.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local controls_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/controls_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local controls_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Controls"; 
                    alpha = 0;
                    enabled = true;
                }
                local controls_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nEsc\tPause\nTab\tLua Command line\nF12\tScreen capture\n"; 
                    alpha = 0;
                    enabled = true;
                }
                self.stack = hud_object `/common/hud/StackX` {
                    parent = self,
                    padding = 0,
                    { align = "TOP" },
                    hud_object `/common/hud/StackY` {
                    padding = 0,
                    hud_object `/common/hud/StackX` {
                       padding = 0,
		                 menu_button {
		                     caption = "<";
		                     size = vec(40, 40);
		                     pressedCallback = function() 
		                         menu_show(last_menu,previous_menu)
		                     end
		                 },
                       keyboard_image,
                    },
                    hud_object `/common/hud/StackX` {
                       padding = 40,
					         hud_object `/common/hud/StackY` {
					            padding = 0,
					            controls_image,
					            controls_footer,
					            controls_infos,
					         },
                    },
                  },
                }
            end,
            escapePressed = function (self)
                menu_show(last_menu,previous_menu)
            end,
        }
    end;

    editor = function(last_menu,previous_menu)
        return hud_object `MenuPage` {
            buildChildren = function(self)
                local orange = menu_keyboard_hover; -- vec(0.8,.17,0.03);
                local editor_image = hud_object `/common/hud/Rect` {
                    size = vec(400, 200);
                    texture = `/common/hud/HelpScreen/editor.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local pad_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "PAD"; 
                    alpha = 0;
                    enabled = true;
                }
                local pad = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<N> Zoom In\n<S> Zoom Out\n<W> Switches 1st/3rd person\n<E> Toggle Lights\n <N-W> ...\n <N-E> ...\n <S-W> ...\n <S-E> ...\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local left_button_target_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Left-Button (LB) & Left-Target (LT)"; 
                    alpha = 0;
                    enabled = true;
                }
                local left_button_target = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<LB> Descend\n<LT> ..."; 
                    alpha = 0;
                    enabled = true;
                }
                local right_button_target_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Right-Button (RB) & Right-Target (RT)"; 
                    alpha = 0;
                    enabled = true;
                }
                local right_button_target = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<RB> Ascend\n<RT> Fire\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local right_stick_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Right-Stick (RS)"; 
                    alpha = 0;
                    enabled = true;
                }
                local right_stick = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<RS-U> Camera\n<RS-D> ...\n<RS-L> ...\n<RS-R> ...\n<RS-PUSH> ..."; 
                    alpha = 0;
                    enabled = true;
                }
                local left_stick_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Left-Stick (LS)"; 
                    alpha = 0;
                    enabled = true;
                }
                local left_stick = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Walk/Drive\n\n<LS-U> Forward\n<LS-D> Backward\n<LS-L> Left\n<LS-R> Right\n<LS-PUSH> Crunch"; 
                    alpha = 0;
                    enabled = true;
                }
                local colored_buttons_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Colored Buttons"; 
                    alpha = 0;
                    enabled = true;
                }
                local colored_buttons = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<X> Jump\n<Y> Board/Abandon\n<A> Enter/Run\n<B> Phone\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local central_buttons_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Central Buttons"; 
                    alpha = 0;
                    enabled = true;
                }
                local central_buttons = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<Back> ...\n<Start> ...\n<Main> Pause\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local status_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Status"; 
                    alpha = 0;
                    enabled = true;
                }
                local status = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 160);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Gamepad Connected"; 
                    alpha = 0;
                    enabled = true;
                }
                self.stack = hud_object `/common/hud/StackX` {
                    parent = self,
                    padding = 0,
                    { align = "TOP" },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        left_button_target_header,
                        left_button_target,
                        left_stick_header,
                        left_stick,
                        pad_header,
                        pad,
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        central_buttons_header,
                        central_buttons,
                        editor_image,
                        status_header,
                        status,
                        menu_button {
                        caption = "<";
                        size = vec(40, 40);
                        pressedCallback = function() 
                            menu_show(last_menu,previous_menu)
                        end
                      },
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        right_button_target_header,
                        right_button_target,
                        colored_buttons_header,
                        colored_buttons,
                        right_stick_header,
                        right_stick,
                    },
                }
            end,
            escapePressed = function (self)
                menu_show(last_menu,previous_menu)
            end,
        }
    end;

    keyboard = function(last_menu,previous_menu)
        return hud_object `MenuPage` {
            buildChildren = function(self)
                local orange = menu_keyboard_hover; --vec(0.8,.17,0.03);
                local thumbs_size = vec(200, 150);
                local infos_size = vec(200, 100);
                local console_image = hud_object `/common/hud/Rect` {
                    size = vec(200, 100);
                    texture = `/common/hud/HelpScreen/keyboard.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local players_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/players_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local players_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Players"; 
                    alpha = 0;
                    enabled = true;
                }
                local players_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nw\tForwards\ns\tBackwards\na\tTurn Left\nd\tTurn Right\nSpace\tJump\nShift\tRun\nc\tCrouch\nf\tBoard\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local cars_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/cars_thumb.png`;
                    caption = "CARS";
                    colour = vec(0.5, 0.5, 0.5);
                }
                local cars_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Cars"; 
                    alpha = 0;
                    enabled = true;
                }
                local cars_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nw\tForwards\ns\tBackwards\na\tTurn Left Automatic\nd\tTurn Right Automatic\n◀\tTurn Left Manual\n▶\tTurn Right Manual\nSpace\tHandbrake\nShift\tFaster\nl\tToggle Lights\nf\tAbandon"; 
                    alpha = 0;
                    enabled = true;
                }
                local planes_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/planes_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local planes_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Planes"; 
                    alpha = 0;
                    enabled = true;
                }
                local planes_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nw\tForwards\ns\tBackwards\na\tTurn Wheels Left\nd\tTurn Wheels Right\n▲\tUp\n▼\tDown\n◀\tTurn Left\n▶\tTurn Right\nf\tAbandon"; 
                    alpha = 0;
                    enabled = true;
                }
                local hovers_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/hovers_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local hovers_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Hovers"; 
                    alpha = 0;
                    enabled = true;
                }
                local hovers_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nw\tForwards\ns\tBackwards\na\tTurn Left\nd\tTurn Right\nSpace\tAscend\nc\tDescend\nShift\tFaster\nl\tToggle Lights\nf\tAbandon"; 
                    alpha = 0;
                    enabled = true;
                }
                local helis_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/helis_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local helis_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Heli\'s"; 
                    alpha = 0;
                    enabled = true;
                }
                local helis_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nw\tForwards\ns\tBackwards\na\tLeft\nd\tRight\nSpace\tAscend\nc\tDescend\nShift\tFaster\nl\tToogle Lights\nf\tAbandon"; 
                    alpha = 0;
                    enabled = true;
                }
                local bikes_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/bikes_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local bikes_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Bikes"; 
                    alpha = 0;
                    enabled = true;
                }
                local bikes_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nw\tForwards\ns\tBackwards\na\tTurn Left\nd\tTurn Right\nSpace\tHandbrake\nShift\tFaster\nl\tToogle Lights\nf\tAbandon"; 
                    alpha = 0;
                    enabled = true;
                }
                local controls_image = hud_object `/common/hud/Rect` {
                    size = thumbs_size;
                    texture = `/common/hud/HelpScreen/controls_thumb.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local controls_footer = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(40, 20);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Controls"; 
                    alpha = 0;
                    enabled = true;
                }
                local controls_infos = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = infos_size;
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "LEFT";
                    value = "\n\nEsc\tPause\nx\t1st/3rd person view\nv\tZoom In\nV\tZoom out\nTab\tLua Command line\nF12\tScreen capture\n"; 
                    alpha = 0;
                    enabled = true;
                }
                self.stack = hud_object `/common/hud/StackX` {
                    parent = self,
                    padding = 0,
                    { align = "TOP" },
                    hud_object `/common/hud/StackY` {
                    padding = 0,
                    hud_object `/common/hud/StackX` {
                       padding = 0,
		                 menu_button {
		                     caption = "<";
		                     size = vec(40, 40);
		                     pressedCallback = function() 
		                         menu_show(last_menu,previous_menu)
		                     end
		                 },
                       console_image,
                    },
                    hud_object `/common/hud/StackX` {
                       padding = 40,
					         hud_object `/common/hud/StackY` {
					            padding = 0,
					            players_image,
					            players_footer,
                           players_infos,
					         },
					         hud_object `/common/hud/StackY` {
					            padding = 0,
					            cars_image,
					            cars_footer,
					            cars_infos,
					         },
					         hud_object `/common/hud/StackY` {
					            padding = 0,
					            planes_image,
					            planes_footer,
                           planes_infos,
					         },
					         hud_object `/common/hud/StackY` {
					            padding = 0,
					            controls_image,
					            controls_footer,
					            controls_infos,
					         },
                    },
                  },
                }
            end,
            escapePressed = function (self)
                menu_show(last_menu,previous_menu)
            end,
        }
    end;

    gamepad = function(last_menu,previous_menu)
        return hud_object `MenuPage` {
            buildChildren = function(self)
                local orange = menu_keyboard_hover; -- vec(0.8,.17,0.03);
                local gamepad_image = hud_object `/common/hud/Rect` {
                    size = vec(400, 200);
                    texture = `/common/hud/HelpScreen/gamepad.png`;
                    colour = vec(0.5, 0.5, 0.5);
                }
                local pad_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "PAD"; 
                    alpha = 0;
                    enabled = true;
                }
                local pad = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<N> Zoom In\n<S> Zoom Out\n<W> Switches 1st/3rd person\n<E> Toggle Lights\n <N-W> ...\n <N-E> ...\n <S-W> ...\n <S-E> ...\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local left_button_target_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Left-Button (LB) & Left-Target (LT)"; 
                    alpha = 0;
                    enabled = true;
                }
                local left_button_target = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<LB> Descend\n<LT> ..."; 
                    alpha = 0;
                    enabled = true;
                }
                local right_button_target_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Right-Button (RB) & Right-Target (RT)"; 
                    alpha = 0;
                    enabled = true;
                }
                local right_button_target = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<RB> Ascend\n<RT> Fire\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local right_stick_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Right-Stick (RS)"; 
                    alpha = 0;
                    enabled = true;
                }
                local right_stick = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<RS-U> Camera\n<RS-D> ...\n<RS-L> ...\n<RS-R> ...\n<RS-PUSH> ..."; 
                    alpha = 0;
                    enabled = true;
                }
                local left_stick_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Left-Stick (LS)"; 
                    alpha = 0;
                    enabled = true;
                }
                local left_stick = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Walk/Drive\n\n<LS-U> Forward\n<LS-D> Backward\n<LS-L> Left\n<LS-R> Right\n<LS-PUSH> Crunch"; 
                    alpha = 0;
                    enabled = true;
                }
                local colored_buttons_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Colored Buttons"; 
                    alpha = 0;
                    enabled = true;
                }
                local colored_buttons = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<X> Jump\n<Y> Board/Abandon\n<A> Enter/Run\n<B> Phone\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local central_buttons_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Central Buttons"; 
                    alpha = 0;
                    enabled = true;
                }
                local central_buttons = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 200);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "<Back> ...\n<Start> ...\n<Main> Pause\n"; 
                    alpha = 0;
                    enabled = true;
                }
                local status_header = hud_object `/common/hud/Label` {
                    font = menu_font;
                    size = vec(400, 40);
                    textColour = orange;
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Status"; 
                    alpha = 0;
                    enabled = true;
                }
                local status = hud_object `/common/hud/Label` {
                    font = infos_font;
                    size = vec(400, 160);
                    textColour = vec(1, 1, 1);
                    colour = vec(0, 0, 0);
                    alignment = "CENTER";
                    value = "Gamepad Connected"; 
                    alpha = 0;
                    enabled = true;
                }
                self.stack = hud_object `/common/hud/StackX` {
                    parent = self,
                    padding = 0,
                    { align = "TOP" },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        left_button_target_header,
                        left_button_target,
                        left_stick_header,
                        left_stick,
                        pad_header,
                        pad,
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        central_buttons_header,
                        central_buttons,
                        gamepad_image,
                        status_header,
                        status,
                        menu_button {
                        caption = "<";
                        size = vec(40, 40);
                        pressedCallback = function() 
                            menu_show(last_menu,previous_menu)
                        end
                      },
                    },
                    hud_object `/common/hud/StackY` {
                        padding = 0,
                        right_button_target_header,
                        right_button_target,
                        colored_buttons_header,
                        colored_buttons,
                        right_stick_header,
                        right_stick,
                    },
                }
            end,
            escapePressed = function (self)
                menu_show(last_menu,previous_menu)
            end,
        }
    end;

    help = function(last_menu)
       return hud_object `MenuPage` {
            stackMenu = function(self)
                return
                menu_button {
                    caption = "System";
                    pressedCallback = function() 
                        menu_show("system", "help",last_menu)
                    end
                },
                menu_button {
                    caption = "Editor";
                    pressedCallback = function() 
                        menu_show("editor", "help",last_menu)
                    end
                },
                menu_button {
                    caption = "Keyboard";
                    pressedCallback = function() 
                        menu_show("keyboard", "help",last_menu)
                    end
                },
                menu_button {
                    caption = "Gamepad";
                    pressedCallback = function() 
                        menu_show("gamepad", "help",last_menu)
                    end
                },
                menu_button {
                    caption = "<";
                    size = vec(40, 40);
                    pressedCallback = function() 
                         menu_show(last_menu)
                    end
                }
            end;
            escapePressed = function (self)
               menu_show(last_menu)
            end,
        }
    end;

    pause = function()
        game_manager:setPause(true)
        return hud_object `MenuPage` {
            alpha = 0,
            stackMenu = function(self)
                return
                menu_button {
                    caption = "Resume";
                    pressedCallback = function() 
                        self:resume()
                    end
                },
                menu_button {
                    caption = "Settings";
                    pressedCallback = function() 
                        menu_show("settings", "pause")
                    end
                },
                menu_button {
                    caption = "Return to main menu";
                    pressedCallback = function() 
                        game_manager:exit()
                    end
                },
                menu_button {
                    caption = "Exit";
                    pressedCallback = quit
                }
            end;
            escapePressed = function (self)
                self:resume()
            end,
            resume = function (self)
                game_manager:setPause(false)
                menu_show(nil)
            end,
        }
    end;
}

menu_active = menu_active or nil

-- Show the menu of the given name, replacing the current one if there is one.
-- This function handles the overall UI aspects of displaying the menu.
function menu_show(name, ...)
    safe_destroy(menu_active)
    if name == nil then
        menu_binds.modal = false
        return
    end
    local inner_menu = menu_pages[name](...)
    menu_active = hud_object `/common/hud/Stretcher` { child=inner_menu, zOrder=13 }
    menu_binds.modal = true
end
