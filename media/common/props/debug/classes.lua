-- Lua file generated by Blender class export script.
-- WARNING: If you modify this file, your changes will be lost if it is subsequently re-exported from blender

class `JengaBrick` (ColClass) {
    renderingDistance = 50.0;
    castShadows = true;
    placementZOffset = 0.11999999731779099;
    placementRandomRotation = false;
    font = `/common/fonts/VerdanaBold24`,
    fontMaterial = `/common/fonts/VerdanaBold24`,
    activate = function (self, instance)
        if ColClass.activate(self, instance) then
            return true
        end
        instance.textBody = gfx_text_body_make(self.font, self.fontMaterial)
        instance.textBody.text = 'Sn: %06d' % (math.random(1000000) - 1)
        instance.textBody.parent = instance.gfx
        instance.textBody.localPosition = vec(-0.42, .1294, 0.1213)
        instance.textBody.localScale = vec(0.002, 0.002, 0.002)
        instance.textBody.castShadows = false
    end,
    destroy = function (self)
        safe_destroy(self.instance.textBody)
    end,
}

