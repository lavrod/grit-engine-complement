editor_themes = {}

-- local light_base = V_ID * 0.95
local light_base = V_ID * vec(0.97, 0.97, 0.95)
editor_themes['light'] =
{
	name = 'light';
	colours =
	{
		-- Menu bar
		menu_bar =
		{
			background = V_ID * light_base;
			background_alpha = 1;
			button = V_ID * 0.95;
			button_hover = V_ID * 1;
			button_pressed = V_ID * 0.3;
			button_border = V_ID * light_base;
			button_alpha = 0.5;
			button_caption = V_ID * 0.3;
			button_caption_greyed = V_ID * 0.9;
			button_caption_hover = V_ZERO;
			button_caption_pressed = V_ID;
		};
		-- Menu bar: menu
		menu =
		{
			background = V_ID;
			background_alpha = 1;
			item_background = V_ID;
			item_hover = V_ID * vec(0.7, 0.9, 1);
			item_text = V_ID*0.3;
			item_text_hover = V_ID;
			item_alpha = 0;
			line = V_ID * 0.8;
			icon = V_ID*0.5;
			icon_alpha = 0;
		};
		-- Tool bar
		tool_bar =
		{
			background = V_ID * light_base;
			alpha = 1;
			separator = V_ID * 0.1;
			separator_alpha = 0.3;
			icon = V_ID;
			icon_hover = vec(1, 0.8, 0.5);
			icon_pressed = vec(1, 0.5, 0);
		};
		tip =
		{
			background = vec(1, 1, 0.8);
			alpha = 1;
			text = V_ZERO;
		};
		status_bar =
		{
			background = V_ID * light_base;
			alpha = 1;
			text = V_ZERO;
			line = vec(1, 0.5, 0);
		};
		-- Window
		window =
		{
			background = V_ID * light_base;
			background_alpha = 0.7;
			titlebar_background = V_ID * 0.3;
			titlebar_background_alpha = 1;
			titlebar_background_inactive = V_ID * 1;
			titlebar_background_inactive_alpha = 1;
			titlebar_text = V_ID;
			titlebar_text_inactive = V_ZERO;
			border = V_ID * 0.6;
			border_alpha = 1;
			closebtn_base = V_ID * 0.3;
			closebtn_hover = V_ID * 0.45;
			closebtn_pressed = V_ID * 0.7;
		};
		checkbox = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};
		radiobutton = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};		
		context_menu = 
		{
			background = V_ID * light_base;
			alpha = 1;
		};
		button = 
		{
			base = V_ID * light_base*0.9;
			hover = V_ID * light_base*0.85;
			pressed = V_ID * light_base*0.75;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0.1;
			caption_hover = V_ID * 0;
			caption_pressed = V_ID * 0;
			caption_greyed = V_ID * 0.5;
			
			alpha = 1;
		};
		image_button = 
		{
			base = V_ID * 0.6;
			hover = vec(1, 0.8, 0.5);
			pressed = vec(1, 0.5, 0);
			greyed = V_ID * 0.5;
			
			active = vec(0.2, 0.7, 1);
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};		
		selectbox = 
		{
			base = V_ID* 1.5;
			hover = V_ID * 1.3;
			pressed = V_ID * 1;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0.3;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 0;
			caption_greyed = V_ID * 0.9;
			
			alpha = 1;
			
			icon = vec(1, 1, 1);
			icon_alpha = 1;
			icon_hover = vec(1, 0.7, 0.2);
			icon_pressed = vec(1, 0.5, 0);			
			
			menu_base = V_ID * 1;
			menu_alpha = 0;
			menu_hover =  V_ID * vec(0.7, 0.9, 1);
			menu_hover_alpha = 1;
			menu_text = V_ID*0;
			
		};		
		window_notebook = 
		{
			background = V_ID * light_base *  0.98;
			alpha = 1;
			
			texture = `/common/gui/icons/window_notebook_light.png`;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.95;
			btn_hover = V_ID * 0.99;
			btn_pressed = V_ID * 0.98;
			btn_selected = V_ID * 1;
			
			btn_caption = V_ID * 0.2;
			btn_caption_hover = V_ID * 0.3;
			btn_caption_pressed = V_ID * 0;
			btn_caption_selected = V_ID * 0;

			-- close btn
			close_btn_base = V_ID * 0.9;
			close_btn_hover = V_ID * 0.8;
			close_btn_pressed = V_ID * 0.5;
			close_btn_greyed = V_ID * 0.9;
			
			close_btn_caption_base = V_ID * 0.2;
			close_btn_caption_hover = V_ID * 0.1;
			close_btn_caption_pressed = V_ID * 1;
			close_btn_caption_greyed = V_ID * 0.1;			
			close_btn_alpha = 1;
		};
		notebook = 
		{
			background = V_ID * light_base;
			alpha = 0;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.9;
			btn_hover = V_ID * 0.95;
			btn_pressed = V_ID * 0.8;
			btn_selected = V_ID * light_base;
			
			btn_caption = V_ID * 0;
			btn_caption_hover = V_ID * 0.5;
			btn_caption_pressed = V_ID * 1;
			btn_caption_selected = V_ID * 0;
			
			menu_background = V_ID * 1;
		};
		scroll_bar = 
		{
			background = vec(0.2, 0.2, 0.2),
			backgroundHover = vec(0.15, 0.15, 0.15),
			bar = vec(0.7, 0.7, 0.7),
			barHover = vec(0.9, 0.9, 0.9),
			barHoverBar = vec(1, 1, 1),
			pressed = vec(1, 0.8, 0.5),
		};
		editbox = 
		{
			background = V_ID * light_base*0.95;
			text = V_ID*0;
			selected_text_background = vec(1, 0.9, 0.5);
			border = V_ID * 0.7;
			font = `/common/fonts/Verdana12`;
			texture = `/common/hud/CornerTextures/Filled02.png`;
		};
		file_explorer = 
		{
			background = V_ID * light_base*0.95;
		};
		browser_icon = 
		{
			hover = V_ID*0.7;
			click = V_ID*0.9;
			default = V_ID*0.5;
			selected = V_ID*0.6;
			text_hover = V_ID * 0;
			text_click = V_ID * 0;
			text_selected = V_ID * 0;
			text_default = V_ID * 0;
		};
		text = 
		{
			default = V_ID*0.3;
		};
		floating_panel = {
			background = V_ZERO;
			alpha = 0.7;
			texture = `/common/hud/CornerTextures/Filled08.png`;
		};
	};
	fonts =
	{
		default = `/common/fonts/Arial12`;
		
		menu_bar =
		{
			button = `/common/fonts/Arial12`;
			menu = `/common/fonts/Arial12`;
		};
		
		checkbox = `/common/fonts/Arial12`;
		
		radiobutton = `/common/fonts/Arial12`;
		
		button = `/common/fonts/Verdana12`;
		
		window_notebook = 
		{
			closebtn = `/common/fonts/Arial12`;
			button = `/common/fonts/Arial14`;
			button_selected = `/common/fonts/ArialBold14`;
		};
	};
};

editor_themes['dark'] =
{
	name = 'dark';
	colours =
	{
		-- Menu bar
		menu_bar =
		{
			background = V_ID * 0;
			background_alpha = 0.5;
			button = V_ID * 0.4;
			button_hover = V_ID * 0.6;
			button_pressed = V_ID * 0.8;
			button_border = V_ID * 0.4;
			button_alpha = 0.5;
			button_caption = V_ID * 0.85;
			button_caption_greyed = V_ID * 0.4;
			button_caption_hover = V_ID;
			button_caption_pressed = V_ZERO;
		};
		-- Menu bar: menu
		menu =
		{
			background = V_ID * 1;
			background_alpha = 1;
			item_background = V_ID;
			item_hover = V_ID * 0.95;
			item_text = V_ID * 0.3;
			item_text_hover = V_ID * 0;
			item_alpha = 0;
			line = V_ID * 0;
			icon = V_ID * 0.6;
			icon_alpha = 0;
		};
		-- Tool bar
		tool_bar =
		{
			background = V_ID * 0;
			alpha = 0.5;
			separator = V_ID * 0.9;
			separator_alpha = 0.3;
			icon = V_ID;
			icon_hover = vec(1, 0.7, 0.4);
			icon_pressed = vec(1, 0.5, 0);
		};
		tip =
		{
			background = vec(1, 1, 0.8);
			alpha = 1;
			text = V_ZERO;
		};
		status_bar =
		{
			background = V_ID * 0;
			alpha = 0.5;
			text = V_ID;
			line = vec(1, 0.5, 0);
		};
		-- Window
		window =
		{
			background = V_ID * 0.4;
			background_alpha = 0.7;
			titlebar_background = V_ID*0.2;
			titlebar_background_alpha = 1;
			titlebar_background_inactive = V_ID * 0.3;
			titlebar_background_inactive_alpha = 1;
			titlebar_text = V_ID;
			titlebar_text_inactive = V_ID*0.7;
			border = V_ID * 0.6;
			border_alpha = 1;
			closebtn_base = V_ID * 0.3;
			closebtn_hover = V_ID * 0.45;
			closebtn_pressed = V_ID * 0.7;
		};
		checkbox = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};
		radiobutton = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};		
		context_menu = 
		{
			background = V_ID;
			alpha = 1;
		};
		button = 
		{
			base = V_ID;
			hover = V_ID * 0.45;
			pressed = V_ID * 0.15;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};
		image_button = 
		{
			base = V_ID;
			hover = vec(1, 0.8, 0.5);
			pressed = vec(1, 0.5, 0);
			greyed = V_ID * 0.5;
			
			active = vec(0.2, 0.7, 1);
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};		
		selectbox = 
		{
			base = V_ID* 0.45;
			hover = V_ID * 0.6;
			pressed = V_ID * 0.3;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0.9;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
			
			icon = vec(1, 1, 1);
			icon_alpha = 1;
			icon_hover = vec(1, 0.7, 0.2);
			icon_pressed = vec(1, 0.5, 0);			
			
			menu_base = V_ID;
			menu_alpha = 0;
			menu_hover = vec(1, 0.9, 0.5);
			menu_hover_alpha = 1;
			menu_text = V_ZERO;
			
		};		
		window_notebook = 
		{
			background = V_ID * 0;
			alpha = 0.5;
		
			texture = `/common/gui/icons/window_notebook_dark.png`;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.35;
			btn_hover = V_ID * 0.4;
			btn_pressed = V_ID * 0.45;
			btn_selected = V_ID * 0.45;
			
			btn_caption = V_ID * 0.8;
			btn_caption_hover = V_ID * 1;
			btn_caption_pressed = V_ID * 0;
			btn_caption_selected = V_ID * 1;

			-- close btn
			close_btn_base = V_ID * 0.9;
			close_btn_hover = V_ID * 0.8;
			close_btn_pressed = V_ID * 0.5;
			close_btn_greyed = V_ID * 0.9;
			
			close_btn_caption_base = V_ID * 0.2;
			close_btn_caption_hover = V_ID * 0.1;
			close_btn_caption_pressed = V_ID * 1;
			close_btn_caption_greyed = V_ID * 0.1;			
			close_btn_alpha = 1;
		};
		notebook = 
		{
			background = V_ID * 0.3;
			alpha = 0;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.45;
			btn_hover = V_ID * 0.6;
			btn_pressed = V_ID * 0.5;
			btn_selected = V_ID * 0.3;
			
			btn_caption = V_ID * 0.8;
			btn_caption_hover = V_ID * 1;
			btn_caption_pressed = V_ID * 0.85;
			btn_caption_selected = V_ID * 1;

			menu_background = V_ID * 0.3;
		};
		scroll_bar = 
		{
			background = vec(0.2, 0.2, 0.2),
			backgroundHover = vec(0.15, 0.15, 0.15),
			bar = vec(0.7, 0.7, 0.7),
			barHover = vec(0.9, 0.9, 0.9),
			barHoverBar = vec(1, 1, 1),
			pressed = vec(1, 0.8, 0.5),
		};
		editbox = 
		{
			background = V_ID * 0.9;
			text = V_ID*0.1;
			selected_text_background = vec(1, 0.9, 0.5);
			border = V_ID * 0.9;
			font = `/common/fonts/Verdana12`;
			texture = `/common/hud/CornerTextures/Filled02.png`;
		};
		file_explorer = 
		{
			background = V_ID * 0.5;
		};
		browser_icon = 
		{
			hover = V_ID*0.7;
			click = V_ID*0.9;
			default = V_ID*0.5;
			selected = V_ID*0.6;
			text_hover = V_ID * 1;
			text_click = V_ID * 0;
			text_selected = V_ID * 1;
			text_default = V_ID * 1;
		};
		text = 
		{
			default = V_ID;
		};
		floating_panel = {
			background = V_ZERO;
			alpha = 0.7;
			texture = `/common/hud/CornerTextures/Filled08.png`;
		};	
	};
	fonts =
	{
		default = `/common/fonts/Verdana12`;
		
		menu_bar =
		{
			button = `/common/fonts/Arial12`;
			menu = `/common/fonts/Arial12`;
		};
		
		checkbox = `/common/fonts/Arial12`;
		
		radiobutton = `/common/fonts/Arial12`;
		
		button = `/common/fonts/Verdana12`;
		
		window_notebook = 
		{
			closebtn = `/common/fonts/Arial12`;
			button = `/common/fonts/Arial14`;
			button_selected = `/common/fonts/ArialBold14`;
		};
	};
}


editor_themes['Dark Magenta'] = {
	name = 'Dark Magenta';
	colours =
	{
		-- Menu bar
		menu_bar =
		{
			background = V_ID * 0;
			background_alpha = 0.5;
			button = V_ID * 0.3;
			button_hover = V_ID * 0.6;
			button_pressed = vec(1, 0.5, 1);
			button_border = vec(1, 0, 1)*0.7;
			button_alpha = 0.7;
			button_caption = vec(1, 0.5, 1);
			button_caption_greyed = V_ID * 0.4;
			button_caption_hover = V_ID;
			button_caption_pressed = V_ZERO;
		};
		-- Menu bar: menu
		menu =
		{
			background = V_ID * 0.3;
			background_alpha = 1;
			item_background = vec(1, 0.5, 1);
			item_hover = vec(1, 0.5, 1);
			item_text = vec(1, 0, 1);
			item_text_hover = vec(0, 0, 0);
			item_alpha = 0;
			line = vec(1, 0, 1);
			icon = V_ID;
			icon_alpha = 0;
		};
		-- Tool bar
		tool_bar =
		{
			background = V_ID * 0;
			alpha = 0.5;
			separator = V_ID * 0.9;
			separator_alpha = 0.3;
			icon = V_ID;
			icon_hover = vec(1, 0.5, 1);
			icon_pressed = vec(1, 0, 1);
		};
		tip =
		{
			background = vec(1, 1, 0.8);
			alpha = 1;
			text = V_ZERO;
		};
		status_bar =
		{
			background = V_ID * 0.35;
			alpha = 1;
			text = V_ID;
			line = vec(1, 0.5, 0);
		};
		-- Window
		window =
		{
			background = V_ID * 0.4;
			background_alpha = 0.7;
			titlebar_background = V_ID*0.2;
			titlebar_background_alpha = 1;
			titlebar_background_inactive = V_ID * 0.7;
			titlebar_background_inactive_alpha = 1;
			titlebar_text = V_ID;
			titlebar_text_inactive = V_ID*0.3;
			border = V_ID * 0.6;
			border_alpha = 1;
			closebtn_base = V_ID * 0.3;
			closebtn_hover = V_ID * 0.45;
			closebtn_pressed = V_ID * 0.7;
		};
		checkbox = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};
		radiobutton = 
		{
			background = V_ID;
			alpha = 0;
			icon = vec(0.2, 1, 0);
		};		
		context_menu = 
		{
			background = V_ID;
			alpha = 1;
		};
		button = 
		{
			base = V_ID;
			hover = V_ID * 0.45;
			pressed = V_ID * 0.15;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};
		image_button = 
		{
			base = V_ID;
			hover = vec(1, 0, 1);
			pressed = vec(1, 0.3, 1);
			greyed = V_ID * 0.5;
			
			active = vec(1, 0, 1);
			
			caption_base = V_ID * 0;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
		};		
		selectbox = 
		{
			base = V_ID* 0.45;
			hover = V_ID * 0.6;
			pressed = V_ID * 0.3;
			greyed = V_ID * 0.5;
			
			caption_base = V_ID * 0.9;
			caption_hover = V_ID * 1;
			caption_pressed = V_ID * 1;
			caption_greyed = V_ID * 0.1;
			
			alpha = 1;
			
			icon = vec(1, 1, 1);
			icon_alpha = 1;
			icon_hover = vec(1, 0.7, 0.2);
			icon_pressed = vec(1, 0.5, 0);			
			
			menu_base = V_ID;
			menu_alpha = 0;
			menu_hover = vec(1, 0.9, 0.5);
			menu_hover_alpha = 1;
			menu_text = V_ZERO;
			
		};		
		window_notebook = 
		{
			background = V_ID * 0;
			alpha = 0.5;
		
			texture = `/common/gui/icons/window_notebook_dark.png`;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.35;
			btn_hover = V_ID * 0.4;
			btn_pressed = V_ID * 0.45;
			btn_selected = V_ID * 0.45;
			
			btn_caption = V_ID * 0.8;
			btn_caption_hover = V_ID * 1;
			btn_caption_pressed = V_ID * 0;
			btn_caption_selected = V_ID * 1;

			-- close btn
			close_btn_base = V_ID * 0.9;
			close_btn_hover = V_ID * 0.8;
			close_btn_pressed = V_ID * 0.5;
			close_btn_greyed = V_ID * 0.9;
			
			close_btn_caption_base = V_ID * 0.2;
			close_btn_caption_hover = V_ID * 0.1;
			close_btn_caption_pressed = V_ID * 1;
			close_btn_caption_greyed = V_ID * 0.1;			
			close_btn_alpha = 1;
		};
		notebook = 
		{
			background = V_ID * 0.3;
			alpha = 0;
		
			-- button
			btn_alpha = 1;
			
			btn_base = V_ID * 0.45;
			btn_hover = V_ID * 0.6;
			btn_pressed = V_ID * 0.5;
			btn_selected = V_ID * 0.3;
			
			btn_caption = V_ID * 0.8;
			btn_caption_hover = V_ID * 1;
			btn_caption_pressed = V_ID * 0.85;
			btn_caption_selected = V_ID * 1;

			menu_background = V_ID * 0.3;
		};
		scroll_bar = 
		{
			background = vec(0.2, 0.2, 0.2),
			backgroundHover = vec(0.15, 0.15, 0.15),
			bar = vec(0.7, 0.7, 0.7),
			barHover = vec(0.9, 0.9, 0.9),
			barHoverBar = vec(1, 1, 1),
			pressed = vec(1, 0.8, 0.5),
		};
		editbox = 
		{
			background = V_ID * 0.3;
			text = V_ID;
			selected_text_background = vec(1, 0.9, 0.5);
			border = V_ID * 0.2;
			font = `/common/fonts/Verdana12`;
			texture = `/common/hud/CornerTextures/Filled02.png`;
		};
		file_explorer = 
		{
			background = V_ID * 0.5;
		};
		browser_icon = 
		{
			hover = V_ID*0.7;
			click = V_ID*0.9;
			default = V_ID*0.5;
			selected = V_ID*0.6;
			text_hover = V_ID * 1;
			text_click = V_ID * 0;
			text_selected = V_ID * 1;
			text_default = V_ID * 1;
		};
		text = 
		{
			default = V_ID;
		};
		floating_panel = {
			background = V_ZERO;
			alpha = 0.7;
			texture = `/common/hud/CornerTextures/Filled08.png`;
		};		
	};
	fonts =
	{
		default = `/common/fonts/Verdana12`;
		
		menu_bar =
		{
			button = `/common/fonts/Verdana12`;
			menu = `/common/fonts/Arial12`;
		};
		
		checkbox = `/common/fonts/Arial12`;
		
		radiobutton = `/common/fonts/Arial12`;
		
		button = `/common/fonts/Verdana12`;
		
		window_notebook = 
		{
			closebtn = `/common/fonts/Arial12`;
			button = `/common/fonts/Arial14`;
			button_selected = `/common/fonts/ArialBold14`;
		};
	};
}

-- it's a handwritten file
gge_safe_include `/editor/config/custom_themes.lua`

gge_safe_include `/editor/config/interface.lua`

if editor_interface_cfg ~= nil and editor_themes[editor_interface_cfg.theme] ~= nil then
	_current_theme = editor_themes[editor_interface_cfg.theme]
else
	_current_theme = editor_themes['dark']
end
