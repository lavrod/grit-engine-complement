-- (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `Clock` {

    init = function (self)
        self.alpha = 0
        self.needsFrameCallbacks = true
        self.needsInputCallbacks = true
        local font = `/common/fonts/Impact50`
        self.label = hud_text_add(font)
        self.label.parent = self
        self.label.letterTopColour=vec(0.6,0.6,0.6)
        self.label.letterBottomColour=vec(0.0,0.0,0)
        self.inside = false;
    end;

    destroy = function (self)
    end;

    frameCallback = function (self, elapsed)
        local secs = env.secondsSinceMidnight
        local t = self.label
        t:clear()
        t:append(format_time(env.secondsSinceMidnight))
        
    end;

    mouseMoveCallback = function (self, rel, abs, inside)
        self.inside = inside
    end;
    buttonCallback = function (self, key)
        if not self.inside then return end
        local interval = gge_input_filter_pressed("Shift") and 60*60 or 5*60
        if key == "+left" then
            env.secondsSinceMidnight = (env.secondsSinceMidnight - interval) % (24*60*60)
        elseif key == "+right" then
            env.secondsSinceMidnight = (env.secondsSinceMidnight + interval) % (24*60*60)
        elseif key == "+middle" then
            env.clockTicking = not env.clockTicking
        end
    end;
}
