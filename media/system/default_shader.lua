-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

shader `Default` {

    textureAnimation = uniform_float(0, 0);
    textureScale = uniform_float(1, 1);

    diffuseMap = uniform_texture_2d(1, 1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);
    diffuseVertex = static_float(0);  -- Boolean

    alphaMask = uniform_float(1);
    alphaVertex = static_float(0);  -- Boolean
    alphaRejectThreshold = uniform_float(-1);

    normalMap = uniform_texture_2d(0.5, 0.5, 1, 1);

    glossMap = uniform_texture_2d(1, 1, 1);
    glossMask = uniform_float(0);
    specularMask = uniform_float(0.04);
    premultipliedAlpha = static_float(0);  -- Boolean

    emissiveMap = uniform_texture_2d(1, 1, 1);
    emissiveMask = uniform_float(0, 0, 0);
    emissiveVertex = static_float(0);  -- Boolean
    emissiveAlphaVertex = static_float(0);  -- Boolean

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
        var normal_ws = rotate_to_world(vert.normal.xyz);
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
    ]],

    dangsCode = [[
        var uv = vert.coord0.xy * mat.textureScale + global.time * mat.textureAnimation;
        var diff_texel = sample(mat.diffuseMap, uv);
        if (mat.premultipliedAlpha > 0) diff_texel = pma_decode(diff_texel);
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask;
        if (mat.diffuseVertex > 0) out.diffuse = out.diffuse * gamma_decode(vert.colour.xyz);
        out.alpha = diff_texel.a * mat.alphaMask;
        if (mat.alphaVertex > 0) out.alpha = out.alpha * vert.colour.w;
        if (out.alpha <= mat.alphaRejectThreshold) discard;
        var normal_texel = sample(mat.normalMap, uv).xyz;
        var normal_ts = normal_texel * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
        var gloss_texel = sample(mat.glossMap, uv);
        out.gloss = gloss_texel.b * mat.glossMask;
        out.specular = gamma_decode(gloss_texel.r) * mat.specularMask;
    ]],

    -- alphaMask is not used to attenuate the emissive lighting here, allowing you to use it
    -- to attenuate the diffuse component only, for glowing gasses, etc.
    additionalCode = [[
        var uv = vert.coord0.xy * mat.textureScale + global.time * mat.textureAnimation;
        var c = sample(mat.emissiveMap, uv);
        var mask = mat.emissiveMask * c.w;
        if (mat.emissiveVertex > 0) mask = mask * gamma_decode(vert.colour.xyz);
        if (mat.emissiveAlphaVertex > 0) mask = mask * vert.colour.w;
        out.colour = gamma_decode(c.rgb) * mask;
    ]],
}

--[=[
shader `Particle` {

    gbuffer0 = uniform_texture_2d(1, 1, 1);
    particleAtlas = uniform_texture_2d(0.5, 0.5, 1);

    vertexCode = [[
        var part_basis_x = vert.coord0.xyz;
        var part_half_depth = vert.coord1.x;
        var part_basis_z = vert.coord2.xyz;
        var part_pos = vert.coord3.xyz;
        var part_diffuse = vert.coord4.xyz;
        var part_alpha = vert.coord5.x;
        var part_emissive = vert.coord6.xyz;

        var fragment_uv = lerp(vert.coord7.xy, vert.coord7.zw,
                               vert.position.xz / Float2(2, -2) + Float2(0.5, 0.5));

        var part_colour = global.particleAmbient * part_diffuse + part_emissive;

        out.position = vert.position.x * part_basis_x
                     + vert.position.z * part_basis_z
                     + part_pos;

        var camera_to_fragment = out.position - global.cameraPos;
    ]],

    additionalCode = [[
        var uv = frag.screen / global.viewportSize;
        uv.y = 1 - uv.y;  // Textures addressed from top left, frag.screen is bottom left
        var ray = lerp(lerp(global.rayBottomLeft, global.rayBottomRight, uv.x),
                       lerp(global.rayTopLeft, global.rayTopRight, uv.x),
                       uv.y);

        var bytes = sample(mat.gbuffer0, uv).xyz;
        var normalised_cam_dist = 255.0 * (256.0*256.0*bytes.x + 256.0*bytes.y + bytes.z)
                                        / (256.0*256.0*256.0 - 1);

        var scene_dist = length(normalised_cam_dist * ray);
        var fragment_dist = length(camera_to_fragment);
        var part_exposed = (scene_dist - fragment_dist + part_half_depth)
                           / part_half_depth;
        var texel = sample(mat.particleAtlas, fragment_uv);
        out.colour = gamma_decode(texel.rgb) * part_colour;
        out.alpha = texel.a * part_alpha * clamp(part_exposed, 0.0, 1.0);
        out.colour = out.colour * out.alpha;
    ]]
}
]=]
