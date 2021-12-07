-- Advent of Code 2021, day 07, part 2

function calcFuel(steps)
	local total = 0
	for i=1, steps do total = total+i end
	return total
end

function solvePart2(input_table)
	local n = #input_table
	local sum = 0
	for i=1, n do sum = sum + input_table[i]; end
	local min_total_fuel = math.huge
	for _,int_funcname in ipairs{"floor","ceil"} do
		local fuel = 0
		local mean_int = math[int_funcname](sum / n)
		for i=1, n do
			fuel = fuel + calcFuel(math.abs(mean_int-input_table[i]))
		end
		min_total_fuel = math.min(min_total_fuel,fuel)
		print("mean", int_funcname, fuel)
	end
	return min_total_fuel
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
	local part2answer = solvePart2(input_table)
	print("Part 2: answer", part2answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart2(test_input)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	test({16,1,2,0,4,2,7,1,2,14}, 168) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
