Room = Class:extend('Room')

function Room:new()
	@.id     = ''
	@.timer  = Timer()
	@.camera = Camera()
	@._queue = {}
	@._ents  = {}
	@._ents_by_id   = {}
	@._ents_by_type = {}
end

function Room:update(dt)
	@.timer:update(dt)
	@.camera:update(dt)

	-- update entitites
	ifor @._ents do 
		it:update(dt) 
	end

	-- delete dead entities
	rfor @._ents do 
		if it.dead then
			for type in it.types do @._ents_by_type[type][it.id] = nil end
			@._ents_by_id[it.id] = nil
			table.remove(@._ents, key)
		end
	end

	-- push entities from queue
	for queued_ent in @._queue do
		ifor type in queued_ent.types do 
			@._ents_by_type[type] = get(@, {'_ents_by_type', type}, {}) -- create type table if not already existing
			@._ents_by_type[type][queued_ent.id] = queued_ent
		end
		@._ents_by_id[queued_ent.id] = queued_ent
		insert(@._ents, queued_ent)
	end
	@._queue = {}
end

function Room:draw()
	table.sort(@._ents, fn(a, b) if a.z == b.z then return a.id < b.id else return a.z < b.z end end)

	local _r, _g, _b, _a = lg.getColor()
	@.camera:draw(function()
		@:draw_inside_camera_bg()
		lg.setColor(_r, _g, _b, _a)

		for @._ents do 
			if it.draw && !it.outside_camera then 
				it:draw()
				lg.setColor(_r, _g, _b, _a)
			end
		end

		@:draw_inside_camera_fg()
		lg.setColor(_r, _g, _b, _a)
	end)

	@:draw_outside_camera_bg()
	lg.setColor(_r, _g, _b, _a)

	for @._ents do 
		if it.draw && it.outside_camera then
			it:draw()
			lg.setColor(_r, _g, _b, _a)
		end
	end

	@:draw_outside_camera_fg()
	lg.setColor(_r, _g, _b, _a)
end

function Room:add(a, b, c)
	local id, types, entity

	if   type(a) == 'string' and type(b) == 'table' and type(c) == 'nil' then
		id, types, entity = a, {}, b
	elif type(a) == 'string' and type(b) == 'table' and type(c) == 'table' then
		id, types, entity = a, b, c
	elif type(a) == 'string' and type(b) == 'string' and type(c) == 'table' then 
		id, types, entity = a, {b}, c
	elif type(a) == 'table' and type(b) == 'table' and type(c) == 'nil' then
		id, types, entity = uid(), a, b
	elif type(a) == 'table' and type(b) == 'nil' and type(c) == 'nil' then
		id, types, entity = uid(), {}, a
	end

	insert(types, entity:class())
	for entity.types do insert(types, it) end

	entity.types = types  
	entity.id    = id

	-- TODO: what to do wehn already existing id ?
	if @._ents_by_id[id] then
		print('id already exist') 
	else
		entity.room  = @
		@._queue[id] = entity
	end 

	return entity
end

function Room:kill(id) 
	local entity = @:get(id)
	if entity then entity:kill() end
end

function Room:get(id) 
	local entity = @._ents_by_id[id]
	if !entity or entity.dead then return false end
	return entity
end

function Room:get_all()
	return @._ents
end

function Room:get_by_type(...)
	local entities = {}
	local types    = {...}
	local filtered = {} -- filter duplicate entities using id

	for type in types do
		if @._ents_by_type[type] then
			for @._ents_by_type[type] do
				if !it.dead then filtered[it.id] = it end
			end
		end
	end

	for filtered do insert(entities, it) end

	return entities
end

function Room:count(...)
	return #@:get_by_type(...)
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