------------------------------------------------------------------------------
--  File Dialog
--
--  (c) 2015 Augusto P. Moura (augustomoura94@hotmail.com)
--
--  Licensed under the MIT license:
--  http://www.opensource.org/licenses/mit-license.php
------------------------------------------------------------------------------

hud_class `window_editbox` (extends(table.extends(_gui.class, EditBoxClass))
{
	alpha = 1;
	
    textColour = _current_theme.colours.editbox.text;
    borderColour = _current_theme.colours.editbox.border;
	selectionColour = _current_theme.colours.editbox.selected_text_background;
	backgroundEditingColour = vec(0.5, 0.5, 0.5);
	
	backgroundHoverColour = vec(0.7, 0.7, 0.7);
	textEditingColour = vec(1, 1, 1);
	textHoverColour = vec(0.3, 0.3, 0.3);
	
    colour = _current_theme.colours.editbox.background;
    font = _current_theme.colours.editbox.font;
	texture = _current_theme.colours.editbox.texture;
	
	init = function (self)
		_gui.class.init(self)
		EditBoxClass.init(self)
	end;
	
	destroy = function (self)
		_gui.class.destroy(self)
		EditBoxClass.destroy(self)
	end;

	parentResizedCallback = function(self, psize)
		_gui.class.parentResizedCallback(self, psize)
		self:parentresizecb(psize)
	end;
	
	parentresizecb = function (self, psize)

	end;

    setEditing = function (self, editing, no_callback)
		EditBoxClass.setEditing(self, editing, no_callback)
    end;
})

function break_line(str, maxchar)
	return str:gsub('(\\s)', '\n')
end

hud_class `BrowserIcon` {
	alpha = 0;
	size = vec(64, 64);
	colour = vec(1, 0, 0);
	zOrder = 0;
	
	hoverColour = _current_theme.colours.browser_icon.hover;
	clickColour = _current_theme.colours.browser_icon.click;
	defaultColour = _current_theme.colours.browser_icon.default;
	selectedColour = _current_theme.colours.browser_icon.selected;
	textHoverColour = _current_theme.colours.browser_icon.text_hover;
	textClickColour = _current_theme.colours.browser_icon.text_click;
	textSelectedColour = _current_theme.colours.browser_icon.text_selected;
	textDefaultColour = _current_theme.colours.browser_icon.text_default;
	
	name = "Default";
	type = "";
	
	init = function (self)
		self.needsInputCallbacks = true
		self.icon = create_rect({
            texture = self.icon_texture,
            size = vec2(42, 42),
            parent = self,
            position = vec(0, 8),
        })
		self.text = gge_hud_text_add(`/common/fonts/TinyFont`)
		self.text.text = self.name
		if self.text.size.x >= self.size.x then
			-- gge_print("long name: "..self.name)
			-- self.text.text = self.name:reverse():sub(-9):reverse().."..."
			self.text.text = break_line(self.name)
			--self.name:reverse():gsub(".....", "...", 1):reverse()
		end
		self.text.position = vec2(0, -self.icon.size.y/2+5)
		self.text.parent = self
		self.text.colour = self.textDefaultColour
	end;
	
	destroy = function (self)
	end;
	
	mouseMoveCallback = function (self, local_pos, screen_pos, inside)
		self.inside = (
			inside and not (
				mouse_pos_abs.y > (self.parent.parent.derivedPosition.y + self.parent.parent.size.y/2) or
				mouse_pos_abs.y < (self.parent.parent.derivedPosition.y - self.parent.parent.size.y/2)
			)
		)

        local icon_flow = self.parent
		if not self.dragging and icon_flow.selected ~= self then
			if self.inside then
				self.colour = self.hoverColour
				self.alpha = 0.5
			else
				self.colour = self.defaultColour
				self.alpha = 0
			end
		end
	end;

    buttonCallback = function (self, ev)
        if ev == "+left" and self.inside then
			self.dragging = true
			self.colour = self.clickColour
			self.text.colour = self.textClickColour
			self.alpha = 1
			if self.lastClick ~= nil and gge_seconds() - self.lastClick <= 1 then
				self:doubleClick()
				return
			end
			self.lastClick = gge_seconds()
        elseif ev == "-left" then
            if self.dragging and not self.greyed then
				if self.inside then
                    -- Not sure if this is actually the icon_flow or the thing under it...
                    local icon_flow = self.parent
					if icon_flow.selected ~= self then
						self.colour = self.hoverColour
						self.text.colour = self.textHoverColour
					end
				
					if icon_flow.selected ~= self and icon_flow.selected ~= nil and icon_flow.selected.destroyed ~= true then
						icon_flow.selected.colour = icon_flow.selected.defaultColour
						icon_flow.selected.alpha = 0
					end
					icon_flow.selected = self
					self.colour = self.selectedColour
					self.text.colour = self.textSelectedColour

					self:pressedCallback()
				else
					self.colour = self.defaultColour
					self.text.colour = self.textDefaultColour
					self.alpha = 0
				end
			end
            self.dragging = false
        end
    end;

    pressedCallback = function (self)

    end;

	doubleClick = function(self)

	end;
}

hud_class `IconFlow` (extends(_gui.class)
{
	size = vec(0, 0);
	alpha = 1;
	icons_size = vec2(64, 64);
    icons_spacing = 4;
	colour = _current_theme.colours.file_explorer.background;
	
    init = function (self)
		_gui.class.init(self)
		self.needsParentResizedCallbacks = true
		self.items = {}
        self.selected = nil
    end;

	parentResizedCallback = function (self, psize)
		self.size = vec(psize.x, self.size.y)
        -- y component is now overwritten.
		self:reorganize()
	end;

	addIcon = function(self, new_icon)
        self.items[#self.items+1] = new_icon
        new_icon.parent = self
		self:reorganize()
	end;
	
	addItem = function(self, m_name, icon, pc, dpc)
        assert(icon ~= nil)
		local new_icon = hud_object `BrowserIcon` {
			icon_texture = icon;
			position = vec2(0, 0);
			parent = self;
			colour = vec(0.5, 0.5, 0.5);
			size = self.icons_size,
			name = m_name;
		}
		if pc ~= nil then
			new_icon.pressedCallback = pc
		end
		if dpc ~= nil then
			new_icon.doubleClick = dpc
		end

        self:addIcon(new_icon)

		return new_icon
	end;
	
    -- Set position of items to flow them into the available width.  Set height accordingly.
	reorganize = function(self)
		local columns = math.floor(self.size.x / (self.icons_size.x + self.icons_spacing))
		local icol, linepos, li = 1, 0, 1

		
		for i = 1, #self.items do
			self.items[i].position = vec(
                -self.size.x/2 + ((li-1) * (self.icons_size.x )) + (li*self.icons_spacing) + self.icons_size.x/2,
                self.size.y/2 - self.icons_size.y/2 - linepos*(self.icons_size.y+self.icons_spacing)
            )
			if icol < columns then
				li = li + 1
				icol = icol + 1
			else
				linepos = linepos+1
				icol = 1
				li = 1
			end
		end
		
        local height = self.size.y
        if columns > 0 then
            height = math.ceil(#self.items/columns)*(self.icons_size.y+self.icons_spacing)
        end
		self.iconarea = vec2(columns*(self.icons_size.x+self.icons_spacing), height)
		
		self.size = vec(self.size.x, self.iconarea.y)
		
		self:updateItems()
	end;

	clearAll = function(self)
		for i = 1, #self.items do
			safe_destroy(self.items[i])
			self.items[i] = nil
		end
	end;
	
	reset = function(self)
		self:reorganize()
	end;	

    -- Enable only the items which fit fully within our bounds.
	updateItems = function(self)
		for i = 1, #self.items do
			if ((self.items[i].position.y + self.items[i].size.y/2) + self.position.y < -self.parent.size.y/2 or
				(self.items[i].position.y - self.items[i].size.y/2) + self.position.y > self.parent.size.y/2
			) then
				self.items[i].enabled = false
			else
				self.items[i].enabled = true
			end
		end	
	end;
})

hud_class `FileDialog` `/common/gui/Window` {
	btn_size = vec(100, 25);
	
	choices = { "All Files (*.*)" };
	
	init = function (self)
		WindowClass.init(self)
		
		self.currentDir = "/";

		self.ok_button = gui.button({
			caption = "OK";
			parent = self.contentArea;
			pressedCallback = function ()
				self:handleCallback()
			end;
			cornered = true;
			texture = _gui_textures.button;
			align = vec(1, -1);
			offset = vec(-10, 45);
			padding = vec(30, 4);
			size = self.btn_size;
		})		
		self.cancel_button = gui.button({
			caption = "Cancel";
			parent = self.contentArea;
			pressedCallback = function ()
				self.enabled = false
			end;
			cornered = true;
			texture = _gui_textures.button;
			align = vec(1, -1);
			offset = vec(-10, 15);
			padding = vec(30, 4);
			size = self.btn_size;
		})		
		self.selectbox = gui.selectbox({
			parent = self.contentArea;
			choices = self.choices;
			selection = 0;
			align = vec(-1, -1);
			offset = vec(5, 20);
			expand_x = true;
			expand_offset = vec(-130, 0);
			size = vec(22, 22);
			zOrder = 4;
		})	
		self.selectbox.onSelect = function()
			self:update_file_explorer(self.currentDir)
		end;
		
		self.file_edbox = hud_object `window_editbox` {
			parent = self.contentArea;
			value = "";
			alignment = "LEFT";
			enterCallback = function()
				self:handleCallback()
			end;
			size = vec(50, 20);
			align = vec(-1, -1);
			offset = vec(5, 45);
			expand_x = true;
			expand_offset = vec(-130, 0);
			
		}
		self.file_edbox:setEditing(true)
		
        local file_dialog = self

		self.file_explorer = hud_object `IconFlow` {
			position = vec2(0, 0),
			parent = self.contentArea,
			size = vec2(self.size.x-20, self.size.y-120),
			alpha = 0,
			zOrder = 1,
		}

        self.scrollArea = hud_object `ScrollArea` {
            scrollX = false,
            content = self.file_explorer,
            scrollCallback = function (self)
                file_dialog.file_explorer:reset()
            end,
			stencil = true,
        }
        self.scrollAreaStretcher = hud_object `/common/hud/Stretcher` {
            child = self.scrollArea,
            parent = self.contentArea,
            calcRect = function(self, psize)
                return 115 - psize.x/2, 80 - psize.y/2, psize.x/2 - 5, psize.y/2 - 40
            end,
        }
		
		self.updir_btn = gui.imagebutton({
			pressedCallback = function(self)
                if file_dialog.currentDir == '/' then return end
                -- Strip off last dir.
				if file_dialog.currentDir:sub(-1) ~= "/" then file_dialog.currentDir = file_dialog.currentDir.."/" end
                file_dialog.currentDir = file_dialog.currentDir:match('(.*/)[^/]*/')
                file_dialog.dir_edbox:setValue(file_dialog.currentDir)
                file_dialog:update_file_explorer(file_dialog.currentDir)
			end;
			icon_texture = _gui_textures.arrow_up;
			parent = self.contentArea;
			colour = V_ID*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(15, -5);
			align = vec(-1, 1);
			zOrder = 4;
		})

		self.newfolder_btn = gui.imagebutton({
			pressedCallback = do_nothing;
			icon_texture = _gui_textures.new_folder;
			parent = self.contentArea;
			colour = V_ID*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(-35, -5);
			align = vec(1, 1);
		})

		self.iconsize_btn = gui.imagebutton({
			pressedCallback = do_nothing;
			icon_texture = `/common/gui/icons/help.png`;-- TODO: replace by a proper icon
			parent = self.contentArea;
			colour = V_ID*0.5;
			defaultColour = V_ID*0.5;
			hoverColour = V_ID*0.6;
			clickColour = V_ID*0.7;
			size = vec2(25, 25);
			offset = vec(-5, -5);
			align = vec(1, 1);
		})

		self.dir_edbox = hud_object `window_editbox` {
			parent = self.contentArea;
			value = self.currentDir;
			alignment = "LEFT";
			size = vec(50, 20);
			offset = vec(50, -8);
			align = vec(-1, 1);
			expand_x = true;
			expand_offset = vec(-120, 0);
		}
		self.dir_edbox.enterCallback = function(self)
            if self.value:sub(-1) ~= '/' then
                self:setValue(self.value .. '/')
            end
            file_dialog.currentDir = self.value
			file_dialog:update_file_explorer(self.value)
		end;
		
		self:update_file_explorer()
	end;
	
    -- Changes the active dir.
	update_file_explorer = function(self, m_dir)
		self.file_explorer:clearAll()
		self.file_explorer.selected = nil
		m_dir = m_dir or '/'
		local m_files, m_folders = get_dir_list(m_dir)

        local file_dialog = self

		for i = 1, #m_folders do
			local nit = self.file_explorer:addItem(m_folders[i], `/common/gui/icons/foldericon.png`)
			nit.type = "folder"
			nit.doubleClick = function(self)
				if file_dialog.currentDir:sub(-1) ~= "/" then
					file_dialog.currentDir = file_dialog.currentDir .. "/" .. self.name
				else
					file_dialog.currentDir = file_dialog.currentDir .. self.name
				end
				file_dialog.dir_edbox:setValue(file_dialog.currentDir)
				file_dialog:update_file_explorer(file_dialog.currentDir)
			end	
		end
		--local selext = self.selectbox.selected.name:sub(-5):gsub([[\)]], "", 1)	
		local selext = self.selectbox.selected.name:_match("%((.-)%)"):sub(3)
		
		for i = 1, #m_files do
			if get_extension(m_files[i]) == selext then
				local nit = nil
				
				nit = self.file_explorer:addItem(m_files[i], "/common/gui/icons/files/"..selext..".png")
				
				nit.type = "file"
				nit.pressedCallback = function (self)
					file_dialog.file_edbox:setValue(self.name)
				end;
				
				nit.doubleClick = function(self)
					file_dialog:handleCallback()
				end;
			end
		end

        self.scrollArea:setOffset(vec(0, 0))
        self.scrollArea:update()
        self.file_explorer:reset()
	end;

	handleCallback = function(self)
		if self.file_edbox.value ~= "" then
			local cd = self.currentDir
			-- remove the slash if it is the first character
			if cd:sub(1, 1) == "/" then
				cd = cd:sub(2)
			end
			
			-- add a slash if the last character isn't a slash
			if cd:sub(-1) ~= "/" and #cd > 0 then
				cd = cd.."/"
			end

			local filepath = cd..self.file_edbox.value

			local selext = self.selectbox.selected.name:_match("%((.-)%)"):sub(3)
			
			-- add the extension if the user forget it
			if get_extension(self.file_edbox.value) ~= selext then
				filepath = filepath.."."..selext
			end
			
			if self:callback(filepath) then
				self:destroy()
			end
		-- open the selected folder
		elseif self.file_explorer.selected ~= nil and self.file_explorer.selected.type == "folder" then
			self.file_explorer.selected:doubleClick()
		end
	end;
	callback = function(self, str)
		return true
	end;
}

_open_file_dialog = nil
_save_file_dialog = nil

function gui.file_dialog(options)
	local t_window = {}
	t_window = hud_object `FileDialog` (options)
	_windows[#_windows+1] = t_window
	return t_window
end

function gui.open_file_dialog(options)
	if _open_file_dialog ~= nil and not _open_file_dialog.destroyed then
		_open_file_dialog:destroy()
	end
	_open_file_dialog = gui.file_dialog(options)
	return _open_file_dialog
end

function gui.save_file_dialog(options)
	if _save_file_dialog ~= nil and not _save_file_dialog.destroyed then
		_save_file_dialog:destroy()
	end
	_save_file_dialog = gui.file_dialog(options)
	return _save_file_dialog
end
