
---@alias Range {min:integer, max:integer}

---@class MultipleRanges
local MultipleRanges = {}; MultipleRanges.__index = MultipleRanges

function MultipleRanges.comparator(a,b)	---@return boolean
	return (a.min == b.min) and (a.max < b.max) or (a.min < b.min)
end

function MultipleRanges:sortRanges()
	table.sort(self, MultipleRanges.comparator)
	self.is_ordered = true
end

local function walkIterator(state, i)
	if not i then return nil end
	i = i + 1
	while i > state.current_range.max do
		state.current_range = nil
		state.i_range = state.i_range + 1
		state.current_range = state.self[state.i_range]
		if not state.current_range then break end
		i = math.max(i, state.current_range.min)
	end
	if not state.current_range then
		i = nil
		return nil
	end
	return i, nil
end

local function walkIteratorForHoles(state, i)
	if not i then return nil end
	local found = false
	while not found do
		state.i_range = state.i_range + 1
		state.current_range = state.self[state.i_range]
		if not state.current_range then break end
		i = math.max( i, state.current_range.max+1 )
		local next_range = state.self[state.i_range+1]
		if not next_range then break end
		if i < next_range.min then
			--print("i_range", state.i_range)
			--print("current_range", state.current_range.min, state.current_range.max)
			--print("next_range", next_range.min, next_range.max)
			--print("Hit?", i)
			if i == next_range.min-1 then
				found = true
			end
		end
	end
	if not found then
		i = nil
	end
	return i, nil
end

function MultipleRanges:walk()
	if not self.is_ordered then self:sortRanges() end
	local local_state = {}
	local_state.self = self
	local_state.i_range = 1
	local_state.current_range = self[local_state.i_range]
	
	return walkIterator, local_state, local_state.current_range and (local_state.current_range.min - 1) or nil
end

function MultipleRanges:walkForHoles()
	if not self.is_ordered then self:sortRanges() end
	local local_state = {}
	local_state.self = self
	local_state.i_range = 0
	local_state.current_range = self[1]
	
	return walkIteratorForHoles, local_state, local_state.current_range and (local_state.current_range.min - 1) or nil
end

function MultipleRanges:addRange(range)
	assert(tonumber(range.min)) assert(tonumber(range.max))
	self.is_ordered = false
	--if range.min <= range.max then
		table.insert(self, range)
	--end
	return self
end

function MultipleRanges:isValueInRange(val)
	if not self.is_ordered then self:sortRanges() end
	local res = false
	for _,range in ipairs(self) do
		res = range.min <= val and val <= range.max
		if res then break end
	end
	return res
end

function MultipleRanges.new()
	return setmetatable({is_ordered = false}, MultipleRanges)
end

return MultipleRanges