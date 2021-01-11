Menu_room = Room:extend('Menu_room')

function Menu_room:new(id)
	Menu_room.super.new(@, id)

	@:add('play_btn', Text(lg.getWidth()/2, lg.getHeight()/2 - 25, "Play \x21", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
	
	@:add('quit_btn', Text(lg.getWidth()/2, lg.getHeight()/2 + 25, "Quit :(", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
end

function Menu_room:update(dt)
	Menu_room.super.update(@, dt)

	local play_btn = @:get('play_btn')
	local quit_btn = @:get('quit_btn')

	if point_rect_collision({lm:getX(), lm:getY()}, play_btn:aabb()) then
		@:once(fn() play_btn.scale_spring:change(1.5) end, 'is_inside_play')
		if pressed('m_1') then game:change_room_with_transition('game') end
	else 
		if @.timer:remove('is_inside_play') then play_btn.scale_spring:change(1) end
	end

	if point_rect_collision({lm:getX(), lm:getY()}, quit_btn:aabb()) then
		@:once(fn() quit_btn.scale_spring:change(1.5) end, 'is_inside_quit')
		if pressed('m_1') then game:change_room_with_transition('game') end
	else 
		if @.timer:remove('is_inside_quit') then quit_btn.scale_spring:change(1) end
	end
end
