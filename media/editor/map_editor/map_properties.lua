hud_class `Expand_List_Item` {
    size = vec(300, 20);
    alpha = 1;
    items = {};
    colour = vec(0.2, 0.5, 0.2);
    default_value = "";
    name = "ItemName";
    
    init = function (self)  
        self.needsParentResizedCallbacks = true;
        --self.needsFrameCallbacks = true
        self.tt = nil
        self.rdt = 0
        self.time_since_last_update = 0
        --self.colour=random_colour()
        self.colour=vec(0.5, 0.5, 0.5)
        self.title_pos = hud_object `/common/hud/Positioner` {
            parent = self;
            offset = vec2(10, 0);
            factor = vec2(-0.5, 0);
        }
        self.title = gge_hud_text_add(`/common/fonts/Verdana12`)
        self.title.parent= self.title_pos
        self:setTitle(self.name)
        
        self.value = hud_object `/common/hud/EditBox` {
            value = "/.gmap";
            size = vec((self.size.x/2) - self.title.size.x+15,20);
            alignment = "LEFT";
            parent=self;
        }
        
        self.value:setValue(self.default_value)
        
        
        self.value.onEditting = function (self, editting)
            if editting == false then
                self.parent:entercallback()
            end
        end;
        
        -- self.value_pos = hud_object '/common/hud/Positioner' {
            -- parent = self;
            -- offset = vec2(-self.value .size.x/2-5, 0);
            -- factor = vec2(0.5, 0);
        -- }
        
        -- self.value.parent = self.value_pos 
        
    end;

    setTitle = function(self, name)
        self.title.text  = name
        self.title.position = vec2(self.title.size.x / 2, self.title.position.y)
    end;

    parentResizedCallback = function (self, psize)
        self.size = vec2(psize.x, self.size.y)
        self.value.size = vec((self.size.x/2) +15,20);
        self.value.border.size = vec((self.size.x/2)+15,20);
        self.value.position = vec2(-self.value.size.x/2+self.size.x/2, self.value.position.y)
        self.value.text.position = vec2(-self.value.size.x/2+self.value.text.size.x/2+4, self.value.text.position.y)
    end;
    
    frameCallback = function (self)
        --local state = (gge_seconds() % 5) / 0.5
        
        -- self.time_since_last_update = gge_seconds() - self.time_since_last_update
        -- self.tt = self.tt + self.time_since_last_update
        if(self.tt == nil) then
            self.tt = gge_seconds()
        end
        if (gge_seconds() - self.tt >= self.rdt) then
            self.colour=random_colour()
            if (self.colour.x+self.colour.y+self.colour.z  >= 1.5) then
                self.title.colour = vec(0, 0, 0)
                self.value.text.colour = vec(1, 1, 1)
            else
                self.title.colour = vec(1, 1, 1)
                self.value.text.colour = vec(0, 0, 0)
            end
            
            -- local blackorwhite = 0
            -- if self.colour.x + self.colour.y + self.colour.z <= 1.5 then
                -- blackorwhite = 1
            -- end
            -- self.value.colour = vec(blackorwhite, blackorwhite, blackorwhite)
            
            self.value.colour = math.abs(self.colour -1)
            self.tt = gge_seconds()
            self.rdt = math.random(10)
        end
    end;
}

hud_class `Expand_List` {
    size = vec(0, 0);
    alpha = 1;
    items = {};
    caption = "Expand";
    init = function (self)  
        self.needsParentResizedCallbacks = true;
        --self.needsInputCallbacks = false;
        self.items = {}
        
        self.base = create_rect({
            colour = vec(0.5, 0.5, 0.5),
            size = vec2(300, 20),
            parent=self,
            cornered = true;
        })
        self.base.texture = `/common/gui/icons/grad_notebook.png`;
        self.title_pos = hud_object `/common/hud/Positioner` {
            parent = self.base;
            offset = vec2(10, 0);
            factor = vec2(-0.5, 0);
        }
        self.title = gge_hud_text_add(`/common/fonts/Verdana12`)
        self.title.parent= self.title_pos
        self.title.text = self.caption
        self:setTitle(self.caption)

        -- TODO: Use /common/hud/Positioner instead of custom parentResizedCallback.
        self.expand_btn = hud_object `/common/hud/Button` {                
                caption = "-";
                padding = vec(8, 1);
                cornered = true;
                borderTexture = `/common/hud/CornerTextures/SquareBorderWhite.png`;
                needsParentResizedCallbacks = true;
                parentResizedCallback = function(self, psize) self.position = vec2(psize.x/2-self.size.x/2, self.position.y) end;
                backgroundPassiveColour = vec(0.2, 0.2, 0.2);
                backgroundHoverColour = vec(1, 0.5, 0);
                backgroundClickColour = vec(0.7, 0.3, 0);
        }
        self.expand_btn.texture = `/common/gui/icons/grad_notebook.png`
        self.expand_btn.border.enabled = false
        --self.expand_btn.texture = `../icons/invdeg.png`;
        --self.expand_btn.border.texture = nil
        --self.expand_btn.border.enabled=false
        self.expand_btn.border.colour=vec(1, 0.5, 0)
        self.expand_button_pos = hud_object `/common/hud/Positioner` {
            parent = self.base;
            offset = vec2(-self.expand_btn.size.x/2-5, 0);
            factor = vec2(0.5, 0);
        }
        
        self.expand_btn.parent = self.expand_button_pos 
        self.expand_btn.pressedCallback = function (self)
            if(self.parent.parent.parent.container.enabled)then
                self:setCaption("+")
                self.parent.parent.texture = `/common/gui/icons/grad_button.png`
            else
                self:setCaption("-")
                self.parent.parent.texture = `/common/gui/icons/grad_notebook.png`
            end
            self.parent.parent.parent:expand()
        end;

        self.container_pos = hud_object `/common/hud/Positioner` {
            parent = self.base;
            offset = vec2(0, -self.base.size.x/2);
            factor = vec2(0, -0.5);
        }
        
        self.container = create_rect({
            colour=vec(0.3, 0.3, 0.3);
            alpha = 1;
            parent = self.base;

            size=vec2(300, 300);
        })

    end;

    setTitle = function(self, name)
        self.title.text  = name
        self.title.position = vec2(self.title.size.x / 2, self.title.position.y)
    end;
    
    expand = function (self)
        self.container.enabled = not self.container.enabled
    end;
    
    reorganize = function (self)
        self.container.size = vec2(self.container.size.x, #self.items*22)
        self.container.position = vec(0, -self.container.size.y/2-self.base.size.y/2)
        local tii = -1
        for i = 1, #self.items do
            self.items[i].position = vec2(0, self.container.size.y/2-self.items[i].size.y/2+tii)
            tii = tii - 22
        end
    end;    
    
    addItem = function (self, nm, defvalue, ecallback)
        self.items[#self.items+1] = hud_object `Expand_List_Item` {
            parent = self.container,
            position = vec(0, (#self.items+1)*-22),
            name = nm,
            default_value = defvalue,
            entercallback = ecallback
        }
        self:reorganize()
        return self.items[#self.items]
    end;    
    
    parentResizedCallback = function (self, psize)
        self.base.size = vec2(psize.x-8, self.base.size.y)
        self.container.size = vec2(psize.x-8, self.container.size.y)
        self.position = vec2(0, self.parent.contentArea.size.y/2-self.parent.titleBar.size.y/2)
    end;
    
    mouseMoveCallback = function (self, local_pos, screen_pos, inside)
        self.inside = inside
        --if inside then gge_print("px") end
    end;

    btcallbacks = function(self)
    end;
    
    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
        end
        self:btcallbacks()
    end;
}

local function update_level_properties()
    if editor_ty.items[8] ~= nil then
        if editor_ty.items[1].value ~= hud_focus then
            editor_ty.items[1].value:setValue(current_map.name)
        end
        
        if editor_ty.items[2].value ~= hud_focus then
            editor_ty.items[2].value:setValue(current_map.author)
        end

        if editor_ty.items[3].value ~= hud_focus then
            editor_ty.items[3].value:setValue(current_map.description)
        end
        
        if editor_ty.items[4].value ~= hud_focus then
            editor_ty.items[4].value:setValue(('%.4f %.4f %.4f'):format(unpack(current_map.spawn.pos)))
        end
        if editor_ty.items[5].value ~= hud_focus then
            editor_ty.items[5].value:setValue(('%.4f %.4f %.4f %.4f'):format(unpack(current_map.spawn.rot)))
        end
        if editor_ty.items[6].value ~= hud_focus then
            editor_ty.items[6].value:setValue(tostring(env.clockRate))
        end
        
        if editor_ty.items[7].value ~= hud_focus then
            editor_ty.items[7].value:setValue(current_map.game_mode)
        end
        
        if current_map.include ~= nil and current_map.include[1] ~= nil then
            if editor_ty.items[8].value ~= hud_focus then
                editor_ty.items[8].value:setValue(current_map.include[1])
            end    
        end

        if current_map.include ~= nil and current_map.include[2] ~= nil then
            if editor_ty.items[9].value ~= hud_focus then
                editor_ty.items[9].value:setValue(current_map.include[2])
            end
        end
    end

end

editor_ty = editor_ty

function editor_init_windows()
    if editor_ty ~= nil then safe_destroy(editor_ty) end
    editor_ty = hud_object `Expand_List` {
        parent = editor_interface.map_editor_page.windows.level_properties,
        caption = "Common",
        needsInputCallbacks = true;
        btcallbacks = function(self)
            update_level_properties()
        end;
    }
    editor_ty.needsInputCallbacks = true

    editor_ty:addItem("Name: ", "Map name", function(self) current_map.name = self.value.value end)
    editor_ty:addItem("Author: ", "someone", function(self) current_map.author = self.value.value end)
    editor_ty:addItem("Description: ", "Description", function(self) current_map.description = self.value.value end)
    editor_ty:addItem("Clock Rate: ", "", function(self)
        if tonumber(self.value.value) ~= nil then
            env.clockRate = tonumber(self.value.value)
            current_map.clock_rate = tonumber(self.value.value)
        end
    end)
    editor_ty:addItem("Game Mode: ", "", function(self) current_map.game_mode = self.value.value end)
    editor_ty:addItem("Include1: ", "", function(self) current_map.include[1] = self.value.value end)
    editor_ty:addItem("Include2: ", "", function(self) current_map.include[2] = self.value.value end)
end
