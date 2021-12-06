-- Advent of Code 2021, day 06, part 1

function passADay(state)
	assert(type(state)=="table")
	for i=1, #state do
		local internal_timer = state[i]
		if internal_timer <= 0 then
			internal_timer = 6 -- reset to 6
			table.insert(state, 8) -- new lanternfish
		else
			internal_timer = internal_timer-1
		end
		-- Set timer
		state[i] = internal_timer
	end
	return state
end

function solvePart1(input_iterable)
	local state = {}
	for timer in input_iterable do
		table.insert(state, timer)
	end
	for i=1, 80 do
		passADay(state)
	end
	-- Return the answer
	return #state
end

local function stringLineIterator(text)
	local next_i = 1
	return function()
		if not next_i then return nil end
		local line = nil
		local found_at = string.find(text,"(,)", next_i)
		if found_at then
			line = text:sub(next_i, found_at-1)
			next_i = found_at+1
		else
			line = text:sub(next_i)
			if #line < 1 then line = nil end -- Ignore last line if it's empty
			next_i = nil
		end
		return (assert(tonumber(line)))
	end
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(stringLineIterator(f:read("*a")))
	f:close()
	print("Part 1: answer", part1answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = "3,4,3,1,2"
	test(test_input, 5934) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
