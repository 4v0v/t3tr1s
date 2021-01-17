Entity = Class:extend('Entity')

function Entity:new(opts)
	@.timer   = Timer()
	@.dead    = false
	@.room    = {}
	@.id      = ''
	@.types   = get(opts, 'types', {})
	@.pos     = Vec2(get(opts, 'x', 0), get(opts, 'y', 0))
	@.dir     = Vec2(0, 1)
	@.z       = get(opts, 'z', 0)
	@.state   = get(opts, 'state', 'default')
	@.outside_camera = get(opts, 'outside_camera', false)
end

function Entity:draw() 
end

function Entity:update(dt) 
	@.timer:update(dt) 
end

function Entity:is_type(...) 
	local types = {...}

	ifor type in types do
		ifor entity_type in @.types do 
			if type == entity_type then return true end
		end
	end

	return false
end

function Entity:kill()
	@.timer:destroy()
	@.dead = true
	@.room = nil
end

function Entity:set_state(state)
	@.state = state
end

function Entity:is_state(state)
	return @.state == state
end

function Entity:get_state()
	return @.state
end

function Entity:after(...)
	@.timer:after(...)
end

function Entity:tween(...)
	@.timer:tween(...)
end

function Entity:every(...)
	@.timer:every(...)
end

function Entity:every_immediate(...)
	@.timer:every_immediate(...)
end

function Entity:during(...)
	@.timer:during(...)
end

function Entity:once(...)
	@.timer:once(...)
end

function Entity:always(...)
	@.timer:always(...)
end

function Entity:move_toward(target, speed, turn_speed)
	local target     = Vec2(target)
	local target_dir = (target - @.pos):normalized()
	local dir_diff   = target_dir - @.dir
	@.dir += (dir_diff * (turn_speed * dt))
	@.pos += @.dir * speed * dt
end
