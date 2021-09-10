-- (c) David Cunningham 2009, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

PhysicalMaterials = PhysicalMaterials or {}

physics = physics or { }

physics.defaultMaterial = {}

function physics:setDefaultMaterial(tab)
        physics.defaultMaterial = {}
        for k,v in pairs(tab) do
                physics.defaultMaterial[k] = v
        end
end

function physics:setMaterial(name, tab)
        for k,v in pairs(physics.defaultMaterial) do
                tab[k] = tab[k] or v
        end
        gge_physics_set_material(name, tab.interactionGroup)
        local mat = PhysicalMaterials[name]
        if mat == nil then
                -- create material
                mat = {}
                PhysicalMaterials[name] = mat
        else
                -- clear it out
                for k,v in pairs(mat) do
                        mat[k] = nil
                end
        end
        for k,v in pairs(tab) do
            mat[k] = v
        end
        return mat
end

function physics:getMaterial(name)
        return PhysicalMaterials[name]
end

physical_material `FallbackPhysicalMaterial` { interactionGroup=0; }

