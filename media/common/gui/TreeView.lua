------------------------------------------------------------------------------
--  Tree View Class
--
--  (c) 2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

local treevlastcol = false

hud_class `TreeViewNode` (extends(_gui.class)
{
	alpha = 0.2;
	size = vec(150, 20);
	zOrder = 0;
	extends_w = true;
	colour = vec(1, 0.5, 0.5);
	align = guialign.left;
	
	icon = `/common/gui/icons/open_15.png`;
	
	isRealNode = false; -- if all objects are attached to this node
	
	name = "Default";
	
	selected = false;
	
	canHaveObjectChilds = true;
	canHaveNodeChilds = true;
	
	open = false;
	
	dragging = false;
	
	init = function (self)
		_gui.class.init(self)
		
		self.needsInputCallbacks = true
		
		self.colour = treevlastcol and vec(0.5, 0.5, 0.5) or vec(0.6, 0.6, 0.6)
		self.defaultColour = self.colour
		
		treevlastcol = not treevlastcol
		
		self.childs = {}
		
		if self.canHaveNodeChilds or self.canHaveObjectChilds then
			self.iconcolapse = gui.imagebutton({
				parent = self,
				align= guialign.left,
				offset = vec(3, 0),
				size = vec(15, 15),
				icon_texture = `/common/gui/icons/treeviewcolapsed.png`,
				alpha = 0,
				node = self
			})
			
			self.iconcolapse.pressedCallback = function(self)
				if self.node.open then
					self.node:colapseChilds()
				else
					self.node:showChilds()
				end
			end
			
			self.iconcolapse.enabled = false
		end
		
		self.iconx = gui.object({
			parent = self,
			texture = self.icon,
			align = guialign.left,
			size = vec(self.size.y-2, self.size.y-2),
			alpha = 1,
			offset = vec(20, 0),
			colour=vec(1, 0.8, 0.5)
		})
		self.text = gui.text({
			parent = self,
			align = guialign.left,
			offset = vec(self.iconx.size.x + 20, 0),
			alpha = 0
		})
		self.text.colour = vec(1, 0, 0)
		self.text:setValue(self.name)
	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
	end;
	
	addChild = function (self, nodename)
		self.childs[#self.childs+1] = hud_object `TreeViewNode` {
			name = nodename,
			parent = self.root,
			offset = vec(self.offset.x+10, (-(#self.childs+1)*21)),
			expand_x = true,
			expand_offset = vec(self.expand_offset.x-20, 0),
			root = self.root,
			align = guialign.top,
			parentNode = self,
			ID = #self.childs+1,
			canDrag = self.root.canDrag
		}
		
		self.childs[#self.childs].enabled = false
		self.iconcolapse.enabled = true
	end;

	removeChild = function(self, id)
		table.remove(self.childs, id)
		
		if #self.childs == 0 then
			self.iconcolapse.enabled = false
			self:setIsOpen(false)
		else
			self:updateChildsID()
		end
	end;

	updateChildsID = function(self)
		for i = 1, #self.childs do
			self.childs[i].ID = i
		end
	end;

	colapseChilds = function(self)
		self.root.activeLines = self.root.activeLines - #self.childs

		self:setIsOpen(false)
		
		for i = 1, #self.childs do
			if self.childs[i].open then
				self.childs[i]:colapseChilds()
			end
			self.childs[i].enabled = false
		end
		
		self.root:update()
	end;
	
	showChilds = function(self)
		self.root.activeLines = self.root.activeLines + #self.childs
		
		self:setIsOpen(true)

		for i = 1, #self.childs do
			self.childs[i].enabled = true
		end
		
		self.root:update()
	end;
	
	update = function(self)
		self.offset = vec(self.offset.x, -(self.root.cline*21))
		self.root.cline = self.root.cline + 1
		self.root.line[self.root.cline] = self
		
		self.lineIndex = self.root.cline
		
		if self.open then
			for i = 1, #self.childs do
				self.childs[i]:update()
			end
		end
	end;
	
	updateChildsPosition = function(self)
		if #self.childs > 0 then
			for i = 1, #self.childs do
				self.childs[i].offset = vec(self.offset.x+10, self.childs[i].position.y)
				self.childs[i].expand_offset = vec(self.expand_offset.x-20, self.childs[i].expand_offset.y)
				if #self.childs[i].childs > 0 then
					self.childs[i]:updateChildsPosition()
				end
			end
		end
	end;

	getAllParents = function(self)
		local parents = {}
		local currentNode = self
		
		while(currentNode ~= self.root) do
			parents[#parents+1] = currentNode.parentNode
			currentNode = currentNode.parentNode
		end
		return parents
	end;

	isParent = function(self, obj)
		local currentNode = self.parentNode
		
		while(currentNode ~= self.root) do
			if currentNode == obj then
				return true
			end
			currentNode = currentNode.parentNode
		end
		return false		
	end;	
	
	setIsOpen = function(self, v)
		self.open = v
		
		if v then
			self.iconcolapse.icon.texture = `/common/gui/icons/treeviewopen.png`
		else
			self.iconcolapse.icon.texture = `/common/gui/icons/treeviewcolapsed.png`
		end
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.dragging and self.canDrag then
			local kj = mouse_pos_abs - self.derivedPosition
			
			if #(kj - self.draggingPos) > 10 and not self.adding then
				self.adding = true
				self.root:startMovingObject(self)
			end
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - self.derivedPosition
		elseif ev == "-left" then
			if self.dragging and not self.adding and self.inside then
				if self.root.selected ~= nil then
					self.root.selected.alpha = 0
					self.root.selected.colour = vec(0, 0, 0)
				end
				self.root.selected = self
				
				self.alpha = 1
				self.colour = vec(0.3, 0.6, 1)
			end
			
			self.dragging = false
			self.draggingPos = vec2(0, 0)
			self.adding = false
        end
    end;	
})

hud_class `DraggingTreeViewObject` {
	alpha = 0;
	size = vec(150, 20);
	zOrder = 7;

	init = function (self)
		self.needsFrameCallbacks = true
		
		self.iconx = create_rect({
			parent = self,
			texture = self.icon,
			alpha = 1,
			size = vec(20, 20)
		})
		
		self.text = hud_text_add(`/common/fonts/Verdana12`)
		self.text.parent = self
		self.text.text = self.caption
		self.text.position = vec(self.text.size.x/2+self.iconx.size.x/2+4, 0)
	end;
	
	destroy = function (self)
		self.needsInputCallbacks = false
		
		self:destroy()
	end;
	
    frameCallback = function (self, elapsed)
		if self.position ~= mouse_pos_abs then
			self.position = mouse_pos_abs
		end
    end;
}

TreeView =  (extends(_gui.class)
{
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	expand = true;
	activeLines = 0;
	
	cline = 0;
	
	-- drag and drop nodes, into other nodes or reorganize nodes with same parent
	canDrag = false;
	
	init = function (self)
		_gui.class.init(self)
		self.childs = {}
		self.line = {}
	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
	end;
	
	addNode = function(self, nodename, par, icon)
		if par == nil then
			self.childs[#self.childs+1] = hud_object `TreeViewNode` {
				name = nodename,
				parent = self,
				childs_child = true,
				offset = vec(0, -(self.activeLines+1)*21+20),
				expand_x = true,
				root = self,
				align = vec(0, 1),
				parentNode = self,
				ID = #self.childs+1,
				lineIndex = self.activeLines+1,
				canDrag = self.canDrag
			}
			
			self.activeLines = self.activeLines + 1
			self.line[#self.activeLines] = self.childs[#self.childs] 
			return self.childs[#self.childs]
		else
			par:addChild(nodename)
		end
	end;
	
	update = function(self)
		self.cline = 0
		for i = 1, #self.childs do
			self.childs[i]:update()
		end
		self.cline = 0
		self.size = self.size
	end;

	startMovingObject = function(self, obj)
		self.floatingObject = hud_object `DraggingTreeViewObject` { icon = obj.icon, caption = obj.name }
		self.draggingNode = obj

		self.marker = create_rect({ parent = self, size = vec(self.size.x, 3.5), colour = vec(1, 0.5, 0), texture=`/common/gui/icons/line.png` })
		self.marker.enabled = false
		self.needsInputCallbacks = true
	end;
	
	getObjectInLine = function(self, line)
		if line <= self.activeLines and line > 0 then
			return self.line[line]
		end
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.floatingObject ~= nil then
			local markerenabled = false
			local nearest_node = nil
			
			local grpn = math.ceil((((self.derivedPosition.y - mouse_pos_abs.y-10) + self.size.y/2)) / 20)
			local grpnx = math.ceil((((self.derivedPosition.y - mouse_pos_abs.y-10) + self.size.y/2)) / 10)
			grpnx = math.mod(grpnx, grpn)
			
			nearest_node = self:getObjectInLine(grpn)
			
			if nearest_node ~= nil and not nearest_node.destroyed then
				if not nearest_node:isParent(self.draggingNode) then
					if self.currentDragInto ~= nil then
						self.currentDragInto.obj.colour = self.currentDragInto.originalColour
						self.currentDragInto.obj.alpha = self.currentDragInto.originalAlpha
					end

					if grpnx ~= 0 then
						if nearest_node.canHaveNodeChilds then
							self.dragInto = true
							
							self.moveDraggingTo = nearest_node
							
							self.currentDragInto = {}
							self.currentDragInto.originalColour = self.moveDraggingTo.colour
							self.currentDragInto.originalAlpha = self.moveDraggingTo.alpha
							self.currentDragInto.obj = self.moveDraggingTo
							
							self.currentDragInto.obj.colour = vec(1, 0.5, 0)
							self.currentDragInto.obj.alpha = 0.1

							markerenabled = false
						end
					elseif nearest_node.parentNode == self.draggingNode.parentNode and -- needs to be the same parent
					self.draggingNode ~= nearest_node and -- not the same node
					nearest_node.ID ~= self.draggingNode.ID -1 then -- prevents resulting in the same position
						self.dragInto = false
						
						self.moveDraggingTo = nearest_node
						
						self.marker.colour = vec(1, 0.5, 0)
						self.marker.position = vec(0, nearest_node.position.y- nearest_node.size.y/2+1)
						markerenabled = true
					end
				end
			end
			
			self.marker.enabled = markerenabled
		else
			self.needsInputCallbacks = false
		end
    end;
	
	moveTo = function(self, g1, g2)
		local parent = g1.parentNode

		if g1.ID > g2.ID then
			table.remove(parent.childs, g1.ID)
			
			for i = #parent.childs, g2.ID+1, -1 do
				if parent.childs[i] ~= nil then
					parent.childs[i+1] = parent.childs[i]
				end
			end
			parent.childs[g2.ID+1] = g1
			self:updateChildsID()
			self:update()
		else
			for i = g1.ID+1, #g2.ID do
				parent.childs[i-1] = parent.childs[i]
			end
			parent.childs[g2.ID] = g1
			self:updateChildsID()
			self:update()			
		end
	end;
	
	moveInto = function(self, g1, g2)
		if g1 ~= nil and g2 ~= nil and not g1.destroyed and not g2.destroyed then
			g1.parentNode:removeChild(g1.ID)
			
			if g2 ~= self then
				g2.iconcolapse.enabled = true
				
				if #g2.childs == 0 then
					g2:setIsOpen(true)
				elseif not g2.open then
					g1.enabled = false
				end
				
				g1.offset = vec(g2.offset.x + 10, g1.offset.y)
				g1.expand_offset = vec(g2.expand_offset.x - 20, g1.expand_offset.y)
			else
				g1.offset = vec(0, g1.offset.y)
				g1.expand_offset = vec(0, g1.expand_offset.y)
			end
			
			g2.childs[#g2.childs+1] = g1
			g1.parentNode = g2
			g1.ID = #g2.childs

			if #g1.childs > 0 then
				g1:updateChildsPosition()
			end
			
			self:update()
		end
	end;
	
	removeChild = function(self, id)
		table.remove(self.childs, id)

		self:updateChildsID()
	end;

	updateChildsID = function(self)
		for i = 1, #self.childs do
			self.childs[i].ID = i
		end
	end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
		elseif ev == "-left" then
			safe_destroy(self.floatingObject)
			safe_destroy(self.marker)
			self.floatingObject = nil
			self.marker = nil
			
			if self.currentDragInto ~= nil then
				self.currentDragInto.obj.colour = self.currentDragInto.originalColour
				self.currentDragInto.obj.alpha = self.currentDragInto.originalAlpha
			end
			
			self.currentDragInto = nil
			
			if self.dragInto then
				if self.moveDraggingTo ~= nil then
					if self.draggingNode ~= self.moveDraggingTo then
						if self.draggingNode.parentNode ~= self.moveDraggingTo then
							if self.moveDraggingTo.inside then
								self:moveInto(self.draggingNode, self.moveDraggingTo)
							elseif self.draggingNode.parentNode ~= self then
								self:moveInto(self.draggingNode, self)
							end
							self:update()
						end
					else
						if not self.moveDraggingTo.inside then
							self:moveInto(self.draggingNode, self)
							self:update()
						end
					end
				end
			elseif self.draggingNode.parentNode == self.moveDraggingTo.parentNode then
				self:moveTo(self.draggingNode, self.moveDraggingTo)
			end
			
			self.draggingNode = nil
			self.moveDraggingTo = nil
        end
    end;
})

hud_class `TreeView` (extends(TreeView)
{
	init = function (self)
		TreeView.init(self)
	end;
	
	destroy = function (self)
		TreeView.destroy(self)
	end;
	
	buttonCallback = function(self, ev)
		TreeView.buttonCallback(self, ev)
	end;
	
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		TreeView.mouseMoveCallback(self, local_pos, screen_pos, inside)
	end;
})

function gui.treeview(options)
	return hud_object `TreeView` (options)
end
