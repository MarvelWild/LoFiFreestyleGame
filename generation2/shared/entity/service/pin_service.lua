-- shared
-- pin one entity to another, so children move with parent


-- just uncomment log messages when debugging, better for performance
--local _debug=true

local _entity_name='PinService'
local _=BaseEntity.new(_entity_name, true)
-- local _={}


-- k=follow
-- v={lead,p1,p2}
local _pins={}


local new_pin=function(lead,lead_x,lead_y,follow_x,follow_y)
	local pin={}
	pin.lead=lead
	pin.lead_x=lead_x
	pin.lead_y=lead_y
	pin.follow_x=follow_x
	pin.follow_y=follow_y
	
	return pin
end


-- todo: call from event
-- happens locally.
-- lead - сущность к которой прикрепляем
-- follow - сущность которую прикрепляем
-- lead_x -  в какой точке прикрепляем к lead
-- follow_x -  в какой точке прикрепляем к follow
_.pin=function(lead,follow,lead_x,lead_y,follow_x,follow_y)
	local existing=_pins[follow]
	if existing then
		log("pin update data:".._str(existing))
		
		existing.lead=lead
		existing.lead_x=lead_x
		existing.lead_y=lead_y
		existing.follow_x=follow_x
		existing.follow_y=follow_y
	else
		local pin=new_pin(lead,lead_x,lead_y,follow_x,follow_y)
		
		_pins[follow]=pin
--		table.insert(_pins,pin)
--		log("pinned new:".._str(pin))
		log("pinned new. lead:".._ets(lead).." follow:".._ets(follow),"verbose")
	end
end

-- todo should be called when entities finished moving
_.update=function()
	-- todo: test call order, / update levels - explicit priority (явный)
--	log("pins update coord start")
	
	
	-- opt: only if moved / on moved event
	for follow,pin in pairs(_pins) do
--		log("updating pin:".._str(pin))
		
		local lead=pin.lead
		
		
		local lead_dx=pin.lead_x
-- todo		
--		if lead.is_watching_left then
--			lead_dx=-lead_dx
--		end
		
		
		local follow_new_x=lead.x+lead_dx-follow.origin_x
		local follow_new_y=lead.y+pin.lead_y-follow.origin_y
		
		local is_moved=
			follow_new_x~=follow.x or
			follow_new_y~=follow.y
			
		if is_moved then
			Movable.instant_move(follow,follow_new_x,follow_new_y)
			--log("pinned entity coord updated:".._xy(follow_new_x,follow_new_y))
		else
			local a=1
		end
	end
end


_.unpin=function(follow)
	local existing=_pins[follow]
	if not existing then
		log("warn:unpin when no pin")
		return
	end
	
	_pins[follow]=nil
end



return _