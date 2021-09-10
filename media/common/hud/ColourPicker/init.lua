-- (c) David Cunningham 2014, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `.` {

    init = function (self)
        self.alpha = 0

        local on_change = function() self:childChanged() end

        local scalesz = vec(388,20)
        local labsz = vec(41,20)

        self.hueScale = hud_object `/common/hud/Scale` { onChange = on_change, size=scalesz, bgTexture=`bg_hue.png`,   bgColour=vec(1,1,1) }
        self.satScale = hud_object `/common/hud/Scale` { onChange = on_change, size=scalesz, bgColour=vec(1,0,0), mgTexture=`bg_sat.png`, mgAlpha=1 }
        self.valScale = hud_object `/common/hud/Scale` { onChange = on_change, size=scalesz, bgTexture=`bg_val.png`,   bgColour=vec(1,1,1), mgTexture=`bg_val_simple.png`, mgAlpha=0, mgColour=vec(1,1,1), gamma=true, maxValue=10 }
        self.aScale   = hud_object `/common/hud/Scale` { onChange = on_change, size=scalesz, mgTexture=`bg_alpha.png`, mgColour=vec(1,1,1), mgAlpha=1, bgColour=vec(1,1,1) }

        self.hueLabel = hud_object `/common/hud/Label` { size=labsz, value="Hue", alpha=0 }
        self.satLabel = hud_object `/common/hud/Label` { size=labsz, value="Sat", alpha=0 }
        self.valLabel = hud_object `/common/hud/Label` { size=labsz, value="Val", alpha=0 }
        self.aLabel = hud_object `/common/hud/Label` { size=labsz, value="Alpha", alpha=0 }

        self.contents = hud_object `/common/hud/StackY` {
            parent = self, 
            padding = -1,
            hud_object `/common/hud/StackX` { padding = -1, self.hueLabel, self.hueScale, },
            hud_object `/common/hud/StackX` { padding = -1, self.satLabel, self.satScale, },
            hud_object `/common/hud/StackX` { padding = -1, self.valLabel, self.valScale, },
            hud_object `/common/hud/StackX` { padding = -1, self.aLabel, self.aScale, },
        }

        self.size = self.contents.size

        self.greyed = not not self.greyed
        self.aGreyed = not not self.aGreyed
        self.hGreyed = not not self.hGreyed
        self.sGreyed = not not self.sGreyed
        self.vGreyed = not not self.vGreyed

    end;
    
    setGreyed = function (self, v)
        self.greyed = v
        self:updateAppearance()
    end;

    updateAppearance = function (self)
        self.hueScale:setGreyed(self.greyed or self.hGreyed)
        self.hueLabel:setGreyed(self.greyed or self.hGreyed)
        self.satScale:setGreyed(self.greyed or self.sGreyed)
        self.satLabel:setGreyed(self.greyed or self.sGreyed)
        self.valScale:setGreyed(self.greyed or self.vGreyed)
        self.valLabel:setGreyed(self.greyed or self.vGreyed)
        self.aScale:setGreyed(self.greyed or self.aGreyed)
        self.aLabel:setGreyed(self.greyed or self.aGreyed)
    end;

    destroy = function (self)
    end;

    updateBgColour = function (self)
        local hsv = self:getColourHSV()
        if hsv == nil then
            self.satScale:setBackgroundColour(vec(1,1,1))
            self.valScale:setBackgroundColour(vec(1,1,1))
            self.aScale:setBackgroundColour(vec(1,1,1))
        else
            self.satScale:setBackgroundColour(HSVtoRGB(vec(hsv.x, 1, 1)))
            self.valScale:setBackgroundColour(HSVtoRGB(vec3(hsv.xy, 1)))
            self.aScale:setBackgroundColour(HSVtoRGB(vec3(hsv.xy, math.min(1,hsv.z))))
        end
    end;
    
    childChanged = function (self)
        if self.contents == nil then return end
        self:updateBgColour()
        self:onChange()
    end;
    
    getColourHSV = function (self)
        if self.hGreyed or self.sGreyed or self.vGreyed then return nil end
        return vec(self.hueScale.value, self.satScale.value, self.valScale.value)
    end;
    getColourRGB = function (self)
        if self.hGreyed or self.sGreyed or self.vGreyed then return nil end
        return HSVtoRGB(self:getColourHSV())
    end;
    setColourRGB = function (self, c)
        self.valScale.maxValue = 10
        self.valScale:setMidgroundAlpha(0)
        self.valScale:setGamma(true)
        if c == nil then
            self.hGreyed = true
            self.sGreyed = true
            self.vGreyed = true
            self.hueScale:setValue(0)
            self.satScale:setValue(0)
            self.valScale:setValue(1)
        else
            local hsv = RGBtoHSV(c)
            self.hGreyed = false
            self.sGreyed = false
            self.vGreyed = false
            self.hueScale:setValue(hsv.x)
            self.satScale:setValue(hsv.y)
            self.valScale:setValue(hsv.z)
            self:updateBgColour()
        end
        self:updateAppearance()
    end;
    setValue = function (self, v, max_value)
        self.valScale.maxValue = max_value
        self.valScale:setMidgroundAlpha(1)
        self.valScale:setGamma(false)
        self.hGreyed = true
        self.sGreyed = true
        self.vGreyed = false
        self.aGreyed = true
        self.hueScale:setValue(0)
        self.satScale:setValue(0)
        self.valScale:setValue(v)
        self:updateBgColour()
        self:updateAppearance()
    end;
    getValue = function (self)
        if self.vGreyed then return nil end
        return self.valScale.value
    end;

    getAlpha = function (self)
        if self.aGreyed then return nil end
        return self.aScale.value
    end;
    setAlpha = function (self, a)
        if a == nil then
            self.aGreyed = true
            self.aScale:setValue(1)
        else
            self.aGreyed = false
            self.aScale:setValue(a)
            self:updateBgColour()
        end
        self:updateAppearance()
    end;
    
    onChange = function (self)
        gge_print("Colour: "..self:getColourRGB().."  Alpha: "..self:getAlpha())
    end;
    
}
