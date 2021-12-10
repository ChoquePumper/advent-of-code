-- Advent of Code 2021, day 10, part 1

local closing_chunk = {
	[")"] = 3, ["]"] = 57, ["}"] = 1197, [">"] = 25137,
}
local opening_chunk = {
	["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">",
}

function checkSyntax(line)
	local stack = {}
	local count = 0
	for c in string.gmatch(line, "(.)") do
		count = count+1
		if opening_chunk[c] then
			table.insert(stack, c) -- push
		elseif closing_chunk[c] then
			local stack_top = stack[#stack]
			if c ~= opening_chunk[stack_top] then
				--print(c, stack_top)
				return false, c, count
			else
				table.remove(stack) -- pop
			end
		else
			error("Unknown char: '"..c.."'")
		end
	end
	return #stack == 0
end

function solvePart1(input_iterable)
	local score = 0
	for line in input_iterable do
		local pass, illegal_char, at_pos = checkSyntax(line)
		if not pass and illegal_char then
			print(line, pass, illegal_char, at_pos)
			score = score + closing_chunk[illegal_char]
		end
	end
	-- Return the answer
	return score
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close()
	print("Part 1: answer", part1answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local i = 0
	local function iterable()
		i=i+1
		return test_input[i]
	end
	local answer = solvePart1(iterable)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = {
		"[({(<(())[]>[[{[]{<()<>>",
		"[(()[<>])]({[<{<<[]>>(",
		"{([(<{}[<>[]}>{[]{[(<()>",
		"(((({<>}<{<{<>}{[]{[]{}",
		"[[<[([]))<([[{}[[()]]]",
		"[{[{({}]{}}([{[{{{}}([]",
		"{<[[]]>}<{[{[{[]{()[[[]",
		"[<(<(<(<{}))><([]([]()",
		"<{([([[(<>()){}]>(<<{{",
		"<{([{{}}[<[[[<>{}]]]>[]]"
	}
	test(test_input, 26397) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
