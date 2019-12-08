local _={}

_.entityName="player"

_.new=function()
	local result=BaseEntity.new(_.entityName)
	
	result.name='Joe'
	result.levelName='start'
	
	-- todo это свойства спрайта
	result.footX=7
	result.footY=15
	
	
	-- откуда начинается квадрат коллизии
	result.collisionX=3
	result.collisionY=0
	
	-- todo: вторые 2 координаты квадрата коллизии
	
	
	-- used for collisions
	result.w=9
	result.h=16
	
	
	
	result.sprite="player"
	result.login=nil
	
	return result
end

_.getById=function(playerId)
	-- special level for storing logged off players
	local magicLevelContainer=Db.getLevelContainer("player")
	local playerContainer=Db.getEntityContainer(magicLevelContainer, "player")
	local result = playerContainer[playerId]
	return result
end

_.getByLogin=function(login)
	local magicLevelContainer=Db.getLevelContainer("player")
	local playerContainer=Db.getEntityContainer(magicLevelContainer, "player")
	for k,player in pairs(playerContainer) do
		if player.login==login then return player end
	end
	
	return nil
end




_.gotoLevel=function(player, levelName)
	log("gotoLevel:"..levelName.." from:"..player.levelName)
	-- wip:
	
	-- delete from db because db stores entities in level containers
	
	-- hanlded by db->entity
	-- update collision container
	-- CollisionService.removeEntity(player)
	
	-- local prevLevel=player.levelName
	Db.remove(player)
	
	-- remove from prev level,send to all on that level
	-- ServerService.notifyEntityRemoved(player, prevLevel)
	
	-- update prop
	player.levelName=levelName
	Level.activate(levelName)
	
	-- тут лишний раз шлётся актёру todo можно оптимизировать
	Db.add(player)
	
	
	-- CollisionService.addEntity(player) - happens in Db.add
	
	-- update entity container
	-- not needed - single container for all levels
	
	-- send updated player,level
	ServerService.sendFullState(player)
	
	
	-- wip unload prev on client
	-- wip load new on client
	
	
end


--
_.interact=function(player,target)
	local target_code=Entity.getCode(target)
	
	local interact=target_code.interact
	if interact~=nil then
		interact(player,target)
	end
end

return _