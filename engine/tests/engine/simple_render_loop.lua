gge_gfx_colour_grade(`neutral.lut.png`)
gge_gfx_option('POST_PROCESSING', true)
function dump(x)
    return tostring(x)
end
while not gge_clicked_close() do
    gge_gfx_render(0.1, vec(0, 0, 0), quat(1, 0, 0, 0))
end
