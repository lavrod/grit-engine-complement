-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

control_being_dragged = nil

hud_class `DragIcon` {
    texture = `ColourDrag.png`;
    zOrder = 7;
    mouseMoveCallback = function (self, local_pos, screen_pos)
        self.position = screen_pos
    end;
    buttonCallback = function (self, ev)
        if control_being_dragged == nil then return end
        if ev == "-left" then
            local c = gge_hud_ray(self.position)
            if c ~= nil and c.receiveDrag ~= nil then
                c:receiveDrag(control_being_dragged)
            end
            self:stopDrag()
        end
    end;
    startDrag = function (self, c)
        control_being_dragged = c
        self.enabled = true
        self.needsInputCallbacks = true
        self.colour = c:getDragColour()
        gge_input_filter_set_cursor_hidden(true)
    end;
    stopDrag = function (self)
        control_being_dragged = nil
        self.enabled = false
        self.needsFrameCallbacks = false
        gge_input_filter_set_cursor_hidden(false)
    end
}
safe_destroy(control_beaker)
control_beaker = hud_object `DragIcon` { enabled = false }

local Control = {

    caption = "Unnamed";
    showCaption = true;

    size = vec(100, 20);
    width = 20;
    
    init = function (self)
        self.needsInputCallbacks = true
        self.alpha = 0
        if self.showCaption then
            self.label = hud_object `/common/hud/Label` {parent=self, borderColour=vec(0, 0, 0), value=self.caption, alpha = 0}
        else
            self.size = vec(self.width, self.size.y)
        end
        self.inside = false
        self.greyed = not not self.greyed
        self.needsResizedCallbacks = true
    end;
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
        self.lastPos = screen_pos
        if self.downPos ~= nil then
            if #(self.downPos - self.lastPos) > 3 then
                control_beaker:startDrag(self)
                self.downPos = nil
            end
        end
    end;

    setGreyed = function (self, v)
        self.greyed = v
        if self.showCaption then
            self.label:setGreyed(self.greyed)
        end
    end;

    getDragColour = function (self) return vec(1,1,1) end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" and self.inside then
            self.downPos = self.lastPos
        elseif ev == "-left" then
            if self.inside then
                self:onClick()
            end
            self.downPos = nil
        end
    end;
    
    update = function(self)
        if self.showCaption then
            self.label:setRect(-self.size.x/2,-self.size.y/2, self.size.x/2-self.width+1,self.size.y/2)
        end
    end;

    resizedCallback = function (self)
        self:update()
    end,

    receiveDrag = function (self, other)
    end;

    onClick = function (self)
    end;

    onChange = function (self)
    end;
}

hud_class `ColourControl` (extends(Control) {
    initialColour = vec(1, 1, 0.5);
    initialAlpha = 1;
    init = function (self)
        Control.init(self)
        self.square = hud_object `/common/hud/Rect` {parent=self, texture = `Capsule.png`}
        self.alphaSquare = hud_object `/common/hud/Rect` {parent=self, texture = `CapsuleAlpha.png`}
        self:setColour(self.initialColour, self.initialAlpha)
        self:updateAppearance()
        self:update()
    end;
    destroy = function(self)
    end;
    updateAppearance = function (self)
        if self.greyed then
            self.square.colour = vec(0.5, 0.5, 0.5)
            self.alphaSquare.alpha = 0
        else
            self.square.colour = tone_map(self.colour)
            self.alphaSquare.alpha = 1 - (self.a or 1)
        end
    end;
    setColour = function(self, v, a)
        if type(v) == "vector4" and a == nil then
            a = v.w
            v = v.xyz
        end
        self.colour = v
        self.a = a
        self:updateAppearance()
    end;
    getDragColour = function(self)
        return self.square.colour
    end;
    update = function(self)
        Control.update(self)
        self.square:setRect(     self.size.x/2-self.width, -self.size.y/2, self.size.x/2,self.size.y/2)
        self.alphaSquare:setRect(self.size.x/2-self.width, -self.size.y/2, self.size.x/2, self.size.y/2)
    end;
    receiveDrag = function (self, other)
        if other.className ~= self.className then return end
        local incoming_alpha = other.a
        if self.a == nil then
            incoming_alpha = nil
        else
            incoming_alpha = incoming_alpha or 1 -- default to 1
        end
        self:setColour(other.colour, incoming_alpha)
        self:onChange()
    end;
})

hud_class `ValueControl` (extends(Control) {
    initialValue = 1;
    format = "%0.3f";
    maxValue = 1;
    init = function (self)
        Control.init(self)    
        self.valueDisplay = hud_object `/common/hud/EditBox` {
            font=`/common/fonts/TinyFont`;
            parent=self;
            borderColour=vec(1,1,1);
            number=true;
            text="INIT";
            maxLength=self.maxLength;
            -- from inside out
            onChange = function (self2)
                local v = tonumber(self2.value) or 0
                self.value = v
                self:onChange()
            end;
            onEditting = function(self2, editting)
                if editting == false then
                    local v = tonumber(self2.value) or 0
                    if v > self.maxValue then
                        v = self.maxValue
                        self.valueDisplay:setValue(self:formatValue(v))
                    end
                    self.value = v
                    self:onChange()
                end
                self:onEditting(editting)
            end;
            onClick = function() self:onClick() end;
        }
        self:update()
        self:setValue(self.initialValue)
    end;
    destroy = function(self)
    end;
    setGreyed = function (self, v)
        Control.setGreyed(self, v)
        self.valueDisplay:setGreyed(self.greyed)
    end;
    update = function(self)
        Control.update(self)
        self.valueDisplay:setRect(self.size.x/2-self.width+1,-self.size.y/2+1, self.size.x/2-1,self.size.y/2-1)
    end;
    -- from outside in
    setValue = function (self, v)
        if type(v) ~= "number" then gge_error("Not a number: "..tostring(type(v))) end
        if v > self.maxValue then v = self.maxValue end
        self.value = v
        self.valueDisplay:setValue(self:formatValue(v))
    end;
    formatValue = function (self,v)
        return self.format:format(v)
    end;
    onEditting = function (self, editting)
        gge_print("ValueControl.onEditting")
    end;
    receiveDrag = function (self, other)
        if other.className ~= self.className then return end
        self:setValue(other.value)
    end;
})

hud_class `EnumControl` (extends (Control) {
    value = 1;
    options = { "False", "True" };
    init = function (self)
        Control.init(self)
        self.valueDisplay = hud_object `/common/hud/Label` {parent=self, borderColour=vec(0,0,0)}
        self:setValue(self.value)
        self:update()
    end;
    destroy = function (self)
    end;
    setGreyed = function (self, v)
        Control.setGreyed(self, v)
        self.valueDisplay:setGreyed(self.greyed)
    end;
    update = function (self)
        Control.update(self)
        self.valueDisplay:setRect(self.size.x/2-self.width,-self.size.y/2, self.size.x/2,self.size.y/2)
    end;
    setValue = function (self, v)
        self.valueDisplay.text.text = self.options[v] or "???"
        self.value = v
    end;
    getTextValue = function (self, v)
        return self.options[self.value]
    end;
    advanceValue = function (self)
        local v = self.value + 1
        if v > #self.options then v = 1 end
        self:setValue(v)
        self:onChange()
    end;
    onClick = function (self)
        advanceValue()
    end;
    
})

