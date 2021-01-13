AnimationFrames = Class:extend('AnimationFrames')

function AnimationFrames:new(image, frame_w, frame_h, ox, oy, frames_list)
  @.image    = image
	@.frame_w  = frame_w
	@.frame_h  = frame_h
	@.ox       = ox or 0
	@.oy       = oy or 0
	@.frames   = map(frames_list, fn(frame)
		return love.graphics.newQuad(
			(frame[1]-1) * @.frame_w + @.ox, 
			(frame[2]-1) * @.frame_h + @.oy, 
			@.frame_w, @.frame_h, 
			@.image:getWidth(), @.image:getHeight()
		)
	end)
end

function AnimationFrames:draw(frame, x, y, r, sx, sy, ox, oy)
  love.graphics.draw(
		@.image, 
		@.frames[frame], 
		x, y, r or 0, sx or 1, sy or sx or 1, 
		@.frame_w/2 + (ox or 0), 
		@.frame_h/2 + (oy or 0)
	)
end

AnimationLogic = Class:extend('AnimationLogic')

function AnimationLogic:new(delay, frames, mode, actions)
	@.delay     = delay
	@.pause     = false
  @.frames    = frames
  @.mode      = mode or 'loop'
  @.actions   = actions
  @.timer     = 0
  @.frame     = 1
  @.direction = 1
end

function AnimationLogic:update(dt)
  if @.pause then return end
	@.timer += dt
	
  local delay = @.delay
	if type(@.delay) == 'table' then delay = @.delay[@.frame] end
	
	if @.timer > delay then
		local action = get(@, {'actions', @.frame})

    @.frame += @.direction
		if @.frame > @.frames || @.frame < 1 then
      if @.mode == 'once' then
        @.frame = @.frames
				@.pause = true
      elif @.mode == 'loop' then
				@.frame = 1
      elif @.mode == 'bounce' then
        @.direction = -@.direction
        @.frame += 2 * @.direction
			end
		end
		if action then action() end
		
		@.timer -= delay
  end
end

Animation =  Class:extend('Animation')

function Animation:new(delay, frames, mode, actions)
  @.delay      = delay
  @.frames     = frames
  @.size       = #frames.frames
  @.mode       = mode
  @.actions    = actions
  @.anim_logic = AnimationLogic(@.delay, @.size, @.mode, @.actions)
end

function Animation:update(dt)
  @.anim_logic:update(dt)
end

function Animation:draw(x, y, r, sx, sy, ox, oy, color)
  @.frames:draw(@.anim_logic.frame, x, y, r, sx, sy, ox, oy, color)
end

function Animation:reset()
	@.anim_logic.frame = 1
	@.anim_logic.timer = 0
	@.anim_logic.direction = 1
	@.anim_logic.pause = false
end

function Animation:set_frame(frame)
	@.anim_logic.frame = frame
	@.anim_logic.timer = 0
end

function Animation:set_actions(actions)
	@.anim_logic.actions = actions
end

function Animation:clone()
	return Animation(@.delay, @.frames, @.mode, @.actions)
end
