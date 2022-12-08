-- Advent Of Code 2022, day 08
require "common"
local GridMap = require "day08.gridmap"

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local map = GridMap.new({1,1},{1,1})
	local x_pos = 0
	for line in input_iterable do
		x_pos = x_pos + 1
		local y_pos = 0
		for char in line:gmatch(".") do
			y_pos = y_pos + 1
			local value = assert(tonumber(char))
			map:set(x_pos, y_pos, value)
		end
	end
	return map
end

local function isVisibleFromLeft(map, x_pos,y_pos)
	local height = map:get(x_pos,y_pos)
	for x=x_pos-1, map.min_x-1, -1 do
		if map:get(x, y_pos) >= height then return false end
	end
	return true
end
local function isVisibleFromRight(map, x_pos,y_pos)
	local height = map:get(x_pos,y_pos)
	for x=x_pos+1, map.max_x+1, 1 do
		if map:get(x, y_pos) >= height then return false end
	end
	return true
end

local function isVisibleFromUp(map, x_pos,y_pos)
	local height = map:get(x_pos,y_pos)
	for y=y_pos-1, map.min_y-1, -1 do
		if map:get(x_pos, y) >= height then return false end
	end
	return true
end
local function isVisibleFromDown(map, x_pos,y_pos)
	local height = map:get(x_pos,y_pos)
	for y=y_pos+1, map.max_y+1, 1 do
		if map:get(x_pos, y) >= height then return false end
	end
	return true
end
local function isVisible(map, x_pos,y_pos)
	return isVisibleFromLeft(map, x_pos,y_pos) or
	       isVisibleFromRight(map, x_pos,y_pos) or
	       isVisibleFromUp(map, x_pos,y_pos) or
	       isVisibleFromDown(map, x_pos,y_pos)
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local map = parseInput(input_iterable)
	local count_visible = 0
	for x=map.min_x, map.max_x do for y=map.min_y, map.max_y do
		if x==map.min_x or x==map.max_x or y==map.min_y or y==map.max_y then
			-- If position is edge
			count_visible = count_visible + 1
		elseif isVisible(map, x,y) then
			count_visible = count_visible + 1
		end
	end end
	return count_visible
end

local function calcScenicScore(map, x_pos, y_pos)
	local count = {left=0, right=0, up=0, down=0}
	local tree_height = map:get(x_pos,y_pos)
	-- Left
	for x=x_pos-1, map.min_x, -1 do
		local height = map:get(x,y_pos)
		count.left = count.left + 1
		if height >= tree_height then break end -- Blocked?
	end
	
	-- Right
	for x=x_pos+1, map.max_x, 1 do
		local height = map:get(x,y_pos)
		count.right = count.right + 1
		if height >= tree_height then break end -- Blocked?
	end

	-- Up
	for y=y_pos-1, map.min_y, -1 do
		local height = map:get(x_pos,y)
		count.up = count.up + 1
		if height >= tree_height then break end -- Blocked?
	end
	
	-- Down
	for y=y_pos+1, map.max_y, 1 do
		local height = map:get(x_pos,y)
		count.down = count.down + 1
		if height >= tree_height then break end -- Blocked?
	end
	
	--print(x_pos, y_pos, count.left, count.right, count.up, count.down)
	return count.left * count.right * count.up * count.down
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local map = parseInput(input_iterable)
	local answer = 0
	for x=map.min_x, map.max_x do for y=map.min_y, map.max_y do
		answer = math.max(calcScenicScore(map, x,y), answer)
	end end
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 08, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end