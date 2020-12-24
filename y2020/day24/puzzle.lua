-- Day 24, part 1 & 2
local input_file = arg[1]

local mt_point = {
	__tostring = function(self)
		return string.format("(%d,%d)",self.x,self.y)
	end,
	__index = {
		move = function(self,dir)
			assert(dir, "Arg 2: no direction specified")
			if dir=="e" then
				self.x = self.x + 2
			elseif dir=="se" then
				self.x = self.x + 1
				self.y = self.y - 1
			elseif dir=="sw" then
				self.x = self.x - 1
				self.y = self.y - 1
			elseif dir=="w" then
				self.x = self.x - 2
			elseif dir=="nw" then
				self.x = self.x - 1
				self.y = self.y + 1
			elseif dir=="ne" then
				self.x = self.x + 1
				self.y = self.y + 1
			else
				error("Arg 2: invalid direction: "..tostring(dir))
			end
			return self
		end,
		isValid = function(self)
			local x,y = self.x, self.y
			return (x%2==0 and y%2==0) or (x%2==1 and y%2==1)
		end
	}
}
function Point(x,y)
	x = tonumber(x)
	y = tonumber(y)
	--z = tonumber(z)
	assert(x, "Arg 1: x must be a number")
	assert(y, "Arg 2: y must be a number")
	local p = setmetatable({x=x, y=y}, mt_point)
	assert( p:isValid(), "invalid point "..tostring(p) )
	return p
end


local mt_map = {
	__index = {
		set = function(self, x,y, val)
			-- x_axis = self
			local y_axis = rawget(self,x)
			if not y_axis then
				y_axis = {} -- this is for y axis
				rawset(self,x,y_axis)
			end
			--[[local z_axis = rawget(y_axis,y)
			if not z_axis then
				z_axis = {} -- this is for z axis
				rawset(y_axis,y,z_axis)
				--print("new z for", x,y,z)
			end
			rawset(z_axis, z, val)	--]]
			rawset(y_axis, y, val)
			-- set min and max
			if not self.min_x or x < self.min_x then self.min_x = x; end
			if not self.max_x or x > self.max_x then self.max_x = x; end
			if not self.min_y or y < self.min_y then self.min_y = y; end
			if not self.max_y or y > self.max_y then self.max_y = y; end
			--if not self.min_z or z < self.min_z then self.min_z = z; end
			--if not self.max_z or z > self.max_z then self.max_z = z; end
		end,
		setAtPoint = function(self,point,val)
			self:set(point.x, point.y, val)
		end,
		get = function(self, x,y)--,z)
			-- x_axis = self
			local res
			local y_axis = rawget(self,x)
			if y_axis then res = y_axis[y]; end
			return res or "white" -- all tiles are white from the start
		end,
		getAtPoint = function(self,point)
			return self:get(point.x, point.y)--, point.z)
		end,
		flipTile = function(self,point)
			local x,y = point.x, point.y
			if self:get(x,y) == "white" then
				self:set(x,y, "black")
				self.count_black_tiles = self.count_black_tiles + 1
			else
				self:set(x,y, "white")
				self.count_black_tiles = self.count_black_tiles - 1
			end
		end,
	}
}

function CreateMap()
	local t = { -- this is for x axis
		min_x = nil, max_x = nil,
		min_y = nil, max_y = nil,
		--min_z = nil, max_z = nil,
		count_black_tiles = 0,
	}
	setmetatable(t, mt_map)
	return t
end

-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

local map = CreateMap()
for line in f:lines() do
	local p = Point(0,0) -- reference tile
	for direction in string.gmatch(line,"([ns]?[ew])") do
		p:move(direction)
		assert( p:isValid() )
	end
	map:flipTile(p)
	--print( p )
end
f:close() -- close file

print("Part 1: how many tiles are left with the black side up?", map.count_black_tiles)

-- Part 2
local directions = {"e","se","sw","w","nw","ne"}
function GenerateChanges(map)
	local changes = {}	-- list of Points
	for x=map.min_x-2, map.max_x+2 do for y=map.min_y-2, map.max_y+2 do
		local res, arg2 = pcall(Point,x,y)
		if res then
			local point = arg2
			local count_black_tiles = 0
			for i,direction in ipairs(directions) do
				-- check tile
				local moving_point = Point(point.x,point.y):move(direction)
				if map:getAtPoint(moving_point) == "black" then
					count_black_tiles = count_black_tiles + 1
				end
			end
			--
			local val = map:getAtPoint(point)
			if val == "black" then
				if count_black_tiles == 0 or count_black_tiles > 2 then
					table.insert(changes, point)
				end
			else -- if the tile is white
				if count_black_tiles == 2 then
					table.insert(changes, point)
				end
			end
		elseif not string.find(arg2,"invalid point") then
			error(arg2)
		end
	end end
	return changes
end

print("Part 2:")
for day=1, 100 do
	local changes = GenerateChanges(map)
	for i,point in ipairs(changes) do
		map:flipTile(point)
	end
	if day<10 or day%10==0 then
		print(string.format("Day %d: %d",day, map.count_black_tiles))
	end
end
print("How many tiles will be black after 100 days?", map.count_black_tiles)
