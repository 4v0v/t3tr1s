Game_room = Room:extend('Game_room')

function Game_room:new()
	Game_room.super.new(@)
	

	@:add('score', Text(400, 500, '0', {
		font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
		scale          = 3, 
		centered       = true,
	}))

	@.empty_grid    = Grid(10, 20)
	@.grid          = Grid(10, 20)
	@.current_idx   = 0
	@.next_idx      = 0
	@.next_piece    = {}
	@.current_blocs = {}
	@.placed_blocs  = {}

	@.pieces = {
		Grid(3, 3, {
			0, 0, 1,
			1, 1, 1,
			0, 0, 0,
		}),
		Grid(3, 3, {
			1, 0, 0,
			1, 1, 1,
			0, 0, 0,
		}), 
		Grid(4, 4, {
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0,
			0, 0, 0, 0
		}),
		Grid(3, 3, {
			1, 1, 0,
			0, 1, 1,
			0, 0, 0,
		}),
		Grid(3, 3, {
			0, 1, 1,
			1, 1, 0,
			0, 0, 0,
		}),
		Grid(3, 3, {
			0, 1, 0,
			1, 1, 1,
			0, 0, 0,
		}),
		Grid(2, 2, {
			1, 1,
			1, 1,
		}),
	}

	@.camera:set_position(400, 300)

	@.next_idx = math.random(#@.pieces)
	local piece = @.pieces[@.next_idx]:to_table()
	ifor bloc in piece do 
		if bloc[3] != 0 then
			insert(@.next_piece, {x = bloc[1], y = bloc[2], v = bloc[3]})
		end
	end
	@:every_immediate(.3, fn() @:move_down() end, _, 'move_down')
end

function Game_room:update(dt)
	Game_room.super.update(@, dt)

	if pressed('left')  || pressed('q') then @:move_left()  end
	if pressed('right') || pressed('d') then @:move_right() end
	if down('down')     || down('s')    then @:move_down()  end
end

function Game_room:draw_inside_camera_fg()
	Game_room.super.draw_outside_camera_fg(@)

	-- grid
	@.grid:foreach(fn(grid, i, j) 
		lg.setColor(.4, .4, .4)
		lg.rectangle('line', 25 * i, 25 * j, 25 , 25 )
	end)

	-- blocks
	@.grid:foreach(fn(grid, i, j)
		local cell = grid:get(i, j)
		if   cell == 0 then return
		elif cell == 1 then lg.setColor(cmyk(.5, .3, .6, .2))
		elif cell == 2 then lg.setColor(cmyk(.1, .4, .5, .2))
		elif cell == 3 then lg.setColor(cmyk(.2, .5, .4, .2))
		elif cell == 4 then lg.setColor(cmyk(.3, .4, .3, .2))
		elif cell == 5 then lg.setColor(cmyk(.4, .3, .2, .2))
		elif cell == 6 then lg.setColor(cmyk(.5, .2, .1, .2))
		elif cell == 7 then lg.setColor(cmyk(.7, .5, .2, .2))
		elif cell == 8 then lg.setColor(cmyk(.3, .3, .3, .3)) end
		lg.rectangle('fill', 25 * i, 25 * j, 25 , 25, 5, 5 )
	end)

	-- next piece preview
	lg.setColor(.5, .5, .5)
	lg.rectangle('line', 300, 25, 100, 100)

	if   @.next_idx == 1 then lg.setColor(cmyk(.5, .3, .6, .2))
	elif @.next_idx == 2 then lg.setColor(cmyk(.1, .4, .5, .2))
	elif @.next_idx == 3 then lg.setColor(cmyk(.2, .5, .4, .2))
	elif @.next_idx == 4 then lg.setColor(cmyk(.3, .4, .3, .2))
	elif @.next_idx == 5 then lg.setColor(cmyk(.4, .3, .2, .2))
	elif @.next_idx == 6 then lg.setColor(cmyk(.5, .2, .1, .2))
	elif @.next_idx == 7 then lg.setColor(cmyk(.7, .5, .2, .2))
	elif @.next_idx == 8 then lg.setColor(cmyk(.3, .3, .3, .3)) end
	ifor @.next_piece do 
		lg.rectangle('fill', 287.5 + 25 * it.x , 25 + 25 * it.y, 25 , 25, 5, 5 )
	end
end

function Game_room:move_down()
	@.grid = @.empty_grid:clone()

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local temp_x, temp_y = it.x, it.y + 1
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then
			-- convert current to placed blocks
			ifor @.current_blocs do 
				insert(@.placed_blocs, {x = it.x, y = it.y})
				@.grid:set(it.x, it.y, 8)
			end
			
			-- check if some lines are full
			local lines_to_remove = {}
			ifor @.current_blocs do -- limit check to current blocks positions
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
					insert(lines_to_remove, it.y)
				end
			end
			lines_to_remove = uniq(lines_to_remove)

			if #lines_to_remove > 0 then 
				-- remove lines
				rfor bloc_pos, bloc in @.placed_blocs do
					ifor line in lines_to_remove do 
						if bloc.y == line then
							table.remove(@.placed_blocs, bloc_pos)
							break
						end
					end
				end

				-- move blocs down
				ifor bloc in @.placed_blocs do
					local dy = 0
					ifor line in lines_to_remove do
						if bloc.y < line then	dy += 1 end
					end
					 bloc.y += dy
				end

				@.camera:shake(15 * #lines_to_remove)
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
		-- generate new current && next piece
		@.current_idx = @.next_idx
		ifor @.next_piece do
			if it.v != 0 then 
				insert(@.current_blocs, {x = it.x + 3, y = it.y, v = @.next_idx}) 
			end
		end
		@.next_piece = {}
	
		@.next_idx = math.random(#@.pieces)
		local piece = @.pieces[@.next_idx]:to_table()
		ifor bloc in piece do 
			if bloc[3] != 0 then
				insert(@.next_piece, {x = bloc[1], y = bloc[2], v = bloc[3]})
			end
		end
	
		ifor @.current_blocs do @.grid:set(it.x, it.y, @.current_idx) end
	end
end

function Game_room:move_left()
	@.grid = @.empty_grid:clone()

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local temp_x, temp_y = it.x - 1, it.y
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then 
			ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
			return
		end
	end
	
	ifor @.current_blocs do 
		it.x -= 1
		@.grid:set(it.x, it.y, it.v)
	end
end

function Game_room:move_right()
	@.grid = @.empty_grid:clone()

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local dx, dy = it.x + 1, it.y
		if @.grid:is_oob(dx, dy) || @.grid:get(dx, dy) != 0 then 
			ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
			return
		end
	end

	ifor @.current_blocs do 
		it.x += 1 
		@.grid:set(it.x, it.y, it.v) 
	end
end

function Game_room:rotate_clockwise()
end

function Game_room:rotate_anticlockwise()
end
