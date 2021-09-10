material `Black` {
    diffuseMask = vec(.01, .01, .01),
}

class `Grenade` (BaseClass) {
    renderingDistance = 400.0;
	placementZOffset = 0.1;

    castShadows = true;
    lifePattern = {1, 2, 1, 4, 1, 2, 1, 8};

    velocity = vec(0, 0, 0);

    fuse = 3;

    friction = 0.05;
    restitution = 0.3;
    mass = 3;

    activate = function(self, instance)
        BaseClass.activate(self, instance)
        self.needsStepCallbacks = true
        instance.orientation = self.rot or Q_ID
        instance.lifeSecs = 0
    end;

    deactivate = function (self)
        self.needsStepCallbacks = false;
        BaseClass.deactivate(self)

        return true  -- Do not respawn.
    end;

    stepCallback = function (self, elapsed_secs)

        local instance = self.instance
        local gfx = instance.gfx

        local p = self.pos

        local dir = (instance.orientation * quat(3, random_vector3_sphere())) * V_FORWARDS

        local movement = self.velocity * elapsed_secs
        self.velocity = self.velocity + physics_get_gravity() * elapsed_secs


        local fraction, hit_obj, wall_normal = physics_sweep_sphere(0.1, p, movement, true, 0)


        if fraction then
            -- hit something

            p = p + fraction * movement

            local rest = dot(self.velocity, -wall_normal) * wall_normal
            local parallel_vel = self.velocity + rest
            local speed = #parallel_vel
            local friction = self.friction * speed * speed
            self.velocity = (parallel_vel * .95) + self.restitution * rest
            hit_obj:impulse(self.mass * (1 + self.restitution) * -rest, p)

        else

            -- Put particle at current position, then move to next position (particle always behind)
            --local vel = random_vector3_box(vec(-0.2, -0.2, 6), vec(0.2, 0.2, 8))
            local r1 = 0.1
            local life = 1
            local r2 = 1
            local grey = 1

            if math.floor(instance.lifeSecs * 200) % 10 == 0 and instance.lifeSecs > 0.05 then
                gfx_particle_emit(`/common/particles/TexturedSmoke`, p, {
                    angle = 360*math.random();
                    velocity = 0.3 * random_vector3_sphere() + vec(0,0,2);
                    initialVolume = 4/3 * math.pi * r1*r1*r1; -- volume of sphere
                    maxVolume = 4/3 * math.pi * r2*r2*r2; -- volume of sphere
                    life = life;
                    diffuse = grey * vec(1, 1, 1);
                    age = 0;
                })
            end

            p = p + movement 
            self.pos = p
            gfx.localPosition = p
        end

        instance.lifeSecs = instance.lifeSecs + elapsed_secs

        if instance.lifeSecs > self.fuse then
            explosion(p, 3, 5000)
            self:destroy()
        end;
        
    end;

}   


WeaponEffectManager:set("Grenade", {

    lastFire = 0;
    reloadSec = 0.5;
    
    fire = function (self, p, q)
        self.lastFire = gge_seconds()
        object `Grenade` (p) { velocity=q*vec(0, 25, 0) }
    end;
    
    checkFire = function (self, p, q)
        if gge_seconds() > self.lastFire + self.reloadSec then
            self:fire(p, q)
        end
    end;
            
    stepCallbackAux = function (self, elapsed_secs, src, quat, accel)
    end;
    
    primaryEngage = function (self, src, quat)
        self:checkFire(src, quat)
    end;
    primaryStepCallback = function (self, elapsed_secs, src, quat)
        self:checkFire(src, quat)
    end;
    primaryDisengage = function (self)
    end;
    
    secondaryEngage = function (self, src, quat)
    end;
    secondaryStepCallback = function (self, elapsed_secs, src, quat)
    end;
    secondaryDisengage = function (self)
    end;
})  

