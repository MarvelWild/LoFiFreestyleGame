local entity_name=Pow.currentFile()
local _=BaseEntity.new(entity_name,true)

local _craftables=nil

--_.drawUnscaledUi=function()
--	love.graphics.print(entity_name.."unscaled")
--end

_.draw_ui=function()
	-- overlay
	love.graphics.setColor(0, 0.2, 0.2, 0.8)
	
	local width, height = love.window.getMode( )
	love.graphics.rectangle("fill",0,0,width,height)
	
	love.graphics.setColor( 1, 1, 1, 1)
	
	-- items
	local x=16
	local y=16
	for k,craftable in pairs(_craftables) do
		local craftable_name=craftable.name
		local icon=Img.get(craftable_name)
		love.graphics.draw(icon,x,y)
		
		craftable.x=x
		craftable.y=y
		craftable.w=icon:getWidth()
		craftable.h=icon:getHeight()
		
		y=y+24
	end
	
--	love.graphics.print("wasted",94,116)
end

_.set=function(craftables)
	_craftables=craftables
end


_.mouse_pressed_exclusive=true


-- wip: ui coords
_.mousePressed=function(gameX,gameY,button,istouch)
	if button~=1 then return end
	
	-- todo: generic bbox hit
	for k,craftable in pairs(_craftables) do

		local x1=craftable.x
		local x2=x1+craftable.w
		if gameX>x1 and gameX<x2 then
			local y1=craftable.y
			local y2=y1+craftable.h
			if gameY>x1 and gameX<x2 then
				log("clicked:"..craftable.name)
				-- wip
			end
		end
	end
	
end



return _