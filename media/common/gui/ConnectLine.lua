------------------------------------------------------------------------------
--  Create a line that connects two points or two hud objects
--
-- Examples:
-- 1:
-- hudobj = hud_object `/common/gui/Draggable` { parent = hud_centre, size=vec(64, 64), colour=vec(0, 0, 1), position=vec(100, -50) })
-- hudobj2 = hud_object `/common/gui/Draggable` { parent = hud_centre, size=vec(64, 64), colour=vec(1, 0, 0), position=vec(50, -100)})
-- myLine = gui.connectline({ parent = hud_centre; p1 = hudobj; p2 = hudobj2 })
-- 2:
-- myLine = gui.connectline({ parent = hud_centre; p1 = vec(0, 0); p2 = vec(10, -50) })
--
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `ConnectLine` {
	alpha = 1;
	size = vec(200, 5);
	texture = _gui_textures.line;
	p1 = vec(0, 0);
	p2 = vec(0, 0);
	
	init = function (self)
		if type(self.p1) == "userdata" and type(self.p2) == "userdata" then -- hud object
			self.needsFrameCallbacks = true
			self.getPoints = self.getPointsObj
		else -- vector
			self.getPoints = self.getPointsVec
			self:update()
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		self:update()
	end;

	getPointsObj = function(self)
		return self.p1.position, self.p2.position
	end;
	
	getPointsVec = function(self)
		return self.p1, self.p2
	end;	
	
	update = function(self)
		local p1, p2 = self:getPoints()
		
		if p1 ~= nil and p2 ~= nil then
			local dif = p1 - p2
			
			self.orientation = math.deg(math.atan2(dif.x, dif.y)) + 90
			self.position = (p1 + p2) / 2
			self.size = vec2(#dif, self.size.y)
		end
	end;
}

function gui.connectline(tab)
	return hud_object `ConnectLine` (tab)
end
