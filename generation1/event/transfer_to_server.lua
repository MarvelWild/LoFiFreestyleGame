--[[ пример использования: 
Entity.transferToServer({grass}) -- on use
]]--
local _=function(event)
	-- server only event, not processed on client
	-- todo: generic way toi mark event as server only (event flag)
	if Session.isServer then
		log("processing transfer_to_server event")
		Entity.acceptAtServer(event.entities)
	end
end

return _