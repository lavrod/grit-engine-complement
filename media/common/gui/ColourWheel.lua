------------------------------------------------------------------------------
--  (c) 2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

local function det(a, b)
	return a.x * b.y - a.y * b.x
end

hud_class `ColourWheel` {
	alpha = 1;
	size = vec(128, 128);
	colour = V_ID;
	texture = `icons/ColourWheel.png`;
	
	hsv = vec(0.5, 0, 1);

	dragging = false;

	init = function (self)
		self.needsInputCallbacks = true
		
		self.point = create_rect({ size = vec(8, 8), parent = self, texture = `/common/hud/CornerTextures/FilledWhiteBorder04.png` })
	
		self.debug_rect = create_rect({ parent = self, position = vec(self.size.x/2+30+50, 0), size = vec(30, 30) })
		-- self.debug_rect.enabled= false
		
		self.controlv = hud_object `/common/hud/Scale` {
			onChange = function(self)
				self.parent.hsv = vec(self.parent.hsv.x, self.parent.hsv.y, math.abs(self.value-1))
				local hsv = self.parent.hsv
				self.sliderBackground.colour = HSVtoRGB(vec(hsv.x, hsv.y, 1))
				self.parent.debug_rect.colour = self.parent:getColour()
			end,
			size = vec(200, 20),
			bgTexture=`icons/alphagrad.png`, 
			bgColour=vec(1,1,1), parent = self,
			orientation = 90,
			position = vec(90, 0)
		})
		-- self.controlv.editBox.enabled = false
	end;
	destroy = function (self)
		self.needsInputCallbacks = false
		
		self:destroy()
	end;

	update = function(self)
		local dist = self.derivedPosition - mouse_pos_abs
		
		if #dist > 0 then
			local dir = norm(dist)
			self.point.position =  dir * math.max(-#dist, -self.size.x/2)
			
			local ppos = self.point.position
			
			local angle = (math.atan2(det(vec(1, 0), ppos), dot(vec(1, 0), ppos)) + math.pi) / (math.pi * 2)

			local sat = #math.max(-#dist, -self.size.x/2)/(self.size.x/2)
			
			self.hsv = vec(angle, sat, self.hsv.z)
			
			self.debug_rect.colour = self:getColour()

			local hsv = self.hsv
			self.controlv.sliderBackground.colour = HSVtoRGB(vec(hsv.x, hsv.y, 1))			
		end		
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside

		if self.dragging then
			self:update()
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self:update()
		elseif ev == "-left" then
			self.dragging = false
        end
    end;	
	
	getColour = function(self)
		return HSVtoRGB(self.hsv)
	end;
}

function gui.colourwheel(tab)
	return hud_object `ColourWheel` (tab)
end
