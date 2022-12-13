-- Advent Of Code 2022, day 09
require "common"
local GridMap = require "day09.gridmap"
local Point = require "day09.point"

local movements = {
	["U"] = Point.new(0, -1),
	["D"] = Point.new(0,  1),
	["L"] = Point.new(-1, 0),
	["R"] = Point.new( 1, 0),
}

local function sig(val)
	if val == 0 then return 0
	else return val < 0 and -1 or 1 end
end

---@param map GridMap
---@param point Point
---@return boolean # `false` = already marked, `true` otherwhise
local function mark(map, point)
	local prev_value = map:get(point:unpack())
	map:set(point.x, point.y, 1)
	return prev_value == 0
end

---@param pointA Point
---@param pointB Point
local function catchupPoint(pointA, pointB)
	local distance = pointB:distance(pointA)
	local movement = Point.new(0,0)
	if math.abs(distance.x) > 1 or math.abs(distance.y) > 1 then
		movement.x = 1*sig(distance.x)
		movement.y = 1*sig(distance.y)
	end
	pointA:move(movement:unpack())
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local map = GridMap.new({1,1},{1,1})
	local head = Point.new(1,1)
	local tail = Point.new(1,1)
	mark(map, tail)	-- mark starting point
	local answer = 1
	for line in input_iterable do
		local direction, count = string.match(line, "(%w)%s+(%d+)")
		local movement = movements[direction]
		assert(movement, "Unknown direction: "..tostring(direction))
		for i=1, count do
			-- Move head
			local head_previous = Point.new(head:unpack())
			head:move(movement:unpack())
			local distance = head:distance(tail)
			if math.abs(distance.x)>1 or math.abs(distance.y)>1 then
				tail.x, tail.y = head_previous:unpack()
				answer = answer + (mark(map, tail) and 1 or 0)
			end
		end
	end
	return answer
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local map = GridMap.new({1,1},{1,1})
	local rope = {} ---@type Point[] # rope[0] = head, rope[#rope] = tail
	for i=0, 9 do rope[i] = Point.new(1,1) end
	mark(map, rope[#rope])	-- mark starting point
	local answer = 1
	for line in input_iterable do
		local direction, count = string.match(line, "(%w)%s+(%d+)")
		local movement = movements[direction]
		assert(movement, "Unknown direction: "..tostring(direction))
		for _=1, count do
			-- Move head
			rope[0]:move(movement:unpack())
			for i=1, #rope do
				catchupPoint(rope[i], rope[i-1])
			end
			answer = answer + (mark(map, rope[#rope]) and 1 or 0)
		end
	end
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 09, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end