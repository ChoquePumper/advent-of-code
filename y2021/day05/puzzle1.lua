-- Advent of Code 2021, day 05, part 1
local GridMap; GridMap = {
	get = function(self, x,y)
		local row = self[y]
		if row then
			return row[x] or 0
		end
		return 0
	end,
	set = function(self, x,y, value)
		local row = self[y]
		if not row then
			row = {}; self[y] = row
		end
		-- set value
		row[x] = value
	end,
	increment = function(self, x,y)
		local value_to_set = self:get(x,y) + 1
		self:set(x,y, value_to_set)
		return value_to_set
	end,
	new = function()
		return setmetatable({
			-- [-i ... +i] = rows
		}, GridMap)
	end,
}
GridMap.__index = GridMap

local function generatePointSequence(x1,y1, x2,y2)
	x1 = assert(tonumber(x1)); y1 = assert(tonumber(y1))
	x2 = assert(tonumber(x2)); y2 = assert(tonumber(y2))
	local sequence = {} -- A list of tuples: {{x,y},...}
	-- For now consider vertical and horizontal lines only
	if x1 == x2 then -- vertical
		for y=y1, y2, (y2>y1) and 1 or -1 do
			table.insert(sequence, {x1,y})
		end
	elseif y1 == y2 then -- horizontal
		for x=x1, x2, (x2>x1) and 1 or -1 do
			table.insert(sequence, {x,y1})
		end
	else
		error("Ign: Not handling 'diagonals for now'")
	end
	assert(#sequence > 0)
	return sequence
end

function solvePart1(input_iterable)
	local map = GridMap.new()
	local count_overlaps = 0
	for line in input_iterable do
		local x1,y1, x2,y2 = string.match(line, "(%d+),(%d+) %-> (%d+),(%d+)")
		--print(x1,y1, x2,y2)
		local _pcall_res, _pcall_ret = pcall(generatePointSequence, x1,y1, x2,y2)
		if not _pcall_res and not _pcall_ret:find("Ign:") then
			error(_pcall_ret,0)
		elseif _pcall_res and _pcall_ret then
			-- Set points on map
			local sequence = _pcall_ret
			for i,point in ipairs(sequence) do
				local x,y = point[1], point[2]
				if map:increment(x,y) == 2 then -- Overlap at least twice
					count_overlaps = count_overlaps + 1
				end
			end
		end
	end
	-- Return the answer
	return count_overlaps
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close()
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
			next_i = nil
		end
		return line
	end
end

function test(test_input, expected_value)
	print("Running test...") 
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[0,9 -> 5,9
	8,0 -> 0,8
	9,4 -> 3,4
	2,2 -> 2,1
	7,0 -> 7,4
	6,4 -> 2,0
	0,9 -> 2,9
	3,4 -> 1,4
	0,0 -> 8,8
	5,5 -> 8,2]]
	test(test_input, 5) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
