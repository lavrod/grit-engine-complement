------------------------------------------------------------------------------
--  Checkbox Class
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `Checkbox` (extends(_gui.class)
{
	alpha = _current_theme.colours.checkbox.alpha;
	colour = _current_theme.colours.checkbox.background;
	textColour = _current_theme.colours.text.default;
	
	caption = nil;
	padding = 5;
	checked = false;
	dragging = false;
	
	init = function (self)
		_gui.class.init(self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks = true
		
		self.icon = create_rect({
			parent = self,
			position = vec2(0, 0),
			texture = self.backgroundTexture or _gui_textures.checkbox.background,
			size = vec(15, 15)
		})
		self.icon_checked = create_rect({
			parent = self.icon,
			position = vec(0, 0),
			texture = self.checkedTexture or _gui_textures.checkbox.checked,
			size = self.icon.size,
			colour = self.checkColour or _current_theme.colours.checkbox.icon
		})
		self.icon_checked.enabled = false
		
		if self.caption then
			self.text = gge_hud_text_add(self.font or _current_theme.fonts.checkbox)
			self.text.parent = self
			self.text.text = self.caption
			self.text.colour = self.textColour
		end
		
		if self.checked then
			self:check()
		end
		
		self:update()
	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)		
		self.inside = inside
		
	end;
	
    update = function (self)		
		self.size = vec(self.text.size.x+self.padding*4+self.icon.size.x, self.icon.size.y)
		self.icon.position = vec(-self.size.x/2+self.icon.size.x/2, self.icon.position.y)
		if self.caption then
			self.text.position = vec(-self.size.x/2+self.icon.size.x+self.padding+self.text.size.x/2, self.text.position.y)
		end
	end;	

    buttonCallback = function (self, ev)
		if ev == "+left" and self.inside then
			self.dragging = true
		elseif ev == "-left"  then
			if self.inside then
				if self.checked then
					self:uncheck()
					self:onUncheck()
				else
					self:check()
					self:onCheck()
				end
			end
			self.dragging = false
		end
    end;

	parentResizedCallback = function(self, psize)
		_gui.class.parentResizedCallback(self, psize)
	end;
	
	check = function(self)
		self.icon_checked.enabled = true
		self.checked = true
	end;

	onCheck = function(self)

	end;
	
	uncheck = function(self)
		self.icon_checked.enabled = false
		self.checked = false
	end;
	
	onUncheck = function(self)

	end;	
	
})

function gui.checkbox(tab)
	return hud_object `Checkbox` (tab)
end
