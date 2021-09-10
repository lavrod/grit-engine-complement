-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Rect` { }

-- An invisible object that always keeps a position within its parent's rectangle.
--
-- Set factor and offset to control the relative location.
hud_class `Positioner` {     
    size = vec(0, 0);    
    factor = vec(1, 1);
    offset = vec(0, 0);
    alpha = 0;
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;    
    end;    
    parentResizedCallback = function (self, psize)
        self.size = psize
        self.position = psize*self.factor + self.offset
    end;    
}   

-- An invisible object that resizes its child to a function of its parent's rectangle.
hud_class `Stretcher` {     
    alpha = 0;
    init = function (self)  
        self.needsParentResizedCallbacks = true;    
        self.child.parent = self
        self.child.size = self.size
    end;    
    -- Override this to specify a different rectangle within the parent.
    calcRect = function (self, psize)
        return 0, 0, psize.x, psize.y
    end;
    parentResizedCallback = function (self, psize)
        local l, b, r, t = self:calcRect(psize)
        self:setRect(l, b, r, t)
        self.child.size = self.size
    end;
}   

hud_centre = hud_centre or hud_object `Positioner` { factor = vec(0.5, 0.5) }
hud_bottom = hud_bottom or hud_object `Positioner` { factor = vec(0.5, 0) }
hud_bottom_left = hud_bottom_left or hud_object `Positioner` { factor = vec(0.0, 0.0) }
hud_bottom_right = hud_bottom_right or hud_object `Positioner` { factor = vec(1.0, 0.0) }
hud_top = hud_top or hud_object `Positioner` { factor = vec(0.5, 1.0) }
hud_top_left = hud_top_left or hud_object `Positioner` { factor = vec(0.0, 1.0) }
hud_top_right = hud_top_right or hud_object `Positioner` { factor = vec(1.0, 1.0) }

--[[ The focus is a simple concept:
- One hud_object at a time may have the focus.
- There is a callback for receiving / losing the focus.
]]
hud_focus = hud_focus or nil
function hud_focus_grab(v)
    if hud_focus ~= nil and not hud_focus.destroyed then
        hud_focus:setFocus(false)
    end
    hud_focus = v
    if hud_focus ~= nil then
        hud_focus:setFocus(true)
    end
end
