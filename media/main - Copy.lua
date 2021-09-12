-- set GRIT_INIT=/test.lua
-- set ZEROBRANE=8172
-- grit.exe
   

print("Initializing")
gge_include("/system/util.lua"); 

main = {
    shouldQuit = false;
    frameCallbacks = CallbackReg.new();
    frameTime = gge_seconds();

    streamerCentre = vec(0, 0, 0);

    camQuat = quat(1, 0, 0, 0);
    camPos = vec(0, 0, 0);
    audioCentrePos = vec(0, 0, 0);
    audioCentreVel = vec(0, 0, 0);
    audioCentreQuat = quat(1, 0, 0, 0);

    controlObj = nil;  -- Recognized by the speedo, set by game modes.

    physicsLeftOver = 0;
    physicsSpeed = 1;
    physicsOneToOne = false;
    physicsEnabled = true;
    physicsMaxSteps = 50;
    physicsAllocs = 0;

    gfxFrameTime = RunningStats.new(20);
    gfxCount = 0;
    gfxUnacctAllocs = 0;
    gfxAllocs = 0;
    gfxShadow1 = {0, 0, 0};
    gfxShadow2 = {0, 0, 0};
    gfxShadow3 = {0, 0, 0};
    gfxLeft = {gbuffer = {0, 0, 0}, deferred = {0, 0, 0}};
    gfxRight = {gbuffer = {0, 0, 0}, deferred = {0, 0, 0}};
    gfxAllShadowStats = function (self)
        return self.gfxShadow1[1] + self.gfxShadow2[1] + self.gfxShadow3[1],
               self.gfxShadow1[2] + self.gfxShadow2[2] + self.gfxShadow3[2],
               self.gfxShadow1[3] + self.gfxShadow2[3] + self.gfxShadow3[3]
    end;
}

local net = {}
net.tcp = {}

net.tcp.server = {
    buf = nil;
    timeout=0;
    blocking=false;
    sleeping=false;
    max_recv = -1;

    send = function( self, msg )
      --print("to tcp srv:".." msg:"..tostring(msg))
           local message = gge_net_make_message()
            message:write_string(msg)
           gge_net_send_packet("tcpserver", net.tcp.server.debugger, message)
    end;
    
    resume = function()
        if net.tcp.server.sleeping == true then
          coroutine.resume(coro_debugger)
        end
    end;

    wakeup_poll = function()

       if net.tcp.server:poll() == true and (net.tcp.server.size == net.tcp.server.max_recv or #net.tcp.server.buf >= net.tcp.server.size) then
            net.tcp.server.sleeping = false
          coroutine.resume(coro_debugger)
       else
          scheduler:timer(nil,0.2,net.tcp.server.wakeup_poll)
       end
    end;
  
    sleep_until_data = function(self)
        if self.sleeping == false then
            self.sleeping = true
            
            scheduler:timer(nil,0.2,net.tcp.server.wakeup_poll)
            coroutine.yield()

        end    
    end;
  
    sleep_upto = function( self, timeout )
        if self.sleeping == false then
            self.sleeping = true
            scheduler:timer("sleep_upto",timeout,net.tcp.server.resume)
            coroutine.yield()
            net.tcp.server.sleeping = false
        end
    end;

    getmax = function( self )

              self.size = self.max_recv

              self:poll()
              
              if self.buf and #self.buf > 0 then
                 self.size = #self.buf
                 return self:get(self.size), true
              end
              
              if self.blocking == true and not self.timeout then
                  repeat 
                     self:sleep_until_data()
                     self:poll()
                  until self.buf and #self.buf > 0 
                  self.size = #self.buf
                  return self:get(self.size), true
              elseif self.blocking == true and self.timeout then
                  self:sleep_upto(self.timeout)
                  self:poll()
                  if self.buf and #self.buf > 0 then
                     self.size = #self.buf
                     return self:get(self.size), true
                  end
              else
              end    
                 
              return nil, "timeout"
    end;

    getfix = function( self, size )

              self.size = size

              self:poll()
              
              if self.buf and #self.buf >= self.size then
                local buf = self:get(self.size)
                return buf, true
              end
              
              if self.blocking == true and not self.timeout then

                  repeat 
                     self:sleep_until_data()
                     self:poll()
                  until self.buf and #self.buf >= self.size 
                  local buf = self:get(self.size)
                  return buf, true
              elseif self.blocking == true and self.timeout then

                  self:sleep_upto(self.timeout)
                  self:poll()
                  if self.buf and #self.buf >= self.size then
                    local buf = self:get(self.size)
                    return buf, true
                  end
              end    
                 
              return nil, "timeout"
    end;

    get = function( self, size )
           if self.buf and size > 0 and #self.buf > 0 and #self.buf >= size then
             local buffer = string.sub(self.buf,1,size)
             self.buf = string.sub(self.buf,1+size,#self.buf)
             return buffer
           else
             return nil
           end
    end;

    receive = function( self, from, size )

           while self:poll() == true do
           end

           if not size then
              local buf, err = self:getmax()
              return buf, err
           else
             local buf, err = self:getfix(size)
             return buf, err
           end
    end;

    poll = function(self)
        local length
        local message
        local from
        length, message, from = gge_net_process_poll_remote_tcp_server()

        if length > 0 and from and message then
            local tuple = tostring(from)
            local sep = string.find(tuple,":")
            local addr = string.sub(tuple,1,sep)
            local port = string.sub(tuple,sep+1,-1)
            local buffer = message:read_buffer(length)
   
            --print("from tcp srv:"..tostring(addr).." port:"..tostring(port).." msg:"..tostring(buffer))
            if port == "8172" then
                if self.buf then
                   self.buf = self.buf..tostring(buffer)
                else
                   self.buf = tostring(buffer)
                end
            end
            return true
         end
         return false
    end;
    
    settimeout = function(self, timeout )
      if timeout and timeout > 0 then
         self.timeout = timeout
         self.blocking = true
      elseif timeout and timeout == 0 then
         self.timeout = timeout
         self.blocking = false
      else
         self.timeout = nil
         self.blocking = true
      end
    end;
}


function connect(host,port)
   local tuple = host..":"..port
   local server = gge_net_resolve_address(tuple)
   print("Server Addr:Port="..tostring(server))

   if not net.tcp.server.debugger then
      net.tcp.server.debugger = server
   end

   return net.tcp.server, true
end

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
   scheduler:post("main",main.task)
end

function main:task()
   local var = 1
   print("main.task"..var)
   scheduler:timer("main.wakeup", 2, main.wakeup)
end

function main:cmdline()

end

function main:debug()
   require('mobdebug').start("127.0.1.1",8172)
end

scheduler:post("main",main.task)
scheduler:post("debug",main.debug)


function main:run (...)

    -- execute cmdline arguments on console
    local arg = ""
    for i=2, select('#', ...) do
        arg = arg .. " " .. select(i,...)
    end
    if #arg > 0 then
        console:exec(arg:sub(2))
    end

    local rel_cam_l_r = 0.0
    local rel_cam_u_d = 0.0

    local last_cam_move = gge_seconds()

    local last_focus = true

    local failName = {}

--    scheduler:post("cmdline",main.cmdline)
    scheduler:post("main",main.task)
  --  scheduler:post("debug",main.debug)
   -- require('mobdebug').start("127.0.1.1",8172)

    -- rendering loop
    while not gge_clicked_close() and not main.shouldQuit do

        scheduler:run()
        
        local curr_time = gge_seconds()
        local elapsed_secs = curr_time - main.frameTime
        main.frameTime = curr_time
          
        -- INPUT
        if last_focus ~= gge_have_focus() then
            last_focus = gge_have_focus()
            gge_input_filter_flush()
        end

        local presses = gge_get_keyb_presses()
        local moved,buttons,x,y,rel_x,rel_y = get_mouse_events()
        local cam_moved;

        mouse_pos_abs = vec(x, y)
        mouse_pos_rel = vec(rel_x, rel_y)

        if moved then
            gge_input_filter_trickle_mouse_move(mouse_pos_rel, mouse_pos_abs)
        end

        for _,key in ipairs(presses) do
         --   if get_keyb_verbose() then print("Lua key event: "..key) end
         --   print("Lua key event: "..key) 
            lua_input_filter_trickle_button(key)
        end

        for _,button in ipairs(buttons) do
            if get_keyb_verbose() then print("Lua mouse event: "..button) end
            lua_input_filter_trickle_button(button)
        end


         if last_cam_move ~= seconds() then
            if rel_cam_l_r ~= 0.0 or rel_cam_u_d ~= 0.0 then
               cam_moved = true 
            end
         end

         if cam_moved == true then
           local gamepad_pos_rel = vec(rel_cam_l_r, rel_cam_u_d)
           gge_input_filter_trickle_mouse_move(gamepad_pos_rel, mouse_pos_abs)
           last_cam_move = seconds()
         end

        -- PHYSICS (and game logic)
        local step_size = physics_option("STEP_SIZE")
        if main.physicsOneToOne then
            main.physicsLeftOver = 0
            gge_physics_maybe_step(step_size)
        else
            gge_physics_frame_step(step_size, elapsed_secs)
            -- NAVIGATION
            gge_navigation_update(elapsed_secs)				
        end

        -- GRAPHICS
        if gge_gfx_window_active() then
            gge_physics_update_graphics(main.physicsEnabled and main.physicsLeftOver or 0)
            gge_physics_draw()
        end
        game_manager:frameUpdate(elapsed_secs)
        gge_object_do_frame_callbacks(elapsed_secs)

		-- NAVIGATION DEBUG
		gge_navigation_update_debug(elapsed_secs)		

        -- AUDIO
        gge_audio_update(main.audioCentrePos, main.audioCentreVel, main.audioCentreQuat)


        -- STREAMING
        gge_give_queue_allowance(1 + 1*get_in_queue_size())
        gge_streamer_centre(main.streamerCentre)


        if gfx_window_active() then
            main.gfxFrameTime:add(elapsed_secs)
        end

        do -- render a frame
            if user_cfg.lowPowerMode then
                --sleep_seconds(0.2 - elapsed_secs)
                gge_sleep(math.floor(1000000*(0.2 - elapsed_secs)))
                --print("Total frame time: "..elapsed_secs)
            end
            main.gfxCount, main.gfxUnacctAllocs = get_alloc_stats()
            reset_alloc_stats()
            gge_gfx_render(elapsed_secs, main.camPos, main.camQuat)
            main.gfxCount, main.gfxAllocs = get_alloc_stats()
            gge_reset_alloc_stats()
        end
        --local post_frame_time = seconds()
        --print("Frame render time: "..(post_frame_time - curr_time))

        main.gfxShadow1[1], main.gfxShadow1[2], main.gfxShadow1[3],
        main.gfxShadow2[1], main.gfxShadow2[2], main.gfxShadow2[3],
        main.gfxShadow3[1], main.gfxShadow3[2], main.gfxShadow3[3],
        main.gfxLeft.gbuffer[1], main.gfxLeft.gbuffer[2], main.gfxLeft.gbuffer[3],
        main.gfxLeft.deferred[1], main.gfxLeft.deferred[2], main.gfxLeft.deferred[3],
        main.gfxRight.gbuffer[1], main.gfxRight.gbuffer[2], main.gfxRight.gbuffer[3],
        main.gfxRight.deferred[1], main.gfxRight.deferred[2], main.gfxRight.deferred[3] = gfx_last_frame_stats()


        xpcall(function ()
            failName.name = nil
            main.frameCallbacks:executeExtended(function (name, cb, ...)
                failName.name = name
                --t:reset()
                if cb == nil then
                        --print(RED.."Callback was nil: "..name)
                        return true
                end
                local result = cb(...)
                --local us = t.us
                --if us>5000 and name~="GFX.frameCallback" then
                --        print("callback \""..name.."\" took "..us/1000 .."ms ")
                --end
                return result
            end)
            failName.name = nil

        end,error_handler)

        if failName.name then
            print("Removed frameCallback: " .. failName.name)
            main.frameCallbacks:removeByName(failName.name)
        end

        if not gge_gfx_window_active() then
            --sleep_seconds(0.2)
            gge_sleep(200000)
        end

    end

	game_manager:exit()
	
    save_user_cfg()
end

main:run()