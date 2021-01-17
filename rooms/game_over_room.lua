Game_over_room = Room:extend('Game_over_room')

function Game_over_room:new(id)
	Game_over_room.super.new(@, id)

	@:add('retry_btn', Text(lg.getWidth()/2, lg.getHeight()/2 - 25, "Retry ?", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
	
	@:add('quit_btn', Text(lg.getWidth()/2, lg.getHeight()/2 + 25, "Menu", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
end

function Game_over_room:update(dt)
	Game_over_room.super.update(@, dt)

	local retry = @:get('retry_btn')
	local quit_btn = @:get('quit_btn')

	if point_rect_collision({lm:getX(), lm:getY()}, retry:aabb()) then
		@:once(fn() retry.scale_spring:change(1.5) end, 'is_inside_play')
		if pressed('m_1') then game:change_room_with_transition('game') end
	else 
		if @.timer:remove('is_inside_play') then retry.scale_spring:change(1) end
	end

	if point_rect_collision({lm:getX(), lm:getY()}, quit_btn:aabb()) then
		@:once(fn() quit_btn.scale_spring:change(1.5) end, 'is_inside_quit')
		if pressed('m_1') then game:change_room_with_transition('menu') end
	else 
		if @.timer:remove('is_inside_quit') then quit_btn.scale_spring:change(1) end
	end
end
