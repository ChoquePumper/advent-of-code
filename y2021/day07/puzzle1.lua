-- Advent of Code 2021, day 07, part 1

function solvePart1(input_table)
	table.sort(input_table) -- Sort list
	local n = #input_table; assert(n%2==0)
	local median = (input_table[math.floor(n/2)] + input_table[math.floor(n/2)+1]) / 2
	assert(math.floor(median) == math.ceil(median), "Can't solve")
	median = math.floor(median)
	local total_fuel = 0
	for i=1, n do
		total_fuel = total_fuel + math.abs(median - input_table[i])
	end
	return total_fuel
end

local function stringLineIterator(text)
	return string.gmatch(text,"([^,]+)")
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local full_input = f:read("*a")
	local input_table = {}
	f:close() -- Close file
	for value in stringLineIterator(full_input) do
		table.insert(input_table, assert(tonumber(value)))
	end
	local part1answer = solvePart1(input_table)
	print("Part 1: answer", part1answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(test_input)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	test({16,1,2,0,4,2,7,1,2,14}, 37) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
