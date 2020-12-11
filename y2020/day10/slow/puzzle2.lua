#!/usr/bin/env lua
-- WARNING: This program is very slow. 
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

function CopyTable(t)
	local new_t = {}
	for k,v in pairs(t) do new_t[k]=v end
	return new_t
end

local mt_arrangent; mt_arrangent = {
	__index = {
		copy = function(self)
			local t = {
				adapters = CopyTable(self.adapters),
				cache_differences = CopyTable(self.cache_differences),
				cache_len = self.cache_len,
			}
			setmetatable(t, mt_arrangent)
			return t
		end,
		add = function(self, val)
			table.insert(self.adapters, val)
			table.sort(self.adapters)
			self.cache_len = self.cache_len + 1
		end,
		remove = function(self, pos)
			table.remove(self.adapters, pos)
			self.cache_len = self.cache_len - 1
		end,
		get = function(self, pos)
			return self.adapters[pos]
		end,
		getDiff = function(self, pos)
			--print(table.unpack(self.cache_differences))
			return self.cache_differences[pos]
		end,
		len = function(self)	return self.cache_len; end,
		cacheDifferences = function(self)
			local new_differences = {}
			for i=1, #self.adapters do
				new_differences[i] = self.adapters[i] - self.adapters[i-1]
			end
			self.cache_differences = new_differences
		end,
	}
}
function NewArrangement()
	local t = {
		adapters = { [0] = 0 },
		cache_differences = {},
		cache_len = 0,
	}
	setmetatable(t, mt_arrangent)
	return t
end

local arrangement = NewArrangement()

for line in f:lines() do
	arrangement:add( tonumber(line) )
end
f:close()	-- close file

-- Add the built-in adapter
arrangement:add( arrangement.adapters[arrangement.cache_len]+3 )
arrangement:cacheDifferences()

function GetRemovableIndexes(arrangement)
	local t = {}
	for i=1, arrangement:len()-1 do
		if arrangement:getDiff(i+1) + arrangement:getDiff(i) <= 3 then
			table.insert(t, i)
		end
	end
	return t
end

function GenerateBooleanTableIter(max_len)
	-- Similar to binary numbers but using a list (table).
	--[[ Example:
		max_len=3:
			{false,false, true}
			{false, true,false}
			{false, true, true}
			{ true,false,false}
			{ true,false, true}
			{ true, true,false}
			{ true, true, true}
	]]
	local t = {}
	for i=1, max_len do table.insert(t,false) end
	local flag_end = false -- flag_end
	---
	return function() -- doesn't return all false
		if flag_end then return nil; end
		local flag_carry = true
		local i = max_len
		while flag_carry and i > 0 do
			local bit = t[i]
			if not bit then flag_carry = false; end
			t[i] = not bit
			i = i-1
		end
		if flag_carry and i < 1 then
			flag_end = true
			return nil
		else
			return t
		end
	end
end


function GetArrangementIter(arrangement)
	local rem_indexes = GetRemovableIndexes(arrangement)
	--print(#rem_indexes)
	local bool_iter = GenerateBooleanTableIter(#rem_indexes)
	return function()
		local valid_arr_found = nil
		local bool_table = bool_iter()
		while not valid_arr_found and bool_table do
			--print(table.unpack(bool_table))
			local copy_arr = arrangement:copy()
			local flag_valid = true
			for i=#bool_table, 1,-1 do
				if bool_table[i] then
					local index = rem_indexes[i]
					--print(copy_arr:getDiff(index),copy_arr:getDiff(index+1))
					if copy_arr:getDiff(index)+copy_arr:getDiff(index+1) > 3 then
						flag_valid = false
						break;
					else
						copy_arr:remove(index)
						copy_arr:cacheDifferences()
					end
				end
			end
			if flag_valid then valid_arr_found = copy_arr; break
			else bool_table = bool_iter()
			end
		end
		
		return valid_arr_found
	end
end

local arrangement_count = 1
for arrangement in GetArrangementIter(arrangement) do
	--print(table.concat(arrangement.adapters,", "))
	--io.write(string.format("Count %d",arrangement_count),"\r")-- io.flush()
	arrangement_count = arrangement_count+1
end
print("Number of arrangements:", arrangement_count)
