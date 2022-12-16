-- Advent Of Code 2022, day 14
require "common"
local GridMap = require "day14.gridmap"
local Point = require "day14.point"

function string.split(s, delimiter)
	local i = 1
	local next_i = 1
	local res = {}	---@type string[]
	while next_i do
		local end_i
		next_i, end_i = string.find(s, delimiter, next_i, true)
		table.insert(res, string.sub(s, i, next_i and next_i-1))
		if end_i then
			i = end_i+1
			next_i = i
		end
	end
	return res
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local lines = {} ---@type Point[][]
	for line in input_iterable do
		local points = {}	---@type Point[]
		for _,str_point in ipairs(line:split("->")) do
			table.insert(points, Point.new(str_point:split(",")))
		end
		assert(#points >= 2, "line must have at least 2 points")
		table.insert(lines, points)
	end
	return lines
end

---@param map GridMap
---@param points_list Point[]
local function drawLine(map, points_list)
	local prev_point = nil	---@type Point
	for _,point in ipairs(points_list) do
		if prev_point then
			if prev_point.x ~= point.x and prev_point.y ~= point.y then
				error("Can't draw diagonal lines")
			elseif prev_point.x ~= point.x then
				for x=prev_point.x, point.x, point.x < prev_point.x and -1 or 1 do
					map:set(x, point.y, "#")
				end
			elseif prev_point.y ~= point.y then
				for y=prev_point.y, point.y, point.y < prev_point.y and -1 or 1 do
					map:set(point.x, y, "#")
				end
			end
		end
		prev_point = point
	end
end

local function dropSandUnit(map, x_pos)
	x_pos = x_pos or 500
	local position = Point.new(x_pos, 0)
	assert(map:get(position:unpack()) == nil, "starting position blocked")
	local falling = true
	local check_delta_x = {0, -1, 1} ---@type integer[]
	while falling do
		-- Check
		local blocked = true
		for _,delta_x in ipairs(check_delta_x) do
			local val = map:get(position.x+delta_x, position.y+1)
			if not val then
				blocked = false
				position:move(delta_x, 1)
				break
			end
		end
		if blocked then
			falling = false
		elseif not map:isInBoundsY(position.y) then
			break
		end
	end
	if not falling then
		assert(map:isInBoundsY(position.y))
		map:set(position.x, position.y, "o") -- Place unit of sand
	end
	return (not falling), position
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local lines = parseInput(input_iterable) ---@type Point[][]
	local map = GridMap.new({500,500},{0,0})
	-- Draw lines of rocks in map
	for _,line in ipairs(lines) do
		drawLine(map, line)
		print(map.min_x, map.max_x, map.min_y, map.max_y)
	end
	local answer = 0
	print("Map")
	--map.floor = map.max_y + 2
	--map.max_y = map.floor
	print(map:toString())
	while dropSandUnit(map, 500) do
		answer = answer + 1
	end
	print("Map")
	print(map:toString())
	return answer
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local lines = parseInput(input_iterable) ---@type Point[][]
	local map = GridMap.new({500,500},{0,0})
	-- Draw lines of rocks in map
	for _,line in ipairs(lines) do
		drawLine(map, line)
		print(map.min_x, map.max_x, map.min_y, map.max_y)
	end
	local answer = 0
	print("Map")
	map.floor = map.max_y + 2
	map.max_y = map.floor
	print(map:toString())
	local function wrapperDropSandUnit()
		local res, err = pcall(dropSandUnit, map, 500)
		if not res then
			if not string.find(err, "starting position blocked", 1, true) then
				error(err)
			end
		end
		return res
	end
	while wrapperDropSandUnit() do
		answer = answer + 1
	end
	--print("Map")
	--print(map:toString())
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 14, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end