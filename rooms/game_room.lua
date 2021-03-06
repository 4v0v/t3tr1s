Game_room = Room:extend('Game_room')

function Game_room:new()
	Game_room.super.new(@)

	@:add('score', Text(400, 500, '0', {
		font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
		scale          = 3, 
		centered       = true,
	}))
	@.grid            = Grid(10, 20)
	@.move_sound      = la.newSource("assets/sounds/move.wav",   "static")
	@.rotate_sound    = la.newSource("assets/sounds/rotate.wav", "static")
	@.placing_sound   = la.newSource("assets/sounds/drop.wav",   "static")

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

	@.current_idx     = 0
	@.next_idx        = 0
	@.hold_idx        = 0
	@.next_blocs      = {}
	@.hold_blocs      = {}
	@.current_blocs   = {}
	@.placed_blocs    = {}
	@.top_left        = {x = 4, y = 1}
	@.move_down_speed = 1
	@.can_move_down   = true
	@.is_holding      = false
	@.can_hold        = true

	@.placing_sound:setEffect('reverb_fx')
	@.camera:set_position(400, 300)
end

function Game_room:enter(dt)
	@.current_idx     = 0
	@.next_idx        = 0
	@.hold_idx        = 0
	@.next_blocs      = {}
	@.hold_blocs      = {}
	@.current_blocs   = {}
	@.placed_blocs    = {}
	@.top_left        = {x = 4, y = 1}
	@.move_down_speed = 1
	@.can_move_down   = true
	@.is_holding      = false
	@.can_hold        = true
	@.score           = 0
	@.grid:fill(0)

	local score = @:get('score')
	if score then score:set_text(@.score) end

	@.next_idx = math.random(#@.pieces)
	local piece = @.pieces[@.next_idx]:to_table()
	ifor bloc in piece do 
		if bloc[3] != 0 then
			insert(@.next_blocs, {x = bloc[1], y = bloc[2], v = bloc[3]})
		end
	end
	@:every_immediate(@.move_down_speed, fn() @:move_down() end, _, 'move_down')
end

function Game_room:update(dt)
	Game_room.super.update(@, dt)

	if pressed('left')  || pressed('q') then @:move('left')  end
	if pressed('right') || pressed('d') then @:move('right') end
	if pressed('up')    || pressed('z') then @:rotate() end
	if pressed('space') then @:hold() end
	if (down('down') || down('s')) && @.can_move_down then @:move_down() end
end

function Game_room:draw_inside_camera_fg()
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
	ifor @.next_blocs do 
		lg.rectangle('fill', 287.5 + 25 * it.x , 25 + 25 * it.y, 25 , 25, 5, 5 )
	end

	-- hold
	lg.setColor(.5, .5, .5)
	lg.rectangle('line', 300, 150, 100, 100)

	if   @.hold_idx == 1 then lg.setColor(cmyk(.5, .3, .6, .2))
	elif @.hold_idx == 2 then lg.setColor(cmyk(.1, .4, .5, .2))
	elif @.hold_idx == 3 then lg.setColor(cmyk(.2, .5, .4, .2))
	elif @.hold_idx == 4 then lg.setColor(cmyk(.3, .4, .3, .2))
	elif @.hold_idx == 5 then lg.setColor(cmyk(.4, .3, .2, .2))
	elif @.hold_idx == 6 then lg.setColor(cmyk(.5, .2, .1, .2))
	elif @.hold_idx == 7 then lg.setColor(cmyk(.7, .5, .2, .2))
	elif @.hold_idx == 8 then lg.setColor(cmyk(.3, .3, .3, .3)) end
	ifor @.hold_blocs do 
		lg.rectangle('fill', 287.5 + 25 * it.x , 150 + 25 * it.y, 25 , 25, 5, 5 )
	end
end

function Game_room:move_down()
	@.grid:fill(0)

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	local is_touching = false
	ifor @.current_blocs do
		local temp_x, temp_y = it.x, it.y + 1
		if @.grid:is_oob(temp_x, temp_y) || @.grid:get(temp_x, temp_y) != 0 then
			is_touching = true
			break
		end
	end

	if !is_touching then
		-- move down
		ifor @.current_blocs do 
			it.y += 1
			@.grid:set(it.x, it.y, it.v) 
		end
		@.top_left.y += 1
	else
		if !@.can_hold then @.can_hold = true end
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
			
			-- update score && change level
			@.score += #lines_to_remove
			local score = @:get('score')
			score:set_text(@.score)

			if   @.score >= 10 && @.score < 20 then @.move_down_speed = .9
			elif @.score >= 20 && @.score < 30 then @.move_down_speed = .8
			elif @.score >= 30 && @.score < 40 then @.move_down_speed = .7
			elif @.score >= 40 && @.score < 50 then @.move_down_speed = .6
			elif @.score >= 50 && @.score < 60 then @.move_down_speed = .5
			elif @.score >= 60 && @.score < 70 then @.move_down_speed = .4
			elif @.score >= 70 && @.score < 80 then @.move_down_speed = .3
			elif @.score >= 80 && @.score < 90 then @.move_down_speed = .2
			elif @.score >= 90                 then @.move_down_speed = .1 end

			@.timer:remove('move_down')
			@:every(@.move_down_speed, fn() @:move_down() end, _, 'move_down')
		end

		@.current_blocs = {}
		@.grid:fill(0)
		
		ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

		-- fx
		@.placing_sound:stop()
		if #lines_to_remove == 0 then
			@.placing_sound:play()
		elif #lines_to_remove > 0 && #lines_to_remove < 4 then 
			@.camera:shake(15 * #lines_to_remove)
			@.placing_sound:play()
		elif #lines_to_remove == 4 then 
			@.camera:shake(15 * #lines_to_remove)
			@.placing_sound:play()
		end

		@.can_move_down = false
		@:after(.1, fn() @.can_move_down = true end)
	end

	-- generate new current && next piece
	if #@.current_blocs == 0 then
		@.current_idx = @.next_idx
		ifor @.next_blocs do
			if it.v != 0 then
				local dx, dy = it.x + 3, it.y
				local g = @.grid:get(dx, dy)
				if g != 0 then game:change_room('over') end --TODO make better game over
				insert(@.current_blocs, {x = dx, y = dy, v = @.next_idx}) 
			end
		end

		@.next_blocs = {}
		@.next_idx = math.random(#@.pieces)
		local piece = @.pieces[@.next_idx]:to_table()
		ifor bloc in piece do 
			if bloc[3] != 0 then
				insert(@.next_blocs, {x = bloc[1], y = bloc[2]})
			end
		end
	
		ifor @.current_blocs do @.grid:set(it.x, it.y, @.current_idx) end
		@.top_left.x = 4
		@.top_left.y = 1
	end
end

function Game_room:move(direction)
	@.grid:fill(0)

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	ifor @.current_blocs do
		local dx, dy
		if direction == 'left' then 
			dx, dy = it.x - 1, it.y
		elif direction == 'right' then
			dx, dy = it.x + 1, it.y
		end
		if @.grid:is_oob(dx, dy) || @.grid:get(dx, dy) != 0 then 
			ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
			return -- don't move
		end
	end

	ifor @.current_blocs do 
		if direction == 'left' then 
			it.x -= 1
		elif direction == 'right' then
			it.x += 1
		end
		@.grid:set(it.x, it.y, it.v) 
	end

	if direction == 'left' then 
		@.top_left.x -= 1
	elif direction == 'right' then
		@.top_left.x += 1
	end
	@.move_sound:play()
end

function Game_room:rotate()
	local can_rotate    = true
	local current_piece = @.pieces[@.current_idx]

	local blocs = (fn()
		local t = {}
		foreach(current_piece.width, fn(j) 
			foreach(current_piece.height, fn(i)
				local bloc = @.grid:get(@.top_left.x + i -1, @.top_left.y + j -1)
					insert(t, bloc || 0)
			end)
		end)
		return t
	end)()
	
	local piece   = Grid(current_piece.width, current_piece.height, blocs)
	local rotated = piece:rotate_clockwise()

	@.grid:fill(0)

	ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

	rotated:foreach(fn(grid, i, j)
		local dx   = i + @.top_left.x -1
		local dy   = j + @.top_left.y -1
		local cell = @.grid:get(dx, dy)

		if @.grid:is_oob(dx, dy) || cell != 0 then 
			can_rotate = false
		end
	end)

	if can_rotate then
		@.current_blocs = {}
		rotated:foreach(fn(grid, i, j)
			local value = grid:get(i, j)
			if value != 0 then
				insert(@.current_blocs, { x = @.top_left.x + i -1, y = @.top_left.y + j - 1, v = @.current_idx})
			end
		end)

		@.rotate_sound:stop()
		@.rotate_sound:play()
	end

	ifor @.current_blocs do @.grid:set(it.x, it.y, it.v) end
end

function Game_room:hold()
	if !@.can_hold then return end
	if !@.is_holding then
		@.hold_idx   = @.current_idx
		@.hold_blocs = {}

		ifor @.pieces[@.hold_idx]:to_table() do 
			if it[3] != 0 then
				insert(@.hold_blocs, {x = it[1], y = it[2]})
			end
		end

		@.current_blocs = {}
		@.grid:fill(0)
		ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end

		@.top_left.x = 4
		@.top_left.y = 1

		@.is_holding = true
	else
		@.current_blocs = {}
		@.current_idx   = @.hold_idx

		ifor @.pieces[@.hold_idx]:to_table() do 
			if it[3] != 0 then
				insert(@.current_blocs, {x = it[1] + 3, y = it[2], v = @.current_idx})
			end
		end
		
		@.grid:fill(0)
		ifor @.placed_blocs do @.grid:set(it.x, it.y, 8) end
		ifor @.current_blocs do @.grid:set(it.x, it.y, @.current_idx) end

		@.top_left.x = 4
		@.top_left.y = 1
		@.hold_idx   = 0
		@.hold_blocs = {}
		@.is_holding = false
		@.can_hold   = false
	end
end
