-- Advent of Code 2021, day 22, part 1

---@class GridMap
---@field min_x number
---@field max_x number
---@field min_y number
---@field max_y number
---@field min_z number
---@field max_z number
local GridMap = {}
function GridMap:isInBounds(x,y,z)
	return (self.min_x <= x and x <= self.max_x and
		self.min_y <= y and y <= self.max_y and
		self.min_z <= z and z <= self.max_z)
end
---@param x number
---@param y number
---@param z number
function GridMap:get(x,y,z)
	local row = self[y]
	if not row then return "0" end
	local col = row[x]
	return col and col[z] or "0"
end
function GridMap:getValuesSet() return self.values_set end
function GridMap:getCubesOn() return self.cubes_on end
---@param x number
---@param y number
---@param z number
function GridMap:set(x,y,z, value)
	local row = self[y]
	if not row then
		row = {}; self[y] = row
	end
	local col = row[x]
	if not col then
		col = {}; row[x] = col
	end
	-- set value
	local prev_value = self:get(x,y,z)
	col[z] = value
	if not col[z] then self.values_set = self.values_set+1 end
	if self:isInBounds(x,y,z) then
		self.cubes_on = self.cubes_on + (prev_value~=value and (value=="1" and 1 or -1) or 0)
	end
	-- update boundaries
	--self.min_x = math.min(self.min_x, x) self.max_x = math.max(self.max_x, x)
	--self.min_y = math.min(self.min_y, y) self.max_y = math.max(self.max_y, y)
end
---@param x_range number[]
---@param y_range number[]
---@param z_range number[]
function GridMap.new(x_range, y_range, z_range)
	local self = setmetatable({
		-- [-i ... +i] = rows
		min_x=x_range[1], max_x=x_range[2],
		min_y=y_range[1], max_y=y_range[2],
		min_z=z_range[1], max_z=z_range[2],
		values_set = 0, -- values that internally are not nil
		cubes_on = 0,
	},GridMap)
	return self
end
GridMap.__index = GridMap

local function rangeIterator(i_start, i_end)
	assert(i_start <= i_end)
	local i = i_start-1
	return function()
		i = i+1
		return i<=i_end and i or nil
	end
end

---@class Cuboid
---@field x1 number
---@field x2 number
---@field y1 number
---@field y2 number
---@field z1 number
---@field z2 number
local Cuboid = {}
Cuboid.__index = Cuboid
---@return fun():number,number,number
function Cuboid:createIterator()
	local x_iter = rangeIterator(self.x1,self.x2)
	local y_iter = rangeIterator(self.y1,self.y2)
	local z_iter = rangeIterator(self.z1,self.z2)
	local x,y,z = x_iter(), y_iter(), z_iter()
	return function()
		local ret_x, ret_y, ret_z = x,y,z
		if z then
			z = z_iter() -- next z value
			if not z then
				y = y_iter() -- next y value
				if not y then
					x = x_iter() -- next x value
					if not x then
						--return nil -- end of iterator
					else
						y_iter = rangeIterator(self.y1,self.y2)
						y = y_iter()
					end
				end
				z_iter = rangeIterator(self.z1,self.z2)
				z = z_iter()
			end
		end
		return ret_x, ret_y, ret_z
	end
end
function Cuboid.new(x_range, y_range, z_range)
	return setmetatable({x1=x_range[1], x2=x_range[2],
		y1=y_range[1], y2=y_range[2],
		z1=z_range[1], z2=z_range[2]}, Cuboid)
end
function Cuboid:__tostring()
	return string.format("Cuboid: x=%d..%d,y=%d..%d,z=%d..%d",
		self.x1,self.x2, self.y1,self.y2, self.z1,self.z2)
end

local function parseLine(line)
	local set, x_range, y_range, z_range = string.match(
		line, "(%w+) x=(%-?%d+%.%.%-?%d+),y=(%-?%d+%.%.%-?%d+),z=(%-?%d+%.%.%-?%d+)")
	local function parseRange(range)
		local r_start, r_end = string.match(range, "(%-?%d+)%.%.(%-?%d+)")
		r_start = assert(tonumber(r_start))
		r_end = assert(tonumber(r_end))
		return {r_start, r_end}
	end
	assert(set=="on" or set=="off")
	local cuboid = Cuboid.new(parseRange(x_range),parseRange(y_range),parseRange(z_range))
	return set, cuboid
end

function solvePart1(input_iterable)
	local range = {-50, 50} -- -50..50
	local map = GridMap.new(range,range,range)
	for line in input_iterable do
		local set, cuboid = parseLine(line)
		--print(set,cuboid)
		local ignore = (cuboid.x1 < map.min_x or cuboid.x2 > map.max_x or
			cuboid.y1 < map.min_y or cuboid.y2 > map.max_x or
			cuboid.x1 < map.min_z or cuboid.z2 > map.max_z)
		if not ignore then
			for x,y,z in cuboid:createIterator() do
				--print(x,y,z)
				local value = set=="on" and "1" or "0"
				map:set(x,y,z, value)
				--print(x,y,z, map:getCubesOn())
			end
		else
			print("Ignoring", tostring(cuboid))
		end
	end
	-- Return the answer
	return map:getCubesOn()
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close()
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	return string.gmatch(text,"([^\n]+)")
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = --[[on x=10..12,y=10..12,z=10..12
	on x=11..13,y=11..13,z=11..13
	off x=9..11,y=9..11,z=9..11
	on x=10..10,y=10..10,z=10..10]]
	[[on x=-20..26,y=-36..17,z=-47..7
on x=-20..33,y=-21..23,z=-26..28
on x=-22..28,y=-29..23,z=-38..16
on x=-46..7,y=-6..46,z=-50..-1
on x=-49..1,y=-3..46,z=-24..28
on x=2..47,y=-22..22,z=-23..27
on x=-27..23,y=-28..26,z=-21..29
on x=-39..5,y=-6..47,z=-3..44
on x=-30..21,y=-8..43,z=-13..34
on x=-22..26,y=-27..20,z=-29..19
off x=-48..-32,y=26..41,z=-47..-37
on x=-12..35,y=6..50,z=-50..-2
off x=-48..-32,y=-32..-16,z=-15..-5
on x=-18..26,y=-33..15,z=-7..46
off x=-40..-22,y=-38..-28,z=23..41
on x=-16..35,y=-41..10,z=-47..6
off x=-32..-23,y=11..30,z=-14..3
on x=-49..-5,y=-3..45,z=-29..18
off x=18..30,y=-20..-8,z=-3..13
on x=-41..9,y=-7..43,z=-33..15
on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
on x=967..23432,y=45373..81175,z=27513..53682]]
	test(test_input, 590784) -- Run a test
	--test(test_input, 39)
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
