shader `Decal` {
 
    vertexCode = "";
    diffuseMap = uniform_texture_2d(1, 1, 1, 1);
    diffuseMask = uniform_float(1, 1, 1);
   
    alphaMask = uniform_float(1);
    alphaRejectThreshold = uniform_float(-1);

    premultipliedAlpha = static_float(0);  -- Boolean
 
    dangsCode = [[
        var diff_texel = sample(mat.diffuseMap, vert.coord0.xy);
        if (mat.premultipliedAlpha > 0) diff_texel = pma_decode(diff_texel);
        out.diffuse = gamma_decode(diff_texel.rgb) * mat.diffuseMask;

        out.alpha = diff_texel.a * mat.alphaMask;
        out.alpha = out.alpha * vert.coord0.z;

        if (out.alpha <= mat.alphaRejectThreshold) discard;

        out.normal = vert.normal;
        out.gloss = 0;
        out.specular = 0;
    ]];
}
 
material `SoundIcon` {
    shader = `Decal`,
    sceneBlend = "ALPHA",
    diffuseMap = `/common/SoundIcon.png`,
    alphaMask = 1,
}
 
material `ScorchMark1` {
    shader = `Decal`,
    sceneBlend = "ALPHA",
    diffuseMap = `ScorchMark1.png`,
}
 
material `ScorchMark2` {
    shader = `Decal`,
    sceneBlend = "ALPHA",
    diffuseMap = `ScorchMark2.png`,
}
 
material `ScorchMark3` {
    shader = `Decal`,
    sceneBlend = "ALPHA",
    diffuseMap = `ScorchMark3.png`,
}
 
material `ScorchMark4` {
    shader = `Decal`,
    sceneBlend = "ALPHA",
    diffuseMap = `ScorchMark4.png`,
}

-- TODO: Cars.
-- TODO: Test on windows
-- TODO: Allow reading normal of underlying surface.
-- TODO: - Attenuate based on normal of surface being project on

WeaponScorch = WeaponScorch or {
    scorchMarks = {},
}

WeaponScorch.decals = { `ScorchMark1`, `ScorchMark2`, `ScorchMark3`, `ScorchMark4` }

function WeaponScorch:scorch(mat, src, q)
    local dist, _, normal = directed_ray(src, q)
    if dist == nil then return nil end
    local hit_pos = src + q * (dist * V_FORWARDS)
    local decal = gfx_decal_make(mat)
    decal.localPosition = hit_pos
    decal.localOrientation = quat(q * V_FORWARDS, normal) * q
    decal.localScale = vec(20, 2, 20)
    return decal
end

function WeaponScorch:primaryEngage(src, quat)
    local decal_name = self.decals[math.random(#self.decals)]
    local mark = self:scorch(decal_name, src, quat)
    if mark ~= nil then
        table.insert(self.scorchMarks, mark)
    end
end
function WeaponScorch:primaryStepCallback(elapsed_secs, src, quat)
end
function WeaponScorch:primaryDisengage(self)
end

function WeaponScorch:secondaryEngage(src, quat)
    local mark = self:scorch(`SoundIcon`, src, quat)
    if mark ~= nil then
        table.insert(self.scorchMarks, mark)
    end
end
function WeaponScorch:secondaryStepCallback(elapsed_secs, src, quat)
end
function WeaponScorch:secondaryDisengage()
end
WeaponEffectManager:set("Scorch", WeaponScorch)

 
-- main.camPos = vector3(-45, -4, 4)
-- system_layer:setEnabled(true)
