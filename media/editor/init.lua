include `map.lua`

-- Loads all editor configuration.  You can delete files in config/ and fall back to the default
-- configuration.
include `default_config/config.lua`
safe_include `config/config.lua`
include `default_config/interface.lua`
safe_include `config/interface.lua`
include `default_config/recent.lua`
safe_include `config/recent.lua`

include `widget_manager.lua`
include `init_editor_interface.lua`

include `game_mode.lua`

-- Temporary
-- Test navmesh
test = function()
    navigation_add_gfx_body(pick_obj().instance.gfx)
    navigation_update_params()
    navigation_build_nav_mesh()
end
-- Test navmesh
test2 = function()
    local objal = object_all()
    local gfxobjs = {}
    for i = 1, #objal do
        if not objal[i].destroyed and objal[i].instance ~= nil and objal[i].instance.gfx ~= nil then
            gfxobjs[#gfxobjs+1] = objal[i].instance.gfx
        end
    end
    
    navigation_add_gfx_bodies(gfxobjs)
    navigation_update_params()
    navigation_build_nav_mesh()
end
