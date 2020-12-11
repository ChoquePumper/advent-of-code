#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end


function Point(x,y)
	x = tonumber(x)
	y = tonumber(y)
	assert(x, "Arg 1: x must be a number")
	assert(y, "Arg 2: y must be a number")
	return {x=x, y=y}
end

local mt_map = {
	__index = {
		set = function(self, x,y, val)
			assert(#val==1, "Arg 3: val must be a 1-char string")
			local row = rawget(self,y)
			assert(row, "Arg 2: Invalid row: "..tostring(y))
			assert(1 <= x and x <= #row, "Arg 1: Invalid col:"..tostring(x))
			rawset(self, y, row:sub(1,x-1)..tostring(val)..row:sub(x+1,#row))
		end,
		get = function(self, x,y)
			local row = rawget(self,y)
			if not row then return nil end
			local res = row:sub(x,x)
			if #res == 1 then
				return res
			else
				return nil
			end
		end,
		checkValidPoint = function(self, point)
			local valid_y = (rawget(self,point.y) ~= nil)
			local valid_x = (1 <= point.x and point.x <= self.max_x)
			return (valid_y and valid_x), valid_x, valid_y
		end,
		print = function(self)
			for i=1, #self do print(self[i]) end
		end,
	}
}

function CreateMap(lines)
	local t = { --[[ Fields:
		1, 2, .. n = each row (string)
	]]
		max_x = 0,
		max_y = 0,
	}
	-- Copy the lines into a new table
	for i,line in ipairs(lines) do
		table.insert(t,line)
		if #line > t.max_x then
			t.max_x = #line
		end
	end
	t.max_y = #t
	setmetatable(t, mt_map)
	return t
end

-- Read all lines
local lines = {}
for line in f:lines() do
	table.insert(lines, line)
end
f:close()
local map = CreateMap(lines)

function MovingPointIterator(point, step_x, step_y)
	assert(point, "Arg 1: no starting point specified")
	step_x = tonumber(step_x)
	assert(type(step_x)=="number", "Arg 2: step_x must be number")
	step_y = tonumber(step_y)
	assert(type(step_y)=="number", "Arg 3: step_y must be number")
	assert(step_x~=0 or step_y~=0, "both step_x and step_y cannot be 0")
	local moving_point = Point(point.x, point.y)
	return function() -- Move the point on every call
		moving_point.x = moving_point.x + step_x
		moving_point.y = moving_point.y + step_y
		return moving_point
	end
end

function PredictArrival(map, point)
	local current = map:get(point.x, point.y)
	local iterator_points = {
		MovingPointIterator(point, -1,  0),	-- Left
		MovingPointIterator(point, -1, -1),	-- UpLeft
		MovingPointIterator(point,  0, -1),	-- Up
		MovingPointIterator(point,  1, -1),	-- UpRight
		MovingPointIterator(point,  1,  0),	-- Right
		MovingPointIterator(point,  1,  1),	-- DownRight
		MovingPointIterator(point,  0,  1),	-- Down
		MovingPointIterator(point, -1,  1),	-- DownLeft
	}
	local flag_stop = false
	local num_adjacent_occupied = 0
	
	for i,iterator_point in ipairs(iterator_points) do
		for val in (function() local p=iterator_point(); return map:get(p.x, p.y); end) do
			if val=="#" then
				num_adjacent_occupied = num_adjacent_occupied+1
				break;
			elseif val=="L" then
				break;
			end
		end
	end
	
	-- If a seat is empty (L) and there are no occupied seats adjacent to it,
	--the seat becomes occupied.
	if current == "L" and num_adjacent_occupied == 0 then
		return "#", current
	-- If a seat is occupied (#) and four or more seats adjacent to it are also occupied,
	--the seat becomes empty.
	elseif current == "#" and num_adjacent_occupied >= 5 then 	-- part 2
		return "L", current
	--Otherwise, the seat's state does not change.
	else
		return current, current
	end
end

local changes
local iteration_count = 0
local previous_number_occupied = 0
repeat
	changes = {}
	iteration_count = iteration_count+1
	print("Iteration", iteration_count)
	map:print()
	local number_occupied = 0
	for y=1, map.max_y do
		for x=1, map.max_x do
			local point = Point(x,y)
			local new_val, previous = PredictArrival(map,point)
			--print(new_val,previous)
			if new_val=="#" then number_occupied = number_occupied+1; end
			if new_val ~= previous then
				table.insert(changes, {point,new_val})
			end
		end
	end
	-- Apply changes
	for i,change in ipairs(changes) do
		--print(new_val, change[2])
		map:set(change[1].x, change[1].y, change[2])
	end
	print("previous_number_occupied",previous_number_occupied)
	previous_number_occupied = number_occupied
	print("number_occupied", number_occupied)
until #changes < 1

print("End")

