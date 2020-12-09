#!/usr/bin/env lua
local answer_from_part1 = tonumber(arg[1])
local input_file = arg[2]
assert(answer_from_part1, "arg[1] must be a number.")
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

local num_list = {}
-- Read numbers
for line in f:lines() do
	table.insert(num_list, tonumber(line))
end
f:close() -- close file

function SumInRange(t,li,ri)
	li = li or 1
	ri = ri or #t
	local total = 0
	for i=li, ri do
		total = total+t[i]
	end
	return total
end

-- Find the range of numbers which sum answer_from_part1
local Lindex, Rindex
for li=1, #num_list-1 do
	local flag_found = false
	for ri=li+1, #num_list do
		-- Check
		local sum = SumInRange(num_list,li,ri)
		if sum == answer_from_part1 then
			flag_found = true
			Lindex, Rindex = li,ri
		end
		if flag_found or sum > answer_from_part1 then break; end
	end
	if flag_found then break; end
end
if Lindex and Rindex then
	assert(Rindex-Lindex > 0, "The range is not at least two numbers")
	print("Range found.",Lindex,Rindex)
	print(table.concat(num_list,"; ",Lindex,Rindex))
	-- Find minimum and maximum numbers in the range
	local min,max = num_list[Lindex],num_list[Lindex]
	for i=Lindex+1, Rindex do
		local num = num_list[i]
		if num < min then min = num
		elseif num > max then max = num
		end
	end
	print("Minimum and maximum numbers:",min,max)
	print(string.format("\t%d + %d = %d", min,max, min+max))
else
	print("No range found.")
end
