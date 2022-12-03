-- Advent Of Code 2022, day 01
require "common"

local function sumOfList(list)
	local total = 0
	for _,calories in ipairs(list) do
		total = total + calories
	end
	return total
end

local function calcAndCacheCalories(elf)
	elf._total_calories = sumOfList(elf)
end

local function createElvesList(input_iterable)
	local elves_list = {}
	local current_elf
	local function addElfToList()
		if current_elf then
			-- Calc and cache the sum by the way
			calcAndCacheCalories(current_elf)
			table.insert(elves_list, current_elf)
			current_elf = nil
		end
	end
	---@param line string
	for line in input_iterable do
		if line:len() > 0 then
			if not current_elf then
				current_elf = {}
			end
			table.insert(current_elf, assert(tonumber(line)))
		else
			addElfToList()
		end
	end
	addElfToList()
	return elves_list
end

---@param input_iterable function
function solvePart1(input_iterable)
	local elves_list = createElvesList(input_iterable)

	-- Find the Elf carrying the most Calories.
	-- How many total Calories is that Elf carrying?
	local max_calories = 0
	for _,elf in ipairs(elves_list) do
		max_calories = math.max(elf._total_calories, max_calories)
	end
	return max_calories
end

function solvePart2(input_iterable)
	local elves_list = createElvesList(input_iterable)

	-- Find the 3 elves carrying the most of total calories
	-- Sort list
	table.sort(elves_list, function (a,b)
		return a._total_calories > b._total_calories
	end)
	print("Top 3: ", elves_list[1]._total_calories, elves_list[2]._total_calories, elves_list[3]._total_calories)
	local answer = elves_list[1]._total_calories + elves_list[2]._total_calories + elves_list[3]._total_calories
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = solverFunction( io.lines(input_file, "l") )
	print("Day 01, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end