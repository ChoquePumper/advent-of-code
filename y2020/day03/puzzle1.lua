
local input_file = arg[1]
-- Open the file
local lines = {}
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end
-- Read all lines
for line in f:lines() do
	table.insert(lines, line)
end
f:close()

local mt_map = {
	--[[ Fields:
		1, 2, .. n = each row (string)
	]]
	__index = {
		--[[
		set = function(self, x,y, val)
			local y_axis = rawget(self,x)
			if not y_axis then
				y_axis = {} -- this is for y axis
				rawset(self,x,y_axis)
			end
			rawset(y_axis, y, val)
		end,
		]]
		get = function(self, x,y)
			local row = rawget(self,y)
			if not row then return nil end
			local x_pattern = (x-1) % row:len() + 1
			return row:sub(x_pattern,x_pattern)
		end
	}
}

function CreateMap(lines)
	local t = { -- this is for x axis
	}
	-- Copy the lines into a new table
	for i,line in ipairs(lines) do table.insert(t,line) end
	setmetatable(t, mt_map)
	return t
end

-- Walk
local map = CreateMap(lines)
local pos = {x=1,y=1} -- start from top left corner
local tree_counter = 0
repeat
	-- advance
	pos.x = pos.x + 3
	pos.y = pos.y + 1
	-- Check for tree
	local data = map:get(pos.x, pos.y)
	if data=="#" then
		tree_counter = tree_counter+1 --found a tree
	end
until pos.y >= #map

print("Trees found:", tree_counter)

