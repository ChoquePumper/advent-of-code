-- Advent of Code 2021, day 08, part 1
local digits_with_unique_number_segments = {
	[2] = 1, [4] = 4, [3] = 7, [7] = 8,
}

local function parseLine(line)
	assert(line and #line>0)
	local signal_string, output_string = string.match(line,"%s*([^|]+)%s*|%s*([^|]+)%s*")
	assert(signal_string and output_string, "Parsing error. Line: "..line)
	local signal_patterns = { string.match(signal_string, ("(%w+)%s*"):rep(10)) }
	local output_digits = { string.match(output_string, ("(%w+)%s*"):rep(4)) }
	assert(#signal_patterns == 10) assert(#output_digits == 4)
	return signal_patterns, output_digits
end

function solvePart1(input_iterable)
	local digits_count = 0
	for line in input_iterable do
		local signals, output = parseLine(line)
		for i,pattern in ipairs(output) do
			local len = #pattern
			if digits_with_unique_number_segments[len] then
				digits_count = digits_count+1;
			end
		end
	end
	-- Return the answer
	return digits_count
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close()
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	return string.gmatch(text,"([^\n]+)")
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(stringLineIterator(test_input))
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
	test(test_input, 26) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
