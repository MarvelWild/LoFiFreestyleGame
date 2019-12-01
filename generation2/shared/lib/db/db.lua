--[[
global Db
stores-persists entities
format: 
local entitiesContainer=_levelContainer[levelName]
local entityContainer=entitiesContainer[entityName]
local entity=entityContainer[entityId]

server only. todo: make it not exist on client
]]--

local _={}


-- root container
-- level 1 entity names by level name
local _levelContainers={}

local _saveName="db"


local _saveDir=""

-- external hook to notify clients from server
-- server service sends entity_added to level
_.onAdded=nil
local _onRemoved=nil

_.setOnRemoved=function(hook)
	assert(_onRemoved==nil)
	_onRemoved=hook
end



_.init=function(saveDir)
	_saveDir=saveDir
end

-- creates empty
-- 
local getEntityContainer=function(levelContainer, entityName)
	local result = levelContainer[entityName]
	if result==nil then
		result={}
		levelContainer[entityName]=result
	end
	return result
end


-- key=entityName val={id=entity}
local getLevelContainer=function(levelName)
	local result = _levelContainers[levelName]
	if result==nil then 
		result={}
		if _levelContainers==nil or levelName==nil then
			local a=1
		end
		
		_levelContainers[levelName]=result
	end
	
	return result
end




-- put entity into level
-- levelName optional
_.add=function(entity, levelName)
	assert(entity)
	
	if levelName==nil then
		levelName=entity.levelName
		assert(levelName)
	else

		if levelName~="player" then
			entity.levelName=levelName
		end
		
	end
	
	local levelContainer=getLevelContainer(levelName)
	
	local entityName=entity.entityName
	
	local entityContainer=getEntityContainer(levelContainer,entityName)
	-- table.insert(entityContainer, entity)
	local entityId=entity.id
	assert(entityContainer[entityId]==nil)
	entityContainer[entityId]=entity
	
	if Level.isActive(levelName) then
		-- todo: preevent double add
		Entity.add(entity)
	end
	
	
	if _.onAdded~=nil then
		_.onAdded(entity, levelName)
	end
	
end

-- remove entity from level
_.remove=function(entity,levelName)
	if levelName==nil then
		levelName=entity.levelName
		assert(levelName)
	end
	
	local levelContainer=getLevelContainer(levelName)
	
	local entityName=entity.entityName
	
	local entityContainer=getEntityContainer(levelContainer,entityName)
	-- table.insert(entityContainer, entity)
	local entityId=entity.id
	if (entityContainer[entityId]==nil) then
		log("warn: trying to delete entity that is not present")
	end
	
	entityContainer[entityId]=nil
	
	if Level.isActive(levelName) then
		Entity.remove(entity)
	end
	
	if _onRemoved~=nil then
		-- sends entity_removed notification
		_onRemoved(entity, levelName)
	end
end

local get=function(levelName,entityName, entityId)
	local levelContainer=getLevelContainer(levelName)
	local entityContainer=getEntityContainer(levelContainer, entityName)
	local result = entityContainer[entityId]
	return result
end

local getByRef=function(ref, levelName)
	return get(levelName, ref.entityName, ref.id)
end

_.get=get
_.getByRef=getByRef
_.getLevelContainer=getLevelContainer
_.getEntityContainer=getEntityContainer

_.save=function()
	log('db save')
	
	local serialized=Pow.serialize(_levelContainers)
	love.filesystem.write(_saveDir.._saveName, serialized)
end

_.load=function()
	log('db load', "db")
	
	local serialized=love.filesystem.read(_saveDir.._saveName)
	
	if serialized~=nil then
		_levelContainers=Pow.deserialize(serialized)
	else
		_levelContainers={}
	end
end

return _