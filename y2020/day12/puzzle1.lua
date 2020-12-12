#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

-- Read all lines
local instructions = {}
for line in f:lines() do
	local instruction = { string.match(line,"(%a)(%d+)") }
	table.insert(instructions, instruction)
	instruction[2] = tonumber(instruction[2])
	--print( table.unpack(instruction) )
end
f:close()

local directions = {
	[0] = "N", [90] = "E", [180] = "S", [270] = "W"
}
local mt_ship = {
	__index = {
		move = function(self, dir, step)
			if dir=="F" then
				dir = directions[self.direction]
			end
			if     dir=="N" then self.y = self.y + step
			elseif dir=="E" then self.x = self.x + step
			elseif dir=="S" then self.y = self.y - step
			elseif dir=="W" then self.x = self.x - step
			else error("Invalid direction ..."..tostring(dir) ) end
			return self
		end,
		turn = function(self, dir, degrees)
			if     dir=="L" then self.direction = self.direction - degrees
			elseif dir=="R" then self.direction = self.direction + degrees
			else error("Invalid direction ..."..tostring(dir) ) end
			self.direction = self.direction % 360
		end,
		getManhattanDistance = function(self)
			return math.abs(self.x) + math.abs(self.y)
		end,
		getPosition = function(self)
			return self.x, self.y
		end
	}
}
function CreateShip()
	local t = {
		x = 0, y = 0,
		direction = 90, -- to east.
			--(0=north; 90=east; 180=south; 270=west)
	}
	setmetatable(t, mt_ship)
	return t
end

local ship = CreateShip()
-- Execute instructions for ship
for i,instruction in ipairs(instructions) do
	local action = instruction[1]
	local value = instruction[2]
	if string.find("FNSEW",action) then
		ship:move(action,value)
		print("Move:", action,value, ship:getPosition() )
	elseif string.find("LR",action) then
		ship:turn(action,value)
		print("Turn:", action,value, ship.direction, directions[ship.direction] )
	else
		error(string.format("Invalid instruction: %s%d",action,value))
	end
	
end
print("Ship's manhatan distance:",ship:getManhattanDistance())
