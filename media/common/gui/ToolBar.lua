------------------------------------------------------------------------------
--  Toolbar
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `ToolBar` (extends(_gui.class)
{
    colour = _current_theme.colours.tool_bar.background;
	alpha = _current_theme.colours.tool_bar.alpha;
    toolPadding = vec(16, 4);
	lastTool = 0;
	orient = "horizontal";
	
    init = function (self)
		_gui.class.init(self)
		
        self.needsParentResizedCallbacks = true
        self.tools = {}
		self.separators = {}

		self.positioner = gui.object({
			parent = self,
			align = vec(self.orient == "horizontal" and -1 or 0, self.orient == "vertical" and 1 or 0),
			alpha = 0,
			--offset = vec(self.orient == "horizontal" and 16 or 0, self.orient == "vertical" and -16 or 0)
		})
    end;

	addTool = function(self, name, icon, cb, ttip)
		local pos = vec(0, 0)
		
		if self.orient == "horizontal" then
			pos = vec2(self.lastTool, 0)
		else
			pos = vec2(0, self.lastTool)
		end
		
		self.tools[#self.tools + 1] = gui.imagebutton({
			pressedCallback = cb;
			texture = icon;
			tip = ttip;
			position = pos;
			parent = self.positioner;
		})
		if self.orient == "horizontal" then
			self.lastTool = self.lastTool + self.tools[#self.tools].size.x + 4
			self.size = vec(math.abs(self.lastTool), self.size.y)
		else
			self.lastTool = self.lastTool - self.tools[#self.tools].size.y - 4
			self.size = vec(self.size.x, math.abs(self.lastTool))
		end		
		
		self:pr_update(self.parent.size)
		
		return self.tools[#self.tools]
	end;

	addSeparator = function(self)
		local pos = vec(0, 0)
		local sz = vec(0, 0)
		
		if self.orient == "horizontal" then
			pos = vec2(self.lastTool - (self.tools[#self.tools].size.x/2), 0)
			sz = vec2(2, self.size.y -14)
		else
			pos = vec2(0, self.lastTool + (self.tools[#self.tools].size.y/2))
			sz = vec2(self.size.x -14, 2)
		end
		
		self.separators[#self.separators + 1] = create_rect({
			parent = self.positioner,
			position = pos,
			colour = _current_theme.colours.tool_bar.separator,
			alpha = _current_theme.colours.tool_bar.separator_alpha,
			size = sz
		})
		if self.orient == "horizontal" then
			self.lastTool = self.lastTool + self.separators[#self.separators].size.x + 4
			self.size = vec(math.abs(self.lastTool), self.size.y)
		else
			self.lastTool = self.lastTool - self.separators[#self.separators].size.y - 4
			self.size = vec(self.size.x, math.abs(self.lastTool))
		end	
		self:pr_update(self.parent.size)
	end;
	
    destroy = function (self)
		_gui.class.destroy(self)
		self.needsParentResizedCallbacks = false
    end;

    parentResizedCallback = function (self, psize)
		_gui.class.parentResizedCallback(self, psize)
    end;
})

function gui.toolbar(tab)
	return hud_object `ToolBar` (tab)
end
