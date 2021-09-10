------------------------------------------------------------------------------
--  Slider Class
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO: add "_current_theme".., extend _gui.class

hud_class `dragbarsld` {
	alpha = 1;
	size = vec(10, 50);
	zOrder = 0;
	colour = vec(1, 1, 1);
	
	normalColour = vec(1, 1, 1);
	hoverColour = vec(1, 1, 1);
	pressColour = vec(1, 0.8, 0.5);
	parentColour = vec(1, 1, 1);
	
	dragging = false;
	draggingPos = vec(0, 0);
	cornered = true;
	texture = `/common/hud/CornerTextures/Filled04.png`;
	unclampedpos = vec(0, 0);
	format = "%0.2f";

	init = function (self)
		self.needsInputCallbacks = true
		self.needsParentResizedCallbacks=true
		self.startpos = vec2(0, 0)
		self.normalColour = self.colour
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if not self.dragging then
			if self.inside then
				self.colour = self.hoverColour
				self.parent.text.colour = self.parent.textHighlight
				self.parent.val.colour = self.parent.textHighlight
				self.parent.colour = self.parentColour*1.2
				--self.zOrder = 1
			else
				self.colour = self.normalColour
				self.parent.text.colour = self.parent.textColour
				self.parent.val.colour = self.parent.textColour
				self.parent.colour = self.parentColour
				--self.zOrder = 0
			end
		end
		
		if self.dragging == true then
			if self.parent.size.x ~= 0 then
				local pcent = ((self.unclampedpos.x) + ((self.parent.size.x-self.size.x)/2))/(self.parent.size.x-self.size.x)
				self.parent:setValue(self.format:format(clamp(pcent, 0, 1)*(self.parent.maxValue-self.parent.minValue)+self.parent.minValue))
			end			
			self.parent.val.position = vec(self.parent.size.x/2-self.parent.val.size.x/2-5, 0)
			self.unclampedpos = vec2(mouse_pos_abs.x - self.draggingPos.x, self.position.y)
			self:setPos(vec(mouse_pos_abs.x - self.draggingPos.x, self.position.y))
		end
    end;

	setPos = function(self, pos)
		self.position = vec2(math.clamp(pos.x, -(self.parent.size.x/2 -self.size.x/2-2), self.parent.size.x/2 -self.size.x/2-2), pos.y)
	end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - vec2(self.position.x, self.position.y)
			self.colour = self.pressColour
			self.parent:onClick()
		elseif ev == "-left" then
			if self.dragging then self.parent:onClickEnd() end
			self.dragging = false
			self.draggingPos = vec2(0, 0)
			self.colour = self.normalColour
			--self.zOrder = 0
        end
    end;
	updateSize = function(self)

	end;
	parentResizedCallback = function(self, psize)
		if self.parent ~= nil then
			self.startpos = vec2(0, self.parent.size.y/2 -self.size.y/2)
		end
		-- self:updateSize()
	end;
}

hud_class `Slider` {
	alpha = 1;
	size = vec(262, 27);
	zOrder = 0;
	colour= vec(0.32, 0.32, 0.32);
	cornered = true;
	texture = _gui_textures.slider;
	localPos = vec(0, 0);	
	maxValue = 45;
	minValue = 30;
	value = 0;
	step = 0;
	caption = "text";
	padding = 10;

	textColour = vec(0.8, 0.8, 0.8);
	textHighlight = vec(1, 1, 1);

	init = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = true
		self.needsInputCallbacks = true
		
		self.text = hud_text_add(`/common/fonts/Verdana12`)
		self.text.parent = self
		self.text.text = self.caption
		self.text.colour = self.textColour
		self.text.position = vec(-self.size.x/2+self.text.size.x/2+self.padding, 0)
		self.text.shadow = vec(1, -1)
		--self.text.zOrder = 0
		
		self.slidebar = hud_object `dragbarsld` { size = vec(9, self.size.y-self.padding/2), colour = vec(1, 1, 1), parent = self, position=vec2(-self.size.x/2+self.padding, 0), parentColour=self.colour, alpha = 1 }
		
		self.slidebar.position = vec(-self.size.x/2 + ((self.value-self.minValue) / (self.maxValue-self.minValue)) * self.size.x, 0)
		--self.slidebar.zOrder = 1

		self.val = hud_text_add(`/common/fonts/Verdana12`)
		self.val.parent = self
		self.val.text = tostring(self.value)
		self.val.colour = self.textColour
		self.val.position = vec(self.size.x/2-self.val.size.x/2-self.padding, 0)
		self.val.shadow = vec(1, -1)
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;

	parentResizedCallback = function(self, psize)
		if self.parent.type ~= nil then
			self.size = vec2(psize.x-self.padding, self.parent.size.y/#self.parent.childs-self.padding/2)
			self.slidebar.size = vec(self.slidebar.size.x, self.size.y-self.padding/2)
		else
			self.size = vec2(psize.x-self.padding, self.size.y)
		end
		self.text.position = vec(-self.size.x/2+self.text.size.x/2+self.padding, 0)
		self.val.position = vec(self.size.x/2-self.val.size.x/2-self.padding, 0)
		self.slidebar:setPos(vec(-self.size.x/2 + ((tonumber(self.value)-self.minValue) / (self.maxValue-self.minValue)) * self.size.x, 0))
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		self.localPos = local_pos
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.slidebar.dragging = true
			self.slidebar.position = vec(self.localPos.x, 0)
			self.slidebar.draggingPos = mouse_pos_abs -vec2(self.slidebar.position.x, self.slidebar.position.y)
			self.slidebar.colour=vec(1, 0.8, 0.5)
			self.slidebar.zOrder = 0
        end
    end;	
	
	setValue = function (self, val)
		if self.step ~= 0 then
			val = math.floor(tonumber(val) / self.step + 0.5 ) * self.step
		else
			val = tonumber(val)
		end
		self.value = val
		self.val.text = tostring(val)
	end;
	
	onClick = function (self)
		
	end;
	
	onClickEnd = function (self)
		
	end;
}

function gui.slider(s_caption_ortab, s_position, s_defaultvalue, s_parent, s_minvalue, s_maxvalue, s_stepsize, s_onclick, s_onclickend)
	local sld
	if type(s_caption_ortab) == "table" then
		sld = hud_object `Slider` (s_caption_ortab)	
	else
		sld = hud_object `Slider` {
			caption = s_caption_ortab or "",
			position = s_position or vec(0, 0),
			value = s_defaultvalue or 0,
			parent = s_parent or hud_centre,
			maxValue = s_maxvalue or 1,
			minValue = s_minvalue or 0,
			step = s_stepsize or 0,
			onClick = s_onclick or do_nothing,
			onClickEnd = s_onclickend or do_nothing
		}
	end
	return sld
end
