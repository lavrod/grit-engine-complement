gge_print("Test begins")

gfx_colour_grade(`neutral.lut.png`)
gfx_option('POST_PROCESSING', false)

gge_print("Making class")
gfx_hud_class_add(`Rect`, {
    colour = vec(1, 0, 0);
    init = function (self)
        self.needsParentResizedCallbacks = true
    end;
    parentResizedCallback = function (self, psize)
        gge_print("[0;31mparentResizedCallback(" .. tostring(psize) .. ")")
        self.position = vec(psize.x/2, psize.y/2)
        self.size = psize / 2
    end;
})

gge_print("Making object")
obj = gfx_hud_object_add(`Rect`)

gge_print("Rendering frame")
gfx_render(0.1, vec(0, 0, 0), quat(1, 0, 0, 0))
gfx_screenshot('output-parent_resized.png')
