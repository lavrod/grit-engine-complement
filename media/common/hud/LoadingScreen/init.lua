-- Displays a fullscreen background + logo, and map loading status.
hud_class `.` {

    alpha = 1;
    loadingBarSize = vec(700, 10);
    speed = 10;

    init = function(self)
        self.needsParentResizedCallbacks = true
        self.rot = 0
        
        self.texture = `Background.png`
        
        self.logo = hud_object `/common/hud/Rect` {texture=`GritLogo.png`, parent=self, size=vec(600, 300)}
        
        self.mapName = gge_hud_text_add(`/common/fonts/Verdana18`)
        self.mapName.parent = self
        self.mapName.position = vec(0, -140)
        
        self.mapStatus = gge_hud_text_add(`/common/fonts/Verdana24`)
        self.mapStatus.parent = self
        self.mapStatus.colour = vector3(1, 0.5, 0)
        self.mapStatus.position = vec(0, -220)

        self.loadingBarShadow = hud_object `/common/hud/Rect` {colour=vector3(0, 0, 0), alpha=0.25, parent=self}
        self.loadingBarShadow.size = vec(self.loadingBarSize.x+6, self.loadingBarSize.y+6)
        self.loadingBarShadow.position = vec(0, -300)
        
        self.loadingBar = hud_object `/common/hud/Rect` {colour=vector3(1, 0.5, 0), parent=self.loadingBarShadow}

        self:setProgress(0.5)
        self:setStatus('status')
        self:setMapName('map name')
    end;
    destroy = function(self)
        self.needsFrameCallbacks = false
        self.logo:destroy()
        self.mapName:destroy()
        self.mapStatus:destroy()
        self.loadingBarShadow:destroy()
        self.loadingBar:destroy()
    end;
    
    setProgress = function(self, v)
        self.progress = math.clamp(v, 0, 1)
        -- TODO: use self.loadingBar:setRect(bottom_left, top_right)
        self.loadingBar.size = vec((self.loadingBarSize.x * self.progress), self.loadingBarSize.y)
        self.loadingBar.position = vec(-self.loadingBarSize.x/2 + self.loadingBar.size.x/2, self.loadingBar.position.y)
    end;
    
    setStatus = function(self, v)
        self.mapStatus.text = v
    end;

    setShow = function(self, v)
    end;

    pump = function(self)
        gge_gfx_render(0, main.camPos, main.camQuat)
    end;

    setMapName = function(self, name)
        self.mapName.text = "Loading map: '"..name.."'"
    end;  

    parentResizedCallback = function (self, psize)
        self:setRect(0, 0, psize.x, psize.y)
    end;
}

