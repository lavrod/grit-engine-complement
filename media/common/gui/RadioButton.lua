------------------------------------------------------------------------------
--  Radio Button Class
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `RadioButton` (extends(_gui.class)
{
	alpha = _current_theme.colours.radiobutton.alpha;
	colour = _current_theme.colours.radiobutton.background;
	textColour = _current_theme.colours.text.default;
	
	caption = "";
	padding = 5;
	selected = false;
	dragging = false;
	
	init = function (self)
		_gui.class.init(self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		
		self.icon = create_rect({
			parent = self,
			position = vec2(0, 0),
			texture = self.backgroundTexture or _gui_textures.radio_button.background,
			size = vec(15, 15)
		})
		self.icon_check = create_rect({
			parent = self.icon,
			position = vec2(0, 0),
			texture = self.checkedTexture or _gui_textures.radio_button.checked,
			size = self.icon.size,
			colour = self.checkColour or _current_theme.colours.radiobutton.icon
		})
		self.icon_check.enabled = false
		
		self.text = hud_text_add(self.font or _current_theme.fonts.radiobutton)
		self.text.parent = self
		self.text.text = self.caption
		self.text.colour = self.textColour		
		
		self:update()
	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
		self.needsParentResizedCallbacks = false
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)		
		self.inside = inside
	end;
	
    update = function (self)		
		self.size = vec(self.text.size.x+self.padding*4+self.icon.size.x, self.icon.size.y)
		self.icon.position = vec(-self.size.x/2+self.icon.size.x/2, self.icon.position.y)
		self.text.position = vec(-self.size.x/2+self.icon.size.x+self.padding+self.text.size.x/2, self.text.position.y)
	end;	

	-- the first radio button creates a table on its parent to point what radio button is selected
	setParentTable = function(self)
		if self.parent.radiobuttons == nil then
			self.parent.radiobuttons = {}
		end
	end;

    buttonCallback = function (self, ev)
		if ev == "+left" and self.inside then
			self.dragging = true
		elseif ev == "-left" then
			if self.inside and self.dragging then
				self:setParentTable()
				-- when a radio button is selected the previous one is unselected..
				if self.parent.radiobuttons.selected ~= self and self.parent.radiobuttons.selected ~= nil and not self.parent.radiobuttons.selected.destroyed then
					self.parent.radiobuttons.selected:unselect()
				end
				if self.parent.radiobuttons.selected ~= self then
					self:select()
				end
			end
			self.dragging = false
		end
    end;

	parentResizedCallback = function(self, psize)
		_gui.class.parentResizedCallback(self, psize)
	end;
	
	select = function(self)
		if self.parent ~= nil then
			self:setParentTable()
			self.parent.radiobuttons.selected = self
		end
		self:onSelect()
		self.icon_check.enabled = true
	end;
	
	onSelect = function(self)
		
	end;	
	
	unselect = function(self)
		self.icon_check.enabled = false
	end;
})

function gui.radiobutton(tab)
	return hud_object `RadioButton` (tab)
end
