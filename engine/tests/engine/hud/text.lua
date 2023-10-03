gge_include `font_impact50.lua`
gge_gfx_colour_grade(`neutral.lut.png`)
gge_gfx_option('POST_PROCESSING', false)
t = gge_gfx_hud_text_add(`Impact50`)
t.text = "Some test text 123"
t.position = vec(200, 100)
gge_gfx_render(0.1, vec(0, 0, 0), quat(1, 0, 0, 0))
gge_gfx_screenshot('output-text.png')
