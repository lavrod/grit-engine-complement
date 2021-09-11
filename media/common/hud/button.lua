-- (c) The Grit Game Engine authors 2016, Licensed under the MIT license (https://goo.gl/YVVx3L).

-- A clickable button, supporting:
-- * static background texture
-- * static border texture
-- * textual caption
-- * dynamic effects via colour masks:
--   * greying out
--   * mouseover
--   * click
hud_class `Button` {

    -- Applied to both background and border textures.
    cornered=true;

    -- Whether the button will be shrunk to match the text.
    autoSize = false;

    -- Padding around the text when auto-sizing.
    padding=vec(8,6);

    backgroundTexture = `/common/hud/CornerTextures/Filled08.png`;
    backgroundPassiveColour = vec(0.25, 0.25, 0.25);
    backgroundHoverColour = vec(0.5, 0.25, 0);
    backgroundClickColour = vec(1, 0.5, 0);
    backgroundGreyedColour = vec(0.25, 0.25, 0.25);

    borderTexture = `/common/hud/CornerTextures/Border08.png`;
    borderPassiveColour = vec(0.6, 0.6, 0.6);
    borderHoverColour = vec(0.6, 0.6, 0.6);
    borderClickColour = vec(0.6, 0.6, 0.6);
    borderGreyedColour = vec(0.6, 0.6, 0.6);

    captionFont = `/common/fonts/Verdana12`;
    caption = "Button";
    captionPassiveColour = vec(0.7, 0.7, 0.7);
    captionHoverColour = vec(0.7, 0.7, 0.7);
    captionClickColour = vec(0.7, 0.7, 0.7);
    captionGreyedColour = vec(0.4, 0.4, 0.4);

    init = function (self)
        self.needsInputCallbacks = true

        if self.backgroundTexture then
            self.texture = self.backgroundTexture
        end

        self.text = gge_hud_text_add(self.captionFont)
        self.text.parent = self
        self:setCaption(self.caption)

        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        if self.borderTexture then
            self.border = hud_object `/common/hud/Rect` {
                texture=self.borderTexture,
                parent=self,
                cornered=self.cornered,
            }
        end
        
        self.state = "PASSIVE"
        self:refreshState()
        self.needsResizedCallbacks = true
        self:update()
    end;

    resizedCallback = function (self)
        self:update()
    end,

    update = function (self)
        if self.borderTexture then
            self.border.size = self.size
        end
    end;
   
    destroy = function (self)
    end;
    
    -- Also resizes the button if autoSize is set.
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
        if self.autoSize then 
            self.size = self.text.size + self.padding * 2
        end
    end;

    setGreyed = function (self, v)
        self.greyed = v
        self:refreshState();
    end;

    refreshState = function (self)
        local old_state = self.lastState
        if self.greyed then
            self.text.colour = self.captionGreyedColour
            if self.borderTexture then
                self.border.colour = self.borderGreyedColour
            end
            self.colour = self.backgroundGreyedColour
            self.state = "GREYED"
        else
            if self.dragging and self.inside then
                self.text.colour = self.captionClickColour
                if self.borderTexture then
                    self.border.colour = self.borderClickColour
                end
                self.colour = self.backgroundClickColour
                self.state = "CLICK"
            elseif self.inside then
                self.text.colour = self.captionHoverColour
                if self.borderTexture then
                    self.border.colour = self.borderHoverColour
                end
                self.colour = self.backgroundHoverColour
                self.state = "HOVER"
            else
                self.text.colour = self.captionPassiveColour
                if self.borderTexture then
                    self.border.colour = self.borderPassiveColour
                end
                self.colour = self.backgroundPassiveColour
                self.state = "PASSIVE"
            end
        end
        if old_state ~= self.state then
            self:stateChangeCallback(old_state, self.state)
        end
    end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
        self:refreshState()
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside and not self.greyed then
                self:pressedCallback()
                -- In case the button destroyed itself.  This is common with "close" buttons.
				if self.destroyed then return end
            end
            self.dragging = false
        end
        self:refreshState()
    end;

    pressedCallback = function (self)
        gge_error("Button has no associated action.")
    end;

    stateChangeCallback = function (self, hover)
    end;

}
