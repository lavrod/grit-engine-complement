include `object_editor/init.lua`
include `map_editor/init.lua`
include `navigation_editor/init.lua`
include `debug_mode/init.lua`

hud_class `EditorInterface` `/common/gui/windownotebook` {
    init = function(self)
        self.needsInputCallbacks = true
        hud_class_get(`/common/gui/windownotebook`).init(self)
    end,
    mouseMoveCallback = function (self)
    end,
    buttonCallback = function (self, event)
        if event == '+left' then
            if hud_ray(mouse_pos_abs) == nil then
                game_manager.currentMode:leftMouseClick()
            end
        elseif event == '-left' then
            game_manager.currentMode:stopDraggingObj()
        end
    end,
}

editor_interface = editor_interface or nil

function make_editor_interface()
    editor_interface = hud_object `EditorInterface` { }

    editor_interface.map_editor_page = make_map_editor_page()
    editor_interface.navigation_editor = make_navigation_editor()

    -- add the button to the editor toolbar
    add_editor_tool("Navigation Editor", map_editor_icons.navigation, function(self) open_navigation_page() end)

    -- store temporary pages
    editor_interface.pagelist = {}
end


function new_object_ed_page(name, cntb, sel)
    editor_interface.pagelist[#editor_interface.pagelist+1] = ed_object_editor_page.new()
    editor_interface.pagelist[#editor_interface.pagelist].meshname = name
    editor_interface.pagelist[#editor_interface.pagelist].content_browser = cntb

    editor_interface.pagelist[#editor_interface.pagelist].button = editor_interface:addPage({
        caption = name,
        edge_colour = vec(0, 1, 1),
        page = editor_interface.pagelist[#editor_interface.pagelist],
        onSelect = function(self) self.page:select() end,
        onUnselect = function(self) self.page:unselect() end,
        onInit = function(self) self.page:init() end,
    })
    
    if sel then
        editor_interface.pagelist[#editor_interface.pagelist].button:select()
    end
end
