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

function Point(x,y)
	x = tonumber(x)
	y = tonumber(y)
	assert(x, "Arg 1: x must be a number")
	assert(y, "Arg 2: y must be a number")
	return {x=x, y=y}
end

local directions = {
	[0] = "N", [90] = "E", [180] = "S", [270] = "W"
}
function getDirX(val)
	return val >= 0 and "E" or "W"
end
function getDirY(val)
	return val >= 0 and "N" or "S"
end
local mt_ship = {
	__index = {
		move = function(self, dir, step)
			if dir=="F" then
				self:move(getDirX(self.waypoint.x), math.abs(self.waypoint.x)*step)
				self:move(getDirY(self.waypoint.y), math.abs(self.waypoint.y)*step)
			elseif dir=="N" then self.y = self.y + step
			elseif dir=="E" then self.x = self.x + step
			elseif dir=="S" then self.y = self.y - step
			elseif dir=="W" then self.x = self.x - step
			else error("Invalid direction ..."..tostring(dir) ) end
			return self
		end,
		moveWaypoint = function(self, dir, step)
			if     dir=="N" then self.waypoint.y = self.waypoint.y + step
			elseif dir=="E" then self.waypoint.x = self.waypoint.x + step
			elseif dir=="S" then self.waypoint.y = self.waypoint.y - step
			elseif dir=="W" then self.waypoint.x = self.waypoint.x - step
			else error("Invalid direction ..."..tostring(dir) ) end
		end,
		turn = function(self, dir, degrees)
			for i=1, math.floor(degrees/90) do
				local current_x = self.waypoint.x
				local current_y = self.waypoint.y 
				if     dir=="L" then
					self.waypoint.x = -current_y
					self.waypoint.y = current_x
				elseif dir=="R" then
					self.waypoint.x = current_y
					self.waypoint.y = -current_x
				else error("Invalid direction ..."..tostring(dir) ) end
			end
			--self.direction = self.direction % 360
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
		x = 0, y = 0, --(+x = east, -x = west; +y = north, -y = south)
			--(0=north; 90=east; 180=south; 270=west)
		waypoint = Point(10,1)
	}
	setmetatable(t, mt_ship)
	return t
end

local ship = CreateShip()
-- Execute instructions for ship
for i,instruction in ipairs(instructions) do
	local action = instruction[1]
	local value = instruction[2]
	if action=="F" then
		ship:move(action,value)
		print("Move:", action,value, "Position:", ship:getPosition() )
	elseif string.find("NSEW",action) then
		ship:moveWaypoint(action,value)
		print("MoveWP:", action,value, "-Waypoint->:", ship.waypoint.x, ship.waypoint.y )
	elseif string.find("LR",action) then
		ship:turn(action,value)
		print("Turn:", action,value, "-Waypoint->:", ship.waypoint.x, ship.waypoint.y )
	else
		error(string.format("Invalid instruction: %s%d",action,value))
	end
	
end
print("Ship's manhatan distance:",ship:getManhattanDistance())
