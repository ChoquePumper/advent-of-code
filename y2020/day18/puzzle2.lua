-- Day 18, part 2
if _VERSION < "Lua 5.2" and not table.unpack then table.unpack = unpack end
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

local operators = "*+" -- ordered by priority
function ComparePriority(op1,op2) -- operators
	if op1==op2 then	return 0;
	elseif operators:find(op1) > operators:find(op2) then
		return 1
	else
		return -1
	end
end

local mt_group = {
	__tostring=function(t) return "{"..table.concat({tostring(t[1]),t[2],tostring(t[3])},",").."}" end
}
function EvaluateExpression(expr)
	print("EvaluateExpression",expr)
	local function group3tostack(stack)
		local len = #stack
		local group = setmetatable({stack[len-2],stack[len-1],stack[len]}, mt_group)
		assert(type(group[2])=="string","group[2] is not an operator")
		table.remove(stack)	-- pop
		table.remove(stack)	-- pop
		table.remove(stack)	-- pop
		table.insert(stack,group)	-- push
	end
	
	local i_next, i2, char = 1, nil, nil
	i_next, i2, char = string.find(expr,"(%S)", i_next)
	local stack = {}
	local last_element_is_operator = false
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
			local sub_result = EvaluateExpression(expr:sub(i_bracket+1,i_pair_bracket-1))
			print("sub_result",sub_result)
			--
			table.insert(stack,sub_result)	-- push
			i_next = i_pair_bracket+1
			--print("Bracket end.")
		elseif char=="+" or char=="*" then
			while #stack>=3 and ComparePriority( stack[#stack-1], char ) >= 0 do
				group3tostack(stack)
			end
			table.insert(stack, char)
			last_element_is_operator = true
			i_next = i_next+1
		else
			-- Probably a number
			local str_num = string.match(expr,"(%d+)", i_next)
			local num = tonumber( str_num )
			--print(str_num, num)
			if not num then error("Parsing error at position "..tostring(i_next)) end
			--
			table.insert(stack,num)	-- push
			
			i_next = i_next + #str_num
		end
		print("Stack:", table.unpack(stack))
		i_next, i2, char = string.find(expr,"(%S)", i_next)
	end
	-- Calc from group
	local function Calc(group)
		if #group == 1 then
			return tonumber(group[1])
		end
		assert(#group == 3, "group length is not 3. Can't calculate.")
		local operand1, operand2 = group[1], group[3]
		local operator = group[2]
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
	
	while #stack>3 do	group3tostack(stack);	end
	
	local result = 0
	if #stack==1 and type(stack[1])=="table" then
		result = Calc(stack[1])
	else
		result = Calc(stack)
	end
	--print("Final result", result)
	return result
end

local total_sum = 0
for i,line in ipairs(lines) do
	local result = EvaluateExpression(line)
	print( string.format("Result %d: %d", i, result) )
	total_sum = total_sum + result
end

print("Sum of the resulting values:", total_sum)
