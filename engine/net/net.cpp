#include <sleep.h>

#include <centralised_log.h>
#include "net.h"

#include "net_manager.h"

static NetManager* netManager;

void net_init()
{
    netManager = new NetManager();
}

void net_shutdown(lua_State *L)
{
    netManager->getCBTable().clear(L); //closing LuaPtrs
    
    delete netManager;
}

void net_process(lua_State* L)
{
    APP_ASSERT(netManager != NULL);

    netManager->process(L);
}

int net_process_poll_server(lua_State* L, NetAddress **from, std::string& data)
{
    APP_ASSERT(netManager != NULL);

    return netManager->process_poll_server(L,from,data);
}

int net_process_poll_client(lua_State* L, NetAddress **from, std::string& data)
{
    APP_ASSERT(netManager != NULL);

    return netManager->process_poll_client(L,from,data);
}

int net_process_poll_remote_tcp_server(lua_State* L, NetAddress **from, std::string& data)
{
    APP_ASSERT(netManager != NULL);

    return netManager->process_poll_remote_tcp_server(L,from,data);
}

void net_send(NetChannel channel, NetAddress& address, const char* packet, uint32_t packetLength)
{
    APP_ASSERT(netManager != NULL);

    std::string s = std::string(packet, packetLength);
    netManager->sendPacket(channel, address, s);
}

bool net_get_loopback_packet(NetChannel channel, std::string& packet)
{
    APP_ASSERT(netManager != NULL);

    return netManager->getLoopbackPacket(channel, packet);
}

void net_set_callbacks(ExternalTable& table, lua_State* L)
{
    APP_ASSERT(netManager != NULL);

    netManager->setCBTable(table);
    
    table.clear(L); //ensure setNil() is called so we don't get LuaPtr shutdown error
}
