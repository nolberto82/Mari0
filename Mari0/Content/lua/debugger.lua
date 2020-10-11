
local lrdb = require("lrdb_server")
lrdb.activate(21110) --21110 is using port number. waiting for connection by debug client.

--debuggee lua code
dofile(main.lua);

lrdb.deactivate() --deactivate debug server if you want.