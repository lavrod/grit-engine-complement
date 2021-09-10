------------------------------------------------------------------------------
--  This is a list that can receive hud objects, with multiple sizes
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

_gui.list = table.extends(_gui.class,
{
	alpha = 1;
	size = vec(0, 0);
	padding = 4;
	cellSpacing = 2;
	orient = "vertical"; -- or horizontal
	
	init = function (self)
		_gui.class.init(self)
		
		self.items = {}
		self.itemsSpace = vec(0, 0)
	end;

	destroy = function (self)

	end;

	parentResizedCallback = function (self, psize)
		_gui.class.parentResizedCallback(self, psize)
	end;
	
	update = function(self, update_is)	
		local lastsize = vec(-self.cellSpacing*#self.items/2, -self.cellSpacing*#self.items/2)

		if update_is then
			self:updateItemsSpace()
			self:updateSize()
		end
		
		for i = 1, #self.items do
			self.items[i].position = vec2(
				self.orient == "horizontal" and (-self.itemsSpace.x/2 + (self.items[i].size.x+self.cellSpacing)/2 + lastsize.x) or 0,
				self.orient == "vertical" and (self.itemsSpace.y/2 - (self.items[i].size.y+self.cellSpacing)/2 - lastsize.y) or 0
			)
			
			lastsize = vec(lastsize.x + self.items[i].size.x + self.cellSpacing, lastsize.y + self.items[i].size.y + self.cellSpacing)
		end
	end;
	
    addItem = function (self, itm)
		self.items[#self.items+1] = itm
		itm.parent = self
		
		self.itemsSpace = vec(
			self.orient == "horizontal" and (self.itemsSpace.x + itm.size.x) or math.max(self.itemsSpace.x, itm.size.x),
			self.orient == "vertical" and (self.itemsSpace.y + itm.size.y) or math.max(self.itemsSpace.y, itm.size.y)
		)
		
		self:updateSize()
		self:update()
    end;

	updateSize = function(self)
		self.size = vec(
			self.itemsSpace.x + self.padding*2 + (self.orient == "horizontal" and ((#self.items-1)*self.cellSpacing) or 0),
			self.itemsSpace.y + self.padding*2 + (self.orient == "vertical" and ((#self.items-1)*self.cellSpacing) or 0)
		)
	end;	
	
	updateItemsSpace = function(self)
		self.itemsSpace = vec(0, 0)
		for i = 1, #self.items do
			if self.items[i] and not self.items[i].destroyed then
				self.itemsSpace = vec(
					self.orient == "horizontal" and (self.itemsSpace.x + self.items[i].size.x) or math.max(self.itemsSpace.x, self.items[i].size.x),
					self.orient == "vertical" and (self.itemsSpace.y +  self.items[i].size.y) or math.max(self.itemsSpace.y, self.items[i].size.y)
				)
			end
		end
	end;
})

hud_class `ObjectList` (_gui.list)

function gui.list(tab)
	return hud_object `ObjectList` (tab)
end
