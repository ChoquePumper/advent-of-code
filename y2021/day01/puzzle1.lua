-- Advent of Code 2021, day 01, part 1
function solvePart1(input_table)
	local count_increased = 0
	local measurements = #input_table
	assert(measurements > 1)
	local last = input_table[1]
	for i=2, measurements do
		local value = input_table[i]
		if value > last then
			count_increased = count_increased+1
		end
		last = value
	end
	return count_increased
end

function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input_table = {} -- A list with the values
	for line in f:lines() do -- Add each value to the list
		table.insert(input_table, assert(tonumber(line)))
	end
	f:close() -- Close file
	local part1answer = solvePart1(input_table)
	print("Part 1: How many measurements are larger than the previous measurement?", part1answer)
end

function test()
	local answer = solvePart1{199,200,208,210,200,207,240,269,260,263}
	print("Test", answer)
	assert(answer == 7)
end

test() -- Run a test
if arg and arg[1] then
	main(arg[1]) -- Run with the input file
end
