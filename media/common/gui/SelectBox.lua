------------------------------------------------------------------------------
--  Selectbox Class
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `selectmenuitem` {
	alpha = 0;
	size = vec(150, 20);
	value = "";
	id = 0;
	colour = _current_theme.colours.selectbox.menu_base;
	baseColour = _current_theme.colours.selectbox.menu_base;
	baseAlpha = _current_theme.colours.selectbox.menu_alpha;
	hoverColour = _current_theme.colours.selectbox.menu_hover;
	hoverAlpha = _current_theme.colours.selectbox.menu_hover_alpha;
	textColour = _current_theme.colours.selectbox.menu_text;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.item = hud_object `/common/hud/Label` {
			parent = self;
			size = self.size;
			textColour = self.textColour;
			alignment = "LEFT";
			value = self.value;
			alpha = 0;
		}
		self.dragging = false;
		self.inside = false;
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		if inside then
			self.item.colour = self.hoverColour
			self.item.alpha = self.hoverAlpha
		else
			self.item.colour = self.baseColour
			self.item.alpha = self.baseAlpha
		end
    end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
            self.dragging = true
        elseif ev == "-left" then
            if self.dragging and self.inside and not self.greyed then
                self:pressedCallback()
				if self.destroyed then return end
				self:endPressedCallback()
            end
            self.dragging = false
        end
    end;

    pressedCallback = function (self)
		self:setSelection()
    end;
	
    setSelection = function (self)
        -- gge_print("Selected: "..self.value.." "..self.id)
		local itm = {}
		itm.name = self.value
		itm.id = self.id
		self.parent.parent:select(itm)
    end;	
	
	endPressedCallback = function (self)
		self.item.colour = self.baseColour
		self.item.alpha = self.baseAlpha
		self.parent.enabled = false
	end;
	
	parentResizedCallback = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
	end;
}

hud_class `selectmenu` {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 1;
	lastItem = 0;
	padding = 2;
	colour = _current_theme.colours.selectbox.menu_base;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.needsParentResizedCallbacks = true
		self.menuitems = {}
		
		self.position = vec2(0, -32)
		self:reorganize()
	end;
	
	reorganize = function(self)
		-- menu item size
		for i=1, #self.menuitems do
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.size = vec2(self.size.x -4, self.menuitems[i].item.size.y)
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			else
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			end
		end
		
		-- menu item and text position
		for i = 1, #self.menuitems do
			self.menuitems[i].position = vec2(0,  self.size.y/2 - ((i-1) * self.menuitems[i].size.y) -self.padding -self.menuitems[i].size.y/2)
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.text.position = vec2(-self.menuitems[i].item.size.x/2 + self.menuitems[i].item.text.size.x/2+5, self.menuitems[i].item.text.position.y)
			end
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
	end;

    buttonCallback = function (self, ev)

    end;

	update = function(self)
		self.size = vec2(self.parent.size.x, self.size.y)
		self.position=vec2(0, -self.size.y/2 - self.parent.size.y/2)
		self:reorganize()		
	end;
	
	parentResizedCallback = function(self, psize)
		self:update()
	end;
	
    addItem = function (self, itm)
		self.menuitems[#self.menuitems+1] = hud_object `selectmenuitem` { value = itm, parent=self, position=vec2(0, self.lastItem), size=vec2(150, 20), id=#self.menuitems }
		self.lastItem = self.lastItem - 20
		self.size = vec2(256, -self.lastItem +5)
		self.position=vec2(0, -self.size.y/2 - self.parent.size.y/2)
		self:reorganize()
    end;
}

hud_class `selectboxicon` {     
    size = vec(0, 0);    
    factor = vec(1, 1);
    offset = vec(0, 0);
    alpha = 0;
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;
    end;
	
    parentResizedCallback = function (self, psize)
        self.position = psize*self.factor + self.offset
    end;
}   

hud_class `Selectbox` (extends(_gui.class)
{
	alpha = 1;
	size = vec(256, 40);
	colour = _current_theme.colours.selectbox.base;
	zOrder = 3;
	
	alpha = _current_theme.colours.selectbox.alpha;
	
	baseColour = _current_theme.colours.selectbox.base;
	hoverColour = _current_theme.colours.selectbox.hover;
	pressedColour = _current_theme.colours.selectbox.pressed;
	colourGreyed = _current_theme.colours.selectbox.greyed;
	
	captionBaseColour = _current_theme.colours.selectbox.caption_base;
	captionHoverColour = _current_theme.colours.selectbox.caption_hover;
	captionPressedColour = _current_theme.colours.selectbox.caption_pressed;
	captionColourGreyed = _current_theme.colours.selectbox.caption_greyed;	
	
	iconColour = _current_theme.colours.selectbox.icon;
	iconAlpha = _current_theme.colours.selectbox.icon_alpha;
	iconHoverColour = _current_theme.colours.selectbox.icon_hover;
	iconPressedColour = _current_theme.colours.selectbox.icon_pressed;
	
	defaultText = "";
	selected = {};
	choices = {};
	cornered = true;
	texture = _gui_textures.grad_button;
	
	init = function (self)
		_gui.class.init(self)
		self.needsParentResizedCallbacks = true;
		self.needsInputCallbacks = true;
		
		self.icon = hud_object `selectboxicon` {
			texture = _gui_textures.triangle.up,
			size = vec2(15, 15),
			offset = vec2(-10, 0),
			factor = vec2(0.5, 0),
			parent = self,
			alpha = self.iconAlpha,			
			colour = self.iconColour
		}
		self.icon.pressedCallback = function(self, ev) self.parent:showMenu() end;
		
		self.caption_pos = hud_object `/common/hud/Positioner` {
			parent = self;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		}
		self.caption = gge_hud_text_add(_current_theme.fonts.default)
		self.caption.parent = self.caption_pos
		self.caption.colour = self.captionBaseColour
		
		self:setTitle(self.defaultText)
		
		self.menu = hud_object `selectmenu` { parent = self }
		
		for i = 1, #self.choices do
			self.menu:addItem(self.choices[i])
		end
		
		if self.selection ~= nil then
			self.menu.menuitems[self.selection+1]:setSelection()
		end
		self.menu:update()
		self.menu.enabled = false
	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
		self.needsParentResizedCallbacks = false
	end;
	
	setTitle = function(self, name)
		self.caption.text  = name
		self.caption.position = vec2(self.caption.size.x / 2, self.caption.position.y)
	end;

	showMenu = function(self)
		self.menu.enabled = not self.menu.enabled
	end;

	onSelect = function(self)
		
	end;
	
	select = function(self, itm)
		if type(itm) == "table" then
			self.selected = itm
			self:setTitle(self.selected.name)
			self:onSelect()
		elseif type(itm) == "string" then
			for i = 1, #self.menu.menuitems do
				if itm == self.menu.menuitems[i].value then
					local nitm = {}
					nitm.name = self.menu.menuitems[i].value
					nitm.id = self.menu.menuitems[i].id
					self:select(nitm)
				end
			end
		elseif type(itm) == "number" then
			for i = 1, #self.menu.menuitems do
				if itm == self.menu.menuitems[i].id then
					local nitm = {}
					nitm.name = elf.menu.menuitems[i].value
					nitm.id = elf.menu.menuitems[i].id
					self:select(nitm)
				end
			end
		end
	end;	
	
	parentResizedCallback = function (self, psize)
		_gui.class.parentResizedCallback(self, psize)
		-- self:parentresizecb(psize)
	end;
	
	parentresizecb = function(self, psize)
		self.size = vec2(psize.x, self.size.y)
	end;

	pressedCallback = function(self, ev)
		self:showMenu()
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
            end
            self.dragging = false
        end
		self:refreshState()
    end;
	
    refreshState = function (self)
		if self.dragging and self.inside then
			self.icon.colour = self.iconPressedColour
			self.colour = self.pressedColour
			self.caption.colour = self.captionPressedColour
		elseif self.inside then
			self.icon.colour = self.iconHoverColour
			self.colour = self.hoverColour
			self.caption.colour = self.captionHoverColour
		elseif not self.menu.enabled then
			self.icon.colour = self.iconColour
			self.colour = self.baseColour
			self.caption.colour = self.captionBaseColour
		end
    end;
})

function gui.selectbox(tab)
	return hud_object `Selectbox` (tab)
end
