gge_gfx_colour_grade(`neutral.lut.png`)
gge_gfx_fade_dither_map `stipple.png`

gge_gfx_register_shader(`Ball`, {
    tex = {
        uniformKind = "TEXTURE_CUBE",
    },
    vertexCode = [[
        var pos_os = vert.position.xyz;
        var normal_os = vert.normal.xyz;
        var normal_ws = rotate_to_world(vert.normal.xyz);
    ]],
    dangsCode = [[
        out.diffuse = 0;
        out.gloss = 0;
        out.specular = 0;
        out.normal = normal_ws;
    ]],
    additionalCode = [[
        out.colour = gamma_decode(sample(mat.tex, pos_os).xyz);
    ]],
})

gge_register_material(`Ball`, {
    shader = `Ball`,
    tex = `cube.dds`,
    additionalLighting = true,
})

b1 = gge_gfx_body_make(`Ball.mesh`)
b1.localPosition = vec(-2, 5, 0)
b1.localScale = vec(10, 10, 10)

b2 = gge_gfx_body_make(`Ball.mesh`)
b2.localPosition = vec(0, 5, 0)
b2.localScale = vec(10, 10, 10)

b3 = gge_gfx_body_make(`Ball.mesh`)
b3.localPosition = vec(2, 5, 0)
b3.localScale = vec(10, 10, 10)

gge_gfx_render(0.1, vec(0, 0, 0), quat(1, 0, 0, 0))
gge_gfx_screenshot('output-cubemap.png')
