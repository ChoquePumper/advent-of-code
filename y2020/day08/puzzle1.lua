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
-- Read lines load the program
for line in f:lines() do
	for operation, argument in string.gmatch(line, "(%a+) (.%d+)") do
		table.insert(program, {operation, tonumber(argument), ex=false})
		--print( operation, tonumber(argument) )
	end
end
f:close() -- close file

function PrintAccumulator()
	print("Accumulator value:", accumulator)
end

function ExecuteProgram()
	local flag_stop = false
	repeat
		pc = pc+step_pc -- increment (or decrement) pc
		if not (step_pc==1) then step_pc=1 end -- reset step_pc
		local instruction = program[pc]
		print(pc, instruction[1], instruction[2]) -- print the trace
		if instruction.ex then
			PrintAccumulator()
			return -- end if the instruction was executed before
		else
			instruction.ex = true
		end
		local func = operations[instruction[1]]
		func( instruction[2] )
	until flag_stop or pc >= #program
end
ExecuteProgram()
