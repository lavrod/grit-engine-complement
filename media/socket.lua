net = {}
net.tcp = {}

net.tcp.server = {
    buf = nil;
    timeout=0;
    blocking=false;
    sleeping=false;
    max_recv = -1;

    send = function( self, msg )
      print("to tcp srv:".." msg:"..tostring(msg))
           local message = gge_net_make_message()
            message:write_string(msg)
           gge_net_send_packet("tcpserver", net.tcp.server.debugger, message)
    end;
    
    resume = function()
      print("resume")
        if net.tcp.server.sleeping == true then
          coroutine.resume(coro_debugger)
        end
    end;

    wakeup_poll = function()
      print("wakeup_poll")
       if net.tcp.server:poll() == true and (net.tcp.server.size == net.tcp.server.max_recv or #net.tcp.server.buf >= net.tcp.server.size) then
            net.tcp.server.sleeping = false
          coroutine.resume(coro_debugger)
       else
          scheduler:timer(nil,0.2,net.tcp.server.wakeup_poll)
       end
    end;
  
    sleep_until_data = function(self)
            print("sleep_until_data")
        if self.sleeping == false then
            self.sleeping = true
            
            scheduler:timer(nil,0.2,net.tcp.server.wakeup_poll)
            coroutine.yield()

        end    
    end;
  
    sleep_upto = function( self, timeout )
            print("sleep_upto")      
        if self.sleeping == false then
            self.sleeping = true
            scheduler:timer("sleep_upto",timeout,net.tcp.server.resume)
            coroutine.yield()
            net.tcp.server.sleeping = false
        end
    end;

    getmax = function( self )
            print("getmax")  
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
            print("getfix") 
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
                  print("get") 
           if self.buf and size > 0 and #self.buf > 0 and #self.buf >= size then
             local buffer = string.sub(self.buf,1,size)
             self.buf = string.sub(self.buf,1+size,#self.buf)
             return buffer
           else
             return nil
           end
    end;

    receive = function( self, from, size )
                  print("receive") 
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
                        print("poll") 
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
   
            print("from tcp srv:"..tostring(addr).." port:"..tostring(port).." msg:"..tostring(buffer))
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
          print("settimeout") 
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


socket = {}

local function tcp ()
       return socket, true
end

local function connect(host,port)
  print("port="..port)
   local tuple = port..":"..8172
   local server = gge_net_resolve_address(tuple)
   print("Server Addr:Port="..tostring(server))

   if not net.tcp.server.debugger then
      net.tcp.server.debugger = server
   end

   return net.tcp.server, true
end 


socket.tcp = tcp
socket.connect = connect
socket.settimeout = net.tcp.server.settimeout
socket.receive = net.tcp.server.receive
socket.poll = net.tcp.server.poll
socket.getmax = net.tcp.server.getmax
socket.get = net.tcp.server.get
socket.sleep_until_data = net.tcp.server.sleep_until_data
socket.sleep_upto = net.tcp.server.sleep_upto
socket.send = net.tcp.server.send
socket.wakeup_poll = net.tcp.server.wakeup_poll
socket.getfix = net.tcp.server.getfix

return socket