-- Advent of Code 2021, day 02, part 1
local Cursor; Cursor = {
	getPos = function(self) return self.x, self.y; end,
	moveCommand = function(self, dir, x)
		x = assert(tonumber(x)); assert(x > 0)
		if     dir=="forward" then self:move(x,0)
		elseif dir=="up"    then self:move(0,-x)
		elseif dir=="down"  then self:move(0,x)
		else error("Invalid direction: "..tostring(dir))
		end
	end,
    move = function(self,x,y)
        assert(tonumber(x));    assert(tonumber(y))
        self.x = self.x + x;    self.y = self.y + y
    end,
    new = function() -- +y = depth
        return setmetatable({x = 0, y = 0}, Cursor)
    end,
}
Cursor.__index = Cursor

function solvePart1(input_iterable)
	local submarine = Cursor:new()
	for instruction in input_iterable do
		local direction, x = string.match(instruction,"(%a+) (%d+)")
		submarine:moveCommand(direction,x)
	end
	local h_pos, depth = submarine:getPos()
	-- Answer: final horizontal position multiplied by final depth
	return h_pos * depth
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close() -- Close file
	print("Part 1: answer", part1answer)
end

function test()
	print("Running test...")
	local test_input = [[
		forward 5
		down 5
		forward 8
		up 3
		down 8
		forward 2]]
	local answer = solvePart1(string.gmatch(test_input,"([^\n]+)"))
	print("Test", answer)
	assert(answer == 150)
end

if arg then
	test() -- Run a test
	if arg[1] then
		main(arg[1]) -- Run with the specified input file from argument 1
	end
end
