-- Advent of Code 2021, day 08, part 2
local digits_with_unique_number_segments = {
	[2] = 1, [4] = 4, [3] = 7, [7] = 8,
}

function groupPatternsByNSegements(list)
	local t = {}
	for _,pattern in ipairs(list) do
		local list = t[#pattern]
		if not list then
			list = {}
			t[#pattern] = list
		end
		table.insert(list,pattern)
	end
	return t
end

function sumSegments(a,b)
	local plus = {}
	for c in string.gmatch(b,"(.)") do
		if not string.find(a,c) then
			table.insert(plus,c)
		end
	end
	return a .. table.concat(plus)
end

function subtractSegments(a,b)
	return string.gsub(a, "["..b.."]", "")
end

function intersectSegments(a,b)
	local sub_a = subtractSegments(a,b)
	if sub_a == a then return "";
	elseif #sub_a < 1 then return sub_a;
	end
	return subtractSegments(a, sub_a)
end

function getDigitTable(unique_digit_patterns)
	assert(type(unique_digit_patterns)=="table")
	assert(#unique_digit_patterns == 10)
	local groups = groupPatternsByNSegements(unique_digit_patterns)
	local digits_table, count = {}, 0
	-- 1, 4, 7 and 8 have unique number of segments
	-- 1 has 2 segments, 4 has 4, 7 has 3, and 8 has 7
	-- Ensure that there is only one patten for each one
	for i,n in ipairs{2,4,3,7} do
		assert(#groups[n]==1)
		-- By the way, add them to the table
		digits_table[digits_with_unique_number_segments[n]] = groups[n][1]
		count = count+1
	end
	assert(#groups[5] == 3) -- 2, 5 and 3 have 5 segments
	assert(#groups[6] == 3) -- 0, 6 and 9 have 6 segments
	assert(count == 4, "There must be 4 digits found")
	-- Let's find "9"
	local four_seven = sumSegments(digits_table[4],digits_table[7])
	-- Segments for 4 and 7 cover all segements for 9 except the bottom.
	-- 0 and 6 cover the bottom and bottom-left segments but 9 doesn't cover the latter one.
	local pattern_nine
	for i,pattern in ipairs(groups[6]) do
		if #subtractSegments(pattern, four_seven) == 1 then
			assert(not pattern_nine)
			pattern_nine = pattern
			table.remove(groups[6], i)
		end
	end
	digits_table[9] = assert(pattern_nine) -- Nine found?
	count = count+1 -- 5
	-- Let's find "3"
	local pattern_three
	for i,pattern in ipairs(groups[5]) do
		if #subtractSegments(pattern, digits_table[1]) == 3 then
			assert(not pattern_three)
			pattern_three = pattern
			table.remove(groups[5], i)
		end
	end
	digits_table[3] = assert(pattern_three) -- Three found?
	count = count+1 -- 6
	-- Let's find "0" and "6"
	local int_06_sum_1 = sumSegments( intersectSegments(groups[6][1],groups[6][2]), digits_table[1] )
	local is_zero = getSortedPattern(int_06_sum_1) == getSortedPattern(groups[6][1])
	--local is_zero = isPatternEqual(int_06_sum_1, groups[6][1])
	local pattern_zero = is_zero and groups[6][1] or groups[6][2]
	local pattern_six = (not is_zero) and groups[6][1] or groups[6][2]
	digits_table[0], digits_table[6] = pattern_zero, pattern_six
	count = count+2 -- 8
	-- Let's find "5" and "2"
	local is_five = #subtractSegments(groups[5][1], digits_table[4]) == 2
	local pattern_five = is_five and groups[5][1] or groups[5][2]
	local pattern_two = (not is_five) and groups[5][1] or groups[5][2]
	digits_table[5], digits_table[2] = pattern_five, pattern_two
	count = count+2

	assert(count == 10)
	return digits_table
end

function pattern2table(pattern)
	assert(type(pattern)=="string")
	local t = {}
	for w in string.gmatch(pattern,"(%w)") do
		table.insert(t, w)
	end
	table.sort(t)
	return t
end

function getSortedPattern(pattern)
	return table.concat(pattern2table(pattern))
end

function getDigit(digits_table, pattern)
	assert(type(pattern)=="string")
	local srt_pattern = getSortedPattern(pattern)
	for i, p in pairs(digits_table) do
		if getSortedPattern(p) == srt_pattern then return i; end
	end
	return nil
end

local function parseLine(line)
	assert(line and #line>0)
	local signal_string, output_string = string.match(line,"%s*([^|]+)%s*|%s*([^|]+)%s*")
	assert(signal_string and output_string, "Parsing error. Line: "..line)
	local signal_patterns = { string.match(signal_string, ("(%w+)%s*"):rep(10)) }
	local output_digits = { string.match(output_string, ("(%w+)%s*"):rep(4)) }
	assert(#signal_patterns == 10) assert(#output_digits == 4)
	return signal_patterns, output_digits
end

function solvePart2(input_iterable)
	local output_total = 0
	for line in input_iterable do
		local signals, output = parseLine(line)
		local digits_table = getDigitTable(signals)
		local output_digits = {}
		for i,pattern in ipairs(output) do
			local found = getDigit(digits_table, pattern)
			table.insert(output_digits, found)
		end
		assert(#output_digits == 4)
		output_total = output_total + tonumber(table.concat(output_digits))
	end
	-- Return the answer
	return output_total
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part2answer = solvePart2(f:lines())
	f:close()
	print("Part 2: answer", part2answer)
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
	local answer = solvePart2(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
	edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
	fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
	fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
	aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
	fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
	dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
	bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
	egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
	gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce]]
	test(test_input, 61229) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
