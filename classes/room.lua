Room = Class:extend('Room')

function Room:new()
	@.id     = ''
	@.timer  = Timer()
	@.camera = Camera()
	@._queue = {}
	@._ents  = { All = {} }
end

function Room:update(dt)
	@.timer:update(dt)
	@.camera:update(dt)

	-- update entitites
	for @._ents['All'] do 
		it:update(dt) 
	end
	-- delete dead entities
	for @._ents['All'] do 
		if it.dead then
			@._ents['All'][it.id] = nil
			for type in it.types do @._ents[type][it.id] = nil end
		end
	end
	-- push entities from queue
	for queued_ent in @._queue do
		ifor type in queued_ent.types do 
			@._ents[type] = get(@, {'_ents', type}, {})
			@._ents[type][queued_ent.id] = queued_ent
		end
		@._ents['All'][queued_ent.id] = queued_ent
	end
	@._queue = {}
end

function Room:draw()
	local entities = {}
	for @._ents['All'] do table.insert(entities, it) end
	table.sort(entities, fn(a, b) if a.z == b.z then return a.id < b.id else return a.z < b.z end end)

	@.camera:draw(function()
		local _r, _g, _b, _a = love.graphics.getColor()
		@:draw_inside_camera_bg()
		love.graphics.setColor(_r, _g, _b, _a)

		for entities do 
			if it.draw && !it.outside_camera then 
				local _r, _g, _b, _a = love.graphics.getColor()
				it:draw()
				love.graphics.setColor(_r, _g, _b, _a)
			end
		end

		local _r, _g, _b, _a = love.graphics.getColor()
		@:draw_inside_camera_fg()
		love.graphics.setColor(_r, _g, _b, _a)
	end)

	local _r, _g, _b, _a = love.graphics.getColor()
	@:draw_outside_camera_bg()
	love.graphics.setColor(_r, _g, _b, _a)

	for entities do 
		if it.draw && it.outside_camera then
			local _r, _g, _b, _a = love.graphics.getColor()
			it:draw()
			love.graphics.setColor(_r, _g, _b, _a)
		end
	end

	local _r, _g, _b, _a = love.graphics.getColor()
	@:draw_outside_camera_fg()
	love.graphics.setColor(_r, _g, _b, _a)
end

function Room:add(a, b, c)
	local id, types, entity

	if type(a) == 'string' and type(b) == 'table' and type(c) == 'nil' then
		id, types, entity = a, {}, b
	elseif type(a) == 'string' and type(b) == 'table' and type(c) == 'table' then
		id, types, entity = a, b, c
	elseif type(a) == 'string' and type(b) == 'string' and type(c) == 'table' then 
		id, types, entity = a, {b}, c
	elseif type(a) == 'table' and type(b) == 'table' and type(c) == 'nil' then
		id, types, entity = uid(), a, b
	elseif type(a) == 'table' and type(b) == 'nil' and type(c) == 'nil' then
		id, types, entity = uid(), {}, a
	end

	table.insert(types, entity:class())
	for entity.types do table.insert(types, it) end

	entity.types = types  
	entity.id    = id
	entity.room  = @
	@._queue[id] = entity
	return entity 
end

function Room:kill(id) 
	local entity = @:get(id)
	if entity then entity:kill() end
end

function Room:get(id) 
	local entity = @._ents['All'][id]
	if !entity or entity.dead then return nil end
	return entity
end

function Room:get_by_type(...)
	local entities = {}
	local types    = {...}
	local filtered = {} -- filter duplicate entities using id

	for type in types do
		if @._ents[type] then
			for @._ents[type] do
				if !it.dead then filtered[it.id] = ent end
			end
		end
	end

	for filtered do table.insert(entities, it) end

	return entities
end

function Room:count(...)
	local entities = {}
	local types    = {...}
	local filtered = {} -- filter duplicate entities using id

	for type in types do
		if @._ents[type] then
			for @._ents[type] do
				if !it.dead then filtered[it.id] = ent end
			end
		end
	end

	for filtered do table.insert(entities, it) end

	return #entities
end

function Room:draw_inside_camera_bg()
end

function Room:draw_outside_camera_bg()
end

function Room:draw_inside_camera_fg()
end

function Room:draw_outside_camera_fg()
end

function Room:enter() 
end

function Room:exit() 
end

function Room:after(...)
	@.timer:after(...)
end

function Room:tween(...)
	@.timer:tween(...)
end

function Room:every(...)
	@.timer:every(...)
end

function Room:every_immediate(...)
	@.timer:every_immediate(...)
end

function Room:during(...)
	@.timer:during(...)
end

function Room:once(...)
	@.timer:once(...)
end

function Room:always(...)
	@.timer:always(...)
end

function Room:zoom(...)
	@.camera:zoom(...)
end

function Room:shake(...)
	@.camera:shake(...)
end

function Room:follow(...)
	@.camera:follow(...)
end

function Room:get_mouse_position_inside_camera() 
	return @.camera:get_mouse_position()
end

function Room:get_mouse_position_outside_camera() 
	return lm.getPosition()
end