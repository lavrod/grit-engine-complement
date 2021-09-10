------------------------------------------------------------------------------
--  Notify
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

-- TODO: fix the problem with bad positioning when random timed notifies are stacked and disappearing shortly

hud_class `ntfmessage` {
	alpha = 0.7;
	size = vec(100, 30);
	colour = vec(0.9, 0.9, 0.9);
	cornered = true;
	texture = `/common/hud/CornerTextures/Filled04.png`;
	tableid = 0;
	speed = 5;
	timelimit = 3;
	currenttime = 0;
	
	init = function (self)
		self.text = hud_text_add(`/common/fonts/Verdana12`)
		self.text.parent = self
		self.text.text = self.value
		
		if self.text_colour ~= nil then
			self.text.colour = self.text_colour
		else
			if self.colour.x + self.colour.y + self.colour.z >= 1.5 then
				self.text.colour = vec(0, 0, 0)
			else
				self.text.colour = vec(1, 1, 1)
			end
		end
		
		self.size = vec(self.text.size.x + 20, self.size.y)
		self.position = vec(self.size.x/2, 0)

		self.needsFrameCallbacks = true
	end;
	
	moveTableIdsDown = function(self)
		for curtab=1,#ntfpanel.messages do
			ntfpanel.messages[curtab].tableid = ntfpanel.messages[curtab].tableid - 1
		end
	end;
	
	destroy = function (self)
		self.needsFrameCallbacks = false
		-- table.remove(ntfpanel.messages, self.tableid)
		-- self.moveTableIdsDown()
		
		ntfpanel.messages[self.tableid] = nil
		self:destroy()
	end;
	
	frameCallback = function (self, elapsed)
		if self.currenttime < self.timelimit then
			self.currenttime = self.currenttime + elapsed
			local distance = self.size.x - self.position.x
			self.position = vec(math.max(self.position.x - (elapsed * distance * self.speed), -self.size.x/2 - 10), (self.size.y * (#ntfpanel.messages - self.tableid)) * 1.2)
		else
			self.alpha = self.alpha - elapsed
			self.text.alpha = self.alpha
			if self.alpha <= 0 then
				self:destroy()
			end
		end
	end;
}

hud_class `notify_panel` {
	alpha = 0;
	size = vec(0, 0);

	init = function (self)
		self.messages = {}
	end;
	
	destroy = function (self)
		self.needsParentResizedCallbacks = false
		self:destroy()
	end;
		
	addMessage = function(self, msg, clr, text_clr, t_limit, b_alpha)
		self.messages[#self.messages+1] = hud_object `ntfmessage` {
			parent = self,
			position = vec2(0, 0),
			value = msg,
			colour = clr,
			text_colour = text_clr,
			tableid = #self.messages+1, -- this is probably the main problem
			alpha = b_alpha,
			timelimit = t_limit
		}
	end;
}

if ntfpanel ~= nil then safe_destroy(ntfpanel) end
ntfpanel = hud_object `notify_panel` { position = vec2(0, 50), parent = hud_bottom_right }

-- otherwise doesn't appear on top of the windows
hud_bottom_right.zOrder = 4

function notify(msg, clr, text_clr, tml, alp)
	if type(msg) == "string" then
		if clr == nil then
			clr = vec(0.9, 0.9, 0.9)
		end
		ntfpanel:addMessage(msg, clr, text_clr, tml or 3, alp or 0.7)
	end
end
