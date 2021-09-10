-- (c) The Grit Game Engine authors 2016, Licensed under the MIT license (https://goo.gl/YVVx3L).

local super = hud_class_get(`/common/hud/Button`)
hud_class `CheckBox` (super) {
    caption = 'X',
    size = vec(32, 32),
    checked = false,
    captionFont = `/common/fonts/VerdanaBold12`;
    borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`,

    init = function (self)
        super.init(self)
        self:updateCheck()
    end,
    updateCheck = function (self)
        self.text.enabled = self.checked
    end,
    pressedCallback = function (self)
        self.checked = not self.checked
        self:updateCheck()
        self:checkedCallback(self.checked)
    end,
    setValue = function (self, v)
        self.checked = v
        self:updateCheck()
    end,
    checkedCallback = function (self, v)
    end,
}
