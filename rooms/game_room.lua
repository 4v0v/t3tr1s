Game_room = Room:extend('Game_room')

function Game_room:new()
	Game_room.super.new(@)

	@.score = 0
	@.grid = Grid(10, 20)

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

	@.grid:set(1, 1, 6)
	@.grid:set(1, 2, 6)
	@.grid:set(2, 1, 6)
	@.grid:set(2, 2, 6)
end

function Game_room:update(dt)
	Game_room.super.update(@, dt)	
end

function Game_room:draw_outside_camera_fg()
	Game_room.super.draw_outside_camera_fg(@)

	@.grid:foreach(fn(grid, i, j) 
		local cell = grid:get(i, j)
		if cell == 0 then 
			lg.setColor(.4, .4, .4)
			lg.rectangle("line", 25 * i, 25 * j, 25 , 25 )
		else
			if     cell == 1 then lg.setColor(.8,  0,  0)
			elseif cell == 2 then lg.setColor( 0, .8,  0)
			elseif cell == 3 then lg.setColor( 0,  0, .8)
			elseif cell == 4 then lg.setColor(.8, .8,  0)
			elseif cell == 5 then lg.setColor(.8,  0, .8)
			elseif cell == 6 then lg.setColor( 0, .8, .8)
			elseif cell == 7 then lg.setColor(.8, .8, .8) end
			lg.rectangle("fill", 25 * i, 25 * j, 25 , 25 )
		end
	end)

end
