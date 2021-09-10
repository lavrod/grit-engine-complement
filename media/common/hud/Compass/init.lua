-- (c) Alexey "Razzeeyy" Shmakov 2013, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- (c) Dave Cunningham and the Grit Game Engine Project, licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

hud_class `.` {
    size = vec(128, 128);
    alpha = 0;

    init = function (self)
        self.needsFrameCallbacks = true

        --pointer is the notch at the top of the compass that marks where you're looking
        self.pointer = hud_object `/common/hud/Rect` {texture=`Pointer.png`, zOrder=7}
        self.pointer.parent = self
        self.pointer.position = vec(0, self.size.y/2 - 24)

        -- compass orientation (what makes N point towards north) 
        self.ring = hud_object `/common/hud/Rect` {texture=`Body.png`, size=self.size}
        self.ring.parent = self

        --player denotes the player model direction (if any)
        self.player = hud_object `/common/hud/Rect` {texture=`Needle.png`}
        self.player.parent = self.ring


        --bearing displayed in degrees
        self.text = hud_text_add(`/common/fonts/TinyFont`)
        self.text.text = "XXX"
        self.text.parent = self
        self.text.position = vec(48, -50)
        self.text.colour = vec(0, 0, 0)

        local inner_sz = self.size - vec(20, 20)

        --the cardinal directions
        local cardinalLettersFont = `/common/fonts/misc.fixed`
        self.N = hud_text_add(cardinalLettersFont)
        self.N.text = "N"
        self.N.parent = self.ring
        self.N.colour = vec(0.8, 0, 0)
        self.N.position = inner_sz * vec (0, 0.5)
        self.N.inheritOrientation = false

        self.S = hud_text_add(cardinalLettersFont)
        self.S.text = "S"
        self.S.parent = self.ring
        self.S.colour = vec(0, 0, 0)
        self.S.position = inner_sz * vec (0, -0.5)
        self.S.inheritOrientation = false

        self.W = hud_text_add(cardinalLettersFont)
        self.W.text = "W"
        self.W.parent = self.ring
        self.W.colour = vec(0, 0, 0)
        self.W.position = inner_sz * vec (-0.5, 0)
        self.W.inheritOrientation = false

        self.E = hud_text_add(cardinalLettersFont)
        self.E.text = "E"
        self.E.parent = self.ring
        self.E.colour = vec(0, 0, 0)
        self.E.position = inner_sz * vec (0.5, 0)
        self.E.inheritOrientation = false
    end;
    destroy = function (self)
    end;
    frameCallback = function (self, elapsed)
        local orientation = -cam_yaw_angle()
        local o = nil -- TODO(dcunnin): this is a game mode thing, figure out how to reimplement it player_ctrl.controlObj
        if o and o.instance and o.instance.body then
            self.player.enabled = true
            local v = o.instance.body.worldOrientation*V_FORWARDS
            self.player.orientation = math.deg(math.atan2(v.x, v.y))
        else
            self.player.enabled = false
        end
        self.text.text = string.format("%03d",cam_yaw_angle() + 0.5)
        self.ring.orientation = orientation
    end;
}

