gge_gfx_colour_grade(`neutral.lut.png`)
gge_gfx_fade_dither_map `stipple.png`


gge_gfx_register_shader(`Money`, {
    tex = {
        uniformKind = "TEXTURE2D",
    },
    vertexCode = [[
        var normal_ws = rotate_to_world(vert.normal.xyz);
    ]],
    dangsCode = [[
        out.diffuse = sample(mat.tex, vert.coord0.xy).rgb;
        out.gloss = 0;
        out.specular = 0;
        out.normal = normal_ws;
    ]],
    additionalCode = [[
        // out.colour = sample(mat.tex, vert.coord0.xy).rgb;
        // out.colour = Float3(1, 1, 1);
    ]],
})

-- Used by Money.mesh.
gge_register_material(`Money`, {
    shader = `Money`,
    tex = `Money_d.dds`,
    additionalLighting = false,
})


gge_print("Loading Money_d.dds")
gge_disk_resource_load(`Money_d.dds`)
gge_print("Loading Money.mesh")
gge_disk_resource_load(`Money.mesh`)


gge_gfx_sunlight_direction(vec(0, 0, -1))
gge_gfx_sunlight_diffuse(vec(1, 1, 1))
gge_gfx_sunlight_specular(vec(1, 1, 1))


b = gge_gfx_instances_make(`Money.mesh`)
b.castShadows = false
b:add(vec(0, 0, 0), quat(1, 0, 0, 0), 1)
b:add(vec(0.4, 0, 0), quat(1, 0, 0, 0), 1)
b:add(vec(0, 0.4, 0), quat(1, 0, 0, 0), 1)
b:add(vec(0.4, 0.4, 0), quat(1, 0, 0, 0), 1)
b:add(vec(0.4, 0.8, 0), quat(0, 1, 0, 0), 1)
b:add(vec(0.8, 0.8, 0), quat(0, 1, 0, 0), 0.5)

-- b2 = gge_gfx_body_make(`Money.mesh`)
-- b2.castShadows = false

gge_gfx_render(0.1, vec(0.04362189, -0.9296255, 0.5302261), quat(0.9800102, -0.1631184, 0.01870036, -0.1123512))
gge_gfx_render(0.1, vec(0.04362189, -0.9296255, 0.5302261), quat(0.9800102, -0.1631184, 0.01870036, -0.1123512))

gge_gfx_screenshot('output.png')

