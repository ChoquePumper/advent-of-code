-- Advent of Code 2021, day 06, part 2
if _VERSION < "Lua 5.2" and not table.unpack then table.unpack = unpack end
local cache_fishes_count_on_days = setmetatable({},{
	__index = {
		set = function(self, timer,days, value)
			local days_table = self[timer]
			if not days_table then
				days_table = {}
				self[timer] = days_table
			end
			days_table[days] = value
		end,
		get = function(self, timer,days)
			local days_table = self[timer]
			if days_table then
				return days_table[days]
			end
			return nil
		end,
	}
})

function fishesCountOnDays(initial_timer,initial_days)
	local timer = assert(tonumber(initial_timer))
	local days = math.max(0, (assert(tonumber(initial_days)) ))
	local cached_res = cache_fishes_count_on_days:get(initial_timer,initial_days)
	if cached_res then
		return cached_res
	end
	local fishes = 1
	local additional = 0
	for d=days, 1, -1 do
		if timer==0 then
			additional = additional + fishesCountOnDays(8, d-1)
			timer = 6
		else
			timer = timer-1
		end
	end
	local total = fishes + additional
	cache_fishes_count_on_days:set(initial_timer,initial_days, total)
	return total
end

function solvePart2(input_iterable)
	local days = 256
	local fish_count = 0
	for timer in input_iterable do
		fish_count = fish_count + fishesCountOnDays(timer,days)
	end
	return fish_count
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
	local part2answer = solvePart2(stringLineIterator(f:read("*a")))
	f:close()
	print("Part 2: answer", part2answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart2(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

-- I had a hard time on figuring out how to calcutate the total. So I made some tests.
function testNoError(test_timer, test_days, expected_value)
	local result = fishesCountOnDays(test_timer, test_days)
	return result == expected_value, result
end

if arg then
	local list_test = { {3,3,1},{3,4,2}, {3,8,2},{3,9,2},{3,10,2},{3,11,3}, {3,13,4},
		{3,18,5}, {3,20,7}, {3,22,8}, {3,25,9}, {3,27,12}, }
	for i,test_in in ipairs(list_test) do -- Run some tests
		local success, result = testNoError(table.unpack(test_in))
		local expected_value = test_in[3]
		print("Test", table.concat(test_in,","), success, result)
	end
	local test_input = "3,4,3,1,2"
	test(test_input, 26984457539) -- Run a test from the example
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
