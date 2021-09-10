-- (c) Al-x Spiker 2015, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local setting_height = 40
local setting_width = 400

hud_class `Vector2Edit` {
    alpha = 0,
    value = vec(0, 0),

    backgroundTexture = `/common/hud/CornerTextures/Filled02.png`;
    backgroundPassiveColour = vec(0.25, 0.25, 0.25);
    backgroundHoverColour = vec(0.5, 0.25, 0);
    backgroundEditingColour = vec(1, 0.5, 0);
    backgroundGreyedColour = vec(0.25, 0.25, 0.25);

    borderTexture = `/common/hud/CornerTextures/Border02.png`;
    borderPassiveColour = vec(0.6, 0.6, 0.6);
    borderHoverColour = vec(0.6, 0.6, 0.6);
    borderEditingColour = vec(0.6, 0.6, 0.6);
    borderGreyedColour = vec(0.6, 0.6, 0.6);

    font = `/common/fonts/Verdana12`;
    textPassiveColour = vec(0.7, 0.7, 0.7);
    textHoverColour = vec(0.7, 0.7, 0.7);
    textEditingColour = vec(0.7, 0.7, 0.7);
    textGreyedColour = vec(0.4, 0.4, 0.4);

    padding = 4,
    cornered = true,
    font = `/common/fonts/Verdana12`,
    editing = false,


    init = function (self)
        local function make_edit_box(v)
            return hud_object `/common/hud/EditBox` {
                alpha = self.alpha,
                colour = self.colour,

                number = true,
                value = tostring(v),
                size = vec(48, 32),
                maxLength = 5,

                padding = self.padding,

                cornered = self.cornered,
                backgroundTexture = `/common/hud/CornerTextures/Filled02.png`;
                backgroundPassiveColour = self.backgroundPassiveColour,
                backgroundHoverColour = self.backgroundHoverColour,
                backgroundEditingColour = self.backgroundEditingColour,
                backgroundGreyedColour = self.backgroundGreyedColour,

                borderTexture = `/common/hud/CornerTextures/Border02.png`;
                borderPassiveColour = self.borderPassiveColour,
                borderHoverColour = self.borderHoverColour,
                borderEditingColour = self.borderEditingColour,
                borderGreyedColour = self.borderGreyedColour,

                font = self.font,
                textPassiveColour = self.textPassiveColour,
                textHoverColour = self.textHoverColour,
                textEditingColour = self.textEditingColour,
                textGreyedColour = self.textGreyedColour,

            }
        end
        self.x = make_edit_box(self.value.x)
        self.x.enterCallback = function(self2)
            local num = math.floor(tonumber(self2.value) or 0)
            self:updateCallback(vec(num, self.value.y))
        end
        self.y = make_edit_box(self.value.y)
        self.y.enterCallback = function(self2)
            local num = math.floor(tonumber(self2.value) or 0)
            self:updateCallback(vec(self.value.x, num))
        end
        self.stack = hud_object `/common/hud/StackX` {
            parent = self,
            padding = 4,
            self.x,
            self.y,
        }
        self.size = self.stack.size
    end,

    setValue = function (self, v)
        self.x:setValue(tostring(v.x))
        self.y:setValue(tostring(v.y))
    end,

    updateCallback = function (self, v)
    end,
}

hud_class `SettingEdit` {

    settingName = "My Setting",
    settingType = { 'one of', false, true },
    settingValue = true,
    font = `/common/fonts/misc.fixed`,
    foregroundColour = vec(0.5, 0.5, 0.5),
    hoverColour = vec(0.875, 0.875, 0.875),
    clickColour = vec(1, 1, 1),

    settingChangedCallback = function (self, v)
        gge_error('No settingChangedCallback.')
    end,
    
    init = function (self)
        self.label = hud_object `/common/hud/Label` {
            alpha = 0,
            textColour = self.foregroundColour,
            font = self.font,
            value = self.settingName,
            size = vec(300, setting_height),
            alignment = 'LEFT',
            padding = 10,
        }

        if self.settingType[1] == 'one of' then
            if self.settingType[2] == false and self.settingType[3] == true then
                self.edit = hud_object `/common/hud/CheckBox` {

                    size = vec(32, 32),
                    alpha = 0,

                    borderPassiveColour = self.foregroundColour,
                    borderHoverColour = self.hoverColour,
                    borderClickColour = self.clickColour,

                    captionPassiveColour = self.foregroundColour,
                    captionHoverColour = self.hoverColour,
                    captionClickColour = self.clickColour,

                    checked = self.settingValue,

                    checkedCallback = function(self2, v)
                        self:settingChangedCallback(v)
                    end,
                }
            else
                local enum = {}
                local setting = nil
                for i = 2, #self.settingType do
                    enum[i - 1] = self.settingType[i]
                end
                self.edit = hud_object `/common/hud/EnumButton` {

                    size = vec(100, 32),
                    alpha = 0,
                    captionFont = `/common/fonts/Verdana12`,

                    borderPassiveColour = self.foregroundColour,
                    borderHoverColour = self.hoverColour,
                    borderClickColour = self.clickColour,

                    captionPassiveColour = self.foregroundColour,
                    captionHoverColour = self.hoverColour,
                    captionClickColour = self.clickColour,

                    enum = enum,
                    selected = self.settingValue,

                    updateCallback = function(self2, v)
                        self:settingChangedCallback(v)
                    end,
                }
            end
        elseif self.settingType[1] == 'range' or self.settingType[1] == 'int range' then
            local format = '%0.3f'
            local integer = false
            if self.settingType[1] == 'int range' then
                format = '%d'
                integer = true
            end
            self.edit = hud_object `/common/hud/Scale` {
                format = format,
                integer = integer,
                bgTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`,
                bgCornered = true,
                alpha = 0,
                size = vec(400, 32),
                bgColour = self.foregroundColour,
                value = self.settingValue,
                minValue = self.settingType[2],
                maxValue = self.settingType[3],
                textWidth = 100;

                textSeparation = 2,
                textBgAlpha = 0;

                textBorderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`,
                textBorderPassiveColour = self.foregroundColour,
                textBorderHoverColour = self.hoverColour,
                textBorderEditingColour = self.clickColour,

                textPassiveColour = self.foregroundColour,
                textHoverColour = self.hoverColour,
                textEditingColour = self.clickColour,

                onChange = function(self2, v)
                    self:settingChangedCallback(self2.value)
                end,
            }
        elseif self.settingType[1] == 'vector2' then
            self.edit = hud_object `Vector2Edit` {
                alpha = 0;
                value = self.settingValue,

                borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`,
                borderPassiveColour = self.foregroundColour,
                borderHoverColour = self.hoverColour,
                borderEditingColour = self.clickColour,

                textPassiveColour = self.foregroundColour,
                textHoverColour = self.hoverColour,
                textEditingColour = self.clickColour,


                updateCallback = function(self2, v)
                    self:settingChangedCallback(v)
                end,
            }
        else
            gge_error('Settings menu did not recognise setting type: ' .. self.settingType[1])
        end
        self.edit = self.edit or hud_object `/common/hud/Label` {
            alpha = 0,
            alignment = 'RIGHT',
            textPassiveColour = self.foregroundColour,
            font = `/common/fonts/Verdana12`,
            value = tostring(self.settingValue),
            size = vec(setting_width, setting_height),
            setValue = function (self, v)
                self.class.setValue(self, tostring(v))
            end,
        }

        self.stack = hud_object `/common/hud/StackX` {
            parent = self,
            padding = 0,
            self.label,
            vec(setting_width - self.edit.size.x, setting_height),
            self.edit,
            vec(4, setting_height),
        }

        self.size = self.stack.size
    end,

    setValue = function (self, v)
        self.edit:setValue(v)
    end,

}
