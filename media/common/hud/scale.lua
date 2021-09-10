-- (c) 2013 Dave Cunningham and the Grit Game Engine Project, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Scale` {

    colour = vec(0, 0, 0),
    size = vec(400, 20);

    textSeparation = 0;
    textWidth = 40;

    textBgAlpha = 1;

    textBackgroundTexture = `/common/hud/CornerTextures/Filled02.png`;
    textBackgroundPassiveColour = vec(0.25, 0.25, 0.25);
    textBackgroundHoverColour = vec(0.5, 0.25, 0);
    textBackgroundEditingColour = vec(1, 0.5, 0);
    textBackgroundGreyedColour = vec(0.25, 0.25, 0.25);
    
    textBorderTexture = `/common/hud/CornerTextures/Border02.png`;
    textBorderPassiveColour = vec(0.6, 0.6, 0.6);
    textBorderHoverColour = vec(0.6, 0.6, 0.6);
    textBorderEditingColour = vec(0.6, 0.6, 0.6);
    textBorderGreyedColour = vec(0.6, 0.6, 0.6);
    
    font = `/common/fonts/Verdana12`;
    textPassiveColour = vec(0.7, 0.7, 0.7);
    textHoverColour = vec(0.7, 0.7, 0.7);
    textEditingColour = vec(0.7, 0.7, 0.7);
    textGreyedColour = vec(0.4, 0.4, 0.4);


    bgAlpha = 1;
    bgColour = vec(0.5, 0.5, 0.5);
    bgTexture = nil;
    bgCornered = false,

    mgAlpha = 0;
    mgColour = vec(0.5, 0.5, 0.5);
    mgTexture = nil;

    fgColour = vec(1, 1, 1);

    value = 1;
    minValue = 0;
    maxValue = 1;
    format = "%0.3f";

    integer = false,
    
    init = function (self)
        self.needsInputCallbacks = true

        self.editBox = hud_object `EditBox` {
            parent = self,
            number = true,
            alpha = self.textBgAlpha,
            maxLength = 5,

            backgroundTexture = self.textBackgroundTexture,
            backgroundPassiveColour = self.textBackgroundPassiveColour,
            backgroundHoverColour = self.textBackgroundHoverColour,
            backgroundEditingColour = self.textBackgroundEditingColour,
            backgroundGreyedColour = self.textBackgroundGreyedColour,

            borderTexture = self.textBorderTexture;
            borderPassiveColour = self.textBorderPassiveColour,
            borderHoverColour = self.textBorderHoverColour,
            borderEditingColour = self.textBorderEditingColour,
            borderGreyedColour = self.textBorderGreyedColour,

            font = self.font,
            textPassiveColour = self.textPassiveColour,
            textHoverColour = self.textHoverColour,
            textEditingColour = self.textEditingColour,
            textGreyedColour = self.textGreyedColour,

            onChange = function(self2) self:editChanged() end,
            onEditting = function(self2, v) self:editEditting(v) end
        }

        self.greyed = false

        -- The background and midground exist to allow alpha blending effects,
        -- e.g. a checkered texture on the blackground fading to a solid colour
        -- on the right hand side.
        self.sliderBackground = hud_object `Rect` {
            parent = self,
            alpha = self.bgAlpha,
            colour = self.bgColour,
            texture = self.bgTexture,
            cornered = self.bgCornered,
            zOrder = 0,
        }

        self.sliderMidground = hud_object `Rect` {
            parent = self,
            colour = self.mgColour,
            alpha = self.mgAlpha,
            texture = self.mgTexture,
        }

        self.slider = hud_object `Rect` {parent=self.sliderMidground, colour=vec(0, 0, 0)}
        self.sliderInside = hud_object `Rect` {parent=self.slider, colour=self.fgColour}
        self:update()

        self.inside = false
        self.dragging = false
        self.localPos = vec(0, 0)

        self:setValue(self.value);
    end;

    destroy = function (self)
    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        self.editBox:setGreyed(v)
        self:updateAppearance()
    end;

    setBackgroundColour = function (self, c)
        self.bgColour = c
        self:updateAppearance()
    end;
    
    setMidgroundColour = function (self, c)
        self.mgColour = c
        self:updateAppearance()
    end;
    
    setBackgroundAlpha = function (self, v)
        self.bgAlpha = v
        self:updateAppearance()
    end;
    
    setMidgroundAlpha = function (self, v)
        self.mgAlpha = v
        self:updateAppearance()
    end;
    
    setGamma = function (self, v)
        self.gamma = v
        self:updateAppearance()
    end;
    
    drag = function (self)
        local val = (self.localPos + self.size.x/2 - 1) / self.sliderBackground.size.x
        val = clamp(val, 0, 1)
        if self.gamma then val = math.pow(val, 2.2) end
        self.value = val * self.maxValue
        if self.integer then
            self.value = math.floor(self.value + 0.5)
        end
        self.editBox:setValue(self.format:format(self.value))
        self:updateAppearance()
        self:onChange(self.value)
    end;
        
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
        self.localPos = local_pos.x
        if self.dragging then
            self:drag()
        end
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" and self.inside then
            self.dragging = true
            if self.inside then
                self:drag()
            end
        elseif ev == "-left" then
            self.dragging = false
        elseif ev == "+up" and self.inside then
            self.value = math.clamp(self.value + 0.001, 0, self.maxValue)
            self.editBox:setValue(self.format:format(self.value))
            self:updateAppearance()
            self:onChange(self.value)
        elseif ev == "+down" and self.inside then
            self.value = math.clamp(self.value - 0.001, 0, self.maxValue)
            self.editBox:setValue(self.format:format(self.value))
            self:updateAppearance()
            self:onChange(self.value)
        end
    end;
    
    editChanged = function (self)
        self.value = tonumber(self.editBox.value)
        if self.value > self.maxValue then
            self.value = self.maxValue
        end
        self:updateAppearance()
        self:onChange(self.value)
    end;

    editEditting = function (self, editting)
        if editting then return end
        self:editChanged()
        self.editBox:setValue(self.format:format(self.value))
    end;

    updateAppearance = function (self)
        local val = math.clamp((self.value - self.minValue) / (self.maxValue - self.minValue), 0, 1)
        if self.gamma then
            val = math.pow(val, 1/2.2)
        end
        self.slider.position = vec((val - 0.5) * (self.sliderMidground.size.x-1),0)
        if self.greyed then
            self.sliderBackground.colour = vec(0.5, 0.5, 0.5)
            self.sliderBackground.texture = nil
            self.sliderMidground.enabled = false
            self.slider.colour = vec(0.35, 0.35, 0.35)
            self.sliderInside.colour = vec(0.65, 0.65, 0.65)
        else
            self.sliderBackground.colour = self.bgColour
            self.sliderBackground.texture = self.bgTexture
            self.sliderMidground.colour = self.mgColour
            self.sliderMidground.texture = self.mgTexture
            self.sliderMidground.alpha = self.mgAlpha
            self.sliderMidground.enabled = true
            self.slider.colour = vec(0, 0, 0)
            self.sliderInside.colour = self.fgColour
        end        
    end;

    setValue = function (self, v)
        if v > self.maxValue then v = self.maxValue end
        if v < self.minValue then v = self.minValue end
        self.value = v
        self.editBox:setValue(self.format:format(self.value))
        self:updateAppearance()
    end;

    updateValue = function (self)
    end;

    resizedCallback = function (self)
        self:update()
    end,

    update = function (self)
        local sz = self.size
        local left   = -sz.x/2
        local right  =  sz.x/2
        local bottom = -sz.y/2
        local top    =  sz.y/2
        self.sliderBackground:setRect(left+1, bottom+1, right-1-self.textWidth-1, top-1)
        self.sliderMidground:setRect(left+1, bottom+1, right-1-self.textWidth-1, top-1)
        self.editBox:setRect(right - 1 - self.textWidth + self.textSeparation, bottom + 1, right - 1, top - 1)
        self.slider.size = vec(3, sz.y-2)
        self.sliderInside.size = vec(1, sz.y-2)
        self:updateAppearance()
    end;
    
    onChange = function (self, v)
        gge_print("Changed to: "..v)
    end;
}
