------------------------------------------------------------------------------
--  A draggable square
--
--  (c) 2014 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

DraggableClass =  {
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	colour = vector3(1, 1, 1);
	dragging = false;
	draggingPos = vec2(0, 0);

	init = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = true
	end;
	destroy = function (self)
		self.needsFrameCallbacks = false
		self.needsInputCallbacks = false
		
		self:destroy()
	end;
	frameCallback = function (self, elapsed)
		
	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
		
		if self.dragging == true then			
			self.position = mouse_pos_abs.y - self.draggingPos
		end
    end;
	
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.draggingPos = mouse_pos_abs - self.position
		elseif ev == "-left" then
			self.dragging = false
			self.draggingPos = vec2(0, 0)
        end
    end;
}

hud_class `Draggable` (extends(DraggableClass)
{
	alpha = 1;
	size = vec(256, 256);
	zOrder = 0;
	colour = vector3(1, 0, 0);

	init = function (self)
		DraggableClass.init(self)
	end;
	
	destroy = function (self)

	end;

    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		DraggableClass.mouseMoveCallback(self, local_pos, screen_pos, inside)
    end;
	
    buttonCallback = function (self, ev)
		DraggableClass.buttonCallback(self, ev)
    end;
})