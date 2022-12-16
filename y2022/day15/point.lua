---@class Point
---@field x integer
---@field y integer
local Point = {};
Point.__index = Point
function Point:__eq(b)
	return self.x==b.x and self.y==b.y
end

function Point:move(delta_x, delta_y)
	if getmetatable(delta_x)==Point then
		delta_x, delta_y = delta_x:unpack()
	end
	self.x = self.x + delta_x
	self.y = self.y + delta_y
	return self
end

-- Distance from that point to this point
function Point:distance(from)
	return Point.new(self.x-from.x, self.y-from.y)
end

function Point:unpack()
	return self.x, self.y
end

function Point:toString()
	return string.format("Point(%d,%d)", self.x, self.y)
end

function Point.new(x,y)
	if getmetatable(x)==Point then
		x, y = x:unpack()
	elseif type(x)=="table" then
		x, y = x[1], x[2]
	end
	x = assert(tonumber(x))
	y = assert(tonumber(y))
	return setmetatable({x=x, y=y}, Point)
end

return Point