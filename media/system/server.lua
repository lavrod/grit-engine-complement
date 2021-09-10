-- (c) David Cunningham and the Grit Game Engine project 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

-- client states
local STATE_CONNECTED = 1
local STATE_INITIALIZED = 2
local STATE_ACTIVE = 3
local STATE_ZOMBIE = 4

if net.server ~= nil then
    main.frameCallbacks:removeByName("net_server")
end

net.server = {}
net.server.clients = {}

net.server.stateID = 1

net.server.serverTime = 0
net.server.remainingTime = 0

net.server.lastTime = gge_seconds()

net.server.process = function(self)
    if not net.runningServer then
        return
    end
    
    local elapsedTime = gge_seconds() - self.lastTime
    self.remainingTime = self.remainingTime + elapsedTime
    
    self.lastTime = gge_seconds()
    
    while self.remainingTime > (1 / 20) do
        self.remainingTime = self.remainingTime - (1 / 20)
        self.serverTime = self.serverTime + (1 / 20)
        
        self:processGame()
    end
end

net.server.processGame = function(self)
    -- send snapshots to clients
    self:sendSnapshots()
end

net.server.sendSnapshots = function(self)
    for i = 1, #self.clients do
        if self.clients[i] ~= 0 then
            local client = self.clients[i]
            
            if client.state == STATE_ACTIVE then
                self:sendSnapshot(client)
            end
        end
    end
end

net.server.sendSnapshot = function(self, client)
    
end

net.server.processPacket = function(self, address, message)
    gge_print("server: packet from " .. tostring(address))
    
    local sequenceNum = message:read_int()
    
    gge_print("seq: " .. sequenceNum)
    
    if sequenceNum == -1 then
        return self:processOutOfBand(address, message)
    end
    
    for i = 1, #self.clients do
        if self.clients[i] ~= 0 then
            local client = self.clients[i]
            
            if client.address == address then
                if client.channel:processPacket(message:clone()) then
                    self:processClientMessage(client, message)
                end
            end
        end
    end
end

net.server.commandHandlers = {}

net.server.processClientMessage = function(self, client, message)
    client.lastMessageReceivedAt = gge_seconds()
    client.lastAcknowledgedMessage = message:read_int()
    client.reliableAcknowledged = message:read_int()
    
    -- check if this command is from an older initialization state
    local stateID = message:read_int()
    
    if stateID ~= self.stateID then
        if client.lastAcknowledgedMessage >= client.lastInitStateMessage then
            self:sendInitializationState(client)
        end
        
        return
    end
    
    -- process client commands
    xpcall(function()
        local command = message:read_int(8)
        
        while command ~= 255 do
            if self.commandHandlers[command] ~= nil then
                self.commandHandlers[command](self, client, message)
            else
                gge_print("unknown command type " .. tostring(command))
                return
            end
        
            command = message:read_int(8)
        end
    end, function(msg)
        local level = 0
        if type(msg)=="table" then
                level,msg = unpack(msg)
        end
        level = level + 1 -- error handler
        level = level + 1 -- the first line is included in the message so don't gge_print it again
        local tb = debug.traceback(msg,level+1) -- error handler
        tb = tb:gsub("\n[^\n]*\n[^\n]*$","")
        tb = tb:gsub("^[^\n]*\n","") -- msg
        tb = tb:gsub("^[^\n]*\n","") -- "stack trace:"
        gge_print(BOLD..RED..msg)
        if tb ~= "stack traceback:" then gge_print(RED..tb) end
        
        self:dropClient(client, "Error while processing client message.")
    end)
end

net.server.challenges = {}

net.server.processOutOfBand = function(self, address, message)
    local oobType = message:read_int(8)
    
    gge_print("OOB message: type " .. oobType)
    
    -- get server info
    if oobType == 1 then
        local response = gge_net_make_message()
        
        response:write_int(-1)
        response:write_int(1 + 128, 8) -- get info, response
        response:write_string("hello world!")
        
        gge_net_send_packet("client", address, response)
    elseif oobType == 2 then -- get challenge
        local challenge = math.floor((self.serverTime + math.random()) * 1000)
    
        self.challenges[tostring(address)] = challenge
        
        local response = gge_net_make_message()
        
        response:write_int(-1)
        response:write_int(2 + 128, 8) -- get challenge, response
        response:write_int(challenge)
        
        gge_net_send_packet("client", address, response)
    elseif oobType == 3 then -- connect request
        local challenge = message:read_int()
        local challengeMatch = self.challenges[tostring(address)]
        
        if challengeMatch == nil or challengeMatch ~= challenge then return end
        
        self.challenges[tostring(address)] = nil
        
        -- add the client
        for i = 1, #self.clients do
            if self.clients[i] == 0 then
                self.clients[i] = ServerClient.new()
                self.clients[i].channel = NetChannel.new("client", address)
                self.clients[i].clientNum = i
                self.clients[i].address = address
                self.clients[i].lastMessageTime = self.serverTime
                
                local response = gge_net_make_message()
        
                response:write_int(-1)
                response:write_int(3 + 128, 8) -- connect to server, response
                response:write_int(i, 8)
                
                gge_net_send_packet("client", address, response)
                
                break
            end
        end
    end
end

for i = 1, 24 do
    net.server.clients[i] = 0
end

main.frameCallbacks:insert("net_server", function()
    net.server.process(net.server)
end)

ServerClient = {}

function ServerClient.new()
    local self = {}
    
    make_instance(self, ServerClient)
    return self
end
