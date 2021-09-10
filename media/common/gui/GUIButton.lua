------------------------------------------------------------------------------
--  GUI button class
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
-- Based on: /common/hud/Button
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `GuiButton` (extends(_gui.class)
{
	padding = vec(8,6);

	alpha = _current_theme.colours.button.alpha;
	
	baseColour = _current_theme.colours.button.base;
	hoverColour = _current_theme.colours.button.hover;
	pressedColour = _current_theme.colours.button.pressed;
	colourGreyed = _current_theme.colours.button.greyed;
	
	captionBaseColour = _current_theme.colours.button.caption_base;
	captionHoverColour = _current_theme.colours.button.caption_hover;
	captionPressedColour = _current_theme.colours.button.caption_pressed;
	captionColourGreyed = _current_theme.colours.button.caption_greyed;
	
	font = _current_theme.fonts.button;
	caption = "Button";
	
	cornered = true;
	texture = _gui_textures.button;
	
	init = function (self)
		_gui.class.init(self)
		
		self.needsInputCallbacks = true

		self.text = hud_text_add(self.font)
		self.text.parent = self
		self.text.colour = self.captionBaseColour
		self:setCaption(self.caption)

		if not self.sizeSet then 
			self.size = self.text.size + self.padding * 2
		end

		self.dragging = false;
		self.inside = false
		if self.greyed == nil then self.greyed = false end

		self:refreshState();
	end;

	destroy = function (self)
		_gui.class.destroy(self)
	end;

	setCaption = function (self, v)
		self.caption = v
		self.text.text = self.caption
	end;

	setGreyed = function (self, v)
		self.greyed = v
		self:refreshState();
	end;

	refreshState = function (self)
		if self.greyed then
			self.text.colour = self.captionColourGreyed
			self.colour = self.colourGreyed
		else
			if self.dragging and self.inside then
				self.colour = self.pressedColour
				self.text.colour = self.captionPressedColour
			elseif self.inside then
				self.colour = self.hoverColour
				self.text.colour = self.captionHoverColour
			else
				self.colour = self.baseColour
				self.text.colour = self.captionBaseColour
			end
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
				if self.destroyed then return end
			end
			self.dragging = false
		end

		self:refreshState()
	end;

	parentResizedCallback = function(self, psize)
		_gui.class.parentResizedCallback(self, psize)
	end;
	
	pressedCallback = function (self)

	end;
})

function gui.button(options)
	return hud_object `GuiButton` (options)
end
