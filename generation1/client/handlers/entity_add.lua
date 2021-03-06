-- used to add player on join
local _=function(data,clientId)
	log("entity_add:"..pack(data))
	
	local entities=data.entities
	local login=data.originalLogin
	
	local isOurs=Session.login==login
	
	-- сейчас сущность перезаписывается, можно сделать с обновлением, но лучше немутабельность
	
	if isOurs then
		-- unregister old
		
		for k,entity in pairs(entities) do
			log("entities_transferred deleting prev:"..Entity.toString(entity).." prevId:"..entity.prevId)
			Entity.delete(entity.entity,entity.prevId)
			
			local testIsDeleted=Entity.find(entity.entity,entity.prevId)
			if testIsDeleted then 
				log("error: entity not deleted")
			end
			
		end
	else
		log("entities_add not ours")
	end
	
	-- register new
	for k,entity in pairs(entities) do
		entity.aiEnabled=false -- ai is server-only
		Entity.register(entity)
	end
	
	Entity.debugPrint()
end


return _