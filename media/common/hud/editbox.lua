-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Improved by Augusto P. Moura - 2016

-- What character index corresponds to the given pixel position?
-- Returns between 0 and #text inclusive
function text_char_pos (font, text, x)
    local len = #text
    local last_char_pos = 0
    for i=1, len do
        local this_char_pos = gfx_font_text_width(font, text:sub(1, i))
        if this_char_pos > x then
            if math.abs(last_char_pos - x) < math.abs(this_char_pos - x) then
                return i - 1
            else
                return i
            end
        end
        last_char_pos = this_char_pos
    end
    return len
end

-- Value is always text.  Can set .number to restrict input to numbers, but 
-- empty string is still a valid state. If using .number, use tonumber(blah.value) or 0

EditBoxClass = {
    cornered = true;

    backgroundTexture = `/common/hud/CornerTextures/Filled02.png`;
    backgroundPassiveColour = vec(0.25, 0.25, 0.25);
    backgroundHoverColour = vec(0.5, 0.25, 0);
    backgroundEditingColour = vec(1, 0.5, 0);
    backgroundGreyedColour = vec(0.25, 0.25, 0.25);

    borderTexture = `/common/hud/CornerTextures/Border02.png`;
    borderPassiveColour = vec(0.6, 0.6, 0.6);
    borderHoverColour = vec(0.6, 0.6, 0.6);
    borderEditingColour = vec(0.6, 0.6, 0.6);
    borderGreyedColour = vec(0.6, 0.6, 0.6);

    font = `/common/fonts/Verdana12`;
    textPassiveColour = vec(0.7, 0.7, 0.7);
    textHoverColour = vec(0.7, 0.7, 0.7);
    textEditingColour = vec(0.7, 0.7, 0.7);
    textGreyedColour = vec(0.4, 0.4, 0.4);

    font = `/common/fonts/Verdana12`;
	selectionColour = vec(0.5, 0.5, 0.5);

    padding = 4;
    alignment = "CENTRE";

    value = "Text";
    number = false;
	editing = false;
	isPassword = false;
	
    init = function (self)
        self.needsInputCallbacks = true
        self.needsResizedCallbacks = true
        self.text = hud_text_add(self.font)
        self.text.parent = self

        if self.borderTexture then
            self.border = hud_object `Rect` {
                texture = self.borderTexture;
                colour = self.borderColour;
                cornered = true;
                parent = self;
            }
        end

        self.caret = hud_object `Rect` {
            texture = `CornerTextures/Caret.png`;
            colour = self.textPassiveColour;
            cornered = true;
            parent = self;
        }

		self.selectionBG = hud_object `Rect` {
            colour = self.selectionColour;
            parent = self;
        }
		self.selectionBG.enabled = false

        self.selection = vec(0, 0); -- begin, end
		
        self.inside = false
        self:setGreyed(not not self.greyed)
        self.caret.enabled = false

        self:setValue(self.value)
        self:refreshState()
    end;

    updateText = function (self)
		if self.isPassword then
			self.text.text = string.rep("*", #self.before+#self.after)
		else
			self.text.text = self.before .. self.after
		end
        self:update()
        self.value = self.before .. self.after
    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        if self.editing then
            hud_focus_grab(nil)
        end
        self:refreshState()
    end;
    
    destroy = function (self)
    end;

    refreshState = function (self)
        local old_state = self.lastState
        if self.greyed then
            self.text.colour = self.textGreyedColour
            if self.borderTexture then
                self.border.colour = self.borderGreyedColour
            end
            self.colour = self.backgroundGreyedColour
        else
            if self.editing then
                self.text.colour = self.textEditingColour
                if self.borderTexture then
                    self.border.colour = self.borderEditingColour
                end
                self.colour = self.backgroundEditingColour
            elseif self.inside then
                self.text.colour = self.textHoverColour
                if self.borderTexture then
                    self.border.colour = self.borderHoverColour
                end
                self.colour = self.backgroundHoverColour
            else
                self.text.colour = self.textPassiveColour
                if self.borderTexture then
                    self.border.colour = self.borderPassiveColour
                end
                self.colour = self.backgroundPassiveColour
            end
        end
    end,

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside and local_pos
        self:refreshState()
		
		if self.clickPos then
			-- print("clpos "..self.clickPos.." localpos "..local_pos.x-self.text.position.x)
			if (self.clickPos == #self.value and local_pos.x-self.text.position.x > self.text.size.x/2) or 
			(self.clickPos == 0 and local_pos.x-self.text.position.x < -self.text.size.x/2) then
				self:unselectAll()
			else
				local pos = text_char_pos(self.font, self.value, local_pos.x + self.size.x/2 - self.padding)
				if pos ~= self.clickPos then
					self:select(self.clickPos, pos)
					-- print("pos: "..pos)
				end
			end
		end
    end;

    setEditing = function (self, editing)
        if self.editing == editing then return end
		if not self.editing then
			self:onEditing(editing)
		end
		self.editing = editing
		if not editing then self:onStopEditing() end
        self:refreshState()
    end;

    setFocus = function (self, editing)
        self.caret.enabled = editing
        self.needsFrameCallbacks = editing
        self:setEditing(editing)
    end;

    buttonCallback = function (self, ev)
        if self.greyed then return end
        if ev == "+left" then
            if not self.inside then
				if self.editing then
					self:unselectAll()
					hud_focus_grab(nil)
				end
            else
                if self.greyed then return end
                hud_focus_grab(self)
                local txt = self.value
                local pos = text_char_pos(self.font, txt, self.inside.x + self.size.x/2 - self.padding)
				if not self.clickPos then
					self.clickPos = pos
					self:unselectAll()
					-- print("init pos: "..pos)
				end
                self.before = txt:sub(1, pos)
                self.after = txt:sub(pos+1)
                self:updateText()
            end
		elseif ev == "-left" then
			self.clickPos = nil
        elseif hud_focus == self then
            if ev == "+Return" then
                hud_focus_grab(nil)
				self:enterCallback()
            elseif ev == "+BackSpace" or ev == "=BackSpace" then
				if #self.selection > 0 then
					self:removeSelectedText()
				else
					self.before = self.before:sub(1, -2)
					self:updateText()
					self:onChange(self)
				end
            elseif ev == "+Delete" or ev == "=Delete" then
				if #self.selection > 0 then
					self:removeSelectedText()
				else
					self.after = self.after:sub(2)
					self:updateText()
					self:onChange(self)
				end
            elseif ev == "+Left" or ev == "=Left" then
				if #self.selection > 0 then
					self:putCaretAt(self.selection.x)
					self:unselectAll()
				else
					if #self.before > 0 then
						local char = self.before:sub(-1, -1)
						self.before = self.before:sub(1, -2)
						self.after = char .. self.after
						self:updateText()
					end
				end
            elseif ev == "+Right" or ev == "=Right" then
				if #self.selection > 0 then
					self:putCaretAt(self.selection.y)
					self:unselectAll()
				else
					if #self.after > 0 then
						local char = self.after:sub(1, 1)
						self.after = self.after:sub(2)
						self.before = self.before .. char
						self:updateText()
					end
				end
			elseif input_filter_pressed("Ctrl") and ev == "+v" then
				local str = get_clipboard()
				if #self.selection > 0 then
					self:removeSelectedText()
				end
				self.before = self.before..str
				self:updateText()
			elseif input_filter_pressed("Ctrl") and ev == "+c" then
				if #self.selection > 0 then
					set_clipboard(self:getSelectedText())
				end
			elseif input_filter_pressed("Ctrl") and ev == "+x" then
				if #self.selection > 0 then
					set_clipboard(self:getSelectedText())
					self:removeSelectedText()
				end
			elseif input_filter_pressed("Ctrl") and ev == "+a" then
				self:selectAll()
            elseif ev:sub(1,1) == ":" then
                if self.maxLength == nil or #self.value < self.maxLength then
					self:removeSelectedText()
                    local key = ev:sub(2)
                    local text = self.value
                    if not self.number or
                       key:match("[0-9]") or
                       (key == "." and not text:match("[.]"))
                    then
                        self.before = self.before .. ev:sub(2)
                        self:updateText()
                        self:onChange(self)
                    end
                end
            end
        end
    end;
    
    frameCallback = function (self)
        local state = (seconds() % 0.5) / 0.5
        self.caret.enabled = state < 0.66
    end;

    update = function (self)
		local alignment_r = vec(self.size.x/2 - self.padding - self.text.size.x/2, 0)

        if self.alignment == "CENTRE" then
            self.text.position = vec(0,0)
        elseif self.alignment == "LEFT" then
			-- when the text is larger than the containing box invert the alignment
			if self.size.x-self.padding > self.text.size.x then
				self.text.position = -alignment_r
			else
				self.text.position = alignment_r
			end
        elseif self.alignment == "RIGHT" then
			if self.size.x-self.padding > self.text.size.x then
				self.text.position = alignment_r
			else
				self.text.position = -alignment_r
			end
        end
        self.caret.size = vec(self.caret.size.x, self.size.y-4)
        if self.border then
            self.border.size = self.size
        end
        local tw = gfx_font_text_width(self.font, self.before)
        self.caret.position = vec(self.text.position.x -self.text.size.x/2 + tw, 0)
    end;

    resizedCallback = function (self)
        self:update()
    end,

    putCaretAt = function (self, pos)
		self.before = self.value:sub(0, pos)
		self.after =  self.value:sub(pos+1, #self.value)
		self:update()
    end;		
	
    selectAll = function (self)
		self.before = self.value
		self.after = ""
		self:select(#self.value, 0)
    end;		
	
    unselectAll = function (self)
		self:setFocus(true)
		self.selection = vec(0, 0)
		self.selectionBG.enabled = false
    end;	
	
    select = function (self, a, b)
		self:setFocus(false)
		self.selectionBG.enabled = true
		local tw
		local crposx = self.text.position.x -self.text.size.x/2+gfx_font_text_width(self.font, self.before)
		
		if a < b then
			self.selectiontype = 'r'
			self.selection = vec(a, b)
			tw = gfx_font_text_width(self.font, self:getSelectedText())
			self.selectionBG.position = vec(crposx+tw/2, 0)
		else
			self.selectiontype = 'l'
			self.selection = vec(b, a)
			tw = gfx_font_text_width(self.font, self:getSelectedText())
			self.selectionBG.position = vec(crposx-tw/2, 0)
		end
		self.selectionBG.size = vec(tw, self.text.size.y)
		-- print(self:getSelectedText())
    end;
	
    getSelectedText = function (self)
		return self.value:sub(self.selection.x+1, self.selection.y)
    end;
	
    removeSelectedText = function (self)
		if self.selectiontype == "l" then
			self.before = self.before:sub(1, #self.before-#self:getSelectedText())
		else
			self.after = self.after:sub(#self:getSelectedText()+1, #self.after)
		end
		
		self:updateText()
		self:unselectAll()
    end;
	
	-- called when anything is typed
    onChange = function (self)
        -- By default, do nothing, since often people will only care when enter is pressed.
    end;
	
	--called when begin editing
    onEditing = function (self, editing)
		
    end;
	
	-- called when stop editing
    onStopEditing = function (self, editing)
		
    end;
	
	-- called when enter is pressed
	enterCallback = function(self)

	end;
    
    setValue = function (self, value)
        self.before = value
        self.after = ""
        self:updateText()
    end;

}

hud_class `EditBox` (EditBoxClass)
