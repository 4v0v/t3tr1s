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
	@:every_immediate(1, fn() @:tick() end, _, 'tick')
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
		lg.rectangle("line", 25 * i, 25 * j, 25 , 25, 5, 5 )
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
end


	-- @.grid:foreach(fn(grid, i, j)
	-- 	local cell = grid:get(i, j)


	-- end)
	--[[
		regarder si on a perdu
			oui: game over
			non: continue

		regarder si il y a une brique active
			non: faire apparaitre brique active
			oui: faire descendre brique active

		regarder si ligne est créée
			non: rien
			oui: score++, faire disparaitre ligne, faire descendre les autres briques 
	]]--
function Game_room:tick()
	@.grid = @.empty_grid:clone()

	ifor @.active do 
		it.y += 1
	end
	
	ifor @.active do
		@.grid:set(it.x, it.y, it.type)
	end

	ifor @.ground do
		@.grid:set(it.x, it.y, it.type)
	end
end

function Game_room:move_left()
	@.grid = @.empty_grid:clone()

	ifor @.active do 
		it.x -= 1
	end

	ifor @.active do
		@.grid:set(it.x, it.y, it.type)
	end

	ifor @.ground do
		@.grid:set(it.x, it.y, it.type)
	end
end

function Game_room:move_right()
	@.grid = @.empty_grid:clone()

	ifor @.active do 
		it.x += 1
	end

	ifor @.active do
		@.grid:set(it.x, it.y, it.type)
	end

	ifor @.ground do 
		@.grid:set(it.x, it.y, it.type)
	end
end

function Game_room:rotate_clockwise()
end

function Game_room:rotate_anticlockwise()
end

function Game_room:fall()
end