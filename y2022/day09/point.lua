---@class Point
---@field x integer
---@field y integer
local Point = {}; Point.__index = Point

function Point:move(delta_x, delta_y)
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

function Point.new(x,y)
	return setmetatable({x=x, y=y}, Point)
end

return Point