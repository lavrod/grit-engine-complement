------------------------------------------------------------------------------
--  A W.I.P. (not working, just a concept) character animation system/ai manager
-- Animation events: call a function when reaches a animation timing
-- State machine: easy way to manage character states and other stuff
-- Animation manager: manage animations and animation blending
-- AI character
-- TODO: 2d animation blending space: see https://goo.gl/I6zYt9
--
--  (c) 2015-2016 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- source = object/camera position (vec3), target = target position (vec3)
function lookAt(source, target)
	local dir = norm(target-source)
	return quat(yaw(dir.x, dir.y), V_DOWN) * quat(pitch(dir.z), V_EAST)
end;

function double_extends (p1, p2)
	return function(child)
		for k,v in pairs(p1) do
			if child[k] == nil then
				child[k] = v
			end
		end
		for k,v in pairs(p2) do
			if child[k] == nil then
				child[k] = v
			end
		end				
		
		return child
	end
end

function multi_extends (parents)
	return function(child)
		for i = 1, #parents do
			for k,v in pairs(parents[i]) do
				if child[k] == nil then
					child[k] = v
				end
			end
		end	
		return child
	end
end

function merge_extends (parents)
	local child = {}
	
	for i = 1, #parents do
		for k,v in pairs(parents[i]) do
			if child[k] == nil then
				child[k] = v
			end
		end
	end	
	return child

end

-- this is an example of a state for StateMachine
-- you probably want to declare it in your object class with other states, like .states = { mystate_state = {...}, mystate2_state = {...} }
-- NOTES:
-- Always use the '_state' after your state name (this is intended for developers that want to store their states on the object class table itself instead of a sub-table like i suggested)
-- Don't forget the paramaters for each methods:
-- self is the reference for the object class
-- state_machine is the reference for this state machine, it is optional
local default_state = {
	init = function(self, state_machine)
		
	end;
	
	update = function(self, elapsed, state_machine)
		
	end;
	
	exit = function(self, state_machine)
		
	end;
}

-- StateMachine states example (pseudo code):
--[[
mystates = {
	idle_state = {
		init = function(self, state_machine)
			self.velocity = V_ZERO
			self:setAnimation('idle')
			self.instance.isRunning = false
		end;
		
		update = function(self, elapsed, state_machine)
			
		end;
		
		exit = function(self, state_machine)
			
		end;
	};
	running_state = {
		init = function(self, state_machine)
			self:setAnimation('runimpulse')
			state_machine.currentState.startRunTiming = 0
			self.instance.isRunning = true
		end;
		
		update = function(self, elapsed, state_machine)
			local cs = state_machine.currentState -- you can use self.state_machine or whatever name you give to this state machine and ignore the 'state_machine' parameter if you prefer 
			
			cs.startRunTiming = cs.startRunTiming + elapsed
			if cs.startRunTiming > 2.0 and not cs.runningLoop then
				self:setAnimation('runningloop')
				cs.runningLoop = true
			end
			
			if cs.startRunTiming > 20 and cs.runningLoop then -- too tired
				state_machine:gotoState('idle')
			end
			
		end;
		
		exit = function(self, state_machine)
			self.instance.isRunning = false
		end;
	};
}
]]

-- do not try to extend this, this is intended to be used on object initialization, as:
-- instance.statemachine = StateMachine.new(self, self.states)
-- where last 'self' is used as reference for wich object class this StateMachine is working for
-- 'self.states' is optional, if you want to store your states on other table other than object class table itself
StateMachine =
{
	new = function(ref, states_table, default)
		local self = {
			currentStateName = "";
			prevStateName = "";

			reference = ref or {}; -- reference for the object class that is using this state machine
			states = states_table or ref or {}; -- states_table is optional, if you want to store your states somewhere else, otherwise use the object class table
		}

		make_instance(self, StateMachine)
		
		if default then
			self:gotoState(default) -- 'default' is optional, when set initializes this state
		end
		return self
	end;
	
    update = function (self, elapsed)
		if self.currentState.update ~= nil then
			-- NOTE: this swap self and the object pointer, we have two 'self', one of the object and other is the real self (state machine)
			self.states[self.currentStateName.."_state"].update(self.reference, elapsed, self)
		end
    end;

	gotoState = function(self, state_name)
		local s = "_state"
		if state_name ~= nil and self.states[state_name..s] ~= nil then
			local curstname = self.currentStateName
			local prevStateName = self.currentStateName
			self.currentStateName = state_name
			
			if self.states[curstname..s] ~= nil and self.states[curstname..s].exit ~= nil then
				self.states[curstname..s].exit(self.reference, self)
			end

			self.currentState = self.states[state_name..s]

			if self.states[self.currentStateName..s].init ~= nil then
				self.states[self.currentStateName..s].init(self.reference, self)
			end
		else
			if self.reference.className then
				error("State '"..state_name.."' from object of class "..self.reference.className.." not found!")
			else
				error("State '"..state_name.."' not found!")
			end
		end
	end;
}

-- a simple state machine
StateClass =  extends (BaseClass)
{
    activate = function(self, instance)
        BaseClass.activate(self, instance)

        self.needsStepCallbacks = true
		instance.currentStateName = ""
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false

        BaseClass.deactivate(self)
    end;
	
    destroy = function (self)

    end;	
	
    stepCallback = function (self, elapsed)
		self:currentState(elapsed)
    end;

	gotoState = function(self, state_name)
		local ins = self.instance
		ins.currentStateName = state_name
		self.currentState = self[state_name.."_state"]
	end;	
	
    currentState = function (self, elapsed)
		
    end;
}

AnimEvent = 
{
    activate = function(self, instance)
		instance.animEvents = {}
		instance.onFinishAnimEvents = {}
		instance.latestUpdate = {}
    end;

    stepCallback = function (self, elapsed)
		local inst = self.instance
		
		for i = 1, #inst.animEvents do
			local event_pos = inst.animEvents.timePos
			local current_pos = inst.animPos[inst.animEvents.animID]
			
			local should_call = false
			
			if inst.animEvents[i].latestUpdate[i] ~= -1 then
				if event_pos >= inst.animEvents[i].latestUpdate[i] and event_pos <= current_pos  then
					should_call = true
				end
			else
				if event_pos == current_pos then
					should_call = true
				end
				inst.animEvents[i].latestUpdate[i] = os.time()
			end
			
			if should_call then
				inst.animEvents[i].callback(self)
			end
		end

		-- TODO
		for i = 1, #inst.onFinishAnimEvents do
			if inst.animPos[inst.animEvents.animID] == inst.animLen[inst.onFinishAnimEvents.animID] then
				inst.onFinishAnimEvents[i].callback()
				-- table.remove(inst.onFinishAnimEvents, i)
			end
		end		
    end;
	
	addEvent = function(self, id, tp, cb)
		self.instance.animEvents[#inst.animEvents+1] = {
			animID = id;
			timePos = tp;
			callback = cb;
			latestUpdate = -1;
		}

	end;
	
	addOnFinishEvent = function(self, id, cb)
		self.instance.onFinishAnimEvents[#inst.onFinishAnimEvents+1] = {
			animID = id;
			callback = cb;
		}
	end;	
}

AnimMgr =
{
    activate = function(self, instance)
		local ins = instance

		ins.animName = {ins.gfx:getAllAnimations()}
		
		ins.animID = {};

		for i = 1, #ins.animName do
			ins.animID[ins.animName[i]] = i
		end
		
		ins.animLen = {};

		for i = 1, #ins.animName do
			ins.animLen[i] = ins.gfx:getAnimationLength(ins.animName[i]);
		end
		
		ins.animPos = {};
		
		for i = 1, #ins.animName do
			ins.animPos[i] = 0;
		end

		ins.currentAnimID = -1
		ins.animFadeSpeed = 3.5
		ins.resetAnim = false		
		
		ins.fadingAnims = {};
		
		for i = 1, #ins.animName do
			ins.fadingAnims[i] = {}
			ins.fadingAnims[i].inx = false
			ins.fadingAnims[i].out = false
		end
    end;

    stepCallback = function (self, elapsed)
		self:fadeAnimations(elapsed)
    end;
 
	setAnimation = function(self, id, reset)
		local inst = self.instance
		
		if inst.currentAnimID >= 0 then
			-- if we have an old animation, fade it out
			inst.fadingAnims[inst.currentAnimID].inx = false
			inst.fadingAnims[inst.currentAnimID].out = true
		end
		
		inst.currentAnimID = id
		-- if we have a new animation, enable it and fade it in
		inst.gfx:setAnimationMask(inst.animName[id], 0)
		inst.fadingAnims[id].inx = true
		inst.fadingAnims[id].out = false
		if reset then inst.gfx:setAnimationPos(inst.animName[id], 0) end
	end;

	fadeAnimations = function(self, elapsed)
		local inst = self.instance
		
		for i = 1, #inst.animName do
			if inst.fadingAnims[i].inx then
				local newWeight = inst.gfx:getAnimationMask(inst.animName[i]) + elapsed * inst.animFadeSpeed
				inst.gfx:setAnimationMask(inst.animName[i], math.clamp(newWeight, 0, 1))
				if newWeight >= 1 then
					inst.fadingAnims[i].inx = false
				end
			elseif inst.fadingAnims[i].out then
				local newWeight = inst.gfx:getAnimationMask(inst.animName[i]) - elapsed * inst.animFadeSpeed
				inst.gfx:setAnimationMask(inst.animName[i], math.clamp(newWeight, 0, 1))

				if newWeight <= 0 then
					inst.fadingAnims[i].out = false
				end				
			end
		end
	end;
}

-- CustomAnimatedClass = double_extends (AnimMgr, ColClass)
-- {
	-- init = function (self)
		-- ColClass.init(self)
	-- end;
	
    -- activate = function(self, instance)
		-- AnimMgr.activate(self, instance)
		
		-- self:setAnimation(instance.animID.idle, false)
		-- self:gotoState("idle")
    -- end;

    -- deactivate = function (self)
        -- self.needsStepCallbacks = false

        -- AnimMgr.deactivate(self)
    -- end;
	
    -- destroy = function (self)

    -- end;	
	
    -- stepCallback = function (self, elapsed)
		-- AnimMgr.stepCallback(self, elapsed)

    -- end;
 
	-- idle_state = function(self, elapsed)
		-- local ins = self.instance
		-- local id = ins.animID.idle
		
		-- ins.animPos[id] = math.mod(ins.animPos[id] + elapsed, ins.animLen[id])
		-- ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
	-- end;
-- }

-- class `CustomAnimated` (CustomAnimatedClass)
-- {

	-- gfxMesh = `/common/characters/robot_med/robot_med.mesh`;
	-- colMesh = `/common/characters/robot_med/robot_med.gcol`;

	-- mass = 90;	
    -- radius = 0.3;
	-- height = 2.2;

    -- placementZOffset = 1.112;
	-- health = 1000;
-- }


-- aichars = {}
-- aichars[#aichars+1] = object (`/navigation/aichar`) (pick_pos()+vec(0, 0, gge_class_get(`/navigation/aichar`).placementZOffset)) {}

-- for i = 1, #current_map.aicharacters do
	-- if not current_map.aicharacters[i].destroyed then
		-- current_map.aicharacters[i].needsStepCallbacks = true
	-- end
-- end

AICharacter =  double_extends(AnimMgr, BaseClass)
{
    renderingDistance = 500.0;
    castShadows = true;

    height = 1.8;
    radius = 0.3;

    mass = 80; 
    
	AICharacter = true;

	states = {
		idle_state = {
			init = function(self)
				self:setAnimation(self.instance.animID.idle, false)
				
				self.onUpdateDestination = function(self)
					self:gotoState("walk")
				end
			end;
			
			update = function(self, elapsed)
				local ins = self.instance
				local id = ins.animID.idle
				
				ins.animPos[id] = math.mod(ins.animPos[id] + elapsed, ins.animLen[id])
				ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
			end;
			
			exit = function(self)

			end;
		};
		walk_state = {
			init = function(self)
				self:setAnimation(self.instance.animID.walk, false)
				
				self.onDestinationReached = function (self)
					-- print(self.className.." reached destination point")
					local ins = self.instance
					if ins.state_machine.currentStateName ~= "idle" then
						self:gotoState("idle")
						self:stop()
					end
				end
			end;
			
			update = function(self, elapsed)
				local ins = self.instance
				local id = ins.animID.walk
				
				ins.animPos[id] = math.mod(ins.animPos[id] + elapsed*(self:getSpeed()*0.5), ins.animLen[id])
				ins.gfx:setAnimationPos(ins.animName[id], ins.animPos[id])
			end;
			
			exit = function(self)
				-- self.onDestinationReached = do_nothing
			end;
		};
	};
	
    activate = function(self, instance)
        BaseClass.activate(self, instance)
		AnimMgr.activate(self, instance)
		
        self.needsStepCallbacks = true
		
		instance.target = nil
		
		-- AI
		instance.destinationRadius = 2
		instance.destinationReached = true

		instance.agentID = -1 -- -1 means navigation agent not set
		
		local pos
		
		if instance.body ~= nil then
			pos = instance.body.worldPosition
		else
			pos  = instance.gfx.localPosition
		end
		
		if gge_navigation_navmesh_loaded() then
			self:setAgentID(gge_agent_make(gge_navigation_nearest_point_on_navmesh(pos) or pos))
		end
		
		instance.destination = nil
		instance.stopped = true

		self.maxPerceptionAngle = 85
		self.maxPerceptionDistance = 200

        instance.isActor = true
        instance.runState = false
		
		if self.states then
			instance.state_machine = StateMachine.new(self, self.states, self.defaultState or "idle")
		end
		
		-- callback
		if self.onActivate then self:onActivate() end
		
    end;

    deactivate = function (self)
		-- callback
		if self.onDeactivate then self:onDeactivate() end
		
        self.needsStepCallbacks = false
		if self:getAgentID() ~= -1 then
			gge_agent_stop(self:getAgentID())
			gge_agent_destroy(self:getAgentID())
		end
        BaseClass.deactivate(self)
    end;
	
    destroy = function (self)
		-- callback
		if self.onDestroy then self:onDestroy() end
		
		if self:getAgentID() ~= -1 then
			gge_agent_stop(self:getAgentID())
			gge_agent_destroy(self:getAgentID())
		end
    end;	
	
    stepCallback = function (self, elapsed)
		-- BaseClass.stepCallback(self, elapsed)
		AnimMgr.stepCallback(self, elapsed)
		if self.instance.state_machine then
			self.instance.state_machine:update(elapsed)
		end
		
		if self:getAgentID() ~= -1 then
			self:updatePosition(elapsed)
			local vel = self:getVelocity()
			if vel ~= V_ZERO then
				local dir = norm(vec(vel.x, vel.y, 0))
				self:setOrientation(quat(V_NORTH, dir))
			end
		end
    end;

	getTargetPosition = function(self)
		local inst = self.instance
		if inst.target ~= nil and not inst.target.destroyed then
			if inst.target.instance.body then
				return inst.target.instance.body.worldPosition
			elseif inst.target.instance.gfx then
				return inst.target.instance.gfx.localPosition
			end
		end
	end;
	
	getEyePosition = function(self)
		return self:getPosition() + vec(0, 0, 1)
	end;	

	canSee = function(self, target_pos)
		local ins = self.instance
		local pos = self:getEyePosition()

		local distance = #(target_pos - pos)
		
		if distance <= self.maxPerceptionDistance then
			local _, occ = physics_cast(pos, norm(target_pos - pos) * distance, true, 0, ins.body)

			if not occ then
				local p = pos + distance * norm(self:getOrientation() * V_NORTH)

				local angle = quat(p - pos, target_pos - pos).angle
				if angle <= self.maxPerceptionAngle then
					return true
				else
				end
			end
		end
		return false
	end;

	getAgentID = function(self)
		return self.instance.agentID
	end;
	
	setAgentID = function(self, id)
		self.instance.agentID = id
	end;
	
	restartAgent = function(self)
		if gge_navigation_navmesh_loaded() then
			if self.instance ~= nil and self:getAgentID() ~= -1 then
				gge_agent_destroy(self:getAgentID())
			end
			self:setAgentID(gge_agent_make(self:getPosition()-vec(0, 0, self.placementZOffset)))
		end
		
		-- callback
		if self.onRestartAgent then self:onRestartAgent() end
	end;		

	getDestination = function(self)
		return self.instance.destination
	end;	
	
	updateDestination = function(self, position, up_prev_path)
		local ins = self.instance
		if not self.activated then return end
		
		local new_dest, target_ref = gge_navigation_nearest_point_on_navmesh(position)
		if not new_dest or target_ref == 0 then return end
		
		gge_agent_move_target(self:getAgentID(), new_dest, up_prev_path)
		ins.destination = new_dest
		self.stopped = false
		self.velocity = V_ZERO
		
		-- callback
		if self.onUpdateDestination then self:onUpdateDestination() end
	end;

	destinationReached = function(self)
		local ins = self.instance
		if #(self:getPosition() - (ins.destination or V_ZERO)) <= ins.destinationRadius then return true end
		-- return gge_agent_distance_to_goal(self:getAgentID(), 0) < 0
	end;	
	
	teleport = function (self, position)
		local new_dest = gge_navigation_nearest_point_on_navmesh(position)
		if not new_dest then return end
		
		gge_agent_destroy(self:getAgentID())
		self:setAgentID(gge_agent_make(result_pos))
		
		self:setPosition(result_pos)
		
		-- callback
		if self.onTeleport then self:onTeleport() end
	end;
	
	isStuck = function(self)
		return false--(self:getSpeed() <= 2 and gge_agent_distance_to_goal(self:getAgentID(), 0) <= 5) -- TODO: get neighbours and its radius to set the value
	end;
	
	setOrientation = function(self, orient) -- gfx and collision only
		local ins = self.instance
		
		if ins.body then
			sins.body.worldOrientation = orient
		elseif ins.gfx then
			ins.gfx.localOrientation = orient
		end
	end;
	
	getOrientation = function(self)
		local ins = self.instance
		
		if ins.body then
			return ins.body.worldOrientation
		elseif ins.gfx then
			return ins.gfx.localOrientation
		end
	end;
	
	setPosition = function(self, pos) -- gfx and collision only
		local ins = self.instance
		
		if ins.body then
			ins.body.worldPosition = pos
		elseif ins.gfx then
			ins.gfx.localPosition = pos
		end
	end;
	
	getPosition = function(self)
		local ins = self.instance
		
		if ins.body then
			return ins.body.worldPosition
		elseif ins.gfx then
			return ins.gfx.localPosition
		end
	end;
	
	gotoState = function(self, state)
		self.instance.state_machine:gotoState(state)
	end;
	
	updatePosition = function(self, elapsed)
		if not self.activated then return end
		
		if gge_agent_active(self:getAgentID()) then
			self:setPosition(gge_agent_position(self:getAgentID())+vec(0, 0, self.placementZOffset))
		end
		
		if self.instance.destination then
			if self:destinationReached() and self.onDestinationReached then
				-- callback
				self:onDestinationReached()
			end
		end
	end;	
	
	setVelocity = function (self, vel)
		local ins = self.instance
		ins.manualVelocity = vel
		if vel ~= V_ZERO then
			ins.stopped = false
		end
		-- ins.destination = V_ZERO
		
		if self.activated then
			gge_agent_request_velocity(self:getAgentID(), ins.manualVelocity)
		end
	end;
	
	getVelocity = function (self)
		if not self.activated then
			return V_ZERO
		end
		return gge_agent_velocity(self:getAgentID())
	end;	
	
	getSpeed = function (self)
		return #self:getVelocity()
	end;
	
	isMoving = function (self)
		return self:getSpeed() ~= 0
	end;
	
	stop = function(self)
		local ins = self.instance

		if gge_agent_stop(self:getAgentID()) then
			ins.destination = nil
			ins.manualVelocity = V_ZERO
			ins.stopped = true
		end
		
		-- callback
		if self.onStop then self:onStop() end
	end;	
	
	getAgentHeight = function (self)
		return gge_agent_height(self:getAgentID())
	end;		
		
	getAgentRadius = function (self)
		return gge_agent_radius(self:getAgentID())
	end;
}
