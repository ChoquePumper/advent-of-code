-- Advent of Code 2021, day 10, part 2

local closing_chunk = {
	[")"] = 1, ["]"] = 2, ["}"] = 3, [">"] = 4,
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
				return false, c, count
			else
				table.remove(stack) -- pop
			end
		else
			error("Unknown char: '"..c.."'")
		end
	end
	return #stack == 0, stack
end

function solvePart2(input_iterable)
	local line_scores = {}
	for line in input_iterable do
		local pass, stack = checkSyntax(line)
		local line_score = 0
		if not pass and type(stack)=="table" then
			for i=#stack, 1, -1 do
				local c = stack[i]
				line_score = line_score * 5 + closing_chunk[opening_chunk[c]]
			end
			print(line, string.reverse(table.concat(stack):gsub(".",opening_chunk)), line_score)
			table.insert(line_scores, line_score)
		end
	end
	table.sort(line_scores)
	-- Return the answer
	assert(#line_scores % 2 == 1)
	return line_scores[(#line_scores+1)/2]
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part2answer = solvePart2(f:lines())
	f:close()
	print("Part 2: answer", part2answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local i = 0
	local function iterable()
		i=i+1
		return test_input[i]
	end
	local answer = solvePart2(iterable)
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
	test(test_input, 288957) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
