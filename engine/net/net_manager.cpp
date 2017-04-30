#include <cstdlib>

#include <sleep.h>

#include <centralised_log.h>

#include "../grit_lua_util.h"

#include "net.h"
#include "net_manager.h"
#include "lua_wrappers_net.h"

NetManager::NetPacket::NetPacket(NetAddress& from, std::string& data_) {
    addr = from;
    data = data_;
    time = micros();
}

#if defined(WIN32)
#    define sock_errno WSAGetLastError()
#    define ADDRESS_ALREADY_USED WSAEADDRINUSE
#    define WOULD_BLOCK WSAEWOULDBLOCK
#    define CONNECTION_RESET WSAECONNRESET
#else
#   define sock_errno errno
#   define closesocket close
#   define ioctlsocket ioctl
#    define WOULD_BLOCK EAGAIN
#    define CONNECTION_RESET ECONNRESET
#    define ADDRESS_ALREADY_USED EADDRINUSE
#endif

NetManager::NetManager()
    : forcedLatency(0)
{
#if defined(WIN32)
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        GRIT_EXCEPT("WSAStartup failed");
    }
#endif

    netSocketClient = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

	netSocketServer = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    // FIXME win32 dependency
    if (netSocketServer == INVALID_SOCKET) {
        GRIT_EXCEPT("socket server creation failed");
    }

    netSocketClient = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);

    // FIXME win32 dependency
    if (netSocketClient == INVALID_SOCKET) {
        GRIT_EXCEPT("socket client creation failed");
    }

    uint16_t port = 48960;

    while (true) {
        sockaddr_in bindEP;
        memset(&bindEP, 0, sizeof(bindEP));
        bindEP.sin_family = AF_INET;
        bindEP.sin_addr.s_addr = INADDR_ANY;
        bindEP.sin_port = htons(port);

        if (bind(netSocketServer, (sockaddr*)&bindEP, sizeof(bindEP)) != 0) {
            if (sock_errno == ADDRESS_ALREADY_USED) {
                port++;
                continue;
            } else {
                GRIT_EXCEPT("binding socket failed");
            }
        }

        break;
    }

    CLOG << "Listening on port " << port << std::endl;

    // set non-blocking mode
    u_long nonBlocking = 1;

    ioctlsocket(netSocketServer, FIONBIO, &nonBlocking);
    ioctlsocket(netSocketClient, FIONBIO, &nonBlocking);
}

NetManager::~NetManager()
{
    if (netSocketServer) {
        closesocket(netSocketServer);
    }

#if defined(WIN32)
    WSACleanup();
#endif
}

void NetManager::processPacket(lua_State* L, NetAddress& from, std::string& data)
{
    STACK_BASE;

    push_cfunction(L, my_lua_error_handler);
    int error_handler = lua_gettop(L);

    const char* err = netCBTable.luaGet(L, "process_packet");

    if (err) {
        my_lua_error(L, err);
    }

    STACK_CHECK_N(2);

    push_netaddress(L, NetAddressPtr(new NetAddress(from)));
    push_netmessage(L, NetMessagePtr(new NetMessage(data.c_str(), data.size())));

    STACK_CHECK_N(4);

    // note this pops the args and the function from the stack
    int status = lua_pcall(L, 2, 0, error_handler);

    if (status) {
        STACK_CHECK_N(2);
        lua_pop(L, 1); // pop the error

        CERR << "Encountered an error during processing of a network packet." << std::endl;

        STACK_CHECK_N(1);
    }

    // empty the stack
    STACK_CHECK_N(1);
    lua_pop(L, 1);
    STACK_CHECK;
}

int NetManager::process_poll_server(lua_State* L, NetAddress **from, std::string& data)
{
	int bytes = 0;
	char buffer[16384];
	sockaddr_storage remoteEP;
	socklen_t remoteEPLength = sizeof(remoteEP);

	if ((bytes = recvfrom(netSocketServer, buffer, sizeof(buffer), 0, (sockaddr*)&remoteEP, &remoteEPLength)) > 0)
	{
		//CLOG << "recvfrom " << bytes << std::endl;
                //char hex[256];
                //sprintf(hex,"%02x%02x%02x%02x%02x%02x",(unsigned char)buffer[0],(unsigned char)buffer[1],(unsigned char)buffer[2],(unsigned char)buffer[3],(unsigned char)buffer[4],(unsigned char)buffer[5]);
		//CLOG << hex << std::endl;
		data.assign(buffer, bytes);
		NetAddress from_addr((sockaddr*)&remoteEP, remoteEPLength);
                *from = &from_addr;
       	}
        else
        {
	     if( bytes < 0 )
             {
		if (sock_errno != WOULD_BLOCK && sock_errno != CONNECTION_RESET)
		{
			CLOG << "socket error " << sock_errno << std::endl;
		}
             }
        }
 	return bytes;
}

int NetManager::process_poll_client(lua_State* L, NetAddress **from, std::string& data)
{
    int bytes = 0;
    char buffer[16384];
    sockaddr_storage remoteEP;
    socklen_t remoteEPLength = sizeof(remoteEP);

    if ((bytes = recvfrom(netSocketClient, buffer, sizeof(buffer), 0, (sockaddr*)&remoteEP, &remoteEPLength)) > 0) {
        data.assign(buffer, bytes);
        NetAddress from_addr((sockaddr*)&remoteEP, remoteEPLength);
        *from = &from_addr;
    }
    else {
        if( bytes < 0 ) {
            if (sock_errno != WOULD_BLOCK && sock_errno != CONNECTION_RESET) {
                CLOG << "socket error " << sock_errno << std::endl;
            }
        }
    }
    return bytes;
}

void NetManager::process(lua_State* L)
{
    char buffer[16384];
    int bytes = 0;
    sockaddr_storage remoteEP;
    socklen_t remoteEPLength = sizeof(remoteEP);

    while (true) {
        bytes = recvfrom(netSocketServer, buffer, sizeof(buffer), 0, (sockaddr*)&remoteEP,
                         &remoteEPLength);
        if (bytes < 0) {
            if (sock_errno != WOULD_BLOCK && sock_errno != CONNECTION_RESET) {
                CLOG << "socket error " << sock_errno << std::endl;
            } else {
                break;
            }
        }

        if (bytes > 0) {
            std::string data(buffer, bytes);
            NetAddress from((sockaddr*)&remoteEP, remoteEPLength);

            if (forcedLatency == 0) {
                processPacket(L, from, data);
            } else {
                receiveQueue.push(NetPacket(from, data));
            }
        }

        // process queues
        uint64_t time = micros();

        if (!sendQueue.empty()) {
            do {
                NetPacket packet = sendQueue.front();

                if (time >= (packet.time + (forcedLatency * 1000))) {
                    sendPacketInternal(packet.addr, packet.data);

                    sendQueue.pop();
                } else {
                    break;
                }
            } while (!sendQueue.empty());
        }

        if (!receiveQueue.empty()) {
            do {
                NetPacket packet = receiveQueue.front();

                if (time >= (packet.time + (forcedLatency * 1000))) {
                    processPacket(L, packet.addr, packet.data);

                    receiveQueue.pop();
                } else {
                    break;
                }
            } while (!receiveQueue.empty());
        }
    }
}

void NetManager::sendPacket(NetChannel channel, NetAddress& address, std::string& data)
{
    if (address.getType() == NetAddress_Loopback) {
        sendLoopbackPacket(channel, data);
    } else {
        if (forcedLatency > 0) {
            sendQueue.push(NetPacket(address, data));
        } else {
            //sendPacketInternal(address, data);
            sockaddr_storage to;
            int toLen;

            address.getSockAddr(&to, &toLen);

            if( channel != NetChan_ClientToServer )
                sendto(netSocketServer, data.c_str(), data.size(), 0, (sockaddr*)&to, toLen);
            else
                sendto(netSocketClient, data.c_str(), data.size(), 0, (sockaddr*)&to, toLen);
        }
    }
}

void NetManager::sendPacketInternal(NetAddress& netAddress, std::string& packet)
{
    sockaddr_storage to;
    int toLen;

    netAddress.getSockAddr(&to, &toLen);

    sendto(netSocketServer, packet.c_str(), packet.size(), 0, (sockaddr*)&to, toLen);
}

void NetManager::sendLoopbackPacket(NetChannel channel, std::string& packet)
{
    if (channel == NetChan_ClientToServer) {
        serverLoopQueue.push(packet);
    } else if (channel == NetChan_ServerToClient) {
        clientLoopQueue.push(packet);
    }
}

bool NetManager::getLoopbackPacket(NetChannel channel, std::string& packet)
{
    std::queue<std::string>* queue = NULL;

    if (channel == NetChan_ClientToServer) {
        queue = &serverLoopQueue;
    } else if (channel == NetChan_ServerToClient) {
        queue = &clientLoopQueue;
    }

    if (queue != NULL) {
        if (!queue->empty()) {
            packet = queue->front();
            queue->pop();

            return true;
        }
    }

    return false;
}

void NetManager::setCBTable(ExternalTable& table)
{
    this->netCBTable = table;
}

ExternalTable& NetManager::getCBTable()
{
    return this->netCBTable;
}
