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
  if !@:is_outside(x, y) then
    return @.grid[@.width*(y-1) + x]
  end
end

function Grid:set(x, y, value)
  if !@:is_outside(x, y) then
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
      table.insert(t, @:get(i, j))
    end
  end
  return t, @.width
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


-- Assume the following grid:
-- grid = Grid(10, 10, {
--   1, 1, 1, 0, 0, 0, 0, 1, 1, 0,
--   1, 1, 0, 0, 0, 0, 1, 1, 1, 1,
--   1, 0, 0, 0, 1, 0, 1, 0, 1, 0,
--   0, 0, 0, 1, 1, 1, 0, 0, 1, 0,
--   0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
--   1, 0, 0, 0, 0, 0, 0, 1, 0, 0,
--   1, 1, 0, 0, 0, 0, 1, 1, 0, 0,
--   1, 1, 0, 1, 1, 0, 0, 1, 1, 1,
--   1, 1, 0, 1, 1, 0, 0, 0, 0, 1,
--   0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
-- })
-- In this grid you can see that there are multiple islands of solid positions formed.
-- This function will go over the entire grid and find all the islands of solid values, mark them with different numbers, and return them.
-- Essentially, it would do this: {
--   1, 1, 1, 0, 0, 0, 0, 2, 2, 0,
--   1, 1, 0, 0, 0, 0, 2, 2, 2, 2,
--   1, 0, 0, 0, 3, 0, 2, 0, 2, 0,
--   0, 0, 0, 3, 3, 3, 0, 0, 2, 0,
--   0, 0, 0, 0, 3, 0, 0, 0, 0, 0,
--   4, 0, 0, 0, 0, 0, 0, 5, 0, 0,
--   4, 4, 0, 0, 0, 0, 5, 5, 0, 0,
--   4, 4, 0, 6, 6, 0, 0, 5, 5, 5,
--   4, 4, 0, 6, 6, 0, 0, 0, 0, 5,
--   0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
-- }
-- All values form islands that are connected, and each of those islands is identified by a different number.
-- The function returns this information in two formats: an array of positions per island number, and the marked grid as shown above.
-- islands, marked_grid = grid:flood_fill(1) -> (the value passed in is what the solid value should be, in the case of the array we're using as an example 1 is the proper value)
-- islands is an array that looks like this: {
--  [1] = {{1, 1}, {2, 1}, {3, 1}, {1, 2}, {2, 2}, {1, 3}},
--  [2] = {{8, 1}, {9, 1}, {7, 2}, {8, 2}, {9, 2}, {10, 2}, {7, 3}, {9, 3}, {9, 4}},
--  ...
--  [7] = {{3, 10}}
-- }
-- It contains all the positions in each island, indexed by island number.
-- And marked_grid is simply a Grid instance that looks exactly like the one shown above right after I said "Essentially, it would do this:"
function Grid:flood_fill(v)
  local islands = {}
  local marked_grid = Grid(@.width, @.height, 0)

  local flood_fill = function(i, j, color)
    local queue = {}
    table.insert(queue, {i, j})
    while #queue > 0 do
      local x, y = unpack(table.remove(queue, 1))
      marked_grid:set(x, y, color)
      table.insert(islands[color], {x, y})

      if @:get(x, y-1) == v and marked_grid:get(x, y-1) == 0 then table.insert(queue, {x, y-1}) end
      if @:get(x, y+1) == v and marked_grid:get(x, y+1) == 0 then table.insert(queue, {x, y+1}) end
      if @:get(x-1, y) == v and marked_grid:get(x-1, y) == 0 then table.insert(queue, {x-1, y}) end
      if @:get(x+1, y) == v and marked_grid:get(x+1, y) == 0 then table.insert(queue, {x+1, y}) end
    end
  end

  local color = 1
  islands[color] = {}
  for i = 1, @.width do
    for j = 1, @.height do
      if @:get(i, j) == v and marked_grid:get(i, j) == 0 then
        flood_fill(i, j, color)
        color = color + 1
        islands[color] = {}
      end
    end
  end

  islands[color] = nil
  return islands, marked_grid
end


function Grid:is_outside(x, y)
  if x > @.width then return true end
  if x < 1 then return true end
  if y > @.height then return true end
  if y < 1 then return true end
end

function Grid:is_inside(x, y)
	return !@:is_outside(x, y)
end

function Grid:__tostring()
  local str = ''
  for j = 1, @.height do
    str = str .. '['
    for i = 1, @.width do
      str = str .. @:get(i, j) .. ', '
    end
    str = str:sub(1, -3) .. ']\n'
  end
  return str
end
