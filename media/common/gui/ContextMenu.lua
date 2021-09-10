safe_destroy(_context_menu)
_context_menu = {}

function show_context_menu(m_items)
	if _context_menu ~= nil and _context_menu.destroyed ~= nil then
		_context_menu:destroy()
	end
	_context_menu = hud_object `Menu` {
		colour = _current_theme.colours.context_menu.background,
		menu_item_colour = V_ID,
		menu_hoverColour = V_ID * 0.8,
		textColour = V_ZERO,
		menu_hoverTextColour = V_ID,
		cornered = false,
		alpha = _current_theme.colours.context_menu.alpha,
		position = vec(0, 0),
		items = m_items,
		zOrder = 10
	}
	_context_menu.position = mouse_pos_abs + vec2(_context_menu.size.x/2, -_context_menu.size.y/2)
	_context_menu.texture = nil
end;
