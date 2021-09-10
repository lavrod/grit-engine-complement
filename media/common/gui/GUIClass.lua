------------------------------------------------------------------------------
--  GUI class, an example to be followed by all other GUI classes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------
guialign = {
	centre = vec(0, 0);
	left = vec(-1, 0);
	right = vec(1, 0);
	top = vec(0, 1);
	topleft = vec(-1, 1);
	topright = vec(1, 1);
	bottom = vec(0, -1);
	bottomleft = vec(-1, -1);
	bottomright = vec(1, -1);
}

_gui.class = {
	alpha = 1;
	colour = vec(1, 1, 1);

	align = vec(0, 0);
	
	expand = false;
	expand_x = false;
	expand_y = false;
	
	offset = vec(0, 0);
	expand_offset = vec(0, 0);
	
	init = function (self)
		self.needsParentResizedCallbacks = self.expand or
		self.expand_x or
		self.expand_y or self.align.x ~= 0 or self.align.y ~= 0
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	alignUpdate = function(self, psize)
		self.position = (psize/2 - self.size/2) * self.align + self.offset
	end;
	
	updateExpand = function(self, psize)
		if self.expand then
			self.size = psize + self.expand_offset
		else
			if self.expand_x then
				self.size = vec(psize.x + self.expand_offset.x, self.size.y + self.expand_offset.y)
			end
			
			if self.expand_y then
				self.size = vec(self.size.x + self.expand_offset.x, psize.y + self.expand_offset.y)
			end
		end
	end;

	pr_update = function(self, psize)
		self:updateExpand(psize)
		self:alignUpdate(psize)
	end;	
	
	parentResizedCallback = function(self, psize)
		self:pr_update(psize)
	end;
}

hud_class `GuiClass` (_gui.class)

function gui.object(tab)
	return hud_object `GuiClass` (tab)
end

function create_rect(tab)
	return hud_object `/common/hud/Rect` (tab)
end
