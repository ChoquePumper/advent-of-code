-- Advent of Code 2021, day ##, part ?
function solvePart1(input_table)
	--[[
		Function body that solves the puzzle
	]]
	-- Return the answer
	return answer
end

function solvePart1_(input_iterable)
	for line in input_iterable do
		--
	end
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

local function main_(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close()
	print("Part 1: answer", part1answer)
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
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

function test(test_input, expected_value)
	print("Running test...")
	local input_table = {} -- A list with the values
	for line in stringLineIterator(test_input) do -- Add each value to the list
	   	--table.insert(input_table, line)
	end
	local answer = solvePart1(input_table)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = {}
	test(test_input, "?") -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
