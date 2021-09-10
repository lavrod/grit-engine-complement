local diff = uniform_texture_2d(0.3, 0.3, 0.3, 1);
local pbr = uniform_texture_2d(0.04, 1, 0);
local normal = uniform_texture_2d(0.5, 0.5, 1);
local scale = uniform_float(1, 1);


shader `HeightmapBlend4` {
    
    diffuseVertex = static_float(0),  -- Boolean

    diffuseMap0 = diff,
    pbrMap0 = pbr,
    normalMap0 = normal,
    uvScale0 = scale,

    diffuseMap1 = diff,
    pbrMap1 = pbr,
    normalMap1 = normal,
    uvScale1 = scale,

    diffuseMap2 = diff,
    pbrMap2 = pbr,
    normalMap2 = normal,
    uvScale2 = scale,

    diffuseMap3 = diff,
    pbrMap3 = pbr,
    normalMap3 = normal,
    uvScale3 = scale,

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
        var normal_ws = rotate_to_world(vert.normal.xyz);
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
        var sharpness = vert.coord1.x;
        var contrast =  1 / max((1-sharpness) * (1-sharpness), 0.0000001);
    ]],
    
    dangsCode = [[
        // Weights from vertexes
        var blend = []Float { 0.5, vert.coord2.x, vert.coord2.y, vert.coord2.z };

        var diff_texel = []Float4 {
            sample(mat.diffuseMap0, vert.coord0.xy * mat.uvScale0),
            sample(mat.diffuseMap1, vert.coord0.xy * mat.uvScale1),
            sample(mat.diffuseMap2, vert.coord0.xy * mat.uvScale2),
            sample(mat.diffuseMap3, vert.coord0.xy * mat.uvScale3),
        };

        var pbr_texel = []Float4 {
            sample(mat.pbrMap0, vert.coord0.xy * mat.uvScale0),
            sample(mat.pbrMap1, vert.coord0.xy * mat.uvScale1),
            sample(mat.pbrMap2, vert.coord0.xy * mat.uvScale2),
            sample(mat.pbrMap3, vert.coord0.xy * mat.uvScale3),
        };

        var norm_texel = []Float4 {
            sample(mat.normalMap0, vert.coord0.xy * mat.uvScale0),
            sample(mat.normalMap1, vert.coord0.xy * mat.uvScale1),
            sample(mat.normalMap2, vert.coord0.xy * mat.uvScale2),
            sample(mat.normalMap3, vert.coord0.xy * mat.uvScale3),
        };

        for (var i = 0; i < 4; i = i + 1) {
            // Incorporate texture heightmap into per-vertex height.
            blend[i] = blend[i] + diff_texel[i].a * 255.0 / 256.0 / 2.0;
        }

        var contribution : [4]Float;
        var highest = max(blend[0], max(blend[1], max(blend[2], blend[3])));
        var tmp = highest - highest * contrast;
        for (var i = 0; i < 4; i = i + 1) {
            contribution[i] = max(0.0, blend[i] * contrast + tmp);
        }

        var total = contribution[0] + contribution[1] + contribution[2] + contribution[3];
        for (var i = 0; i < 4; i = i + 1) {
            contribution[i] = contribution[i] / total;
        }

        
        var blended_diffuse : Float3;
        for (var i = 0; i < 4; i = i + 1) {
            blended_diffuse = blended_diffuse + contribution[i] * gamma_decode(diff_texel[i].xyz);
        }
        out.diffuse = blended_diffuse;
        //if (mat.diffuseVertex > 0) out.diffuse = out.diffuse * vert.colour.xyz;
        
        var blended_specular : Float;
        for (var i = 0; i < 4; i = i + 1) {
            blended_specular = blended_specular + contribution[i] * gamma_decode(pbr_texel[i].x);
        }
        out.specular = blended_specular;
        
        var blended_gloss : Float;
        for (var i = 0; i < 4; i = i + 1) {
            blended_gloss = blended_gloss + contribution[i] * pbr_texel[i].b;
        }
        out.gloss = blended_gloss;
        
        var blended_normal : Float3;
        for (var i = 0; i < 4; i = i + 1) {
            blended_normal = blended_normal + contribution[i] * norm_texel[i].xyz;
        }
        var normal_ts = blended_normal * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
        
    ]],
}


shader `HeightmapBlend2` {
    
    diffuseVertex = static_float(0),  -- Boolean

    diffuseMap0 = diff,
    pbrMap0 = pbr,
    normalMap0 = normal,
    uvScale0 = scale,

    diffuseMap1 = diff,
    pbrMap1 = pbr,
    normalMap1 = normal,
    uvScale1 = scale,

    vertexCode = [[
        out.position = transform_to_world(vert.position.xyz);
        var normal_ws = rotate_to_world(vert.normal.xyz);
        var tangent_ws = rotate_to_world(vert.tangent.xyz);
        var binormal_ws = vert.tangent.w * cross(normal_ws, tangent_ws);
        var sharpness = vert.coord1.x;
        var contrast =  1 / max((1-sharpness) * (1-sharpness), 0.0000001);
    ]],
    
    dangsCode = [[
        // Weights from vertexes
        var blend = []Float { 0.5, vert.coord2.x };

        var diff_texel = []Float4 {
            sample(mat.diffuseMap0, vert.coord0.xy * mat.uvScale0),
            sample(mat.diffuseMap1, vert.coord0.xy * mat.uvScale1),
        };

        var pbr_texel = []Float4 {
            sample(mat.pbrMap0, vert.coord0.xy * mat.uvScale0),
            sample(mat.pbrMap1, vert.coord0.xy * mat.uvScale1),
        };

        var norm_texel = []Float4 {
            sample(mat.normalMap0, vert.coord0.xy * mat.uvScale0),
            sample(mat.normalMap1, vert.coord0.xy * mat.uvScale1),
        };

        for (var i = 0; i < 2; i = i + 1) {
            // Incorporate texture heightmap into per-vertex height.
            blend[i] = blend[i] + diff_texel[i].a * 255.0 / 256.0 / 2.0;
        }

        var contribution : [2]Float;
        var highest = max(blend[0], blend[1]);
        var tmp = highest - highest * contrast;
        for (var i = 0; i < 2; i = i + 1) {
            contribution[i] = max(0.0, blend[i] * contrast + tmp);
        }

        var total = contribution[0] + contribution[1];
        for (var i = 0; i < 2; i = i + 1) {
            contribution[i] = contribution[i] / total;
        }

        
        var blended_diffuse : Float3;
        for (var i = 0; i < 2; i = i + 1) {
            blended_diffuse = blended_diffuse + contribution[i] * gamma_decode(diff_texel[i].xyz);
        }
        out.diffuse = blended_diffuse;
        //if (mat.diffuseVertex > 0) out.diffuse = out.diffuse * vert.colour.xyz;
        
        var blended_specular : Float;
        for (var i = 0; i < 2; i = i + 1) {
            blended_specular = blended_specular + contribution[i] * gamma_decode(pbr_texel[i].x);
        }
        out.specular = blended_specular;
        
        var blended_gloss : Float;
        for (var i = 0; i < 2; i = i + 1) {
            blended_gloss = blended_gloss + contribution[i] * pbr_texel[i].b;
        }
        out.gloss = blended_gloss;
        
        var blended_normal : Float3;
        for (var i = 0; i < 2; i = i + 1) {
            blended_normal = blended_normal + contribution[i] * norm_texel[i].xyz;
        }
        var normal_ts = blended_normal * Float3(-2, 2, 2) + Float3(1, -1, -1);
        out.normal = normal_ts.x*tangent_ws + normal_ts.y*binormal_ws + normal_ts.z*normal_ws;
        
    ]],
}

