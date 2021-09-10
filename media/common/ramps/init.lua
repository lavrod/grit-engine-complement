material `Atlas` {
    glossMask = 3.5,
    diffuseMap = `Atlas_D.dds`,
    normalMap = `Atlas_N.dds`,
    glossMap = `Atlas_S.tga`
}

--Classes
class `Small` (ColClass) {
    castShadows = true,
    renderingDistance = 100,
}

class `Large` (ColClass) {
    castShadows = true,
    renderingDistance = 100,
}

class `HalfPipeSmall` (ColClass) {
    castShadows = true,
    renderingDistance = 100,
}

class `HalfPipeLarge` (ColClass) {
    castShadows = true,
    renderingDistance = 100,
}
