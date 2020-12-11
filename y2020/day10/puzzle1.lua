#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

local adapters = { [0]=0 }

for line in f:lines() do
	table.insert( adapters, tonumber(line) )
end

table.sort( adapters )
-- Add the built-in adapter
table.insert( adapters, adapters[#adapters]+3 )

local differences = {}
for i=1, #adapters do
	local jolt_rate = adapters[i]
	local delta = jolt_rate - adapters[i-1]
	local table_difference = differences[delta]
	if not table_difference then	
		table_difference = {}
		differences[delta] = table_difference
	end
	table.insert(table_difference, i) -- save the index of adapters
end

for i=1,99 do
	local table_diff = differences[i]
	if table_diff then
		print(string.format("Number of %d-jolt differences: %d", i, #table_diff))
	end
end

print("Answer:", #differences[1] * #differences[3])