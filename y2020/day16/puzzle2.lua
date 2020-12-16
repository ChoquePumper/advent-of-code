
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end
local f_lines_iterator = f:lines()

local rules = {}

function rangeToList(range_text) -- e.g. 000-999
	local a,b = string.match(range_text,"(%d+)-(%d+)")
	return {tonumber(a), tonumber(b)}
end

-- read lines
for line in f_lines_iterator do
	if line:len() < 1 then break; end
	local rule, ranges1, ranges2 = string.match(line, "([%w%s]+): (%d+-%d+) or (%d+-%d+)")
	--print(rule, ranges, ranges2)
	rules[rule] = {rangeToList(ranges1), rangeToList(ranges2)}
end

local your_ticket = {}
-- your ticket
assert(f_lines_iterator()=="your ticket:")
for line in f_lines_iterator do
	if line:len() < 1 then break; end
	for number in string.gmatch(line, "([^,]+)") do
		local num = tonumber(number)
		assert(num, "Can't parse "..number.." to number.")
		table.insert(your_ticket, num)
	end
end

local nearby_tickets = {}
-- nearby tickets
assert(f_lines_iterator()=="nearby tickets:")
for line in f_lines_iterator do
	if line:len() < 1 then break; end
	local ticket = {}
	for number in string.gmatch(line, "([^,]+)") do
		local num = tonumber(number)
		assert(num, "Can't parse "..num.."to number.")
		table.insert(ticket, num)
	end
	table.insert(nearby_tickets, ticket)
end

f:close() -- close file

local overall_invalid_numbers = {} -- number as key; value is boolean
function validateTicket(ticket)
	local invalid_numbers = {}
	for i,num in ipairs(ticket) do
		-- check every number
		local is_valid = false
		if type(overall_invalid_numbers[num]) == "boolean" then
			-- If the invalid number is cached, return the cached value and save time
			is_valid = not(overall_invalid_numbers[num])
		else
			-- validate
			for rule,ranges in pairs(rules) do
				local ranges1 = ranges[1]
				local ranges2 = ranges[2]
				--print(rule, ranges1[1], ranges1[2], ranges2[1], ranges2[2])
				if (ranges1[1] <= num and num <= ranges1[2]) or (ranges2[1] <= num and num <= ranges2[2]) then
					-- valid number
					is_valid = true; break
				end
			end
		end
		if not is_valid then
			overall_invalid_numbers[num] = true
			table.insert(invalid_numbers, num)
		end
	end
	return #invalid_numbers == 0, invalid_numbers
end
-- add all valid tickets to a list
local valid_tickets = {}
for i,ticket in ipairs(nearby_tickets) do
	local is_valid, list_invalid_numbers = validateTicket(ticket)
	if is_valid then
		table.insert(valid_tickets, ticket)
	end
end

-- check per index
local valid_rules_by_index = {}
for i=1, #your_ticket do -- index
	local valid_rules = {}
	--print("Possible valid rules for index "..tostring(i))
	for rule,ranges in pairs(rules) do
		local is_valid = true
		for _,ticket in ipairs(valid_tickets) do
			local num = ticket[i]			--print(i,num)
			local ranges1 = ranges[1]
			local ranges2 = ranges[2]
			if not( (ranges1[1] <= num and num <= ranges1[2]) or (ranges2[1] <= num and num <= ranges2[2]) ) then
				is_valid = false; break
			end
		end
		if is_valid then
			table.insert(valid_rules, rule)
		end
	end
	table.sort(valid_rules)
	--[[print
	for i,rule in ipairs(valid_rules) do
		print("*", rule)
	end
	--]]
	valid_rules_by_index[i] = valid_rules
end
-- elminate by one
function RemoveValueFromTable(t,value)
	if value==nil then return; end
	for i,val in ipairs(t) do
		if val==value then
			table.remove(t,i)
			break
		end
	end
end
-- search for indexes with only one valid rule
local flag_found
repeat
	flag_found = 0
	local rule = nil
	for i,valid_rules in ipairs(valid_rules_by_index) do
		if #valid_rules == 1 then
			flag_found = i
			rule = valid_rules[1]
			valid_rules.final = rule
			break
		end
	end
	--print("flag_found",flag_found)
	if flag_found > 0 then
		for i,valid_rules in ipairs(valid_rules_by_index) do
			RemoveValueFromTable(valid_rules,rule)
		end
	end
until flag_found == 0

-- multiply all departures values for your_ticket
local answer = 1
for i,valid_rules in ipairs(valid_rules_by_index) do -- index
	print("Valid rule for index "..tostring(i), valid_rules.final)
	if string.find(valid_rules.final,"departure") == 1 then
		answer = answer * your_ticket[i]
	end
end

print("What do you get if you multiply those six (departure) values together?")
print( answer )
