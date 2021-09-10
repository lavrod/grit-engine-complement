------------------------------------------------------------------------------
--  Flex Box Sizer
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `FlexBoxsizer` {
	alpha = 1;
	size = vec(256, 256);
	orient = "vertical"; -- v = vertical, h = horizontal
	expand = true;
	expandType = function(self)end;
	type = "boxsizer";
	child_settled = {};
	settled_size = 0;
	growablechilds = 0;
	
	init = function (self)
		self.needsParentResizedCallbacks = true
		
		self.childs = {}
		
		self.child_settled = {}
		
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
		local numsettled = 0
		local numexpand = 0
		local expandsize = 0
		
		if self.growablechilds ~= 0 then
			expandsize = (psize.y-self.settled_size)/self.growablechilds
		end
		
		for i = 1, #self.childs do
			if self.child_settled[i] == true then
				self.childs[i].size = vec(psize.x, self.childs[i].size.y)
				numsettled = numsettled + 1
			else
				self.childs[i].size = vec(psize.x, expandsize)
				numexpand = numexpand + 1
			end
		end
		
		local settledadded = 0
		local numexpandsadded = 0
		
		for i = 1, #self.childs do
			if not self.childs[i].destroyed then
				if self.child_settled[i] == true then
					self.childs[i].position = vec(self.childs[i].position.x, self.size.y/2 - self.childs[i].size.y/2 + (expandsize*numexpandsadded) + settledadded)
					settledadded = settledadded + self.childs[i].size.y
				elseif self.child_settled[i] == false then
					self.childs[i].position = vec(self.childs[i].position.x, self.size.y/2 - (expandsize*numexpandsadded) - settledadded-expandsize/2)
					numexpandsadded = numexpandsadded +1
				end
			end
		end
	end;
	
	updateChildsH = function (self, psize)
		for i = 1, #self.childs do
			if not self.childs[i].destroyed then
				self.childs[i].position = vec(math.ceil(psize.x/2 -psize.x/(2*#self.childs)- ((i-1) * psize.x/#self.childs)) , self.childs[i].position.y)
			end
		end
	end;
	
	addChild = function (self, child, settled, settled_sz)
		self.childs[#self.childs+1] = create_rect({ parent = self, colour = random_colour(), alpha = 0, size = settled_sz or child.size })
		child.parent = self.childs[#self.childs]
		
		if self.childs[#self.childs].expand and self.childs[#self.childs].updateExpandType ~= nil then
			self.childs[#self.childs]:updateExpandType()
			self.childs[#self.childs]:expandType(self.size)
		end
		
		if settled then
			if self.orient == "vertical" then
				self.settled_size = self.settled_size + self.childs[#self.childs].size.y
			else
				self.settled_size = self.settled_size + self.childs[#self.childs].size.x
			end
			self.child_settled[#self.child_settled + 1] = true
		else
			self.child_settled[#self.child_settled + 1] = false
			self.growablechilds = self.growablechilds+1
		end
		self:update(self.size)
	end;
	
	updateExpandType = function(self)
		if self.expand then
			if self.parent.type ~= nil and #self.parent.childs > 0 then
				if self.parent.type == "boxsizer" then
					if self.parent.orient == "horizontal" then
						self.expandType = function(self, psize) self.size = vec(self.parent.size.x / #self.parent.childs, self.parent.size.y) end
					elseif self.parent.orient == "vertical" then
						self.expandType = function(self, psize) self.size = vec(self.parent.size.x, self.parent.size.y/#self.parent.childs) end
					end
				-- elseif self.parent.type == "grid" then
					-- self.expandType = function(self, psize) self.size = vec(self.parent.size.x/#self.parent.childs, self.parent.size.y/#self.parent.childs) end
				end
			end
		end
	end;
}

function gui.flexboxsizer(g_expand, g_orient, p, g_size, g_colour, g_alpha)
	local bs = hud_object `FlexBoxsizer` {
        parent = p,
        orient = g_orient or "horizontal",
        expand = g_expand or false,
        colour = g_colour or vec(0.3, 0.3, 0.3),
        alpha = g_alpha or 1,
        size = g_size,
    }
	if p then
		bs:updateExpandType()
	end
	return bs
end
