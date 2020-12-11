#!/usr/bin/env lua
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
			local old_diff = self:getDiff(pos)
			table.remove(self.cache_differences, pos)
			self.cache_differences[pos] = self.cache_differences[pos]+1
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
f:close() -- close file

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

function GetValidArrangementCount2(arrangement,removable_indexes)
	-- GetValidArrangementCount function is O(n^2)
	-- So, instead of processing a large removable_indexes list, split the list
	-- in groups of consecutive numbers, pass that list as argument at GetValidArrangementCount,
	-- and multiply all the results.
	-- I couldn't find a better way. :(
	local sub_rm_indexes = {}
	local total_count = 1
	for i=1, #removable_indexes do
		if #sub_rm_indexes == 0 or removable_indexes[i] - sub_rm_indexes[#sub_rm_indexes] <= 1  then
			table.insert( sub_rm_indexes, removable_indexes[i] )
		else
			--print( table.concat(sub_rm_indexes,", ") )
			total_count = total_count * GetValidArrangementCount(arrangement,sub_rm_indexes)
			sub_rm_indexes = {removable_indexes[i]}
		end
	end
	if #sub_rm_indexes > 0 then
		--print( table.concat(sub_rm_indexes,", ") )
		total_count = total_count * GetValidArrangementCount(arrangement,sub_rm_indexes)
	end
	return total_count
end

function GetValidArrangementCount(arrangement,removable_indexes)
	-- O(n^2). A large removable_indexes list will take years.
	if #removable_indexes < 1 then return 1; end	-- base case
	local index = removable_indexes[#removable_indexes]
	local copy_rm_val = CopyTable(removable_indexes)
	table.remove(copy_rm_val)
	local count_after_remove = 0
	if arrangement:getDiff(index)+arrangement:getDiff(index+1) <= 3 then
		local copy_arr = arrangement:copy()
		copy_arr:remove(index)
		count_after_remove = GetValidArrangementCount(copy_arr, copy_rm_val)
	end
	local total = count_after_remove + GetValidArrangementCount(arrangement, copy_rm_val)
	return total
end
-- Calling GetValidArrangementCount instead of GetValidArrangementCount2
print("Number of arrangements:", GetValidArrangementCount(arrangement, GetRemovableIndexes(arrangement)))
