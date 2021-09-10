-- (c) Alexey "Razzeeyy" Shmakov 2014, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- HorizontalLine fills its parent horizontally but with the given thickness.
hud_class `HorizontalLine` {
    init = function (self)
        self.needsParentResizedCallbacks = true;
        self:setThickness(2);
    end;
    
    parentResizedCallback = function (self, psize)
        self.size = vec(psize.x, self.size.y);
    end;
    
    setThickness = function (self, width)
        self.size = vec(self.size.x, width);
    end;
    
    getThickness = function (self)
        return self.size.y;
    end;
}

-- VerticalLine fills its parent vertically but with the given thickness.
hud_class `VerticalLine` {
    init = function (self)
        self.needsParentResizedCallbacks = true;
        self:setThickness(2);
    end;
    
    parentResizedCallback = function (self, psize)
        self.size = vec(self.size.x, psize.y);
    end;
    
    setThickness = function (self, width)
        self.size = vec(width, self.size.y);
    end;
    
    getThickness = function (self)
        return self.size.x;
    end;
}
