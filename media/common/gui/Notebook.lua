------------------------------------------------------------------------------
--  Notebook
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `page_button` {
    padding = vec(10,6);

    baseColour = _current_theme.colours.notebook.btn_base;
    hoverColour = _current_theme.colours.notebook.btn_hover;
    clickColour = _current_theme.colours.notebook.btn_pressed;
	selectedColour = _current_theme.colours.notebook.btn_selected;
	
    font = `/common/fonts/Verdana12`;
    caption = "Page";
    captionColour = _current_theme.colours.notebook.btn_caption;

	captionHoverColour = _current_theme.colours.notebook.btn_caption_hover;
	captionClickColour = _current_theme.colours.notebook.btn_caption_pressed;
	captionSelectedColour = _current_theme.colours.notebook.btn_caption_selected;
	alpha = _current_theme.colours.notebook.btn_alpha;
	selected = false;
	
	texture = _gui_textures.notebook_button;
	cornered = true;
	
    init = function (self)
        self.needsInputCallbacks = true

        self.text = hud_text_add(self.font)
        self.text.parent = self
        self:setCaption(self.caption)

        if not self.sizeSet then 
            self.size = vec(self.text.size.x + self.padding.x * 2, 20) 
        end

        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        self:refreshState();
    end;

    destroy = function (self)
    end;
    
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
    end;

    refreshState = function (self)
		if self.selected then
			self.colour = self.selectedColour
			self.text.colour = self.captionSelectedColour			
		else
			self.text.colour = self.captionColour
			if self.dragging and self.inside then
				self.colour = self.clickColour
				self.text.colour = self.captionClickColour
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
		self:refreshState()
	end;

	buttonCallback = function (self, ev)
		if ev == "+left" and self.inside then
			self.dragging = true
		elseif ev == "-left" then
			if self.dragging and self.inside and not self.selected then
				self:pressedCallback()
			end
			self.dragging = false
		end

		self:refreshState()
	end;

    pressedCallback = function (self)
		self.parent.parent.parent.page_buttons[self.parent.parent.parent.selected].selected = false
		self.parent.parent.parent.page_buttons[self.parent.parent.parent.selected]:refreshState()
		self.parent.parent.parent:select(self.id)
		self.selected = true
		self:refreshState()
		self:onOpen()
    end;
	
    onOpen = function (self)
		
    end;
}

hud_class `Notebook` {
	alpha = _current_theme.colours.notebook.alpha;
	size = vec(256, 256);
	zOrder = 0;
	pageButtonSize = vec(40, 20);
	pageButtonColour = _current_theme.colours.notebook.btn_base;
	pageSelectedButtonColour = _current_theme.colours.notebook.btn_selected;
	contentAreaColour = _current_theme.colours.notebook.background;
	menuBackgroundColour = _current_theme.colours.notebook.menu_background;
	selected = 1;
	
	init = function (self)
		self.needsParentResizedCallbacks = true
		self.page_buttons = {}
		
		self.pages = {}
		self.page_menu = create_rect({
			parent = self,
			position = vec2(0, -self.size.y+self.pageButtonSize.y),
			size = vec(self.size.x, self.pageButtonSize.y),
			colour = self.menuBackgroundColour,
			texture = _gui_textures.invgrad
		})
		self.content_area = create_rect({
			parent = self,
			position = vec2(0, -self.pageButtonSize.y/2),
			colour = self.contentAreaColour
		})
		self.current_page_content = {}
		self.page_menu_list = gui.list({ parent = self.page_menu, alpha = 0, orient = "horizontal", border = 0, cellSpacing = 0.5 })
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
			
		self:destroy()
	end;
	
	parentResizedCallback = function (self, psize)
		self.size = psize
		
		self:update()
		self:updateTabs()
	end;
	
	addPage = function (self, page, name, p_onOpen)
		self.page_buttons[#self.page_buttons+1] = hud_object `page_button` {
			parent = self.page_menu,
			position = vec2(0, 0),
			colour = self.pageButtonColour,
			caption = name,
			id = #self.page_buttons+1,
			onOpen = p_onOpen or function(self)end
		}
		self.page_menu_list:addItem(self.page_buttons[#self.page_buttons])
		self:updateTabs()
		
		if page == nil then
			self.pages[#self.page_buttons] = create_rect({ parent = self.content_area, position = vec2(0, 0), colour = _current_theme.colours.notebook.btn_pressed, enabled = false })
		else
			self.pages[#self.page_buttons] = page
			self.pages[#self.page_buttons].parent = self.content_area
			self.pages[#self.page_buttons].position = vec2(0, 0)
			self.pages[#self.page_buttons].colour = _current_theme.colours.notebook.btn_pressed
		end
		
		if #self.page_buttons == 1 then
			self:select(1)
			self.page_buttons[#self.page_buttons].selected = true
			self.page_buttons[#self.page_buttons]:refreshState()
		else
			page.enabled = false
		end
		
		self:update()
		self:updateTabs()
	end;
	
	updateTabs = function (self)
		self.page_menu_list.position = vec(-self.page_menu.size.x/2+self.page_menu_list.size.x/2 + 2, 0)
	end;
	
	update = function (self)
		self.page_menu.size = vec(self.size.x, self.page_menu.size.y)
		if self.content_area.size ~= nil then
			self.content_area.size = vec(self.size.x, self.size.y - self.pageButtonSize.y-2)
			self.page_menu.position = vec(0, self.content_area.size.y/2)
		else
			self.page_menu.position = vec(0, (self.size.y - self.pageButtonSize.y-2)/2)
		end
	end;
	
	select = function (self, id)
		self.current_page_content.enabled = false
		self.current_page_content = self.pages[id]
		self.current_page_content.enabled = true
		self.selected = id
		self:update()
	end;	
}

function gui.notebook(t_parent)
	return hud_object `Notebook` { parent = t_parent }
end

function gui.notebookpanel()
	return gui.boxsizer({ parent = hud_centre, position = vec2(0, 0), size = vec(0, 0), colour = random_colour(), enabled = false })
end
