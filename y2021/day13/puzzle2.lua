-- Advent of Code 2021, day 13, part 2
local GridMap; GridMap = {
	get = function(self, x,y)
		local row = self[y]
		return row and row[x] or nil
	end,
	set = function(self, x,y, value)
		local row = self[y]
		if not row then
			row = {}
			self[y] = row
		end
		-- set value
		row[x] = value
		-- update boundaries
		self.min_x = math.min(self.min_x, x) self.max_x = math.max(self.max_x, x)
		self.min_y = math.min(self.min_y, y) self.max_y = math.max(self.max_y, y)
	end,
	foldUp = function(self, y_val)
		assert((math.abs(self.min_y)+math.abs(self.max_y)) / 2 == y_val)
		for y=y_val+1, self.max_y do
			local dy = y - y_val
			for x=self.min_x, self.max_x do
				local value = self:get(x,y)
				if value then self:set(x,y_val-dy, value) end
			end
		end
		self.max_y = y_val-1
	end,
	foldLeft = function(self, x_val)
		-- This assert is useless?
		--print(x_val, (math.abs(self.min_x)+math.abs(self.max_x)+1) / 2)
		--assert((math.abs(self.min_x)+math.abs(self.max_x)) / 2 == x_val)
		for x=x_val+1, self.max_x do
			local dx = x - x_val
			for y=self.min_y, self.max_y do
				local value = self:get(x,y)
				if value then self:set(x_val-dx,y, value) end
			end
		end
		self.max_x = x_val-1
	end,
	countVisibleDots = function(self)
		local count = 0
		for y=self.min_y, self.max_y do for x=self.min_x, self.max_x do
			count = count + (self:get(x,y)=="#" and 1 or 0)
		end end
		return count
	end,
	printMap = function(self)
		for y=self.min_y, self.max_y do
			for x=self.min_x, self.max_x do
				io.write(self:get(x,y) or ".")
			end
			io.write("\n")
		end
		io.flush()
	end,
	new = function()
		return setmetatable({
			-- [-i ... +i] = rows
			min_x = 0, min_y = 0,
			max_x = 0, max_y = 0,
		}, GridMap)
	end
}
GridMap.__index = GridMap

function solvePart2(input_iterable)
	local map = GridMap.new()
	for line in input_iterable do
		if line:len()<1 or not line:find("(%S)") then break end
		local x,y = string.match(line, "(%d+),(%d+)")
		x = assert(tonumber(x)); y = assert(tonumber(y))
		map:set(x,y, "#")
	end
	-- input_iterable returned nil here. Now parse the fold instructions
	local fold_instructions = {}
	for line in input_iterable do
		local axis, val = string.match(line, "fold along (%w)=(%d+)")
		assert(axis) val = assert(tonumber(val))
		table.insert(fold_instructions, {axis=axis, val=val})
	end
	
	local count_instructions = #fold_instructions
	for i,fold in ipairs(fold_instructions) do
		print(string.format("Executing fold instruction %d/%d...", i, count_instructions))
		if fold.axis == "y" then
			map:foldUp(fold.val)
		elseif fold.axis == "x" then
			map:foldLeft(fold.val)
		else
			error("Invalid axis: "..tostring(fold.axis))
		end
	end
	map:printMap() -- The answer is printed out.
	--return map:countVisibleDots() no numeric answer on this part
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part2answer = solvePart2(f:lines())
	f:close()
	print("Part 2: answer", part2answer)
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
	local answer = solvePart2(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %s", tostring(expected_value)))
end

if arg then
	local test_input = [[6,10
	0,14
	9,10
	0,3
	10,4
	4,11
	6,0
	6,12
	4,1
	0,13
	10,12
	3,4
	3,0
	8,4
	1,10
	2,14
	8,10
	9,0
	
	fold along y=7
	fold along x=5]]
	test(test_input, nil) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
