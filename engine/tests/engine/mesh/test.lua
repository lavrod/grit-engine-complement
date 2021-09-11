
-- Used by the meshes.
gge_register_material(`Small`, {
})

gge_print("Loading Test.08.mesh")
gge_disk_resource_load(`Test.08.mesh`)
gge_print("Using Test.08.mesh")
b08 = gge_gfx_body_make(`Test.08.mesh`)

gge_print("Loading Test.08.mesh")
gge_disk_resource_load(`Test.10.mesh`)
gge_print("Using Test.08.mesh")
b10 = gge_gfx_body_make(`Test.10.mesh`)
