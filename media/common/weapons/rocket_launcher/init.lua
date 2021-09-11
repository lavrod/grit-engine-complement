-- Code (c) David Cunningham 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
-- Art (c) Vincent Mayeur 2013, Licenced under Creative Commons License BY-NC-SA: http://creativecommons.org/licenses/by-nc-sa/3.0/

-- TODO: addressingMode

material `rocket_launcher` { 
	shadowBias = 0.1,

	diffuseMap = {
        image = `../../textures/rocket_launcher.tga`,
        filterMag = "NONE",
    },
}

class `Rocket` (BaseClass) {
    gfxMesh = `rocket.mesh`;

    renderingDistance = 100.0;

    speed = 40; 

    castShadows = true;


    activate = function(self, instance)
        BaseClass.activate(self, instance)
        self.needsStepCallbacks = true
        instance.orientation = self.rot or Q_ID

    end;

    deactivate = function (self)
        self.needsStepCallbacks = false;
        BaseClass.deactivate(self)

        return true -- do not respawn
    end;

    stepCallback = function (self, elapsed)

        local instance = self.instance
        local gfx = instance.gfx

        local p = self.pos

        local movement = (instance.orientation*V_FORWARDS)*elapsed*self.speed

        local fraction, hit_obj, wall_normal = physics_sweep_cylinder(0.1, 0.5, instance.orientation*quat(90,vector3(1,0,0)), p, movement, true, 0)
        if fraction then
            -- hit something

            local hit_pos = p + fraction * movement
            
            explosion(hit_pos)

            self:destroy()
        else
            p = p + movement
            self.pos = p
            gfx.localPosition = p
            local vel = random_vector3_box(vector3(-0.2,-0.2,6),vector3(0.2,0.2,8))
            local sz = 0.1+math.random()*0.1
            emit_textured_smoke(p, vel, sz, sz*10, vector3(0.3, 0.3, 0.3)+math.random()*vector3(0.4,0.4,0.4))
        end


    end;

    
}

function fire_rocket (pos)

    pos = pos or player_ctrl.camFocus+player_ctrl.camDir * V_FORWARDS

    object `Rocket` (pos) { rot=player_ctrl.camDir }

end

--detached_binds:bind("A+-", function () fire_rocket() end )

class `RocketLauncher` (BaseClass) {
    gfxMesh = `rocket_launcher.mesh`;
}
