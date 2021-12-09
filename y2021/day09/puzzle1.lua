-- Advent of Code 2021, day 09, part 1

function getLevel(map, x,y)
	local y_row = map[y]
	if not y_row then return nil end
	return y_row[x]
end

function solvePart1(input_table)
	local map = input_table
	map.max_y = #map
	map.max_x = #map[1]
	local sum_risk_levels = 0
	for y=1,map.max_y do for x=1, map.max_x do
		local level = getLevel(map,x,y)
		local is_low = true
		for _,dy in ipairs{-1,1} do
			local adyacent_level = getLevel(map,x,y+dy)
			if adyacent_level and level >= adyacent_level then
				is_low = false
			end
		end
		for _,dx in ipairs{-1,1} do
			local adyacent_level = getLevel(map,x+dx,y)
			if adyacent_level and level >= adyacent_level then
				is_low = false
			end
		end
		if is_low then
			print("low point at",x,y, level)
			sum_risk_levels = sum_risk_levels + 1 + level;
		end
	end end
	-- Return the answer
	return sum_risk_levels
end

local function charsToTable(chars)
	local t = {}
	for level in string.gmatch(chars,"(%d)") do
		table.insert(t,assert(tonumber(level)))
	end
	return t
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input_table = {} -- A list with the values
	for line in f:lines() do -- Add each value to the list
	   	table.insert(input_table, charsToTable(line))
	end
	f:close() -- Close file
	local part1answer = solvePart1(input_table)
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	local next_i = 1
	return function()
		if not next_i then return nil end
		local line = nil
		local found_at = string.find(text,"(\n)", next_i)
		if found_at then
			line = text:sub(next_i, found_at-1)
			next_i = found_at+1
		else
			line = text:sub(next_i)
			if #line < 1 then line = nil end -- Ignore last line if it's empty
			next_i = nil
		end
		return line
	end
end

function test(test_input, expected_value)
	print("Running test...")
	local input_table = {} -- A list with the values
	for line in stringLineIterator(test_input) do -- Add each value to the list
	   	table.insert(input_table, charsToTable(line))
	end
	local answer = solvePart1(input_table)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[2199943210
	3987894921
	9856789892
	8767896789
	9899965678]]
	test(test_input, 15) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
