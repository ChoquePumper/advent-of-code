-- Advent Of Code 2022, day 10
require "common"

---@class VM
---@field X integer # register
---@field program table[] # register
---@field cycle_count integer
---@field signal_strength_cache table
local VM = {}; VM.__index = VM

VM.opetations = {
	---@param vm VM
	["noop"] = function(vm)
		vm:countCycle() -- do nothing
	end,
	---@param vm VM
	---@param value integer
	["addx"] = function(vm, value)
		vm:countCycle()
		vm:countCycle()
		vm.X = vm.X + value
	end,
}

function VM.new(program)
	return setmetatable({
		X=1, program=program, cycle_count = 0,
		signal_strength_cache = {}
	}, VM)
end

function VM:countCycle()
	self.cycle_count = self.cycle_count + 1
	if (self.cycle_count+20) % 40 == 0 then
		self.signal_strength_cache[self.cycle_count] = self.cycle_count * self.X
		print("Cycle:", self.cycle_count, "X=", self.X)
	end
end

function VM:run()
	for i,instruction in ipairs(self.program) do
		local func = VM.opetations[instruction[1]]
		assert(func, "Unknown operator "..tostring(instruction[1]))
		--print(i, table.concat(instruction, ":"), "X=", self.X)
		func( self, tonumber(instruction[2]) or instruction[2] )
	end
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local program = {}
	for line in input_iterable do
		local op, arg = string.match(line, "(%S+)%s*(%S*)")
		table.insert(program, {op, arg})
	end
	return program
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local vm = VM.new(parseInput(input_iterable))
	vm:run()
	local answer = 0
	for nth_cycle, signal_strength in pairs(vm.signal_strength_cache) do
		answer = answer + signal_strength
	end
	return answer
end

---@class VMp2
---@field image table
local VMp2 = {}; VMp2.__index = VMp2
setmetatable(VMp2, VM)

function VMp2.new(program)
	return setmetatable({
		X=1, program=program, cycle_count = 0,
		image = {}
	}, VMp2)
end

function VMp2:countCycle()
	self.cycle_count = self.cycle_count + 1
	local i_row = math.ceil(self.cycle_count/40)
	local row = self.image[i_row]
	if not row then
		row = {}
		self.image[i_row] = row
	end
	local col = 1 + (self.cycle_count-1) % 40
	local sprite_pos = self.X
	row[col] = (col==(sprite_pos) or col==(sprite_pos+1) or col==(sprite_pos+2)) and "#" or "."
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local vm = VMp2.new( parseInput(input_iterable) )
	vm:run()
	for i,row in ipairs(vm.image) do
		print(i, table.concat(row) )
	end
	return nil
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 10, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end