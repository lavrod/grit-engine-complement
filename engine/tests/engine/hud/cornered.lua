gge_gfx_colour_grade(`neutral.lut.png`)
gge_gfx_option('POST_PROCESSING', false)

gge_gfx_hud_class_add(`Rect`, {
})

obj = gge_gfx_hud_object_add(`Rect`)
obj.position = vec(200, 100)  -- centre of object, from screen bottom left
obj.texture = `speech-bubble.png`
obj.size = vec(50, 50)
obj.cornered = true



gge_gfx_render(0.1, vec(0, 0, 0), quat(1, 0, 0, 0))
gge_gfx_screenshot('output-cornered.png')
