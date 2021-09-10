------------------------------------------------------------------------------
--  Window Notebook (tabs that cover the entire window)
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `roundbutton` (extends(_gui.class)
{
	alpha = _current_theme.colours.window_notebook.close_btn_alpha;
	
	baseColour = _current_theme.colours.window_notebook.close_btn_base;
	hoverColour = _current_theme.colours.window_notebook.close_btn_hover;
	pressedColour = _current_theme.colours.window_notebook.close_btn_pressed;
	colourGreyed = _current_theme.colours.window_notebook.close_btn_greyed;
	
	captionBaseColour = _current_theme.colours.window_notebook.close_btn_caption_base;
	captionHoverColour = _current_theme.colours.window_notebook.close_btn_caption_hover;
	captionPressedColour = _current_theme.colours.window_notebook.close_btn_caption_pressed;
	captionColourGreyed = _current_theme.colours.window_notebook.close_btn_caption_greyed;
	
	padding = vec(8,6);
	
	font = _current_theme.fonts.window_notebook.closebtn;
	caption = "x";

	texture = _gui_textures.window_notebook.closebtn;
	
	init = function (self)
		_gui.class.init(self)
		
		self.needsInputCallbacks = true

		self.text = hud_text_add(self.font)
		self.text.parent = self
		self.text.colour = self.captionBaseColour
		self.text.position = vec(0, 1)
		self:setCaption(self.caption)

		-- if not self.sizeSet then 
			-- self.size = self.text.size + self.padding * 2
		-- end

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
			end
			if not self.destroyed then
				self.dragging = false
			else
				return
			end
		end

		self:refreshState()
	end;

	parentResizedCallback = function(self, psize)
		_gui.class.parentResizedCallback(self, psize)
	end;	
	
	reloadTheme = function(self)
		local class = hud_class_get(self.className)
		self.alpha = class.alpha
		self.colour = class.colour
		self.texture = class.texture
		
		self.baseColour = class.baseColour
		self.hoverColour = class.hoverColour
		self.pressedColour = class.pressedColour
		self.selectedColour = class.selectedColour
		
		self.text.font = class.font
		self.captionColour = class.captionColour
		self.captionHoverColour = class.captionHoverColour
		self.captionPressedColour = class.captionPressedColour
		self.captionSelectedColour = class.captionSelectedColour
	end;
	
    pressedCallback = function (self)
		
    end;
})

hud_class `window_page_button` {
    baseColour = _current_theme.colours.window_notebook.btn_base;
    hoverColour = _current_theme.colours.window_notebook.btn_hover;
    pressedColour = _current_theme.colours.window_notebook.btn_pressed;
	selectedColour = _current_theme.colours.window_notebook.btn_selected;
    
	font = _current_theme.fonts.window_notebook.button;	
    caption = "Text";
    captionColour = _current_theme.colours.window_notebook.btn_caption;
	captionHoverColour = _current_theme.colours.window_notebook.btn_caption_hover;
	captionPressedColour = _current_theme.colours.window_notebook.btn_caption_pressed;
	captionSelectedColour = _current_theme.colours.window_notebook.btn_caption_selected;
	
	alpha = _current_theme.colours.window_notebook.btn_alpha;
	
	texture = _current_theme.colours.window_notebook.texture;

	padding = vec(10,6);
	selected = false;
	draggingPos = vec2(0, 0);
	ID = 0;
	cornered = true;
	zOrder = 1;
	
	closebtn = true;
	
    init = function (self)
        self.needsInputCallbacks = true
		self.needsFrameCallbacks = false
		
        self.text = hud_text_add(self.font)
        self.text.parent = self
		self.text.position = vec(0, 0)
        self:setCaption(self.caption)
		
		if self.closebtn then
			self.close_btn = hud_object `roundbutton` {
				parent = self,
				align = vec(1, 0),
				position=vec(0, -1),
				offset = vec(-10, -2),
				pressedCallback = function(self) self.parent.parent:destroyTab(self.parent.ID) end
			}
		end
		
        if not self.sizeSet then 
			self.size = vec(175, 25)
        end

		self.ornament = create_rect({
			parent = self,
			size = vec(self.size.x, 2),
			position = vec(0, self.size.y/2-1),
			colour = self.edge_colour
		})
		
        self.dragging = false;
        self.inside = false
        if self.greyed == nil then self.greyed = false end

        self:refreshState();
		
		self.destPos = self.position
		
		self:onInit()
		
    end;

    destroy = function (self)
		self:onDestroy()
    end;
    
    setCaption = function (self, v)
        self.caption = v
        self.text.text = self.caption
    end;

    refreshState = function (self)
		if self.selected then
			self.colour = self.selectedColour
			self.text.colour = self.captionSelectedColour
			self.text.font = _current_theme.fonts.window_notebook.button_selected
		else
			self.text.colour = self.captionColour
			self.text.font = _current_theme.fonts.window_notebook.button
			
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
		self.localPos = local_pos
		self:refreshState()
		
		if self.moving then
			-- swap if close enought, or has exceeded the position (when moving fast)
			if self.parent.buttons[self.ID-1] ~= nil and (#(self.position - self.parent.buttons[self.ID-1].position) < 15 or self.position.x < self.parent.buttons[self.ID-1].position.x) then
				self.parent:swap(self.ID, self.ID-1)
			elseif self.parent.buttons[self.ID+1] ~= nil and (#(self.position - self.parent.buttons[self.ID+1].position) < 15 or self.position.x > self.parent.buttons[self.ID+1].position.x) then
				self.parent:swap(self.ID, self.ID+1)
			end
			self.position = vec(mouse_pos_abs.x-self.parent.position.x-self.draggingPos.x, self.position.y)
			if not self.dragging then self.moving = false end
		else
			if self.dragging and #(local_pos - self.draggingPos) > 15 then
				self.zOrder = 2
				self.moving = true
			end
		end
	end;

	buttonCallback = function (self, ev)
		if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = self.localPos
		elseif ev == "-left" then
			if self.dragging then
				if self.inside and not self.selected and not self.moving then
					self:pressedCallback()
				end
				
				if self.moving then
					self.moving = false
					if self.position ~= self.destPos then
						self.needsFrameCallbacks = true
					end
				end
				
			end
			self.dragging = false
		end

		self:refreshState()
	end;

	frameCallback = function(self, elapsed)
		if self.destPos ~= nil then
			if #(self.position - self.destPos) > 0.99 then
				self.position = lerp(self.position, self.destPos, elapsed*5)
			else
				self.position = self.destPos
				self.needsFrameCallbacks = false
				self.zOrder = 1
			end
		end
	end;
	
    pressedCallback = function (self)
		self:select()
    end;
	
	select = function (self)
		if self.parent.selected ~= nil and not self.parent.selected.destroyed then
			self.parent.selected:onUnselect()
			self.parent.selected.selected = false
			self.parent.selected:refreshState()
		end
		self.parent:select(self)
		self.selected = true
		self:refreshState()
		self:onSelect()		
	end;	

	reloadTheme = function(self)
		local class = hud_class_get(self.className)
		self.alpha = class.alpha
		self.colour = class.colour or V_ID
		self.texture = class.texture
		
		self.baseColour = class.baseColour
		self.hoverColour = class.hoverColour
		self.pressedColour = class.pressedColour
		self.selectedColour = class.selectedColour
		
		self.text.font = class.font
		self.captionColour = class.captionColour
		self.captionHoverColour = class.captionHoverColour
		self.captionPressedColour = class.captionPressedColour
		self.captionSelectedColour = class.captionSelectedColour
		
		if self.close_btn then
			self.close_btn:reloadTheme()
		end
	end;

	onSelect = function (self)
		
	end;
	
	onUnselect = function (self)
		
	end;

	onInit = function (self)
		
	end;	
	
	onDestroy = function (self)
		
	end;
}

hud_class `windownotebook` (extends(_gui.class)
{
	alpha = _current_theme.colours.window_notebook.alpha;
	colour = _current_theme.colours.window_notebook.background;
	-- pageButtonSize = vec(40, 20);
	
	size = vec(1, 29);
	zOrder = 0;
	expand_x = true;
	padding = 2;
	zOrder = 5;
	
	init = function (self)
		_gui.class.init(self)
		self.buttons = {}

	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
		self.needsParentResizedCallbacks = false
	end;
	
	parentResizedCallback = function (self, psize)
		_gui.class.parentResizedCallback(self, psize)
		self.position = vec(gfx_window_size().x/2, gfx_window_size().y-self.size.y/2)
		self:updateTabs()
	end;
	
	addPage = function (self, tab)
		local top_pos = 0
		if self.buttons[#self.buttons] ~= nil then
			top_pos = self.buttons[#self.buttons].position.x+self.buttons[#self.buttons].size.x/2
		else
			top_pos = -self.size.x/2
		end
		
		self.buttons[#self.buttons+1] = hud_object `window_page_button` (tab)
		self.buttons[#self.buttons].parent = self
		self.buttons[#self.buttons].ID = #self.buttons
		
		self.buttons[#self.buttons].position = vec(top_pos+self.buttons[#self.buttons].size.x/2+self.padding*2, -2)
		self.buttons[#self.buttons].destPos = self.buttons[#self.buttons].position
		return self.buttons[#self.buttons]
	end;
	
	updateTabs = function (self)
		local top_pos = -self.size.x/2

		for i = 1, #self.buttons do
			if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
				self.buttons[i].position = vec(top_pos+self.buttons[i].size.x/2+self.padding*2, -2)
				self.buttons[i].destPos = self.buttons[i].position
				self.buttons[i].needsFrameCallbacks = false
				top_pos = self.buttons[i].position.x + self.buttons[i].size.x/2
			end
		end
	end;
	
	select = function (self, obj)
		self.prevSelected = self.selected
		self.selected = obj
	end;
	
	swap = function (self, id1, id2)
		local btn1dp = self.buttons[id1].destPos
		
		self.buttons[id1].destPos = self.buttons[id2].destPos
		
		self.buttons[id2].destPos = btn1dp
		self.buttons[id2].needsFrameCallbacks = true
		
		local btn1 = self.buttons[id1]

		self.buttons[id1] = self.buttons[id2]
		self.buttons[id2] = btn1
		
		self.buttons[id1].ID = id1
		self.buttons[id2].ID = id2
	end;
	
	destroyTab = function (self, id)
		if self.selected == self.buttons[id] then
			self.buttons[id]:onUnselect()
			
			if self.prevSelected ~= nil and not self.prevSelected .destroyed then
				self.prevSelected:select()
			elseif self.buttons[id-1] ~= nil and not self.buttons[id-1].destroyed then
				self.buttons[id-1]:select()
			elseif self.buttons[id+1] ~= nil and not self.buttons[id+1].destroyed then
				self.buttons[id+1]:select()
			end
		end
		
		local dest_positions = {}
		
		if id ~= #self.buttons then
			for i = id, #self.buttons do
				if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
					dest_positions[i] = self.buttons[i].destPos
				end
			end

			safe_destroy(self.buttons[id])
			for i = id+1, #self.buttons do
				if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
					self.buttons[i].destPos = dest_positions[i-1]
					self.buttons[i].needsFrameCallbacks = true
					if self.buttons[i] ~= nil and not self.buttons[i].destroyed then
						self.buttons[i-1] = self.buttons[i]
						self.buttons[i-1].ID = self.buttons[i].ID-1
					end
				end
			end
			self.buttons[#self.buttons] = nil
		else
			safe_destroy(self.buttons[id])
			self.buttons[id] = nil
		end
	end;
	reloadTheme = function(self)
		local class = hud_class_get(self.className)
		self.alpha = class.alpha
		self.colour = class.colour
		
		for i = 1, #self.buttons do
			if self.buttons[i] and not self.buttons[i].destroyed then
				self.buttons[i]:reloadTheme()
			end
		end
	end;
})

gui.windownotebook = function(options)
	return hud_object `windownotebook` (options)
end
