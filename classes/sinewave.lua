Sinewave = Class:extend('Sinewave')

function Sinewave:new(value, speed, amplitude)
    @.val       = value or 0
    @.v         = value or 0
    @.speed     = speed or 1
    @.amplitude = amplitude or 1
    @.time      = 0
    @.sine      = 0
    @.is_updating = true
end

function Sinewave:update(dt)
	if !@.is_updating then return end
	@.time += dt
	@.sine = (@.amplitude * math.sin(@.time * @.speed))
	@.val  = @.v + @.sine
end

function Sinewave:value() 
	return @.val
end

function Sinewave:stop()
	@.is_updating = false
end

function Sinewave:play()
	@.is_updating = true
end

function Sinewave:setValue(v)
	@.val = v
	@.v   = v 
end
