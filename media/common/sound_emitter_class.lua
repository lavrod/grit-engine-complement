-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- TODO(dcunnin): It does not make sense to have to specify all this stuff just to get a
-- GfxSpriteBody.

particle `SoundIcon` {
    map = `SoundIcon.png`,
    frames = { 0,0, 128, 128, }, frame = 0,
    emissive = vec(0.5, 0.5, 0.5),
    behaviour = function(particle, elapsed)
    end,
}

SoundEmitterClass = {
    renderingDistance=50,

    init = function(self)
        self:addDiskResource(self.audioFile or self.className..".wav")
    end,

    activate = function(self, instance)
        instance.audio = audio_body_make(self.audioFile or self.className..".wav")
        instance.audio.looping = true
        instance.audio.position = self.spawnPos
        if self.pitch then
            instance.audio.pitch = self.pitch
        end
        if self.orientation then
            instance.audio.orientation = self.orientation
            instance.audio.separation = self.separation or 1
        end
        if self.volume then
            instance.audio.volume = self.volume
        end
        if self.referenceDistance then
            instance.audio.referenceDistance = self.referenceDistance
        end
        if self.rollOff then
            instance.audio.rollOff = self.rollOff
        end
        instance.audio:play()
        if self.editorVisualisation then
            instance.editorVisualisationSprite = gfx_sprite_body_make(`SoundIcon`)
            instance.editorVisualisationSprite.localPosition = self.spawnPos
            instance.editorVisualisationSprite.diffuse = vec3(0, 0, 0)
            instance.editorVisualisationSprite.emissive = vec3(0.5, 0.5, 0.5)
        end
    end,

    deactivate = function(self)
        local instance = self.instance

        safe_destroy(instance.audio)
        safe_destroy(instance.editorVisualisationSprite)
    end,
}
