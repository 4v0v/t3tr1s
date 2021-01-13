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

	@.pieces = {
		Grid(3, 3, {
			0, 0, 1,
			1, 1, 1,
			0, 0, 0,
		}),
		Grid(3, 3, {
			2, 0, 0,
			2, 2, 2,
			0, 0, 0,
		}), 
		Grid(4, 4, {
			0, 0, 0, 0,
			3, 3, 3, 3,
			0, 0, 0, 0,
			0, 0, 0, 0
		}),
		Grid(3, 3, {
			4, 4, 0,
			0, 4, 4,
			0, 0, 0,
		}),
		Grid(3, 3, {
			0, 5, 5,
			5, 5, 0,
			0, 0, 0,
		}),
		Grid(3, 3, {
			0, 6, 0,
			6, 6, 6,
			0, 0, 0,
		}),
		Grid(2, 2, {
			7, 7,
			7, 7,
		}),
	}

	@.next_piece_idx    = 0
	@.current_piece_idx = 0
	@.next_piece        = {}
	@.current_blocs     = {}
	@.placed_blocs      = {}

	@:generate_next()
	@:every_immediate(.3, fn() @:move_down() end, _, 'move_down')
end

function Game_room:update(dt)
	Game_room.super.update(@, dt)

	if pressed('left') || pressed('q') then @:move_left() end
	if pressed('right') || pressed('d') then @:move_right() end
	if down('down') || down('s') then @:move_down() end
end

function Game_room:draw_outside_camera_fg()
	Game_room.super.draw_outside_camera_fg(@)

	@.grid:foreach(fn(grid, i, j) 
		lg.setColor(.4, .4, .4)
		lg.rectangle("line", 25 * i, 25 * j, 25 , 25 )
	end)

	@.grid:foreach(fn(grid, i, j)
		local cell = grid:get(i, j)
		if   cell == 0 then return
		elif cell == 1 then lg.setColor(CMYK(.5, .3, .6, .1))
		elif cell == 2 then lg.setColor(CMYK(.1, .4, .5, .2))
		elif cell == 3 then lg.setColor(CMYK(.2, .5, .4, .3))
		elif cell == 4 then lg.setColor(CMYK(.3, .4, .3, .1))
		elif cell == 5 then lg.setColor(CMYK(.4, .3, .2, .2))
		elif cell == 6 then lg.setColor(CMYK(.5, .2, .1, .3))
		elif cell == 7 then lg.setColor(CMYK(.7, .5, .2, .4))
		elif cell == 8 then lg.setColor(CMYK(.5, .5, .5, .5)) end
		lg.rectangle("fill", 25 * i, 25 * j, 25 , 25, 5, 5 )
	end)

	lg.setColor(.5, .5, .5)
	lg.rectangle("line", 300, 25, 100, 100)

	ifor @.next_piece do 
		if   it.v == 1 then lg.setColor(CMYK(.5, .3, .6, .1))
		elif it.v == 2 then lg.setColor(CMYK(.1, .4, .5, .2))
		elif it.v == 3 then lg.setColor(CMYK(.2, .5, .4, .3))
		elif it.v == 4 then lg.setColor(CMYK(.3, .4, .3, .1))
		elif it.v == 5 then lg.setColor(CMYK(.4, .3, .2, .2))
		elif it.v == 6 then lg.setColor(CMYK(.5, .2, .1, .3))
		elif it.v == 7 then lg.setColor(CMYK(.7, .5, .2, .4))
		elif it.v == 8 then lg.setColor(CMYK(.5, .5, .5, .5)) end
		lg.rectangle("fill", 287.5 + 25 * it.x , 25 + 25 * it.y, 25 , 25, 5, 5 )
	end
end

function Game_room:move_down()
	@.grid = @.empty_grid:clone()

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local temp_x, temp_y = it.x, it.y + 1
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then
			ifor @.current_blocs do 
				insert(@.placed_blocs, {x = it.x, y = it.y})
				@.grid:set(it.x, it.y, 8)
			end
			
			-- check in placed blocs if complete lines
			ifor @.current_blocs do 
				if
					@.grid:get(1,  it.y) == 8 &&
					@.grid:get(2,  it.y) == 8 &&
					@.grid:get(3,  it.y) == 8 &&
					@.grid:get(4,  it.y) == 8 &&
					@.grid:get(5,  it.y) == 8 &&
					@.grid:get(6,  it.y) == 8 &&
					@.grid:get(7,  it.y) == 8 &&
					@.grid:get(8,  it.y) == 8 &&
					@.grid:get(9,  it.y) == 8 &&
					@.grid:get(10, it.y) == 8 
				then
					for i = #@.placed_blocs, 1, -1 do
						local bloc = @.placed_blocs[i]
						if bloc.x >= 1 && bloc.x <= 10 && bloc.y == it.y then 
							table.remove(@.placed_blocs, i) 
	 					end
					end
				end
			end

			@.current_blocs = {}
			break
		end
	end

	ifor @.current_blocs do 
		it.y += 1
		@.grid:set(it.x, it.y, it.v) 
	end

	if #@.current_blocs == 0 then
		@:insert_current()
	end
end

function Game_room:move_left()
	@.grid = @.empty_grid:clone()

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local temp_x, temp_y = it.x - 1, it.y
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then 
			goto cannot_move
		end
	end
	
	ifor @.current_blocs do it.x -= 1 end

	::cannot_move::

	ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
end

function Game_room:move_right()
	@.grid = @.empty_grid:clone()

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local temp_x, temp_y = it.x + 1, it.y
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then 
			goto cannot_move
		end
	end

	ifor @.current_blocs do it.x += 1 end

	::cannot_move::

	ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
end

function Game_room:rotate_clockwise()
end

function Game_room:rotate_anticlockwise()
end

function Game_room:insert_current()
	@.current_piece_idx = @.next_piece_idx
	ifor @.next_piece do
		if it.v != 0 then 
			insert(@.current_blocs, {x = it.x + 3, y = it.y, v = it.v}) 
		end
	end
	@.next_piece = {}
	@:generate_next()

	ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
end

function Game_room:generate_next()
	@.next_piece_idx = math.random(7)
	local piece = @.pieces[@.next_piece_idx]:to_table()
	ifor bloc in piece do 
		if bloc[3] != 0 then
			insert(@.next_piece, {x = bloc[1], y = bloc[2], v = bloc[3]})
		end
	end
end