#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

local VM; VM = { -- Virtual Machine
	pc = 0, -- program counter
	accumulator = 0,
	step_pc = 1,
	program = {}, -- a list of values in a table {op,arg,ex=false}
		-- the "ex" one is a flag that indicates if it the instruction was executed before
	operations = {
		acc = function(arg)
			VM.accumulator = VM.accumulator + arg
		end,
		jmp = function(arg)
			VM.step_pc = arg
		end,
		nop = function()	--[[ do nothing ]]	end,
	}
}

-- Read lines, parse and load the program
for line in f:lines() do
	for operation, argument in string.gmatch(line, "(%a+) (.%d+)") do
		table.insert(VM.program, {operation, tonumber(argument), ex=false})
	end
end
f:close() -- close file

function VM:PrintAccumulator()
	print("Accumulator value:", self.accumulator)
end

function VM:ExecuteProgram()
	local flag_stop = false
	repeat
		local pc = self.pc + self.step_pc -- increment (or decrement) pc
		self.pc = pc
		if not (self.step_pc==1) then self.step_pc=1 end -- reset step_pc
		local instruction = self.program[pc]
		--print(pc, instruction[1], instruction[2]) -- print the trace
		if instruction.ex then
			self:PrintAccumulator()
			return -- end if the instruction was executed before
		else
			instruction.ex = true
		end
		local func = self.operations[instruction[1]]
		func( instruction[2] ) -- Execute instruction
	until flag_stop or pc >= #self.program
end
VM:ExecuteProgram()
