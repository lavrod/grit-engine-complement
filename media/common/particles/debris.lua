-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

particle `Debris` {
    map = `GenericParticleSheet.dds`;
    alphaReject = 0.5;
    frames = { 
        512,    128,    64, 64, -- metal / plastic fragments
        576,    128,    64, 64,
        640,    128,    64, 64,
        704,    128,    64, 64,
        768,    128,    64, 64,
        832,    128,    64, 64,
        512,    192,    64, 64,
        576,    192,    64, 64,
        640,    192,    64, 64,
        704,    192,    64, 64,
        768,    192,    64, 64,
        832,    192,    64, 64,

        768,    512,    64, 64, -- grass
        832,    512,    64, 64,
        896,    512,    64, 64,
        960,    512,    64, 64,

        768,    576,    64, 64, -- dirt
        832,    576,    64, 64,
        896,    576,    64, 64,
        960,    576,    64, 64,
    };  
    
    behaviour = function (particle, elapsed)
        particle.life = particle.life - elapsed
        if particle.life <= 0 then return false end
        particle.position = particle.position + particle.velocity * elapsed
        particle.velocity = particle.velocity + gge_physics_get_gravity() * elapsed
        particle.angle = particle.angle + particle.angleRate * elapsed
    end
}   

function emit_debris (pos, vel, frame, life)
    gge_gfx_particle_emit(`Debris`, pos, {
        angle = math.random(360),
        velocity = vel,
        angleRate = math.random(-300,300),
        dimensions = 0.60*vector3(1,1,1),
        frame = frame,
        life = life,
    })
end
