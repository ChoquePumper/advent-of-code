#!/usr/bin/env lua
local preamble_length = tonumber(arg[1])
local input_file = arg[2]
assert(preamble_length, "arg[1] must be a number.")
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

for i=preamble_length+1, #num_list do -- Recycled partial code from day 1
	local num = num_list[i]
	-- Find the 2 numbers which sum num_list[i]
	local num1, num2
	for li=i-preamble_length, i-2 do
		local flag_found = false
		local v1 = num_list[li]
		for ri=li+1, i-1 do
			local v2 = num_list[ri]
			local sum = v1+v2
			-- Check
			if sum == num then
				flag_found = true
				num1, num2 = v1, v2
			end
			if flag_found then break end
		end
		if flag_found then break end
	end
	if not(num1 and num2) then
		print("Answer:", num)
		break
	end
end
