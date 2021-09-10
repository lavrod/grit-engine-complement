-- (c) David Cunningham 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

sky_material `Moon` {
    emissiveMap = `starfield.dds`,
    emissiveMask = vec(0.3, 0.3, 0.3),
    alphaRejectThreshold = 0.5,
}


shader `SkyBackground` {
    starfieldMask = uniform_float(1, 1, 1),
    starfieldMap = uniform_texture_2d(0, 0, 0),
    vertexCode = import_str `SkyBackground.vert.gsl`,
    additionalCode = import_str `SkyBackground.colour.gsl`,
}

sky_material `Sky` {
    starfieldMap = {
        image = `starfield.dds`;
        modeU = "CLAMP", modeV = "CLAMP", modeW = "CLAMP",
        filterMin = "LINEAR", filterMax = "LINEAR", filterMip = "ANISOTROPIC",
        anisotropy = 16,
    };
    starfieldMask = vec(0.2, 0.2, 0.2);
    shader = `SkyBackground`;
}


shader `Clouds` {
    perlin = uniform_texture_2d(0, 0, 0);
    perlinN = uniform_texture_2d(0.5, 0.5, 1);
    vertexCode = import_str `SkyClouds.vert.gsl`;
    additionalCode = import_str `SkyClouds.colour.gsl`;
}

sky_material `Clouds` {
    shader = `Clouds`,
    sceneBlend = "ALPHA",

    perlin = `PerlinNoise.png`,
    perlinN = `PerlinNoiseN.png`,
}
