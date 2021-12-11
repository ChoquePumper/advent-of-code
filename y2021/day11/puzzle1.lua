-- Advent of Code 2021, day 11, part 1
local GridMap; GridMap = {
	get = function(self, x,y)
		assert(self:isInBounds(x,y))
		return self[y][x]
	end,
	set = function(self, x,y, value)
		assert(self:isInBounds(x,y))
		self[y][x] = value
	end,
	isInBounds = function(self, x,y) return 1<=x and x<=self.max_x and 1<=y and y<=self.max_y end,
	new = function(width,height,values)
		local self = assert(values)
			-- [-i ... +i] = rows
		self.values_set = values and width*height or 0
		self.max_y = height
		self.max_x = width
		return setmetatable(self, GridMap)
	end
}
GridMap.__index = GridMap

function increaseToAdjacent(map, points)
	assert(map)
	assert(points,"points table is required, got "..tostring(points))
	local more_flashes_points = {}
	for i,point in ipairs(points) do
		for _,dy in ipairs{-1,0,1} do for _,dx in ipairs{-1,0,1} do
			local adj_x, adj_y = point.x+dx, point.y+dy
			if not(dy==0 and dx==0) and map:isInBounds(adj_x,adj_y) then
				local energy_level = map:get(adj_x,adj_y)
				if energy_level > 0 then
					energy_level = energy_level + 1
					if energy_level > 9 then -- FLASH!
						table.insert(more_flashes_points, {x=adj_x,y=adj_y})
						energy_level = 0
					end
					map:set(adj_x,adj_y, energy_level)
				end
			end
		end end
	end
	return more_flashes_points
end

function doStep(map)
	local flashes_count = 0
	local flashes_points = {}
	for y=1, map.max_y do for x=1, map.max_x do
		local energy_level = map:get(x,y) + 1
		if energy_level > 9 then -- FLASH!
			flashes_count = flashes_count + 1
			table.insert(flashes_points, {x=x,y=y})
			energy_level = 0
		end
		map:set(x,y, energy_level)
	end end
	while #flashes_points > 0 do
		flashes_points = increaseToAdjacent(map,flashes_points)
		flashes_count = flashes_count + #flashes_points
	end
	return flashes_count
end

function solvePart1(input_table, num_steps)
	local max_x, max_y = #input_table[1], #input_table
	local map = GridMap.new(max_x, max_y, input_table)
	local total_flashes = 0
	for i=1, num_steps do
		total_flashes = total_flashes + doStep(map)
		if i%10==0 then
			print(string.format("After %s steps, there have been a total of %d flashes.",i,total_flashes))
		end
	end
	-- Return the answer
	return total_flashes
end

function inputTo2Dtables(input_iterable)
	local input_table = {} -- A list with the values
	for line in input_iterable do
		local row = {}
		for c in string.gmatch(line,"(%d)") do
			table.insert(row, assert(tonumber(c)))
		end
		table.insert(input_table,row)
	end
	return input_table
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input_table = inputTo2Dtables(f:lines())
	f:close() -- Close file
	local part1answer = solvePart1(input_table, 100)
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	return string.gmatch(text,"([^\n]+)")
end

function test(test_input, num_steps, expected_value)
	print("Running test...")
	local input_table = inputTo2Dtables(stringLineIterator(test_input))
	local answer = solvePart1(input_table, num_steps)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input1 = [[
		11111
		19991
		19191
		19991
		11111]]
	local test_input2 = [[
		5483143223
		2745854711
		5264556173
		6141336146
		6357385478
		4167524645
		2176841721
		6882881134
		4846848554
		5283751526]]
	test(test_input1, 2, 9) -- Run a test
	test(test_input2, 100, 1656) -- Run another test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
