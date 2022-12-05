-- Advent Of Code 2022, day 05
require "common"
---@class Stack
local Stack = {}; Stack.__index = Stack
function Stack:stack(...) -- push
	local items = {...}
	for _,item in ipairs(items) do
		table.insert(self,item)
	end
end

function Stack:take() -- pop
	local element = self:top()
	table.remove(self)
	return element
end

function Stack:top() -- peek
	return self[#self]
end

---@param input_iterable fun():string
---@return Stack[], table
local function parseInput(input_iterable)
	local first_lines = {} ---@type string[]
	for line in input_iterable do
		if line:len() > 1 then
			table.insert(first_lines, line)
		else
			break
		end
	end
	-- Actual parsing
	local num_stacks = math.ceil(first_lines[#first_lines]:len() / 4)
	---@param lines string[]
	---@param i_stack integer
	local function getStack(lines, i_stack)
		local stack = setmetatable({}, Stack)
		for i_line=#lines-1, 1, -1 do
			local cut_from, cut_to = 1+(i_stack-1)*4, (i_stack)*4
			local sub_line = lines[i_line]:sub(cut_from, cut_to)
			local crate = sub_line:match("%[(%w)%]%s?")
			if not crate then
				if sub_line:sub(1,3)=="   " then
					break -- Top of the stack reached
				else
					error( string.format("parsing failed at line %d:%d",i_line,cut_from) )
				end
			else
				stack:stack(crate)
			end
		end
		return stack
	end
	local stacks = {}
	for i=1, num_stacks do
		table.insert(stacks, getStack(first_lines, i))
	end
	-- Procedure
	local procedure = {}
	for line in input_iterable do
		local move,from,to = string.match(line, "move (%d+) from (%d+) to (%d+)")
		table.insert(procedure, {
			count = assert(tonumber(move)), from = assert(tonumber(from)), to = assert(tonumber(to))
		})
	end
	return stacks, procedure
end

local function getPuzzleAnswer(stacks)
	local answer = {}
	for _,stack in ipairs(stacks) do
		table.insert(answer, stack:top())
	end
	return table.concat(answer)
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local stacks, procedure = parseInput(input_iterable)
	-- Do procedure
	for _,step in ipairs(procedure) do
		local stack_from = stacks[step.from]
		local stack_dest = stacks[step.to]
		for i=1, step.count do
			stack_dest:stack( stack_from:take() )
		end
	end
	return getPuzzleAnswer(stacks)
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local stacks, procedure = parseInput(input_iterable)
	-- Do procedure
	for _,step in ipairs(procedure) do
		local stack_from = stacks[step.from]
		local stack_dest = stacks[step.to]
		local group = {}
		for i=1, step.count do -- insert in reverse order
			table.insert(group, 1, stack_from:take())
		end
		stack_dest:stack(table.unpack(group))
	end
	return getPuzzleAnswer(stacks)
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 05, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end