-- Advent of Code 2021, day 25, part 1

---@class GridMap
---@field max_x number
---@field max_y number
---@field groups table
local GridMap; GridMap = {}
---@param x number
---@param y number
---@return SeaCucumber|nil
function GridMap:get(x,y)
	local row = self[y]
	return row and row[x] or nil
end
---@param x number
---@param y number
function GridMap:set(x,y, value)
	local row = self[y]
	if not row then
		row = {}
		self[y] = row
	end
	-- set value
	row[x] = value
end
function GridMap:move(x,y, dest_x,dest_y)
	if not self:get(dest_x,dest_y) then
		local item = self:get(x,y)
		self:set(x,y, nil)
		self:set(dest_x,dest_y, item)
		return true
	end
	return false
end
---@param x number
---@param y number
---@param obj SeaCucumber
function GridMap:addSeaCucumber(x,y, obj)
	assert(not self:get(x,y))
	table.insert(self.groups[obj:getDirection()], obj)
	self:set(x,y, obj)
end
function GridMap:setDimensions(width, height)
	self.max_x = width
	self.max_y = height
end
function GridMap:doStep()
	local count_moved = 0
	for _,dir in ipairs{">","v"} do
		local group = assert(self.groups[dir])
		local order = {}
		for i,sea_cucumber in ipairs(group) do
			if sea_cucumber:canMove() then table.insert(order, sea_cucumber) end
		end
		--for y=1, self.max_y do for x=1, self.max_x do
		--	local sea_cucumber = self:get(x,y)
		--	if sea_cucumber and sea_cucumber:getDirection()==dir then
		--		if sea_cucumber:canMove() then table.insert(order, sea_cucumber) end
		--	end
		--end end
		for _,sea_cucumber in ipairs(order) do
			assert(sea_cucumber:move())
			count_moved = count_moved + 1
		end
	end

	return count_moved
end
function GridMap:print()
	for y=1, self.max_y do
		for x=1, self.max_x do
			local item = self:get(x,y)
			io.write( item and (item:getDirection()) or '.' )
		end
		io.write("\n")
	end
end
function GridMap.new(width, height)
	local self = setmetatable({
		-- [-i ... +i] = rows
		max_x=width or 0, max_y=height or 0,
		groups = {[">"]={}, ["v"]={}}, -- group sea cucumbers by direction
	},GridMap)
	return self
end
GridMap.__index = GridMap

---@class SeaCucumber
---@field direction string
---@field map GridMap
---@field x number
---@field y number
local SeaCucumber = {valid_directions = {[">"]={1,0}, ["v"]={0,1}}}
SeaCucumber.__index = SeaCucumber
function SeaCucumber:getDirection() return self.direction end
function SeaCucumber:canMove()
	local direction = SeaCucumber.valid_directions[self.direction]
	local dest_x = 1+(self.x-1 + direction[1]) % self.map.max_x
	local dest_y = 1+(self.y-1 + direction[2]) % self.map.max_y
	local res = not self.map:get(dest_x,dest_y)
	return res, res and dest_x or self.x, res and dest_y or self.y
end
function SeaCucumber:move()
	local can_move, dest_x, dest_y = self:canMove()
	if can_move then
		assert(self.map:move(self.x, self.y, dest_x, dest_y))
		self.x, self.y = dest_x, dest_y
	end
	return can_move
end
---@return SeaCucumber
function SeaCucumber.new(direction,map, x,y)
	assert(SeaCucumber.valid_directions[direction])
	assert(map); x, y = assert(tonumber(x)), assert(tonumber(y))
	local self = setmetatable({direction=direction, map=map, x=x,y=y}, SeaCucumber)
	map:addSeaCucumber(x,y, self)
	return self
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local map = GridMap.new()
	local count_line = 0
	local width = 0
	for line in input_iterable do
		line = line:match("(%S+)")
		if line and line:len() > 0 then
			count_line = count_line + 1 -- y
			width = math.max(width,line:len())
			local count_c = 0
			for c in string.gmatch(line,"(.)") do
				count_c = count_c + 1 -- x
				if c~="." then SeaCucumber.new(c,map,count_c,count_line) end
			end
		end
	end
	map:setDimensions(width, count_line)
	return map
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local map = parseInput(input_iterable)
	local step_count = 0
	repeat
		step_count = step_count + 1
		if step_count < 60 then 
			--map:print()	
			--print(string.format("After %d steps:", step_count))
		end
	until map:doStep() < 1
	--map:print()
	-- Return the answer
	return step_count
end

local function main(filename)
	filename = filename~="-" and filename or nil
	local part1answer = solvePart1(io.lines(filename))
	print("Part 1: answer", part1answer)
end

---@return fun():string
local function stringLineIterator(text)
	return string.gmatch(text, "([^\n]+)")
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[
		v...>>.vv>
		.vv>>.vv..
		>>.>v>...v
		>>v>>.>.v.
		v>v.vv.v..
		>.>>..v...
		.vv..>.>v.
		v.v..>>v.v
		....v..v.>
	]]
	test(test_input, 58) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
