-- set GRIT_INIT=/test.lua
-- set ZEROBRANE=8172
-- grit.exe
   

print("Initializing")
--gge_include("/system/util.lua"); 

main = {
    shouldQuit = false;
}


scheduler = {}
scheduler.timers = {}
scheduler.tasks = {}

function scheduler:timer(name, duration, task)
   local timer = {desc=name, deadline=gge_seconds()+duration, wakeup = task }
   table.insert(scheduler.timers,timer)
end

function scheduler:run()
    local task

   while true do
        for i=#scheduler.timers,1,-1 do
          if gge_seconds() > scheduler.timers[i].deadline then
            local task = scheduler.timers[i].wakeup
            local desc = scheduler.timers[i].desc
            scheduler:post(desc, task )
            table.remove(scheduler.timers, i)
          end  
        end
        task = table.remove(scheduler.tasks,1)
        if task then
            task.call()
        end
    end
end

function scheduler:post( name, task )
   local t = {desc=name, call = task}
   table.insert(scheduler.tasks,1,t)
end

function main:wakeup()
   scheduler:post("debug",main.debug)
end

gge_gfx_register_shader(`Ball`, {
    tex = {
        uniformKind = "TEXTURE_CUBE",
    },
    vertexCode = [[
        var pos_os = vert.position.xyz;
        var normal_os = vert.normal.xyz;
        var normal_ws = rotate_to_world(vert.normal.xyz);
    ]],
    dangsCode = [[
        out.diffuse = 0;
        out.gloss = 0;
        out.specular = 0;
        out.normal = normal_ws;
    ]],
    additionalCode = [[
        out.colour = gamma_decode(sample(mat.tex, pos_os).xyz);
    ]],
})

gge_register_material(`Ball`, {
    shader = `Ball`,
    tex = `cube.dds`,
    additionalLighting = true,
})

function main:task()
  gge_gfx_colour_grade(`neutral.lut.png`)
gge_gfx_fade_dither_map `stipple.png`
  b1 = gge_gfx_body_make(`Ball.mesh`)
b1.localPosition = vec(-2, 5, 0)
b1.localScale = vec(10, 10, 10)

b2 = gge_gfx_body_make(`Ball.mesh`)
b2.localPosition = vec(0, 5, 0)
b2.localScale = vec(10, 10, 10)

b3 = gge_gfx_body_make(`Ball.mesh`)
b3.localPosition = vec(2, 5, 0)
b3.localScale = vec(10, 10, 10)

gge_gfx_render(0.1, vec(0, 0, 0), quat(1, 0, 0, 0))
gge_gfx_screenshot('output-cubemap.png')
   scheduler:timer("main.run", 2, main.run)
end

function main:cmdline()
end

function main:debug()
   require('mobdebug').start("127.0.1.1",8172)
   print("main:run()")
   main:run();
end

function main:run (...)
    -- rendering loop
    if not gge_clicked_close() and not main.shouldQuit then
         print("main:run")
         gge_gfx_render(0.1, vec(0.04362189, -0.9296255, 0.5302261), quat(0.9800102, -0.1631184, 0.01870036, -0.1123512))
         scheduler:timer("main:run",2,main.run)
    end
end







scheduler:post("main:task",main.task)
scheduler:run()
