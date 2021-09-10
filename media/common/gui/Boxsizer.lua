------------------------------------------------------------------------------
--  Box Sizer: Distribute objects equally on parent
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `Boxsizer` {
	alpha = 1;
	size = vec(256, 256);
	orient = "vertical";
	expand = true;
	expandType = function(self)end;
	type = "boxsizer";
	
	init = function (self)
		self.needsParentResizedCallbacks = true
		
		self.childs = {}
		
		if self.orient == "vertical" then
			self.update = self.updateChildsV
		else
			self.update = self.updateChildsH
		end	
		self.expandType = function(self, psize) self.size = psize end;
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
			
		self:destroy()
	end;
	
	parentResizedCallback = function (self, psize)
		if self.expand then
			self:expandType(psize)
		end
		self:update(psize)
	end;

	updateChildsV = function (self, psize)
		for i = 1, #self.childs do
			-- self.childs[i].position = vec(self.childs[i].position.x, -psize.y/#self.childs*(i+1))
			if not self.childs[i].destroyed then
				self.childs[i].position = vec(self.childs[i].position.x, psize.y/2 -psize.y/(2*#self.childs) - ((i-1) * psize.y/#self.childs))
			end
			--psize.y/2 - ((i-1) * self.menuitems[i].size.y) -self.menuitems[i].size.y/2
		end
	end;
	
	updateChildsH = function (self, psize)
		for i = 1, #self.childs do
			if not self.childs[i].destroyed then
				self.childs[i].position = vec(psize.x/2 -psize.x/(2*#self.childs)- ((i-1) * psize.x/#self.childs) , self.childs[i].position.y)
			end
		end
	end;	
	
	addChild = function (self, child)
		self.childs[#self.childs+1] = child
		self.childs[#self.childs].parent = self
		self:update(self.size)
		
		if self.childs[#self.childs].expand then
			self.childs[#self.childs]:updateExpandType()
			self.childs[#self.childs]:expandType(self.size)
		end
		
	end;
	
	updateExpandType = function(self)
		if self.expand then
			if self.parent.type ~= nil and #self.parent.childs > 0 then
				if self.parent.type == "boxsizer" then
					if self.parent.orient == "horizontal" then
						self.expandType = function(self, psize)
							self.size = vec(self.parent.size.x / #self.parent.childs, self.parent.size.y)
						end
					elseif self.parent.orient == "vertical" then
						self.expandType = function(self, psize)
							self.size = vec(self.parent.size.x, self.parent.size.y/#self.parent.childs)
						end
					end
				-- elseif self.parent.type == "grid" then
					-- self.expandType = function(self, psize) self.size = vec(self.parent.size.x/#self.parent.childs, self.parent.size.y/#self.parent.childs) end
				end
			end
		end
	end;
}

function gui.boxsizer(g_expand, g_orient, p, g_size, g_colour, g_alpha)
	local bs = hud_object `Boxsizer` {
        parent = p,
        orient = g_orient or "h",
        expand = g_expand or false,
        colour = g_colour or vec(0.3, 0.3, 0.3),
        alpha = g_alpha or 0,
        size = g_size
    }
	if p then
		bs:updateExpandType()
	end
	return bs
end

-- safe_destroy(bxsz)
-- safe_destroy(it1)
-- safe_destroy(it2)
-- safe_destroy(it3)
-- safe_destroy(it4)

-- bxsz = gui.boxsizer(true, "h", editor_interface.windows.object_properties)

-- it1 = hud_object `/editor/core/hud/boxsizer` { colour = vec(1, 0, 0), size = vec(50, 50), alpha = 1 }
-- it2 = hud_object `/editor/core/hud/boxsizer` { colour = vec(0, 1, 0), size = vec(50, 50), alpha = 1, expand = false }
-- it3 = hud_object `/editor/core/hud/boxsizer` { colour = vec(0, 0, 1), size = vec(50, 50), alpha = 1 }
-- it4 = hud_object `/editor/core/hud/boxsizer` { colour = vec(0, 1, 1), size = vec(50, 50), alpha = 1, orient="v" }

-- bxsz:addChild(it1)
-- bxsz:addChild(it2)
-- bxsz:addChild(it3)
-- bxsz:addChild(it4)

-- it4child1 = hud_object `/editor/core/hud/boxsizer` { colour = vec(1, 0, 1), size = vec(50, 50), alpha = 1 }
-- it4child2 = hud_object `/editor/core/hud/boxsizer` { colour = vec(0, 0, 0), size = vec(50, 50), alpha = 1 }

-- it4:addChild(it4child1)
-- it4:addChild(it4child2)
