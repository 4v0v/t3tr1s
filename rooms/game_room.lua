Game_room = Room:extend('Game_room')

function Game_room:new()
	Game_room.super.new(@)

	@:add('score', Text(400, 500, '0', {
		font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
		outside_camera = true,
		scale          = 3, 
		centered       = true,
	}))

	@.empty_grid = Grid(10, 20)
	@.grid       = Grid(10, 20)

	@.orange_ricky = Grid(4, 4, {
		0, 0, 1, 0,
		1, 1, 1, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.blue_ricky = Grid(4, 4, {
		0, 0, 2, 0,
		2, 2, 2, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.hero = Grid(4, 4, {
		3, 3, 3, 3,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.cleveland_z = Grid(4, 4, {
		4, 4, 0, 0,
		0, 4, 4, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.rhode_island_z = Grid(4, 4, {
		0, 5, 5, 0,
		5, 5, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.teewee = Grid(4, 4, {
		0, 6, 0, 0,
		6, 6, 6, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.smashboy = Grid(4, 4, {
		7, 7, 0, 0,
		7, 7, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0
	})

	@.next = {
		{type = 3, x = 1, y = 1},
		{type = 3, x = 2, y = 1},
		{type = 3, x = 2, y = 2},
		{type = 3, x = 3, y = 2},
	}

	@.active = {
		{type = 2, x = 1, y = 1},
		{type = 2, x = 2, y = 1},
		{type = 2, x = 2, y = 2},
		{type = 2, x = 3, y = 2},
	}
	@.ground = {
		{type = 8, x = 5, y = 20}, 
		{type = 8, x = 6, y = 20}, 
		{type = 8, x = 7, y = 20},
		{type = 8, x = 6, y = 19},
	}
	@:every_immediate(.3, fn() @:tick() end, _, 'tick')
end

function Game_room:update(dt)
	Game_room.super.update(@, dt)

	if pressed('left') || pressed('q') then @:move_left() end
	if pressed('right') || pressed('d') then @:move_right() end
end

function Game_room:draw_outside_camera_fg()
	Game_room.super.draw_outside_camera_fg(@)

	@.grid:foreach(fn(grid, i, j) 
		lg.setColor(.4, .4, .4)
		lg.rectangle("line", 25 * i, 25 * j, 25 , 25 )
	end)

	@.grid:foreach(fn(grid, i, j)
		local cell = grid:get(i, j)
		if     cell == 0 then return
		elseif cell == 1 then lg.setColor(.8,  0,  0)
		elseif cell == 2 then lg.setColor( 0, .8,  0)
		elseif cell == 3 then lg.setColor( 0,  0, .8)
		elseif cell == 4 then lg.setColor(.8, .8,  0)
		elseif cell == 5 then lg.setColor(.8,  0, .8)
		elseif cell == 6 then lg.setColor( 0, .8, .8)
		elseif cell == 7 then lg.setColor(.8, .8, .8)
		elseif cell == 8 then lg.setColor(.5, .5, .5) end
		lg.rectangle("fill", 25 * i, 25 * j, 25 , 25, 5, 5 )
	end)

	lg.setColor(.5, .5, .5)
	lg.rectangle("line", 300, 25, 100, 100)

	ifor @.next do 
		if     it.type == 1 then lg.setColor(.8,  0,  0)
		elseif it.type == 2 then lg.setColor( 0, .8,  0)
		elseif it.type == 3 then lg.setColor( 0,  0, .8)
		elseif it.type == 4 then lg.setColor(.8, .8,  0)
		elseif it.type == 5 then lg.setColor(.8,  0, .8)
		elseif it.type == 6 then lg.setColor( 0, .8, .8)
		elseif it.type == 7 then lg.setColor(.8, .8, .8)
		elseif it.type == 8 then lg.setColor(.5, .5, .5) end
		lg.rectangle("fill", 287.5 + 25 * it.x , 25 + 25 * it.y, 25 , 25, 5, 5 )
	end

end

function Game_room:tick()
	@.grid = @.empty_grid:clone()

	ifor @.ground do @.grid:set(it.x, it.y, 8) end

	ifor @.active do
		local temp_x, temp_y = it.x, it.y + 1
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then
			ifor @.active do 
				table.insert(@.ground, {x = it.x, y = it.y})
				@.grid:set(it.x, it.y, 8)
			end
			@.active = {}
			break
		end
	end

	ifor @.active do 
		it.y += 1
		@.grid:set(it.x, it.y, it.type) 
	end

	if #@.active == 0 then
		ifor @.next do 
			table.insert(@.active, it)
		end
		local color = math.random(7)
		@.next = {
			{type = color, x = 1, y = 1},
			{type = color, x = 2, y = 1},
			{type = color, x = 2, y = 2},
			{type = color, x = 3, y = 2},
		}
		ifor @.active do @.grid:set(it.x, it.y, it.type) end
	end
end

function Game_room:move_left()
	@.grid = @.empty_grid:clone()

	ifor @.ground do @.grid:set(it.x, it.y, 8) end

	ifor @.active do
		local temp_x, temp_y = it.x - 1, it.y
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then 
			goto is_not_moving
		end
	end

	ifor @.active do it.x -= 1 end

	::is_not_moving::

	ifor @.active do	@.grid:set(it.x, it.y, it.type) end
end

function Game_room:move_right()
	@.grid = @.empty_grid:clone()

	ifor @.ground do @.grid:set(it.x, it.y, 8) end

	ifor @.active do
		local temp_x, temp_y = it.x + 1, it.y
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then 
			goto is_not_moving
		end
	end

	ifor @.active do it.x += 1 end

	::is_not_moving::

	ifor @.active do @.grid:set(it.x, it.y, it.type) end
end

function Game_room:rotate_clockwise()
end

function Game_room:rotate_anticlockwise()
end

function Game_room:fall()
end