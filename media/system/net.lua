-- (c) David Cunningham and the Grit Game Engine project 2012, Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php

if net ~= nil then
    main.frameCallbacks:removeByName("net")
end

net = {}
net.showPackets = false

-- netchannel class
NetChannel = {}

function NetChannel:send(message)
    self.sequenceOut = self.sequenceOut + 1
    
    gge_net_send_packet_sequenced(self.channel, self.address, message, self.sequenceOut)
    
    if net.showPackets then
        gge_print(string.format("sending %db, seq=%d", message.length, self.sequenceOut))
    end
end

function NetChannel:processPacket(message)
    return true
end

function NetChannel.new(channel, address)
    local self = {}
    self.channel = channel
    self.address = address
    self.sequenceIn = 0
    self.sequenceOut = 0
    
    make_instance(self, NetChannel)
    return self
end

-- net manager

net.runningClient = true

gge_include `server.lua`
gge_include `client.lua`

net.loopbackAddress = gge_net_resolve_address("localhost:0")

net.process = function()
    -- process the code side of networking
    gge_net_process()
    
    -- handle loopback packets
    if net.runningClient then
        net.processLoopback("client", net.client, net.client.processPacket)
    end
    
    if net.runningServer then
        net.processLoopback("server", net.server, net.server.processPacket)
    end
end

net.processLoopback = function(channel, handler, callback)
    local packet = gge_net_get_loopback_packet(channel)
    
    while packet ~= nil do
        if packet ~= nil then
            callback(handler, net.loopbackAddress, packet)
        end
        
        packet = gge_net_get_loopback_packet(channel)
    end
end

gge_net_register_callbacks({
    process_packet = function(address, message)
        -- listen clients will get handled by loopback channel 'client'
        if net.runningServer then
            net.server:processPacket(address, message)
        else
            net.client:processPacket(address, message)
        end
    end
})

main.frameCallbacks:insert("net", net.process)

-- server/client start apis
function server()
    net.runningClient = false
    net.runningServer = true
end
