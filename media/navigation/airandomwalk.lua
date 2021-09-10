airandomwalk = {
	idle_state = {
		init = function(self, state_machine)
			self:setAnimation(self.instance.animID.idle, false)
			
			self.onUpdateDestination = function(self)
				self:gotoState("walk")
			end
			state_machine.idlet = 0
			-- print(self.instance.state_machine)
			-- print("Idle begin")
		end;
		
		update = function(self, elapsed)
			local ins = self.instance
			local id = ins.animID.idle
			
			ins.animPos[id] = math.mod(ins.animPos[id] + elapsed, ins.animLen[id])
			ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
			
			if ins.state_machine.idlet > math.random(6, 12) then
				self:updateDestination(navigation_random_navmesh_point(), false)
			end
			
			ins.state_machine.idlet = ins.state_machine.idlet + elapsed
		end;
		
		exit = function(self)
			-- print("Idle finish")
		end;
	};
	walk_state = {
		init = function(self, state_machine)
			self:setAnimation(self.instance.animID.walk, false)
			
			self.onDestinationReached = function (self)
				-- print(self.className.." reached destination point")
				local ins = self.instance
				if ins.state_machine.currentStateName ~= "idle" then
					self:gotoState("idle")
					self:stop()
				end
			end
			
			state_machine.stuckCheck = 0
			state_machine.stuckCheckPos = self:getPosition()
			
			-- print("Walk begin")
		end;
		
		update = function(self, elapsed, state_machine)
			local ins = self.instance
			local id = ins.animID.walk
			
			ins.animPos[id] = math.mod(ins.animPos[id] + elapsed*(self:getSpeed()*0.5), ins.animLen[id])
			ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
			
		if state_machine.stuckCheck > 3 then
				state_machine.stuckCheck = 0
				-- print("stuck check: "..#(self:getPosition()-state_machine.stuckCheckPos).." "..self.className)
				if #(self:getPosition()-state_machine.stuckCheckPos) <= 0.5 then
					self:updateDestination(navigation_random_navmesh_point(), false)
				end
				state_machine.stuckCheckPos = self:getPosition()
			end
			
			state_machine.stuckCheck = state_machine.stuckCheck + elapsed
			
		end;
		
		exit = function(self)
			self.onDestinationReached = do_nothing
			-- print("Walk finish")
			-- state_machine.stuckCheck = 0
		end;
	};
};
