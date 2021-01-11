function love.run()
	lg, la, lm, lk        = love.graphics, love.audio, love.mouse, love.keyboard
	local _INPUT          = {_CUR = {}, _PRE = {}}
	local _ACCUMULATOR    = 0
	local _FIXED_TIMESTEP = 1/60

	function pressed(key) 
		return _INPUT._CUR[key] and not _INPUT._PRE[key] 
	end
	
	function released(key)
		return _INPUT._PRE[key] and not _INPUT._CUR[key] 
	end

	function down(key) 
		if key=='m_1'or key=='m_2'or key=='m_3' then 
			return lm.isDown(tonumber(key:sub(7))) 
		else 
			return lk.isDown(key) 
		end 
	end

	function love.load()
		lg.setDefaultFilter('nearest', 'nearest')
		lg.setLineStyle('rough')
		lg.setBackgroundColor(.2, .2, .2, .2)
		
		Class   = require('libraries/class')
		Camera  = require('libraries/camera')
		Timer   = require('libraries/timer')
		Vec2    = require('libraries/vector')
		Physics = require('libraries/physics')

		require('libraries/utils')
		require('libraries/monkey')

		require_all('classes')
		require_all('rooms')
		require_all('entities', {recursive = true})

		game = Game()
		game:add_room('menu', Menu_room())
		game:add_room('game', Game_room())

		game:change_room('game')
	end

	function love.update(dt)
		if pressed('escape') then love.load() end
		game:update(dt)
	end
	
	function love.draw()
		game:draw()
	end

	love.load()
	love.timer.step()

	return function()
		love.event.pump()
		for name,a,b,c,d,e,f in love.event.poll() do
			if name == 'quit'          then return 0 end
			if name == 'mousepressed'  then _INPUT._CUR['m_'.. c] = true end
			if name == 'keypressed'    then _INPUT._CUR[a] = true if c then _INPUT._PRE[a] = false end end -- c => isRepeat
			if name == 'mousereleased' then _INPUT._CUR['m_'.. c] = false end
			if name == 'keyreleased'   then _INPUT._CUR[a] = false end
			love.handlers[name](a,b,c,d,e,f)
		end

		_ACCUMULATOR = _ACCUMULATOR + love.timer.step()
		while _ACCUMULATOR >= _FIXED_TIMESTEP do
			love.update(_FIXED_TIMESTEP)
			for k,v in pairs(_INPUT._CUR) do _INPUT._PRE[k] = v end -- input update
			_ACCUMULATOR = _ACCUMULATOR - _FIXED_TIMESTEP
		end

		lg.origin()
		lg.clear(lg.getBackgroundColor())
		love.draw()
		lg.present()
		love.timer.sleep(0.001)
	end
end
