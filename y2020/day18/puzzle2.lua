-- Day 18, part 2
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

-- Read all lines
local lines = {}
for line in f:lines() do
	table.insert(lines, line)
end
f:close() -- close file

local operators = "+*" -- ordered by priority

function EvaluateExpresion(expr)
	print("EvaluateExpresion",expr)
	local result = 0
	local flag_operator_found = false
	local i_next, i2, char = 1, nil, nil
	i_next, i2, char = string.find(expr,"([0-9%(%+%*])", i_next)
	local stack = {}
	while i_next do
		--print(i_next,i2,char)
		if char=="(" then
			--print("Bracket found")
			-- find the pair
			local i_bracket = i_next
			local i_pair_bracket = i_next
			local level = 1
			local i_next2 = i_next+1
			repeat
				local i1,i2,c = string.find(expr, "([%(%)])", i_next2)
				assert(i1,"Closing bracket not found for position "..tostring(i_bracket))
				level = level + (c=="(" and 1 or -1)
				if level == 0 then i_pair_bracket = i1 end
				i_next2 = i1 + 1
			until level == 0
			local sub_result = EvaluateExpresion(expr:sub(i_bracket+1,i_pair_bracket-1))
			print("sub_result",sub_result)
			--
			if stack[#stack]=="+" then -- if it's operator
				local group = {stack[#stack-1],stack[#stack],sub_result}
				table.remove(stack)
				table.remove(stack)
				table.insert(stack,group)
			else
				table.insert(stack,sub_result)
			end
			i_next = i_pair_bracket+1
			--print("Bracket end.")
			--print("Current result:", result)
		elseif char=="+" or char=="*" then
			if char=="*" and stack[#stack-1]=="*" then
				local group = {stack[#stack-2],stack[#stack-1],stack[#stack]}
				table.remove(stack)
				table.remove(stack)
				table.remove(stack)
				table.insert(stack,group)
			end
			table.insert(stack, char)
			i_next = i_next+1
		else
			-- Probably a number
			local str_num = string.match(expr,"(%d+)", i_next)
			local num = tonumber( str_num )
			--print(str_num, num)
			if not num then error("Parsing error at position "..tostring(i_next)) end
			--
			if stack[#stack]=="+" then -- if it's operator
				local group = {stack[#stack-1],stack[#stack],num}
				table.remove(stack)
				table.remove(stack)
				table.insert(stack,group)
			else
				table.insert(stack,num)
			end
			
			i_next = i_next + #str_num
			--print("Current result:", result)
		end
		print("Stack:", table.unpack(stack))
		i_next, i2, char = string.find(expr,"([0-9%(%+%*])", i_next)
	end
	-- Calc from stack
	local function Calc(stack)
		if #stack % 2 == 0 then
			print(table.unpack(stack))
		end
		assert(#stack % 2 == 1, "Stack length % 2 == 0. Can't calculate.")
		local operand1, operand2 = stack[1], stack[3]
		local operator = stack[2]
		if type(operand1)=="table" then
			operand1 = Calc(operand1)
		end
		if type(operand2)=="table" then
			operand2 = Calc(operand2)
		end
		if operator=="+" then
			return operand1 + operand2
		elseif operator=="*" then
			return operand1 * operand2
		else
			error("Invalid operator "..tostring(operator))
		end
	end
	if #stack==1 and type(stack[1])=="table" then
		result = Calc(stack[1])
	else
		result = Calc(stack)
	end
	print("Final result", result)
	return result
end

local total_sum = 0
for i,line in ipairs(lines) do
	local result = EvaluateExpresion(line)
	print( string.format("Result %d: %d", i, result) )
	total_sum = total_sum + result
end

print("sum of the resulting values:", total_sum)
