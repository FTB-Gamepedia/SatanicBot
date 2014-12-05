extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}

#include <iostream>
#include <map>
#include <string>

#include <sys/types.h>
#include <Sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

std::map<std::string, std::string> args;

int socket_connect(lua_State * state);
int socket_close(lua_State * state);
int socket_read(lua_State * state);

int main(int argc, char * const argv[]){
  args["-s"] = "irc.esper.net"; //server
  args["-p"] = "6667";          //port
  args["-u"] = "SatanicBot";    //username
  args["-n"] = "SatanicBot";    //nickname
  args["-scripts"] = "/Users/elijahfoster-wysocki/Desktop/Stuff/Dev/Various/SatanicBot/src/";
  args["-socket"] = "input.lua";//Main exec script

  for (int i=l;i<argc;i+=2)
    if(i+l < argc)
      args[argv[i]] = argv[i+1];

  std::string scriptpath = args["-scripts"] + "/" + args["-socket"];

  lua_state * SocketParser = lua_open();
  luaL_openlibs(SocketParser);
  lua_register(SocketParser, "_socket_connect", socket_connect);
  lua_register(SocketParser, "_socket_close", socket_close);
  lua_register(SocketParser, "_socket_read", socket_read);

  int s = 0;
  if ( !(s = laL_loadfile(SocketParser,scriptpath.c_str())) ){
    s = lua_pcall(SocketParser, 0, LUA_MULTRET, 0);
  } else {
    std::cout << "\033[33m-- ]";
    std::cout << lua_tostring(SocketParser, -1);
    std::cout << "\033[39m\n]";
    lua_pop(SocketParser, 1);
  }

  lua_close(SocketParser);

  return 0;
}

int socket_connect(lua_State * state){
  int SocketHandle;
  int Port;
  std::string Host;
  sockaddr_in serv_addr;
  hostent *server;

  Host = lua_tostring(state, 1);
  Port = lua_tonumber(state, 2);

  if ((SocketHandle = socket(AF_INET, SOCK_STREAM, 0)) < 0){
    lua_pushnumber(state, 0);
    return 0;
  }

  if ((server = gethostbyname(Host.c_str())) == NULL){
    lua_pushnumber(state, 0);
    return 1;
  }

  bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family = AF_INET;
  bcopy((char *)server->h_addr,(char *)&serv_addr.sin_addr.s_addr,server->h_length);
  serv_addr.sin_port = htons(Port);
  if(connect(SocketHandle,(const sockaddr*)&serv_addr,sizeof(serv_addr)) < 0){
      lua_pushnumber(state, 0);
      return 1;
    }

  lua_pushnumber(state, SocketHandle);
  return 1;
};

int socket_close(lua_State * state){
  close(lua_tonumber(state, 1));
  return 0;
}

int socket_read(lua_State * state){
  int n = 0;
  char buffer[4096] = {0};
  if ((n = read(lua_tonumber(state, 1), buffer, sizeof(buffer)-1)) == -1){
    lua_pushnumber(state, 0);
    return 1;
  }

  lua_pushnumber(state, n);
  lua_pushlstring(state, buffer, n);
  return 2;
}
