-- Set a value for these two local variables here to skip argument check
local puzzle_input	-- = {0,3,6}
local limit	-- = 2020

if not limit and not arg[1] then
	print("Argument 1 not specified. Setting limit to 2020 (part 1).")
	limit = 2020
elseif arg[1] then
	limit = tonumber(arg[1])
	if not limit then
		print("Program argument 1 is not a number.") os.exit(1)
	end
end
if not puzzle_input and #arg < 2 then
	puzzle_input = {0, 3, 6} -- {20,9,11,0,1,2}
	print("List of numbers not specified. Setting list from the example: "..table.concat(puzzle_input,", ")..".")
elseif #arg >= 2 then
	puzzle_input = {}
	for i=2, #arg do
		local num = tonumber(arg[i])
		if num then
			table.insert(puzzle_input, num)
		else
			print(string.format("Note: ignoring argument %d since it's not a number: %s",i,arg[i]))
		end
	end
	if #puzzle_input == 0 then
		print("No valid numbers specified. Exiting.") os.exit(1)
	end
end

local table_number_spoken = {
	turn = 0,
	last_spoken = nil,
	-- Following the example
	-- Num | Value changes
	-- [0] = 1, 4, 8, 10, ...
	-- [1] = 7, ...
	-- [3] = 2, 5, 6,...
	-- [4] = 9, ...
	-- [6] = 3, ...
}

function recordNumber(num)
	-- Set the last number spoken
	table_number_spoken.last_spoken = num
	-- Count up the turn
	table_number_spoken.turn = table_number_spoken.turn + 1
	
	local num_previously_spoken_at = table_number_spoken[num]
	table_number_spoken[num] = table_number_spoken.turn
	-- Propare next number
	table_number_spoken.next_number = (num_previously_spoken_at==nil) and 0 or table_number_spoken.turn - num_previously_spoken_at
end

function nextNumber() -- call this function after the starting numbers
	return table_number_spoken.next_number
end

-- Start with the starting numbers
for i,num in ipairs(puzzle_input) do
	recordNumber(num)
end

while table_number_spoken.turn < limit do
	local num = nextNumber()
	--print("num", num)
	recordNumber( num )
end

print("table_number_spoken.last_spoken",table_number_spoken.last_spoken)
