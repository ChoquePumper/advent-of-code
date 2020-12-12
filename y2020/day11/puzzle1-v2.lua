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


function PredictArrival(map, point)
	local current = map:get(point.x, point.y)
	if current=="." then return ".","." end
	local adjacent_points = {
		Point(point.x-1, point.y),	-- Left
		Point(point.x-1, point.y-1),	-- UpLeft
		Point(point.x, point.y-1),	-- Up
		Point(point.x+1, point.y-1),	-- UpRight
		Point(point.x+1, point.y),	-- Right
		Point(point.x+1, point.y+1),	-- DownRight
		Point(point.x, point.y+1),	-- Down
		Point(point.x-1, point.y+1),	-- DownLeft
	}
	local flag_stop = false
	local num_adjacent_occupied = 0
	
	for i,adjacent_point in ipairs(adjacent_points) do
		if map:get(adjacent_point.x, adjacent_point.y) == "#" then
			num_adjacent_occupied = num_adjacent_occupied+1
		end
	end
	
	-- If a seat is empty (L) and there are no occupied seats adjacent to it,
	--the seat becomes occupied.
	if current == "L" and num_adjacent_occupied == 0 then
		return "#", current
	-- If a seat is occupied (#) and four or more seats adjacent to it are also occupied,
	--the seat becomes empty.
	elseif current == "#" and num_adjacent_occupied >= 4 then
		return "L", current
	--Otherwise, the seat's state does not change.
	else
		return current, current
	end
end

-- Try to save time by saving the count of times when the cell hasn't changed.
-- Skip calling PredictArrival if the count reached to max_iterations.
local count_no_changes = { max_iterations = 2 }
for i=1, map.max_y do count_no_changes[i] = {}; end

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
			if not(count_no_changes[point.y][point.x]) or count_no_changes[point.y][point.x] < count_no_changes.max_iterations then
				local new_val, previous = PredictArrival(map,point)
				--print(new_val,previous)
				if new_val=="#" then number_occupied = number_occupied+1; end
				if new_val ~= previous then
					table.insert(changes, {point,new_val})
				elseif not count_no_changes[point.y][point.x] then
					count_no_changes[point.y][point.x] = 1
				else
					count_no_changes[point.y][point.x] = count_no_changes[point.y][point.x] + 1
				end
			elseif map:get(point.x, point.y)=="#" then
				number_occupied = number_occupied+1
			end
		end
	end
	-- Apply changes
	for i,change in ipairs(changes) do
		--print(new_val, change[2])
		map:set(change[1].x, change[1].y, change[2])
		-- Reset the counter there is a change on the cell at point(x,y)
		count_no_changes[change[1].y][change[1].x] = 0
	end
	print("previous_number_occupied",previous_number_occupied)
	previous_number_occupied = number_occupied
	print("number_occupied", number_occupied)
until #changes < 1

print("End")

