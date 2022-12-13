---@class GridMap
---@field min_x number
---@field max_x number
---@field min_y number
---@field max_y number
local GridMap = {}

function GridMap:isInBoundsX(x) return self.min_x <= x and x <= self.max_x end
function GridMap:isInBoundsY(y) return self.min_y <= y and y <= self.max_y end
function GridMap:isInBounds(x,y)
	return self:isInBoundsX(x) and self:isInBoundsY(y)
end

---@param axis '"x"'|'"y"'
---@param coord number
function GridMap:updateBoundary(axis, coord)
	local min_axis, max_axis = "min_"..axis, "max_"..axis
	self[min_axis] = math.min(self[min_axis], coord)
	self[max_axis] = math.max(self[max_axis], coord)
end

---@param x number
---@param y number
function GridMap:get(x,y)
	local row = self[y]
	if not row then return 0 end
	local col = row[x]
	return col or 0 --and col[z] or "0"
end

---@param x number
---@param y number
function GridMap:set(x,y, value)
	local row = self[y]
	if not row then
		row = {}; self[y] = row
	end
	row[x] = value
	-- update boundaries
	self:updateBoundary("x", x)	self:updateBoundary("y", y)
end
---@param x_range number[]
---@param y_range number[]
function GridMap.new(x_range, y_range)
	local self = setmetatable({
		-- [-i ... +i] = rows
		min_x=x_range[1], max_x=x_range[2],
		min_y=y_range[1], max_y=y_range[2],
	},GridMap)
	return self
end
GridMap.__index = GridMap
return GridMap