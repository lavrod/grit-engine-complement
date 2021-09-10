-- (c) David Cunningham and the Grit Game Engine project 2013, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

ClientKey = {}

function ClientKey:setDown(down)
    self.down = down
end

function ClientKey.new()
    local self = {}
    self.down = false
    
    make_instance(self, ClientKey)
    return self
end

client_input = {}
client_input.keys = {
    forwards = ClientKey.new(),
    backwards = ClientKey.new(),
    left = ClientKey.new(),
    right = ClientKey.new(),
}

client_input.commandArchive = {}
client_input.commandQueue = {}

client_input.commandNum = 0

local function compare_keys(l, r)
    for k, v in pairs(l) do
        if r[k] ~= v then return false end
    end
    
    return true
end

client_input.serializeCommand = function(self, message, base) -- self is command
    if base == nil then
        message:write_int(self.serverTime * 1000)
        
        for _,v in pairs(self.keys) do
            message:write_bool(v)
        end
    else
        if (self.serverTime - base.serverTime) < 0.255 then -- 0.255? what is this?
            message:write_bool(true)
            message:write_int((self.serverTime - base.serverTime) * 1000, 8)
        else
            message:write_bool(false)
            message:write_int(self.serverTime * 1000)
        end
        
        if not compare_keys(self.keys, base.keys) then
            message:write_bool(true)
        
            for _,v in pairs(self.keys) do
                message:write_bool(v)
            end
        else
            message:write_bool(false)
        end
    end
end

client_input.createCommand = function(self)
    local command = {}
    command.serverTime = gge_seconds() + net.client.timeBase
    
    command.keys = {}
    
    command.serialize = client_input.serializeCommand
    
    for k,v in pairs(self.keys) do
        table.insert(command.keys, v.down)
    end
    
    table.insert(self.commandQueue, command)
    
    self.commandArchive[self.commandNum % 64] = command
    self.commandNum = self.commandNum + 1
end

client_input.getCommand = function(self, index)
    if index == nil then
        if #self.commandQueue == 0 then
            return nil
        else
            return table.remove(self.commandQueue, 1)
        end
    else
        if index <= (self.commandNum - 64) then
            return nil
        else
            return commandArchive[index % 64]
        end
    end
end

for i = 1, 64 do
    client_input.commandArchive[i] = 0
end
