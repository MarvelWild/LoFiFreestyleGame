local _={}

_.new=function()
	local result=BaseEntity.new()
	result.entity="Server"
	result.id=nil -- we are service, no serialization
	result.isActive=true
	
	-- Grease.tcpServer
	result.tcpServer=nil
	
	Entity.register(result)
	
	return result
end

-- Static
_.clientsByLogin={}
_.loginByClient={}
_.commandHandlers={}
loadScripts("server/handlers/", _.commandHandlers)

_.registerClient=function(clientId,login)
	_.clientsByLogin[login]=clientId
	_.loginByClient[clientId]=login
end






_.sendFiltered=function(data,excludedLogin)
	for login,client in pairs(_.clientsByLogin) do
		if login~=excludedLogin then
			Server.send(data,client)
		end
	end
end


-- единственная точка через которую сервер отправляет сообщения
_.send=function(data, clientId,requestId)
	data.requestId=requestId
	local cmd=data.cmd
	
	local packed=pack(data)
	
	local sendLen=string.len(packed)
	
	if requestId==nil then requestId="nil" end
	if cmd==nil then cmd="nil" end
	local sendInfo="sending rqid="..requestId.." cmd="..cmd.." size="..sendLen.." data:"..packed
	log(sendInfo)
	
	ServerEntity.tcpServer:send(packed..NET_MSG_SEPARATOR, clientId)
end


-- static end

local connect=function(id)
	-- id is userdata if tcp
	log("Client connected")

	-- report back to the client with ID
	--self:sendWelcome(id)
	--self:sendSnapshot(id)	
end

local recv=function(data, id)
	log("recv:"..data)
	local dataParts=string.split(data,NET_MSG_SEPARATOR)
	
	for k,dataCommand in pairs(dataParts) do
		local command=TSerial.unpack(dataCommand)
		local handler=_.commandHandlers[command.cmd]
		if handler==nil then 
			log("error: no handler for cmd:"..command.cmd) 
		else
			handler(command,id)
		end
	end
end

local disconnect=function(ip, port)
	log("disconnect:"..ip..":"..port)
end

local handshake=">>"
local port="8421"

_.activate=function(server)
	--log("server activate")
	
	local tcpServer=Grease.tcpServer()
	server.tcpServer=tcpServer
	local callbacks=tcpServer.callbacks
	callbacks.connect=connect
	callbacks.recv=recv
	callbacks.disconnect=disconnect
	tcpServer.handshake=handshake
	
	tcpServer:listen(port)
	log("tcp server started on "..port)
end


_.update=function(server,dt)
	-- log("server update")
	server.tcpServer:update(dt)
end




_.sendEventsToClients=function(events)
	for login,client in pairs(_.clientsByLogin) do
		local preparedEvents=Event.prepareEventsForLogin(login,events)
		
		if next(preparedEvents)~=nil then
			local command=
			{
				cmd="events_client",
				events=events
			}
			
			if Config.isDebug then
				for k,event in pairs(events) do
					log("sending event:"..Event.toString(event))
				end
			end
			
			Server.send(command)
		else
			log("no events for:"..login)
		end
	end
end

return _