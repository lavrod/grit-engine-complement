-- (c) Augusto Moura 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- NOT TESTED, W.I.P.
hud_class `listedit` {
	alpha = 1;
	size = vec(400, 30);
	--zOrder = 0;

	init = function (self)
		self.needsFrameCallbacks = true;
		self.base = hud_object `/common/hud/Border` { parent=self,  position=vec2(0, 0)}
		self.items = {}
		
		self.itemPositioner = hud_object `/common/hud/Positioner` {
			parent = self;
			offset = vec2(10, 0);
			factor = vec2(-0.5, 0);
		}
		self.valuePositioner = hud_object `/common/hud/Positioner` {
			parent = self;
			offset = vec2(-10, 0);
			factor = vec2(0.5, 0);
		}
		
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsParentResizedCallbacks = false
		
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		
	end;
	
	addItem = function(self, name, defaultvalue)
		self.items[#self.items + 1] = {
			title = gge_hud_text_add(``, { text = name, parent = itemPositioner, position = vec2(size.x / 2, position.y) });
			
			value = hud_object `/common/hud/EditBox` {
				value = defaultvalue;
				size = vec(100,20);
				alignment = "LEFT";
				parent=valuePositioner;
				position=vec2(value.size.x / 2, value.position.y);
			}
		}
	end;
}

-- TODO: Lists (W.I.P.)
