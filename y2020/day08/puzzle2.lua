#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

local pc = 0 -- program counter
local accumulator = 0
local step_pc = 1
local operations = {
	acc = function(arg)
		accumulator = accumulator + arg
	end,
	jmp = function(arg)
		step_pc = arg
	end,
	nop = function()	--[[ do nothing ]]	end,
}
local program = {} -- a list of values in a table {op,arg,ex=false}
	-- the "ex" one is a flag that indicates if it the instruction was executed before
local instructions_nop_jmp = {}
	-- a list of numbers of instruction which operation is nop or jmp
local trace = {}

-- Read lines load the program
for line in f:lines() do
	for operation, argument in string.gmatch(line, "(%a+) (.%d+)") do
		table.insert(program, {operation, tonumber(argument), ex=false})
		if operation=="jmp" or operation=="nop" then
			table.insert(instructions_nop_jmp, #program)
		end
	end
end
f:close() -- close file

function PrintAccumulator()
	print("Accumulator value:", accumulator)
end

function ResetValues()
	pc, step_pc, accumulator = 0, 1, 0
end
function ResetExFlags()
	for i,num in ipairs(trace) do
		program[num].ex = false
	end
	trace = {}
end

function ExecuteProgram()
	local flag_stop = false
	print("ExecuteProgram")
	repeat
		pc = pc+step_pc -- increment (or decrement) pc
		if pc > #program then break; end
		if not (step_pc==1) then step_pc=1 end -- reset step_pc
		local instruction = program[pc]
		--print(pc, instruction[1], instruction[2])
		if instruction.ex then
			print("Interrupted on pc:", pc)
			return 1 -- end if the instruction was executed before
		else
			table.insert(trace, pc) -- add to the trace
			instruction.ex = true
		end
		local func = operations[instruction[1]]
		func( instruction[2] )
	until flag_stop
	print("Program terminates normally.")
	return 0
end

local last_change -- a table with to values: [1] is the number of instruction, [2] the previous op
local i_nop_jmp = 1
while not(ExecuteProgram()==0) do
	if last_change then	-- revert change
		program[last_change[1]][1] = last_change[2]
		print("Reverting change")
	end
	local next_num_instruction = instructions_nop_jmp[ i_nop_jmp ]
	local instruction = program[next_num_instruction]
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
	ResetValues()
	ResetExFlags()
	-- Try again
end
PrintAccumulator()
