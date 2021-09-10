------------------------------------------------------------------------------
--  Menu bar
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `MenuItem` {
	alpha = _current_theme.colours.menu.item_alpha;
	size = vec(150, 20);
	
	colour = _current_theme.colours.menu.item_background;
	baseColour = _current_theme.colours.menu.item_background;
	hoverColour = _current_theme.colours.menu.item_hover;
	
	value = "No text";
	textColour = _current_theme.colours.menu.item_text;
	hoverTextColour = _current_theme.colours.menu.item_text_hover;
	
	init = function (self)
		self.needsInputCallbacks = true;
		self.item = hud_object `/common/hud/Label` {
			parent = self;
			size = self.size;
			textColour = self.textColour;
			alignment = "LEFT";
			value = self.value;
			alpha = 0;
			colour = self.colour;
			font = _current_theme.fonts.menu_bar.menu;
		}
		self.icon = create_rect({
			parent = self.item,
			size = vec2(15, 15),
			colour = _current_theme.colours.menu.icon,
			position = vec2(-self.item.size.x/2-20, 0),
			alpha = _current_theme.colours.menu.icon_alpha
		})
		self.dragging = false;
		self.inside = false;
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;

    setGreyed = function (self, v)
        self.greyed = v
		self.item:setGreyed(v)
    end;
	
    setIcon = function (self, ic)
		self.icon.alpha = 1
		self.icon.texture = ic
    end;	
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		if inside then
			self.item.colour = self.hoverColour
			self.item.alpha = 1
			self.item.text.colour = self.hoverTextColour
		else
			self.item.colour = self.baseColour
			self.item.alpha = 0
			self.item.text.colour = self.textColour
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
			if not self.destroyed then
				self.dragging = false
			end
        end
    end;

    pressedCallback = function (self)
        print (RED.."Menu item has no associated action.")
    end;	
	
	endPressedCallback = function (self)
		
	end;
}

hud_class `Menu` {
	alpha = _current_theme.colours.menu.background_alpha;
	size = vec(256, 256);
	zOrder = 0;
	lastItem = 0;
	iconspacing = 20;
	texture = _gui_textures.menu;
	cornered = true;
	colour = _current_theme.colours.menu.background;
	
	menu_item_colour = _current_theme.colours.menu.item_background;
	menu_hoverColour = _current_theme.colours.menu.item_hover;
	
	textColour = _current_theme.colours.menu.item_text;	
	menu_hoverTextColour = _current_theme.colours.menu.text_hover;
	
	init = function (self)
		self.needsInputCallbacks = true
		self.menuitems = {}
		
		if self.items ~= nil then
			for i = 1, #self.items do
				if next(self.items[i]) == nil then
					self.menuitems[i] = hud_object `/common/hud/HorizontalLine` {
						parent = self,
						position = vec2(0, self.lastItem + 7.5),
						colour = _current_theme.colours.menu.line
					}
					self.menuitems[i]:setThickness(1);
					self.lastItem = self.lastItem - 5
				else
					self.menuitems[i] = hud_object `MenuItem` {
						value = self.items[i].name;
						pressedCallback = self.items[i].callback;
						endPressedCallback = self.items[i].endPressedCallback or function(self)end;
						parent = self;
						position = vec2(0, self.lastItem);
						size = vec2(150, 20);
						textColour = self.textColour;
						colour = self.menu_item_colour;
						hoverColour = self.menu_hoverColour;
						hoverTextColour = self.menu_hoverTextColour;
					}
					
					if(self.items[i].icon ~= nil) then
						self.menuitems[i]:setIcon(self.items[i].icon)
						if self.items[i].icon_enabled == false then
							self.menuitems[i].icon.enabled = false
						end
					end
					self.lastItem = self.lastItem - 20
				end
			end
		end
		self.size = vec2(152, (self.lastItem* -1) +5)
		self:reorganize()
	end;
	
	reorganize = function(self)
		local minsize = 0
		-- Menu background size, set with the major item size
		for i=1, #self.menuitems do
			if(self.menuitems[i].item ~= nil) then
				if (self.menuitems[i].item.text.size.x > minsize) then
					minsize = self.menuitems[i].item.text.size.x
				end
			end
		end
			
		minsize = minsize+self.iconspacing
		self.size = vec2((minsize + self.iconspacing) or self.size.x, self.size.y)
		
		-- menu item size
		for i=1, #self.menuitems do
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.size = vec2(self.size.x -4, self.menuitems[i].item.size.y)
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			else
				self.menuitems[i].size = vec2(self.size.x -4, self.menuitems[i].size.y)
			end
		end
		
		-- menu item icons
		for i=1, #self.menuitems do
			if(self.menuitems[i].icon ~= nil) then
				self.menuitems[i].icon.position = vec2(-self.menuitems[i].item.size.x/2 + self.menuitems[i].icon.size.x/2 +2, self.menuitems[i].icon.position.y)
			end
		end
		-- menu item position
		for i = 1, #self.menuitems do
			self.menuitems[i].position = vec2(0, self.menuitems[i].position.y + self.size.y/2 -10 - 2.5)
			if(self.menuitems[i].item ~= nil) then
				self.menuitems[i].item.text.position = vec2(-self.menuitems[i].item.size.x/2 + self.menuitems[i].item.text.size.x/2+ self.iconspacing, self.menuitems[i].item.text.position.y)
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
}

hud_class `MenuBarButton` {
    padding = vec(8,6);

    baseColour = _current_theme.colours.menu_bar.button;
    hoverColour = _current_theme.colours.menu_bar.button_hover;
    pressedColour = _current_theme.colours.menu_bar.button_pressed;

	borderTexture = _gui_textures.menu_bar.button_border;
    borderColour = _current_theme.colours.menu_bar.button_border;

    font = _current_theme.fonts.menu_bar.button;
    caption = "Button";
    captionColour = _current_theme.colours.menu_bar.button_caption;
    captionColourGreyed = _current_theme.colours.menu_bar.button_caption_greyed;
	captionHoverColour = _current_theme.colours.menu_bar.button_caption_hover;
	captionPressedColour = _current_theme.colours.menu_bar.button_caption_pressed;
	
	alpha = _current_theme.colours.menu_bar.button_alpha;
	
    init = function (self)
        self.needsInputCallbacks = true

        self.text = hud_text_add(self.font)
        self.text.parent = self
        self:setCaption(self.caption)

        if not self.sizeSet then 
            self.size = self.text.size + self.padding * 2
        end

        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        self.border = create_rect({
            texture = self.borderTexture,
            colour = self.borderColour,
            parent = self,
            cornered = true,
            size = self.size,
        })
        
        self:refreshState();
        self.needsResizedCallbacks = true
    end;

    resizedCallback = function (self)
        self.border.size = self.size
    end;
   
    destroy = function (self)
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
            self.colour = self.baseColour
        else
            self.text.colour = self.captionColour
            if self.dragging and self.inside then
                self.colour = self.pressedColour
				self.text.colour = self.captionPressedColour
            elseif self.inside then
                self.colour = self.hoverColour
				self.text.colour = self.captionHoverColour
            else
                self.colour = self.baseColour
            end
        end
    end;

	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if inside then
			--self:showTip()
			if self.parent.parent.selecting == true then
				self.parent.parent.selected.menu.enabled = false
				self.parent.parent.selected = self
				self.parent.parent.selected.menu.enabled = true
			end
		end
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

    pressedCallback = function (self)
        error "Button has no associated action."
    end;
}

hud_class `MenuBar` (extends(_gui.class)
{
    colour = _current_theme.colours.menu_bar.background;
	alpha = _current_theme.colours.menu_bar.background_alpha;
	buttonPadding = vec(8, 4);
	lastButton = -35;
	selected = nil;
	selecting = false;
	spacing = 1;
	size = vec(2, 26);
	-- texture = `../icons/menubar.png`;
	distanceToUnselect = 200;
	zOrder = 6;
	
    init = function (self)
		_gui.class.init(self)
		
        self.needsParentResizedCallbacks = true
		self.needsInputCallbacks = true
        self.buttons = {}

		self.leftPositioner = hud_object `/common/hud/Positioner` {
			parent = self;
			offset = vec2(40, 0);
			factor = vec2(-0.5, 0);
		}
    end;

	append = function(self, obj, name)
		self.buttons[#self.buttons + 1] = hud_object `MenuBarButton` {
			menu = obj;
			pressedCallback = function (self)
				if self.menu.enabled ~= true then
					self.menu.enabled = true
					self.menu.position = vec2(self.menu.size.x/2 - self.size.x/2, -self.size.y/2 - self.menu.size.y/2-2)
				else
					self.menu.enabled = false
				end
				self.parent.parent.selected = self
				
				if self.parent.parent.selecting ~= true then
				self.parent.parent.selecting = true
				else
					self.parent.parent.selecting = false
				end
			end;
			caption = name;
			padding = self.buttonPadding;
			parent = self.leftPositioner;
		}
		
		for i = 1, #obj.menuitems do
			obj.menuitems[i].endPressedCallback = function (self)
				self.parent.parent.parent.parent.selecting = false
				self.parent.enabled=false
				self.item.colour = vec(1, 1, 1)
				self.item.alpha = 0
			end;
		end
		
		--self.buttons[#self.buttons].border.enabled = false
		self.buttons[#self.buttons].position = vec2(self.lastButton + (self.buttons[#self.buttons].size.x/2), 0)
		self.lastButton = self.lastButton + self.buttons[#self.buttons].size.x + self.spacing
		obj.parent = self.buttons[#self.buttons]
		obj.position = vec2(obj.size.x/2 - self.buttons[#self.buttons].size.x/2, - self.buttons[#self.buttons].size.y/2 - obj.size.y/2-2)
		obj.enabled = false
	end;

    destroy = function (self)
		self.needsParentResizedCallbacks = false
		self:destroy()
    end;
	
    parentResizedCallback = function (self, psize)
		_gui.class.parentResizedCallback(self, psize)
    end;

	unselect = function (self)
		self.selecting = false
		self.selected.menu.enabled = false		
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = inside
		if self.selecting and --#(mouse_pos_abs-self.selected.menu.derivedPosition) > 200
		(
			mouse_pos_abs.x < self.selected.menu.derivedPosition.x-self.selected.menu.size.x/2-self.distanceToUnselect or
			mouse_pos_abs.x > self.selected.menu.derivedPosition.x+self.selected.menu.size.x/2+self.distanceToUnselect or
			mouse_pos_abs.y < self.selected.menu.derivedPosition.y-self.selected.menu.size.y/2-self.distanceToUnselect or
			mouse_pos_abs.y > self.selected.menu.derivedPosition.y+self.selected.menu.size.y/2+self.distanceToUnselect
		)
		then
			self:unselect()
		end
	end;

    buttonCallback = function (self, ev)
		if self.selected == nil then return end
        -- mouse_inside_any_menu got removed.  Not sure how best to implement this now.
		-- if ev == "+left" and not mouse_inside_any_menu() then
		if ev == "+left" and self.inside then
			self:unselect()
        end
    end;
})

_menus = {}

function gui.menubar_menu(tab)
	local mn = hud_object `Menu` (tab)
	_menus[#_menus+1] = mn
	return mn
end

function gui.menubar(tab)
	return hud_object `MenuBar` (tab)
end
