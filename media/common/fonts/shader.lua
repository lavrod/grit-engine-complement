shader `Font` {

    diffuseMap = uniform_texture_2d(1, 1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);

    alphaMask = uniform_float(1);
    alphaRejectThreshold = uniform_float(-1);

    normalMap = uniform_texture_2d(0.5, 0.5, 1, 1);

    premultipliedAlpha = static_float(0);  -- Boolean

    emissiveMap = uniform_texture_2d(1, 1, 1);
    emissiveMask = uniform_float(0, 0, 0);
    emissiveVertex = static_float(0);  -- Boolean
    emissiveAlphaVertex = static_float(0);  -- Boolean

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
        var normal_ws = rotate_to_world(Float3(0, 0, 1));
        var tangent_ws = rotate_to_world(Float3(1, 0, 0));
        var binormal_ws = rotate_to_world(Float3(0, 1, 0));
    ]],

    dangsCode = [[
        var uv = vert.coord0.xy;
        var diff_texel = sample(mat.diffuseMap, uv);
        if (mat.premultipliedAlpha > 0) diff_texel = pma_decode(diff_texel);
        out.alpha = diff_texel.a * mat.alphaMask * vert.coord1.w;
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask * gamma_decode(vert.coord1.xyz);
        if (out.alpha <= mat.alphaRejectThreshold) discard;
        var normal_texel = sample(mat.normalMap, uv).xyz;
        var normal_ts = normal_texel * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
    ]],

    -- alphaMask is not used to attenuate the emissive lighting here, allowing you to use it
    -- to attenuate the diffuse component only, for glowing gasses, etc.
    additionalCode = [[
        var uv = vert.coord0.xy;
        var c = sample(mat.emissiveMap, uv);
        var mask = mat.emissiveMask * c.w * gamma_decode(vert.coord1.xyz) * vert.coord1.w;
        out.colour = gamma_decode(c.rgb) * mask;
    ]],
}
