-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

material `rockmap1` {
    diffuseMap = `rockmap1.png`,
    normalMap = `rockmap1_n.png`,
    -- specularMap = `rockmap1_s.png`,
}

class `rock` (ColClass) {
    castShadows = true,
    renderingDistance = 100,
    placementRandomRotation = true,
    placementZOffset = 0.3735,
 }

material `Log` { diffuseMap = `Log_d.dds` }

include `classes.lua`
