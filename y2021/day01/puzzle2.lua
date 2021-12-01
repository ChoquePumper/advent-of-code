-- Advent of Code 2021, day 01, part 2
function getThreeMeasurement(input_table,pos)
	local val1, val2, val3 = input_table[pos], input_table[pos+1], input_table[pos+2]
	return val1+val2+val3
end

function solvePart2(input_table)
	local count_increased = 0
	local measurements = #input_table
	assert(measurements > 1)
	local last = getThreeMeasurement(input_table,1)
	for i=2, measurements-2 do
		local value = getThreeMeasurement(input_table,i)
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
	local part2answer = solvePart2(input_table)
	print("Part 2: How many measurements are larger than the previous measurement?", part2answer)
end

function test()
	local answer = solvePart2{199,200,208,210,200,207,240,269,260,263}
	print("Test", answer)
	assert(answer == 5)
end

test()
if arg and arg[1] then
	main(arg[1])
end
