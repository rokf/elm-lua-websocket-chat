<h4 align="center">Elm & Lua WebSocket communication</h4>

This is a simple example of WebSocket communication between a Lua server and Elm client.
The server is a console application built with the `http`, `lua_uuid` and `cqueues` modules.

The client uses a Flexbox layout, which is made with the help of Tachyons.

Each client is asigned an unique ID after connecting and the first part of
the UUID is taken as the username which is displayed inside the chat.

The server has a clients table which contains all active WebSockets (client connections).
Each socket is saved under a string key which is the users UUID.

On a disconnect event of the client the Elm WebSocket module automatically sends an 1001 error message,
which removes the client from the table on the server side.

The model has a `messages` field. When a new message is received it is added to that list.
Because I had some issues with the `overflow-y-scroll` CSS class there is a limit of
messages that can be displayed at once for the sake of this example.
When the limit is reached the head of the list is discarded and the tail is kept with the new
value appended at the end.

Server dependencies can be installed with LuaRocks. The http rock should also
install cqueues as one of its dependencies.

```
luarocks install http
luarocks install lua_uuid
lua server/server.lua
```

Client dependencies are listed inside the `client/elm-package.json` file and can
be installed with a simple `elm-package install`.
