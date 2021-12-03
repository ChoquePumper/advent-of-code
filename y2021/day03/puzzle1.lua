-- Advent of Code 2021, day 03, part 1
function bin2dec(bin_num_table)
	local num_digits = #bin_num_table
	assert(num_digits > 0)
	local res = 0
	for i=1, num_digits do
		res = res + (bin_num_table[i] * 2^(num_digits-i))
	end
	return res
end

function solvePart1(input_iterable)
	local count_0s, count_1s
	for bin_num in input_iterable do
		local num = string.match(bin_num,"([01]+)")
		assert(num)
		if not count_0s and not count_1s then
			count_0s, count_1s = {}, {}
			for i=1, #num do
				count_0s[i] = 0
				count_1s[i] = 0
			end
		end
		for i=1, #num do
			local c = num:sub(i,i)
			if c=="0" then count_0s[i] = count_0s[i]+1
			elseif c=="1" then count_1s[i] = count_1s[i]+1
			else error("Parsing error") end
		end
	end
	-- Gamma rate
	local gamma_rate = {}
	for i=1, #count_0s do
		table.insert(gamma_rate, (count_0s[i] > count_1s[i]) and 0 or 1)
	end
	print(table.concat(gamma_rate))
	gamma_rate = bin2dec(gamma_rate)
	print(gamma_rate)
	-- Epsilon rate
	local epsilon_rate = {}
	for i=1, #count_0s do
		table.insert(epsilon_rate, (count_0s[i] < count_1s[i]) and 0 or 1)
	end
	print(table.concat(epsilon_rate))
	epsilon_rate = bin2dec(epsilon_rate)
	print(epsilon_rate)
	-- Return the answer
	return gamma_rate * epsilon_rate
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close() -- Close file
	print("Part 1: answer", part1answer)
end

function test(test_input, expected_value)
	print("Running test...") 
	local answer = solvePart1(string.gmatch(test_input,"([^\n]+)"))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[
		00100
		11110
		10110
		10111
		10101
		01111
		00111
		11100
		10000
		11001
		00010
		01010]]
	test(test_input, 198) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
