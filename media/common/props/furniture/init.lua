-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

material `WorkBench` {
    shadowBias = .02,

    -- diffuseVertex = 1,
    diffuseMap = `WorkBench.dds`,
    normalMap = `WorkBenchN.dds`,
    -- specularMap = `WorkBenchS.dds`,
    glossMask = 0.1,
}

class `WorkBench` (ColClass) {
    renderingDistance = 100,
    castShadows = true,
    placementZOffset = 0.65,
}
