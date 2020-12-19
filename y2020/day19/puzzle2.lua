-- Day 19, part 2
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

-- Read lines to get the rules
local rules = {}
for line in f:lines() do
	local i_rule, str_rules = string.match(line,"(%d+):%s*(.+)")
	if #line < 1 then break; end -- stop at the empty line
	local i = tonumber(i_rule)
	assert(i)
	--rules[i] = str_rules
	if str_rules:sub(1,1)~='"' then
		--print(i, "["..str_rules.."]")
		local pipe_char = string.find(str_rules,"|")
		local rule_p1, rule_p2
		if pipe_char then
			rule_p1, rule_p2 = string.match(str_rules,"(.+)%s?|%s?(.+)")
		else
			rule_p1 = str_rules --string.sub(str_rules,1,pipe_char-1)
		end
		print("R1", rule_p1, "R2 ",rule_p2)
		local function Parse(rules)
			local t = {}
			for num in string.gmatch(rules,"(%d+)%s?") do
				local num_2 = tonumber(num); assert(num_2)
				table.insert(t, num_2)
			end
			if #t==0 then return nil end
			return t
		end
		rules[i] = {rule_p1 and Parse(rule_p1), rule_p2 and Parse(rule_p2)} -- the second one can be nil
	else
		rules[i] = str_rules:sub(2,2) -- the char between '"'
	end
end

function SetRulesForPart2( loop_first )
	if loop_first then
		rules[8] =	{ {42, 8}, {42} }
		rules[11] =	{ {42, 11, 31}, {42, 31} }
	else
		rules[8] =	{ {42}, {42, 8} }
		rules[11] =	{ {42, 31}, {42, 11, 31} }
	end
end

-- Read the messages
local messages = {}
for line in f:lines() do
	table.insert(messages, line)
end
f:close() -- close file

function ValidMatchForRule(i,str,pos)
	pos = pos or 1
	local spaces = string.rep("  ",pos-1)
	-- 			print(spaces.."ValidMatchForRule", i, pos)
	local rule = rules[i]
	if type(rule)=="string" then
		local res = rule == str:sub(pos, pos)
		--			print(spaces.."string at pos "..tostring(pos) ,rule, str:sub(pos, pos), res)
		return res,	1
	else -- if it's a table
		-- rule = { {sub_rule1}, {sub_rule2}, ...}
		--        { {4 2 1},     {3 4 1},     ...}
		--print(spaces.."Check")
		if pos > #str then return true, 0 end
		local flag = false
		local total_chars = 0
		--print( spaces.."rule length ", rule[1],rule[2])
		for i,sub_rule in ipairs(rule) do
			--print(spaces.."Check group "..tostring(i), flag)
			local flag2 = true
			local count_chars = 0
			for j=1, #sub_rule do
				--print(spaces.."Check num rule", flag2, table.concat(sub_rule))
				local num_rule = sub_rule[j]
				local res_sub, chars = ValidMatchForRule(num_rule, str, pos+(count_chars))
				count_chars = count_chars + chars
				flag2 = flag2 and res_sub
				--print(spaces.."Check num rule end", flag2)
				if not flag2 then
					break;
				end
			end
			flag = flag or flag2
			--print(spaces.."Check group end "..tostring(i), flag)
			if flag then
				total_chars = count_chars
				break;
			else
				--print(spaces.."Next group")
			end
		end
		--			print(spaces.."Result:",flag)
		return flag, total_chars
	end
end

function ValidateMessage(msg)
	local res,num_chars = ValidMatchForRule(0,msg,1)
	return res and num_chars == #msg
end

SetRulesForPart2( false )
local count_valid = 0
local valid_messages = {}
for i,message in ipairs(messages) do
	if ValidateMessage(message) then
		count_valid = count_valid + 1
		table.insert(valid_messages, message)
		print("Valid message:", message)
	end
end

-- Now remove messages for loop_first = true
SetRulesForPart2( true )
for i,message in ipairs(valid_messages) do
	if ValidateMessage(message) then
		count_valid = count_valid - 1
		valid_messages[i] = false
		print("NOT valid message:", message)
	end
end
for i=#valid_messages, 1, -1 do
	if not valid_messages[i] then
		table.remove(valid_messages,i)
	end
end
--]]
print("How many messages completely match rule 0?", count_valid)
--print( table.concat(valid_messages,"\n") )