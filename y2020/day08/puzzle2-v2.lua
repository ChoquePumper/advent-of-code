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
	},
	trace = {},
}

local instructions_nop_jmp = {}
	-- a list of numbers of instruction which operation is nop or jmp

-- Read lines load the program
for line in f:lines() do
	for operation, argument in string.gmatch(line, "(%a+) (.%d+)") do
		table.insert(VM.program, {operation, tonumber(argument), ex=false})
		if operation=="jmp" or operation=="nop" then
			table.insert(instructions_nop_jmp, #VM.program)
		end
	end
end
f:close() -- close file

function VM:PrintAccumulator()
	print("Accumulator value:", self.accumulator)
end

function VM:ResetValues()
	self.pc, self.step_pc, self.accumulator = 0, 1, 0
end
function VM:ResetExFlags()
	for i,num in ipairs(self.trace) do
		self.program[num].ex = false
	end
	self.trace = {}
end

function VM:ExecuteProgram()
	local flag_stop = false
	print("ExecuteProgram")
	repeat
		local pc = self.pc + self.step_pc -- increment (or decrement) pc
		self.pc = pc
		if pc > #self.program then break; end
		if not (self.step_pc==1) then self.step_pc=1 end -- reset step_pc
		local instruction = self.program[pc]
		--print(pc, instruction[1], instruction[2])
		if instruction.ex then
			print("Interrupted on pc:", pc)
			return 1 -- end if the instruction was executed before
		else
			table.insert(self.trace, pc) -- add to the trace
			instruction.ex = true
		end
		local func = self.operations[instruction[1]]
		func( instruction[2] )
	until flag_stop
	print("Program terminates normally.")
	return 0
end

local last_change -- a table with to values: [1] is the number of instruction, [2] the previous op
local i_nop_jmp = 1
while not(VM:ExecuteProgram()==0) do
	if last_change then	-- revert change
		print("Reverting change")
		VM.program[last_change[1]][1] = last_change[2]
	end
	local next_num_instruction = instructions_nop_jmp[ i_nop_jmp ]
	local instruction = VM.program[next_num_instruction]
	last_change = {next_num_instruction, instruction[1]}
	print("next_num_instruction", next_num_instruction)
	if instruction[1] == "jmp" then
		instruction[1] = "nop"
	elseif instruction[1] == "nop" then
		instruction[1] = "jmp"
	else
		assert(false)
	end
	i_nop_jmp = i_nop_jmp+1
	VM:ResetValues()
	VM:ResetExFlags()
	-- Try again
end
VM:PrintAccumulator()
