Grid = Class:extend('Grid')

function Grid:new(w, h, value)
  @.grid   = {}
	@.width  = w
	@.height = h
	
	if type(value) ~= 'table' then
		foreach(h, fn(j) 
			foreach(w, fn(i) 
				@.grid[w*(j-1) + i] = value or 0
			end)
		end)
	else
		foreach(h, fn(j) 
			foreach(w, fn(i)
				@.grid[w*(j-1) + i] = value[w*(j-1) + i]
			end)
		end)
  end
end

function Grid:clone()
	return Grid(@.width, @.height, @.grid)
end

function Grid:get(x, y)
  if !@:is_oob(x, y) then
    return @.grid[@.width*(y-1) + x]
  end
end

function Grid:set(x, y, value)
  if !@:is_oob(x, y) then
    @.grid[@.width*(y-1) + x] = value
  end
end

function Grid:foreach(func)
  for i = 1, @.width do
    for j = 1, @.height do
      func(@, i, j)
    end
  end
end

function Grid:to_table() 
  local t = {}
  for j = 1, @.height do
    for i = 1, @.width do
      insert(t, {i, j, @:get(i, j)}) 
    end
  end
  return t -- {{x, y, value}, ...}
end

function Grid:rotate_anticlockwise()
  local new_grid = Grid(@.height, @.width, 0)
  for i = 1, @.width do
    for j = 1, @.height do
      new_grid:set(j, i, @:get(i, j))
    end
  end

  for i = 1, new_grid.w do
    for k = 0, math.floor(new_grid.h/2) do
      local v1, v2 = new_grid:get(i, 1+k), new_grid:get(i, new_grid.h-k)
      new_grid:set(i, 1+k, v2)
      new_grid:set(i, new_grid.h-k, v1)
    end
  end

  return new_grid
end

function Grid:rotate_clockwise()
  local new_grid = Grid(@.height, @.width, 0)
  for i = 1, @.width do
    for j = 1, @.height do
      new_grid:set(j, i, @:get(i, j))
    end
  end

  for j = 1, new_grid.h do
    for k = 0, math.floor(new_grid.w/2) do
      local v1, v2 = new_grid:get(1+k, j), new_grid:get(new_grid.w-k, j)
      new_grid:set(1+k, j, v2)
      new_grid:set(new_grid.w-k, j, v1)
    end
  end

  return new_grid
end

function Grid:is_oob(x, y)
  if x > @.width then return true end
  if x < 1 then return true end
  if y > @.height then return true end
  if y < 1 then return true end
end

function Grid:to_string()
  local str = ''
  for j = 1, @.height do
		str ..= '['
		foreach(@.width, fn(i) str ..= @:get(i, j) .. ', ' end)
    str = str:sub(1, -3) .. ']\n'
  end
  return str
end
