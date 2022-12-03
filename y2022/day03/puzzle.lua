-- Advent Of Code 2022, day 03
require "common"

---@param item string -- length 1
---@return number
local function getPriority(item)
	assert(isString(item)) assert(item:len()==1)
	local ascii_value = item:byte()
	if 97 <= ascii_value and ascii_value <= 122 then
		return ascii_value-97 + 1
	elseif 65 <= ascii_value and ascii_value <= 90 then
		return ascii_value-65 + 27
	else
		error("Invalid item "..item)
	end
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local answer = 0 -- Sum of priorities
	for line in input_iterable do
		local half_length = line:len() / 2
		local rucksack = {line:sub(1,half_length), line:sub(half_length+1)}
		local items1 = {}
		for item in string.gmatch(rucksack[1], ".") do
			if not items1[item] then items1[item] = 0 end
			items1[item] = items1[item] + 1
		end
		local common_item
		for item in string.gmatch(rucksack[2], ".") do
			if items1[item] then
				-- Found item in common
				common_item = item
				break
			end
		end
		assert(common_item)
		answer = answer + getPriority(common_item)
	end
	return answer
end

local function intersection(rucksack1, rucksack2)
	local common = {}
	for item in string.gmatch(rucksack1,".") do
		if string.find(rucksack2, item) then
			if not common[item] then
				table.insert(common, item)
				common[item] = true
			end
		end
	end
	return table.concat(common)
end

local function inputIterableGroup3(input_iterable)
	return function() ---@return string, string, string
		local line1 = input_iterable()
		if not line1 then return nil end
		return line1, input_iterable(), input_iterable()
	end
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local answer = 0
	for rs1, rs2, rs3 in inputIterableGroup3(input_iterable) do
		local common = intersection(intersection(rs1,rs2),rs3)
		answer = answer + getPriority(common)
	end
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 03, "..args[2].." result:", result)
end
if _G.arg then runMainFunc(main) end