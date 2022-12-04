-- Advent Of Code 2022, day 04
require "common"

local function range(from, to)
	assert(isNumber(from)) assert(isNumber(to))
	return {min=from, max=to}
end

local function isRangeAFullyContainB(a,b)
	return (a.min <= b.min) and (b.max <= a.max)
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local list = {}
	for line in input_iterable do
		local min_a,max_a, min_b,max_b = string.match(line,"(%d+)%-(%d+),(%d+)%-(%d+)")
		min_a, max_a = tonumber(min_a), tonumber(max_a)
		min_b, max_b = tonumber(min_b), tonumber(max_b)
		table.insert(list, {range(min_a, max_a), range(min_b, max_b)} )
	end
	return list
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local ranges = parseInput(input_iterable)
	-- In how many assignment pairs does one range fully contain the other?
	local answer = 0
	for _,pair in ipairs(ranges) do
		if isRangeAFullyContainB(pair[1],pair[2]) or isRangeAFullyContainB(pair[2],pair[1]) then
			answer = answer + 1
		end
	end
	return answer
end

local function isRangeOverlapping(a,b)
	return (a.max >= b.min) and (a.min <= b.max)
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local ranges = parseInput(input_iterable)
	-- In how many assignment pairs do the ranges overlap?
	local answer = 0
	for _,pair in ipairs(ranges) do
		if isRangeOverlapping(pair[1],pair[2]) then
			answer = answer + 1
		end
	end
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 04, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end