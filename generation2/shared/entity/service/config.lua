-- shared config
-- global ConfigService

local _={}

_.port=4242

-- client uses to connect
_.serverHost='127.0.0.1'

-- localhost only
_.serverListen='127.0.0.1'

_.serverFps=60

-- listens on ipv6
-- _.serverListen='*'

-- todo: listen all by default
-- ask community
-- forwarded to internet
-- _.serverListen='192.168.1.195'

return _