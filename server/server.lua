
local server = require 'http.server'
local websocket = require 'http.websocket'
local cqueues = require 'cqueues'
local uuid = require "lua_uuid"

local conf = {
  host = '127.0.0.1',
  port = 4000
}

local cq = cqueues.new()

local clients = {}

local function send_to_clients(cli,sender,msg)
  for _, ws in pairs(cli) do
    ws:send(sender..":"..msg)
  end
end

cq:wrap(function ()
  local s = server.listen({
    host = conf.host,
    port = conf.port,
    onstream = function (_,st)
      local ws = websocket.new_from_stream(st, st:get_headers())
      ws:accept()
      -- now that the client is connected
      -- generate him a UUID
      local my_uuid = uuid()
      print('new clients UUID is ' .. my_uuid)
      -- append client to clients table
      clients[my_uuid] = ws
      -- send him the uuid
      ws:send("uuid:" .. my_uuid)
      while true do
        local message, error_description, error_code = ws:receive()
        if message == nil then
          print(message,error_description,error_code) -- print error message
          break -- break from loop
        end
        send_to_clients(clients,my_uuid,message)
      end
      -- remove client from clients list
      clients[my_uuid] = nil
      -- close the connection
      ws:close()
    end
  })
  s:loop()
end)

cq:loop() -- blocking loop
