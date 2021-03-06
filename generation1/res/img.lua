local Img={}

local baseDir="res/img"

local i=function(path)
	local fileInfo=love.filesystem.getInfo(path)
	if fileInfo==nil then return nil end
	
	return LG.newImage(path)
end


Img.get=function(id)
	
	local result=rawget(Img,id)
	
	if result==nil then
		result=i(baseDir.."/"..id..".png")
		if result==nil then
			log("error: no img by id:"..id)
		end
		
		Img[id]=result
		
		-- log("image loaded:"..id)
	end
	
	return result
end


local mt={}
local _imgGet=Img.get
mt.__index=function(t,key)
	return _imgGet(key)
end

setmetatable(Img,mt)

return Img