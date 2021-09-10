------------------------------------------------------------------------------
--  Status Bar
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `StatusBar` {
    colour = _current_theme.colours.status_bar.background;
	alpha = _current_theme.colours.status_bar.alpha;
	
	size = vec2(0, 25);
	
	defpadding = 10;
	
    init = function (self)
        self.needsParentResizedCallbacks = true

		self.fields = {}
		self.widths = {};
		
		self.line = hud_object `/common/hud/HorizontalLine` {
			parent = self;
			position = vec2(0, self.size.y/2);
			colour = _current_theme.colours.status_bar.line;
			alpha = 0.3;
		}
		self.line:setThickness(1)
		
		self.text = hud_text_add(`/common/fonts/Arial12`)
		self.text.parent = self
		self.text.colour = _current_theme.colours.status_bar.text
		self:setText("")
    end;

    destroy = function (self)
		self.needsParentResizedCallbacks = false

		self:destroy()
    end;

    parentResizedCallback = function (self, psize)
		self.position = vec(psize.x/2, self.size.y/2)
		self.size = vec(psize.x, self.size.y)
		self.text.position = vec2(-self.size.x/2+self.text.size.x/2+30, self.text.position.y)
		self:updateFields()
    end;

	framecallback = function(self, elapsed)
		
	end;	
	
	frameCallback = function(self, elapsed)
		self:framecallback(elapsed)
	end;
	
	setText = function(self, txt)
		self.text.text = txt
		self.text.position = vec2(-self.size.x/2+self.text.size.x/2+30, self.text.position.y)
	end;
	
	updateFields = function(self, txt)
		local ppos = self.size.x/2-20
		for i = 1, #self.fields do
			local lpos = 0
			if self.fields[i-1] ~= nil and self.fields[i-1].position ~= nil then
				lpos = self.fields[i-1].position.x-self.widths[i-1]/2
			end
			self.fields[i].position = vec(ppos + lpos - self.widths[i]/2, 0)
			ppos = 0
		end
	end;	
	
	addField = function(self, txt, sz)
		self.fields[#self.fields+1] = hud_text_add("/common/fonts/Arial12")
		self.fields[#self.fields].parent = self
		self.fields[#self.fields].colour = _current_theme.colours.status_bar.text
		self.fields[#self.fields].text = txt	
		
		self.widths[#self.widths+1] = sz or self.fields[#self.fields].size.x + self.defpadding

		self:updateFields()
		return #self.fields, self.widths[#self.widths]
	end;	
}

function gui.statusbar(options)
	return hud_object `StatusBar` (options)
end
