-- Day 17, part 1
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

function Point(x,y,z)
	x = tonumber(x)
	y = tonumber(y)
	z = tonumber(z)
	assert(x, "Arg 1: x must be a number")
	assert(y, "Arg 2: y must be a number")
	assert(z, "Arg 3: z must be a number")
	return {x=x, y=y, z=z}
end


local mt_map = {
	__index = {
		set = function(self, x,y,z, val)
			-- x_axis = self
			local y_axis = rawget(self,x)
			if not y_axis then
				y_axis = {} -- this is for y axis
				rawset(self,x,y_axis)
			end
			local z_axis = rawget(y_axis,y)
			if not z_axis then
				z_axis = {} -- this is for z axis
				rawset(y_axis,y,z_axis)
				--print("new z for", x,y,z)
			end
			rawset(z_axis, z, val)
			-- set min and max
			if not self.min_x or x < self.min_x then self.min_x = x; end
			if not self.max_x or x > self.max_x then self.max_x = x; end
			if not self.min_y or y < self.min_y then self.min_y = y; end
			if not self.max_y or y > self.max_y then self.max_y = y; end
			if not self.min_z or z < self.min_z then self.min_z = z; end
			if not self.max_z or z > self.max_z then self.max_z = z; end
		end,
		setAtPoint = function(self,point,val)
			self:set(point.x, point.y, point.z, val)
		end,
		get = function(self, x,y,z)
			-- x_axis = self
			local y_axis = rawget(self,x)
			if not y_axis then return nil end
			local z_axis = rawget(y_axis,y)
			if not z_axis then return nil end
			return z_axis[z]
		end,
		getAtPoint = function(self,point)
			return self:get(point.x, point.y, point.z)
		end,
	}
}

function CreateMap(lines)
	local t = { -- this is for x axis
		min_x = nil, max_x = nil,
		min_y = nil, max_y = nil,
		min_z = nil, max_z = nil,
	}
	setmetatable(t, mt_map)
	-- Copy the lines into a new table
	for i,line in ipairs(lines) do
		for j=1, #line do
			local c = line:sub(j,j)
			t:set(j,i,0,c) --i:y, j:x
		end
	end
	return t
end

function MovingPointIterator(point, step_x, step_y, step_z)
	assert(point, "Arg 1: no starting point specified")
	step_x = tonumber(step_x)
	assert(type(step_x)=="number", "Arg 2: step_x must be number")
	step_y = tonumber(step_y)
	assert(type(step_y)=="number", "Arg 3: step_y must be number")
	step_z = tonumber(step_z)
	assert(type(step_z)=="number", "Arg 4: step_z must be number")
	assert(step_x~=0 or step_y~=0 or step_z~=0, "all step_x, step_y and step_z cannot be 0")
	local moving_point = Point(point.x, point.y, point.z)
	return function() -- Move the point on every call
		moving_point.x = moving_point.x + step_x
		moving_point.y = moving_point.y + step_y
		moving_point.z = moving_point.z + step_z
		return moving_point
	end
end

local cache_combinations = {}
function GenerateCombinationTableIter(max_len, max_digit)
	local num = 0
	local max_combinations = math.floor( max_digit^max_len )
	--- prepare cache
	if not cache_combinations[max_digit] then cache_combinations[max_digit]={} end
	---
	return function()
		if num >= max_combinations then return nil; end
		if cache_combinations[max_digit][num] then
			num = num+1
			return cache_combinations[max_digit][num-1]
		end
		local t = {}
		for i=1, max_len do
			t[max_len-(i-1)] = math.floor(num / (max_digit^(i-1))) % max_digit
		end
		cache_combinations[max_digit][num] = t
		num = num+1
		return t
	end
end


-- Read all lines
local lines = {}
for line in f:lines() do
	table.insert(lines, line)
end
f:close() -- close file

local map = CreateMap(lines)

function CheckActiveNeighbors(map, point)
	local values = {-1, 0, 1}
	local count_active = 0
	--local list_points = {}
	for t in GenerateCombinationTableIter(3,3) do
		local digit2, digit1, digit0 = t[1], t[2], t[3]
		local x, y, z = values[digit2+1], values[digit1+1], values[digit0+1]
		if not (x==0 and y==0 and z==0) then
			local moving_point = Point(point.x+x, point.y+y, point.z+z)
			--print( map:getAtPoint( moving_point ) )
			if map:getAtPoint( moving_point ) == "#" then
				--print("CheckActiveNeighbors", "loop", point.x+x, point.y+y, point.z+z)
				count_active = count_active + 1
				--print("?")
				--table.insert(list_points, moving_point)
			end
		end
	end
	return count_active	--, list_points
end

function PrintMap(map)
	print("PrintMap called")
	print("min/max x", map.min_x, map.max_x)
	print("min/max y", map.min_y, map.max_y)
	print("min/max z", map.min_z, map.max_z)
	for z=map.min_z, map.max_z do
		print("z="..tostring(z))
		for y=map.min_y, map.max_y do
			for x=map.min_x, map.max_x do
				io.write( map:get(x,y,z) or "." )
			end
			io.write("\n")
		end
	end
end

PrintMap(map)
for i=1, 6 do
	print("Cycle:", i, "-----------------")
	--print(map.min_x, map.max_x)
	--print(map.min_y, map.max_y)
	--print(map.min_z, map.max_z)
	--print("------------------")
	local changes = {}
	local count_active = 0
	for x=map.min_x-1, map.max_x+1 do
		for y=map.min_y-1, map.max_y+1 do
			for z=map.min_z-1, map.max_z+1 do
				local c = map:get(x,y,z)
				local point = Point(x,y,z)
				local num_active_neighbors = CheckActiveNeighbors(map,point)
				--print(c, x,y,z,"num_active_neighbors",num_active_neighbors)
				if c=="#" then
					count_active = count_active+1
					if not(num_active_neighbors==2 or num_active_neighbors==3) then
						table.insert(changes, {point,"."})
						--print("Set to inactive")
					end
				else
					if num_active_neighbors==3 then
						table.insert(changes, {point,"#"})
						--print("Set to active")
					end
				end
			end
		end
	end
	-- Apply changes
	for i,change in ipairs(changes) do
		map:setAtPoint(change[1], change[2])
		count_active = count_active + (change[2]=="#" and 1 or -1)
	end
	PrintMap(map)
	print("Cubes in active state:", count_active)
	print()
end
