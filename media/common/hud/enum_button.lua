-- (c) The Grit Game Engine authors 2016, Licensed under the MIT license (https://goo.gl/YVVx3L).

local super = hud_class_get(`/common/hud/Button`)
hud_class `EnumButton` (super) {
    enum = {'1', '2', '3'},
    selected = '1',
    captionFont = `/common/fonts/VerdanaBold24`;
    borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`,

    init = function (self)
        super.init(self)
        self:updateEnum()
    end,
    updateEnum = function (self)
        self.text.text = self.selected
    end,
    getEnumIndex = function (self, text)
        local selected = nil
        for k, v in ipairs(self.enum) do
            if v == text then
                selected = k
            end
        end
        assert(selected ~= nil, 'Not a member of the enum: "' .. text .. '"')
        return selected
    end,
    pressedCallback = function (self)
        self.checked = not self.checked
        local selected = self:getEnumIndex(self.selected)
        selected = selected + 1
        if selected > #self.enum then selected = 1 end
        self.selected = self.enum[selected]
        self:updateEnum()
        self:updateCallback(self.selected)
    end,
    setValue = function (self, v)
        -- Assert it's valid.
        self:getEnumIndex(v)
        self.selected = v
        self:updateEnum()
    end,
    updateCallback = function (self, v)
    end,
}

