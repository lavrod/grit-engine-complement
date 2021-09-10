-- size of the whole screen

hud_class `SystemLayer` {

    buttonDescs = { };
    colour = vec(0.1, 0.1, 0.1);
    buttonPadding = vec(16, 4);
    zOrder = 15;

    init = function (self)
        self.needsParentResizedCallbacks = true
        local buttons = { padding = 10 }

        self.consoleButton = hud_object `Button` {
            pressedCallback = function (button) self:onConsolePressed() end;
            autoSize = true;
            caption = "Console";
            orientation = -90;
            padding = self.buttonPadding;
            parent=self;
        }

        for i, desc in ipairs(self.buttonDescs) do
            -- create 
            local panel = desc.panel
            buttons[i] = hud_object `Button` {
                pressedCallback = function (button) self:onPanePress(i) end;
                autoSize = true;
                caption = desc.name;
                orientation = -90;
                padding = self.buttonPadding;
            }
        end

        self.buttonStack = hud_object `StackY` (buttons)
        self.buttonStack.parent = self

        local sp = self.selectedPane
        self:selectPane(nil)
        self:selectPane(sp)
        self:selectConsole(self.consoleEnabled)

    end;

    onConsolePressed = function (self)
        self:selectConsole(not self.consoleEnabled)
    end;

    onPanePress = function (self, id)
        if self.selectedPane == id then
            self:selectPane(nil)
        else
            self:selectPane(id)
        end
    end;

    selectConsole = function (self, v)
        self.consoleEnabled = v
        console.enabled = self.consoleEnabled and self.enabled
    end;

    hidePane = function (self, pane)
        for name, desc in ipairs(self.buttonDescs) do
            if desc.panel == pane then
                self:selectPane(nil)
            end
        end
        if pane == console then
            self:selectConsole(false)
        end
    end;

    selectPane = function (self, id)
        self.selectedPane = id
        for i, desc in ipairs(self.buttonDescs) do
            local desc = self.buttonDescs[i]
            local should_enable = i == id and self.enabled
            if desc.panel.enabled ~= should_enable then
                desc.panel.enabled = should_enable
                if desc.onChange then
                    desc:onChange(should_enable)
                end
            end
        end
    end;

    setEnabled = function (self, v)
        self.enabled = v
        system_binds.modal = v
        ticker.enabled = not v
        self:selectConsole(self.consoleEnabled)  -- refresh console enable status
        self:selectPane(self.selectedPane)  -- refresh pane enable status
        if self.consoleEnabled then
            hud_focus_grab(console)
        end
		if not v then hud_focus = nil end
    end;

    destroy = function (self)
    end;

    parentResizedCallback = function (self, psize)
        self:setRect(0, 0, 40, psize.y)
        self.buttonStack.position = vec(0, -psize.y/2 + self.buttonStack.size.y/2 + 8)
        self.consoleButton.position = vec(0, psize.y/2 - self.consoleButton.bounds.y / 2 - 8)
    end;
}
