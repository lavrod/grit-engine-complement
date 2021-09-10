shader `Paint` {
    -- A noise texture, use the one provided.
    microFlakesMap = uniform_texture_2d(0, 0, 0),
    microFlakesMask = uniform_float(1);

    -- This map and mask control the mix of colours.  Each fragment has a blend of the 4 colours
    -- from the body.  If the map is not used, the whole material will have a solid blend.
    -- Note: The alpha channel is inverted (i.e. 0 means full colour3, 1 means no colour3).
    paintSelectionMap = uniform_texture_2d(1, 0, 0, 1),
    paintByDiffuseAlpha = static_float(0),
    
    diffuseMap = uniform_texture_2d(1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);

    normalMap = uniform_texture_2d(0.5, 0.5, 1);
    
    glossMap = uniform_texture_2d(1, 1, 1);
    glossMask = uniform_float(0);
    specularMask = uniform_float(0.04);

    emissiveMap = uniform_texture_2d(1, 1, 1);
    emissiveMask = uniform_float(0, 0, 0);

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
        var normal_ws = rotate_to_world(vert.normal.xyz);
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
    ]],
    
    dangsCode = [[
        var uv = vert.coord0.xy;
        var diff_texel = sample(mat.diffuseMap, uv);
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask;
        var gloss_texel = sample(mat.glossMap, uv);
        out.gloss = gloss_texel.b * mat.glossMask;
        out.specular = gamma_decode(gloss_texel.r) * mat.specularMask;

        var paint_selector = sample(mat.paintSelectionMap, uv);
        // Since textures without alpha channel have it set to 1.
        paint_selector.w = 1 - paint_selector.w;
        var paint_diffuse = paint_selector.x * body.paintDiffuse0
                          + paint_selector.y * body.paintDiffuse1
                          + paint_selector.z * body.paintDiffuse2
                          + paint_selector.w * body.paintDiffuse3;
        var paint_metallic = paint_selector.x * body.paintMetallic0
                           + paint_selector.y * body.paintMetallic1
                           + paint_selector.z * body.paintMetallic2
                           + paint_selector.w * body.paintMetallic3;
        var paint_specular = paint_selector.x * body.paintSpecular0
                        + paint_selector.y * body.paintSpecular1
                        + paint_selector.z * body.paintSpecular2
                        + paint_selector.w * body.paintSpecular3;
        var paint_gloss = paint_selector.x * body.paintGloss0
                        + paint_selector.y * body.paintGloss1
                        + paint_selector.z * body.paintGloss2
                        + paint_selector.w * body.paintGloss3;

        var micro_flakes_mask = 0.0;

        if (mat.paintByDiffuseAlpha > 0) {
            out.diffuse = lerp(paint_diffuse, out.diffuse, diff_texel.a);
            out.gloss = lerp(paint_gloss, out.gloss, diff_texel.a);
            out.specular = lerp(paint_specular, out.specular, diff_texel.a);
            micro_flakes_mask = lerp(paint_metallic, mat.microFlakesMask, diff_texel.a);
        } else {
            out.diffuse = out.diffuse * paint_diffuse;
            out.gloss = out.gloss * paint_gloss;
            out.specular = out.specular * paint_specular;
            micro_flakes_mask = mat.microFlakesMask * paint_metallic;
        }

        var scale = 16.0;
        var micro_flakes_uvw = scale * vert.position.xyz;
        var micro_flakes_uv = Float2(micro_flakes_uvw.x, mod(micro_flakes_uvw.y, 1.0) / 32 + floor(micro_flakes_uvw.y * 32) / 32);
        var microFlakes = sample(mat.microFlakesMap, micro_flakes_uv).r;
        microFlakes = micro_flakes_mask * pow(microFlakes, 3.0);
        out.gloss = out.gloss - microFlakes;
        out.specular = lerp(out.specular, 0.3, microFlakes);

        var normal_texel = sample(mat.normalMap, uv).xyz;
        var normal_ts = normal_texel * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;

    ]],

    additionalCode = [[
        var uv = vert.coord0.xy;
        var c = sample(mat.emissiveMap, uv);
        out.colour = gamma_decode(c.rgb) * mat.emissiveMask;
    ]],
}
