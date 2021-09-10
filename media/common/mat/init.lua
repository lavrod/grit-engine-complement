-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

material `Red` { diffuseMask=vec(.5, 0, 0), glossMask=.5 }
material `Blue` { diffuseMask=vec(0, 0, .5), glossMask=.5 }
material `Green` { diffuseMask=vec(0, .5, 0), glossMask=.5 }
material `Yellow` { diffuseMask=vec(.5, .5, 0), glossMask=.5 }
material `Cyan` { diffuseMask=vec(0, .5, .5), glossMask=.5 }
material `Magenta` { diffuseMask=vec(.5, 0, .5), glossMask=.55 }
material `Black` { diffuseMask=vec(.1, .1, .1), glossMask=.75 }
material `White` { diffuseMask=vec(.7, .7, .7), glossMask=.25 }
material `Grey` { diffuseMask=vec(.5, .5, .5), glossMask=.0 }

material `Emissive` { diffuseMask=vec(.7, .7, .7), glossMask=.25, emissiveMask=vec(3, 3, 3), additionalLighting=true }

material `Chrome` { diffuseMask=vec(0, 0, 0), specularMask=1, glossMask=1 }

material `Test` { diffuseMap=`../tex/Test.dds` }
material `TestNorm` { diffuseMap=`../tex/Test.dds`, normalMap=`../tex/Test_n.dds` }

material `Burnt` { diffuseMap=`burnt.png`, diffuseMask=vec(1, 1, 1), specularMask=0.03, glossMask=0.01 }

material `Grass` {
    diffuseMap = `../tex/davec/Grass_d.dds`,
    specularMask = 0.03,
    glossMask = 0.01,
}

material `PackedGravel` {
    diffuseMap = `../tex/davec/PackedGravel_d.dds`,
    normalMap = `../tex/davec/PackedGravel_n.dds`,
    specularMask = 0.03,
    glossMask = 0,
}

material `RoadSurface` {
    diffuseMap = `../tex/davec/RoadSurface_d.dds`,
    normalMap = `../tex/davec/RoadSurface_n.dds`,
    specularMask = 0.03,
    -- specularMap = `../tex/davec/RoadSurface_s.dds`,
}

material `RedBrick` {
    diffuseMap = `../tex/davec/RedBrick_d.dds`,
    normalMap = `../tex/davec/RedBrick_n.dds`,
    diffuseVertex = 1
}

material `RoofTiles` {
    diffuseMap = `../tex/davec/RoofTiles_d.dds`,
    diffuseMask = srgb(248, 253, 255),
    specularMask = 0.03,
    diffuseVertex = 1,
}
