-- (c) David Cunningham and the Grit Game Engine project 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

include `client_input.lua` 

local STATE_IDLE = 1
local STATE_CHALLENGING = 2
local STATE_CONNECTING = 3
local STATE_CONNECTED = 4
local STATE_INGAME = 5

if net.client ~= nil then
    main.frameCallbacks:removeByName("net_client")
end

net.client = {}

net.client.clientTime = 0
net.client.lastTime = seconds()
net.client.lastMessageTime = 0

net.client.timeBase = 0

net.client.state = STATE_IDLE

net.client.curServer = nil

net.client.process = function(self)
    if not net.runningClient then
        return
    end
    
    -- update time
    local elapsedTime = seconds() - self.lastTime
    self.clientTime = self.clientTime + elapsedTime
    
    self.lastTime = seconds()
    
    -- check for state
    if self.state ~= STATE_IDLE then
        -- create user command
        client_input:createCommand()
        
        -- check if we timed out
        self:checkForTimeout()
        
        -- check if a packet needs sending
        self:checkCommandPacket(elapsedTime)
        self:checkConnectPacket()
    end
end

net.client.checkForTimeout = function(self)
    if self.state == STATE_IDLE then return end
    
    if (self.clientTime - self.lastMessageTime) > 30 then
        print("Server connection timed out.")
        self.state = STATE_IDLE
        self.currentServer = nil
    end
end

net.client.lastConnectTime = 0
net.client.serverChallenge = 0

net.client.checkConnectPacket = function(self)
    if self.state == STATE_CHALLENGING then
        if (self.clientTime - self.lastConnectTime) > 2 then
            local message = net_make_message()
            message:write_int(-1)
            message:write_int(2, 8)
            
            net_send_packet("server", self.currentServer, message)
            
            self.lastConnectTime = self.clientTime
        end
    elseif self.state == STATE_CONNECTING then
        if (self.clientTime - self.lastConnectTime) > 2 then
            local message = net_make_message()
            message:write_int(-1)
            message:write_int(3, 8)
            message:write_int(self.serverChallenge)
            
            net_send_packet("server", self.currentServer, message)
            
            self.lastConnectTime = self.clientTime
        end
    end
end

net.client.maxCommands = 30
net.client.timeSinceLastPacket = 0

net.client.checkCommandPacket = function(self, elapsed)
    if self.state ~= STATE_CONNECTED and self.state ~= STATE_INGAME then
        return
    end
    
    self.timeSinceLastPacket = self.timeSinceLastPacket + elapsed
    
    if self.timeSinceLastPacket > (1 / self.maxCommands) then
        self:sendCommandPacket()
    end
end

net.client.lastReliableMessage = 0
net.client.lastServerMessage = 0
net.client.commandSequence = 0

net.client.sendCommandPacket = function(self)
    local message = net_make_message()
    
    message:write_int(self.lastServerMessage)
    message:write_int(self.lastReliableMessage)
    
    -- to be replaced by state id
    message:write_int(1)
    
    -- TODO: reliable messages
    
    -- user commands
    message:write_int(1, 8)
    
    -- command count
    message:write_int(#client_input.commandQueue, 8)
    
    local command = client_input:getCommand()
    local lastCommand = nil
    
    while command ~= nil do
        -- write the command
        command:serialize(message, lastCommand)
        
        -- set the new command as base
        lastCommand = command
    
        command = client_input:getCommand()
    end
    
    -- end of command
    message:write_int(255, 8)
    
    -- send to server
    self.serverChannel:send(message)
    
    self.commandSequence = self.commandSequence + 1
end

net.client.processPacket = function(self, address, message)
    print("client: packet from " .. tostring(address))

    local sequenceNum = message:read_int()
    
    if sequenceNum == -1 then
        return self:processOutOfBand(address, message)
    end
    
    if address ~= self.serverChannel.address then return end
    
    if serverChannel:processPacket(message:clone()) then
        self:processServerMessage(message)
    end
end

net.client.processOutOfBand = function(self, address, message)
    local oobType = message:read_int(8)
    
    print("CL OOB message: type " .. oobType)
    
    if oobType == (128 + 2) then -- challenge response
        if self.state ~= STATE_CHALLENGING then
            return
        end
        
        self.lastConnectTime = -9999
        self.lastMessageTime = self.clientTime
        
        self.serverChallenge = message:read_int()
        
        self.state = STATE_CONNECTING
    elseif oobType == (128 + 3) then -- connect response
        if self.state ~= STATE_CONNECTING then
            return
        end
        
        self.clientNum = message:read_int(8)
        
        self.lastConnectTime = -9999
        self.lastMessageTime = self.clientTime
        
        self.serverChannel = NetChannel.new("server", self.currentServer)
        
        self.state = STATE_CONNECTED
    end
end

main.frameCallbacks:insert("net_client", function()
    net.client.process(net.client)
end)

function connect(host)
    if host == nil then return end
    
    if net.runningServer then
        print("Client and server can not be running at the same time currently")
        
        return
    end
    
    local server = net_resolve_address(host)
    
    if server ~= net.client.currentServer then
        net.client.currentServer = server
        
        net.client.state = STATE_CHALLENGING
        
        net.client.lastMessageTime = net.client.clientTime
        net.client.lastConnectTime = -9999
        
        net.runningClient = true
    end
end
