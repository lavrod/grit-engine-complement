local icon_size = vec(64, 80)


-- Display of the file / directory icon.
-- Handles mouse interaction with icon but defers to callbacks for actual behavior.
-- startDragging()
-- doubleClick()
hud_class `BrowserIcon` {

    zOrder = 0,

    hoverColour = _current_theme.colours.browser_icon.hover,
    clickColour = _current_theme.colours.browser_icon.click,
    defaultColour = _current_theme.colours.browser_icon.default,
    textHoverColour = _current_theme.colours.browser_icon.text_hover,
    textClickColour = _current_theme.colours.browser_icon.text_click,
    textDefaultColour = _current_theme.colours.browser_icon.text_default,
    
    name = "Default",
    draggable = false,
    
    init = function (self)
        self.needsInputCallbacks = true;
        self.icon = create_rect({ texture=self.icon_texture, size=vec2(64, 64), parent=self, position=vec(0, 8)})
        self.text = hud_text_add(`/common/fonts/TinyFont`)
        self.text.text = self.name
        if self.text.size.x >= self.size.x then
            -- gge_print("long name: "..self.name)
            self.text.text = self.name:reverse():sub(-9):reverse().."..."
            --self.name:reverse():gsub(".....", "...", 1):reverse()
        end
        self.text.position = vec2(0, -self.icon.size.y/2+5)
        self.text.parent = self
        self:updateColour()

        self.lastClick = 0
    end,
    
    destroy = function (self)
        safe_destroy(_context_menu)
    end,

    updateColour = function (self)
        if self.mouseDown and not self.dragging then
            self.colour = self.clickColour
            self.text.colour = self.textDefaultColour
            self.alpha = 1
        else
            if self.inside then
                self.colour = self.hoverColour
                self.text.colour = self.textHoverColour
                self.alpha = 0.5
            else
                self.colour = self.defaultColour
                self.text.colour = self.textDefaultColour
                self.alpha = 0
            end
        end
    end,
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside =  (
			inside and not (
				mouse_pos_abs.y > (self.parent.parent.derivedPosition.y + self.parent.parent.size.y/2) or
				mouse_pos_abs.y < (self.parent.parent.derivedPosition.y - self.parent.parent.size.y/2)
			)
		)
        self:updateColour()
        if self.mouseDown and not self.dragging and  #(screen_pos - self.draggingPos) > 30 then
            self.dragging = true
            self:startDragging()
        end
    end,

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.mouseDown = self.draggable
            self.draggingPos = mouse_pos_abs
            self:updateColour()
            if self.lastClick ~= nil and gge_seconds() - self.lastClick <= 1 then
                self.lastClick = nil
                -- Can destroy the icon.
                self:doubleClick()
                return
            end
            self.lastClick = gge_seconds()

        elseif ev == "-left" then
            self.dragging = false
            self.mouseDown = false
            self:updateColour()
        end
    end,
    
    startDragging = function(self)

    end,
    
    doubleClick = function(self)

    end,
}

-- Return all the classes defined in the given dir.
local function get_class_dir(dir)
    local classes = {}
    for i, cls in ipairs(class_all()) do
        local class_dir, class_name = cls.name:match('^(.*/)([^/]*)$')
        if class_dir == dir then
            classes[#classes + 1] = class_name
        end
    end
    return classes
end

-- Is the mouse pointer over the game world (as opposed to blocked by a HUD object)
-- avoid_obj is excluded from the test, useful for drag icons.
local function mouse_over_game_world(avoid_obj)
    local old_enabled = avoid_obj.enabled
    avoid_obj.enabled = false
    local r = hud_ray(mouse_pos_abs) == nil
    avoid_obj.enabled = old_enabled
    return r
end

hud_class `FloatingObject` {

    size = vec(64, 64),
    texture = `/common/gui/icons/files/object.png`,
    zOrder = 7,
    id = 0,
    objectClass = "",
    positionOffset = vec(0, 0),
    
    init = function (self)
        self.needsInputCallbacks = true
        local cl = class_get(self.objectClass)
        self.zOffset = cl.placementZOffset or 0

        -- Will store the name of the object, after we have created it and while we continue to
        -- propose positions.
        self.newObjectName = nil

        -- Are we currently proposing positions on the map?
        self.positioning = false,

        self:updatePos()
    end,

    destroy = function (self)
    end,

    updatePos = function(self)
        self.position = mouse_pos_abs + self.positionOffset
    end,

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
        self:updatePos()

        local editor = game_manager.currentMode

        if mouse_over_game_world(self) then
            local cast_ray = 1000 * gfx_screen_to_world(main.camPos, main.camQuat, mouse_pos_abs)
            
            local body = nil
            if self.newObjectName ~= nil then
                body = editor.mapFile:getPhysicalRepresentation(self.newObjectName)
                -- Might still be nil if the object has no physical representation or is streamed
                -- out.
            end

            local dist
            if body ~= nil then
                -- Avoid the object colliding with itself.
                dist = gge_physics_cast(main.camPos, cast_ray, true, 0, body)
            else
                dist = gge_physics_cast(main.camPos, cast_ray, true, 0)
            end
            
            local pos = (main.camPos + cast_ray * (dist or 0.02)) + vec(0, 0, (self.zOffset or 0))
            
            if self.newObjectName == nil then
                local name = ('Unnamed:%s:%d'):format(self.objectClass, math.random(0, 50000))
                editor.mapFile:add(name, self.objectClass, pos)
                self.newObjectName = name
                self.alpha = 0
            else
                editor.mapFile:proposePosition(self.newObjectName, pos)
            end
        else
            if self.newObjectName then
                editor.mapFile:cancelChange()
                self.newObjectName = nil
                self.alpha = 1
            end
        end
    end,

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            -- The object only exists while the mouse is held down, so we should never get this.

        elseif ev == "-left" then
            self:droppedCallback()
            if self.newObjectName ~= nil then
                game_manager.currentMode.mapFile:applyChange()
                self.newObjectName = nil
            end
            self:droppedCallback()
            self:destroy()
        end
    end,

    -- Useful for notifying whoever made us that we're dead now.
    droppedCallback = function (self)
    end,
}

hud_class `ContentBrowser` `/common/gui/Window` {

    title = "Class Browser",

    -- Must always begin and end with a '/'.
    currentDir = '/',
    size = vec2(560, 320),
    minSize = vec2(470, 235),
    contentAreaAlpha = 1,
    
    init = function (self)
        WindowClass.init(self)

        -- Filled in while we're dragging an object icon across windows / the scene.
        self.dragIcon = nil
        
        self.dirTree = gui.object({
            colour = vec(0.2, 0.2, 0.2);
            alpha = 1;
            parent = self.contentArea;
            size = vec(180, self.size.y-120);
            align = vec(-1, 1);
            offset = vec(5, -35);
            expand_y = true;
            expand_offset = vec(0, -35-10);
        })

        self.dirTree.enabled = false

        local content_browser = self
        
        self.fileExplorer = hud_object `/common/gui/IconFlow` {
            size = vec2(self.size.x-20, self.size.y-120);
            alpha = 0;
            zOrder = 1,
            icons_size = icon_size,
        }
        self.scrollArea = hud_object `/common/gui/ScrollArea` {
            scrollX = false,
            content = self.fileExplorer,
            scrollCallback = function (self)
                -- Hide icons that spill out.
                content_browser.fileExplorer:reset()
            end,
			stencil = true,
        }
        self.scrollAreaStretcher = hud_object `/common/hud/Stretcher` {
            child = self.scrollArea,
            parent = self.contentArea,
            calcRect = function(self, psize)
                return 115 - psize.x/2, 5 - psize.y/2, psize.x/2 - 5, psize.y/2 - 35
            end,
        }

        self.upButton = gui.imagebutton({
            pressedCallback = function(self)
                if content_browser.currentDir == '/' then return end
                -- Strip off last dir.
                content_browser.currentDir = content_browser.currentDir:match('(.*/)[^/]*/')
                content_browser.editBox:setValue(content_browser.currentDir)
                content_browser:updateFileExplorer()
            end;
            icon_texture = _gui_textures.arrow_up;
            position = vec2(0, 0);
            parent = self.contentArea;
            colour = vec(1, 1, 1)*0.5;
            defaultColour = V_ID*0.5;
            hoverColour = V_ID*0.6;
            clickColour = V_ID*0.7;
            size = vec2(25, 25);
            offset = vec(-5, -5);
            align = vec(1, 1)        
        })

        self.editBox = hud_object `/common/gui/window_editbox` {
            parent = self.contentArea;
            value = self.currentDir;
            alignment = 'LEFT';
            size = vec(50, 20);
            offset = vec(5, -8);
            align = vec(-1, 1);
            expand_x = true;
            expand_offset = vec(-45, 0);
            enterCallback = function(self)
                if self.value.sub(-1) ~= '/' then
                    self:setValue(self.value .. '/')
                end
                content_browser.currentDir = self.value
                content_browser:updateFileExplorer()
            end,
        }
        self:updateFileExplorer()
    end;

    
    -- Changes the active dir.
    updateFileExplorer = function(self)
        local cb = self,

        self.fileExplorer:clearAll()
        local m_files, m_folders = get_dir_list(self.currentDir)
        
        m_files = get_class_dir(self.currentDir)

        local function add_icon(folder, name)
            self.fileExplorer:addIcon(
                hud_object `BrowserIcon` {
                    icon_texture = folder and  `/common/gui/icons/foldericon.png` or `/common/gui/icons/files/object.png`,
                    size = icon_size,
                    name = name,
                    draggable = not folder,
                    doubleClick = function(self)
                        if folder then
                            cb.currentDir = cb.currentDir .. self.name .. '/'
                            cb.editBox:setValue(cb.currentDir)
                            cb:updateFileExplorer()
                        end
                    end,
                    startDragging = function (self)
                        -- Only called if self.draggable == true
                        if cb.dragIcon == nil then
                            cb.dragIcon = hud_object `FloatingObject` {
                                positionOffset = self.icon.derivedPosition - self.draggingPos,
                                objectClass = cb.currentDir .. self.name,
                                droppedCallback = function (self)
                                    if not cb.destroyed then
                                        cb.dragIcon = nil
                                    end
                                end,
                            }
                        end
                    end
                }
            )
        end

        for _, name in ipairs(m_folders) do
            add_icon(true, name)
        end

        for _, name in ipairs(m_files) do
            add_icon(false, name)
        end

        self.scrollArea:setOffset(vec(0, 0))
        self.scrollArea:update()
        self.fileExplorer:reset()
    end,
}

local content_browserx = nil

function create_content_browser()
    if content_browserx ~= nil and not content_browserx.destroyed then
        content_browserx:destroy()
    end
    
    content_browserx = hud_object `ContentBrowser` {
        parent = hud_centre,
        position = vec(200, -200),
    }
    _windows[#_windows + 1] = content_browserx
    window_focus_grab(content_browserx)
    return content_browserx
end
