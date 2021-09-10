-- (c) Alexey "Razzeeyy" Shmakov 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

local firstTime = true

local playlist = {
    `Massimo_Ruberti_-_02_-_Sabotage.ogg`,
    `Massimo_Ruberti_-_03_-_Last_bird_in_the_valley.ogg`,
    `Massimo_Ruberti_-_04_-_Aldo__Lea.ogg`,
    `Massimo_Ruberti_-_06_-_The_wind.ogg`
}

for i,v in ipairs(playlist) do
        playlist[i] = v
end

hud_class `.` {
    size = vec(512, 256);
    font = `/common/fonts/misc.fixed`;
    --alpha = 0;
    init = function(self)
        self.needsFrameCallbacks = true
        self.trackID = 1; --start with a first track in a playlist
        self.isplayng = false; --don't play by default
        --currenty playing audio source will be stored here
        self.trackname = hud_text_add(self.font)
        self.trackname.parent = self
        self.trackname.position = vec(0, self.size.y/2-64)
        self.trackname.colour = vec(0, 0, 0)
        self.trackname.text = playlist[self.trackID]
        -- TODO: maybe load should be a no-op?  or add ensure_loaded?
        --self.audiosource = audio_body_make_ambient(playlist[self.trackID]);
        self.texture = `body.png`
        
        self.showHideButton = hud_object `/common/hud/Button` {
            caption=":";
            captionFont=`/common/fonts/misc.fixed`;
            backgroundTexture=`/common/hud/CornerTextures/Filled04.png`;
            borderTexture=`/common/hud/CornerTextures/Border04.png`;
            size=vec(16, 16);
            parent=self,
        }
        self.showHideButton.position = vec(self.size.x/2-32, self.size.y/2-18)
        self.showHideButton.pressedCallback = function(self2)
            system_layer:hidePane(self)
        end
        
        self.playPauseButton = hud_object `/common/hud/Button` {
            caption="▶",
            captionFont=`/common/fonts/misc.fixed`,
            size=vec(48, 32),
            parent=self,
        }
        self.playPauseButton.position = vec(0, -90)
        self.playPauseButton.pressedCallback = function(this)
			if(firstTime)then
					self.audiosource = audio_body_make_ambient(playlist[self.trackID])
					firstTime=false
			end
            if self.audiosource.playing then
                self.isplaying = false
                self.audiosource:pause()
                self.playPauseButton:setCaption("▶")
            else
                self.isplaying = true
                self.audiosource:play()
                self.playPauseButton:setCaption("||")
            end
        end
        
        self.prevSongButton = hud_object `/common/hud/Button` {
            caption="<",
            captionFont=`/common/fonts/misc.fixed`,
            size=vec(32, 24),
            parent=self,
        }
        self.prevSongButton.position = vec(-52, -90)
        self.prevSongButton.pressedCallback = function(this)
            self.audiosource:destroy()
            self.trackID = (self.trackID - 1 < 1) and #playlist or self.trackID - 1
            self.trackname.text = playlist[self.trackID]
            self.audiosource = audio_body_make_ambient(playlist[self.trackID]);
            if self.isplaying then
                self.audiosource:play()
            end
        end
        
        self.nextSongButton = hud_object `/common/hud/Button` {
            caption=">",
            captionFont=`/common/fonts/misc.fixed`,
            size=vec(32, 24),
            parent=self,
        }
        self.nextSongButton.position = vec(52, -90)
        self.nextSongButton.pressedCallback = function(this)
            self.audiosource:destroy()
            self.trackID = (self.trackID + 1 > #playlist) and 1 or self.trackID + 1
            self.trackname.text = playlist[self.trackID]
            self.audiosource = audio_body_make_ambient(playlist[self.trackID]);
            if self.isplaying then
                self.audiosource:play()
            end
        end
    end;
    destroy = function(self)
        if self.audiosource then
            self.audiosource:destroy()
            self.audiosource = nil
        end
    end;
    frameCallback = function (self, elapsed)
        if self.isplaying and (not self.audiosource.playing) then
            --song ended, lets go to a next one
            self.nextSongButton:pressedCallback()
        end
    end;
}
