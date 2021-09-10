-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

audio = audio or { }

 -- prevent it from being unloaded by anyone until we release it
audio.collision = gge_disk_resource_hold_make(`/common/sounds/collision.wav`)
 -- force load it (in rendering thread)
gge_disk_resource_ensure_loaded(audio.collision.name)

audio.explosion = gge_disk_resource_hold_make(`/common/sounds/explosion.wav`)
gge_disk_resource_ensure_loaded(audio.explosion.name)
