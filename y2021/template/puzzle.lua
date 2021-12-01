-- Advent of Code 2021, day ##, part ?
function solvePart1(input_table)
	--[[
		Function body that solves the puzzle
	]]
	-- Return the answer
	return answer
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input_table = {} -- A list with the values
	for line in f:lines() do -- Add each value to the list
	   	-- Get the values
	end
	f:close() -- Close file
	local part1answer = solvePart1(input_table)
	print("Part 1: answer", part1answer)
end

function test()
	print("Running test...")
	local test_input = {--[[ test input ]]}
	local answer = solvePart1(test_input)
	print("Test", answer)
	assert(answer == "?")
end

if arg then
	test() -- Run a test
	if arg[1] then
		main(arg[1]) -- Run with the specified input file from argument 1
	end
end
