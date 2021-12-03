-- Advent of Code 2021, day 03, part 2
function bin2dec(bin_num)
	local num_digits = #bin_num
	assert(num_digits > 0)
	local res = 0
	for i=1, num_digits do
		res = res + (bin_num:sub(i,i) * 2^(num_digits-i))
	end
	return res
end

local function oxigen_criteria(count_0s, count_1s)
	-- Most common bit
	return (count_0s > count_1s) and "0" or "1"
end

local function co2_criteria(count_0s, count_1s)
	-- Least common bit
	return (count_0s <= count_1s) and "0" or "1"
end

function discard_numbers(bin_num_list, bit_index, criteria_func)
	assert(#bin_num_list > 1, "Not enough items in list")
	bit_index = assert(tonumber(bit_index)) -- selected bit
	assert(type(criteria_func)=="function","criteria is not a function")
	local newlist = {}
	local count_0s, count_1s = 0, 0
	for _,num in ipairs(bin_num_list) do
		local c = num:sub(bit_index,bit_index)
		if     c=="0" then count_0s = count_0s + 1
		elseif c=="1" then count_1s = count_1s + 1
		else error("Parsing error") end
		-- Add to the new list
		table.insert(newlist, num)
	end
	-- Discard numbers that don't match the criteria
	local criteria = criteria_func(count_0s,count_1s)
	for i=#newlist, 1, -1 do
		if #newlist <= 1 then break; end
		local num = newlist[i]
		if num:sub(bit_index,bit_index) ~= criteria then
			table.remove(newlist,i) -- not matching. discard.
		end
	end
	local remaining = #newlist
	local count_removed = #bin_num_list - remaining
	print(string.format("discard_numbers result: bit_index=%d, remaining=%d (%d removed)",bit_index, remaining, count_removed))
	assert(#newlist >= 1, "Ended with no elements")
	return newlist
end

function solvePart2(input_iterable)
	local initial_list = {}
	for bin_num in input_iterable do
		local num = string.match(bin_num,"([01]+)")
		assert(num)
		table.insert(initial_list,num)
	end
	local len_bits = #initial_list[1]
	-- Find oxygen generator rating
	local o2_gen_list = initial_list
	local next_bit_index = 1
	while #o2_gen_list > 1 do
		o2_gen_list = discard_numbers(o2_gen_list,next_bit_index,oxigen_criteria)
		next_bit_index = 1 + next_bit_index % len_bits
	end
	local o2_gen_rating = bin2dec( assert(o2_gen_list[1]) )
	-- Find CO2 scrubber rating
	local co2_scr_list = initial_list
	local next_bit_index = 1
	while #co2_scr_list > 1 do
		co2_scr_list = discard_numbers(co2_scr_list,next_bit_index,co2_criteria)
		next_bit_index = 1 + next_bit_index % len_bits
	end
	local co2_scr_rating = bin2dec( assert(co2_scr_list[1]) )
	-- Return the answer
	return o2_gen_rating * co2_scr_rating
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart2(f:lines())
	f:close() -- Close file
	print("Part 2: answer", part1answer)
end

function test(test_input, expected_value)
	print("Running test...") 
	local answer = solvePart2(string.gmatch(test_input,"([^\n]+)"))
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
	test(test_input, 230) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
