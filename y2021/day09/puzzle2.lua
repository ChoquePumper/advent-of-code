-- Advent of Code 2021, day 09, part 2
local GridMap; GridMap = {
    get = function(self, x,y)
        local row = self[y]
        if row then
            return row[x]
        end
        return nil
    end,
    getValuesSet = function(self)
        return self.values_set
    end,
    set = function(self, x,y, value)
        local row = self[y]
        if not row then
            row = {}
            self[y] = row
        end
        if not row[x] then self.values_set = self.values_set+1 end
        -- set value
        row[x] = value
    end,
    new = function(width,height,values)
		local self = values or {}
            -- [-i ... +i] = rows
		self.values_set = values and width*height or 0
		self.max_y = height
		self.max_x = width
        return setmetatable(self, GridMap)
    end
}
GridMap.__index = GridMap

local TracePoint; TracePoint = {
	getNextDirection = function(self)
		local res = next(self.directions_remaining)
		if res then self.directions_remaining[res] = nil; end
		return res
	end,
	new = function(x,y, from)
		local directions_remaining = {l=true, r=true, u=true, d=true}
		if from then
			directions_remaining[from:sub(1,1)] = nil
		end
		return setmetatable({
			x = x, y = y,
			directions_remaining=directions_remaining,
			from = from,
		},TracePoint)
	end
}
TracePoint.__index = TracePoint

local opposite_dir = {l="r", r="l", u="d", d="u"}

local Cursor; Cursor = {
	moveByDir = function(self,direction)
		if direction=="l" then self:move(-1, 0)
		elseif direction=="r" then self:move( 1, 0)
		elseif direction=="u" then self:move( 0,-1)
		elseif direction=="d" then self:move( 0, 1)
		else error("Invalid direction: "..direction)
		end
	end,
    move = function(self,x,y)
        assert(tonumber(x)) assert(tonumber(y))
        self.x = self.x + x
        self.y = self.y + y
    end,
	findBasinSize = function(self)
		-- Use another map to mark all locations for a single basin
		local basin_map = GridMap.new(self.map.max_x, self.map.max_y)
		local trace = {} -- a stack
		local function markPoint(dir_from)
			basin_map:set(self.x, self.y, 1)
			table.insert(trace,TracePoint.new(self.x, self.y, dir_from))
		end
		local flag_stop = false
		local last_direction = nil
		repeat
			if self:canMark(basin_map) then
				if last_direction then from = opposite_dir[last_direction] end
				markPoint(from)
			end
			-- Get the top of the stack
			local next_point = trace[#trace]
			if next_point then
				self.x, self.y = next_point.x, next_point.y
				local direction = next_point:getNextDirection()
				if not direction then
					table.remove(trace) -- pop
				else
					self:moveByDir(direction)
				end
				-- Probably this last_direction thing was not well implemented
				--last_direction = direction
			else
				flag_stop = true
			end
		until flag_stop
		return basin_map:getValuesSet()
	end,
	isInBounds = function(self) return 1<=self.x and self.x<=self.map.max_x and 1<=self.y and self.y<=self.map.max_y end,
	canMark = function(self, basin_map)
		return self:isInBounds() and (not basin_map:get(self.x,self.y)) and self.map:get(self.x,self.y)<9
	end,
    new = function(map, init_x, init_y)
        return setmetatable({
            map = map,
            x = init_x or 1, y = init_y or 1,
        }, Cursor)
    end,
}
Cursor.__index = Cursor

function getLevel(map, x,y)
	local y_row = map[y]
	if not y_row then return nil end
	return y_row[x]
end

function solvePart2(input_table)
	local max_y = #input_table
	local max_x = #input_table[1]
	local map = GridMap.new(max_x,max_y, input_table)
	local cursors = {}
	for y=1,max_y do for x=1, max_x do
		local level = map:get(x,y)
		local is_low = true
		for _,dy in ipairs{-1,1} do
			local adyacent_level = map:get(x,y+dy)
			if adyacent_level and level >= adyacent_level then
				is_low = false
			end
		end
		for _,dx in ipairs{-1,1} do
			local adyacent_level = map:get(x+dx,y)
			if adyacent_level and level >= adyacent_level then
				is_low = false
			end
		end
		if is_low then
			-- Set a cursor at position x,y
			table.insert(cursors, Cursor.new(map, x, y))
		end
	end end
	-- Get all basins size
	assert(#cursors >= 3)
	local basin_sizes = {}
	for i,cursor in ipairs(cursors) do
		local bs = cursor:findBasinSize(); assert(bs > 0)
		table.insert(basin_sizes, bs)
		print("Cursor "..tostring(i), bs)
	end
	table.sort(basin_sizes)
	-- Return the answer: multiply the 3 biggest basins
	return table.remove(basin_sizes)*table.remove(basin_sizes)*table.remove(basin_sizes)
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
	local part2answer = solvePart2(input_table)
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
	local input_table = {} -- A list with the values
	for line in stringLineIterator(test_input) do -- Add each value to the list
	   	table.insert(input_table, charsToTable(line))
	end
	local answer = solvePart2(input_table)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[2199943210
	3987894921
	9856789892
	8767896789
	9899965678]]
	test(test_input, 1134) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
