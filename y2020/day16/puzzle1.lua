
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

local sum_invalid_numbers = 0
for i,ticket in ipairs(nearby_tickets) do
	local is_valid, list_invalid_numbers = validateTicket(ticket)
	for i,invalid_num in ipairs(list_invalid_numbers) do
		sum_invalid_numbers = sum_invalid_numbers + invalid_num
	end
	--[[
	if not is_valid then
		print("Invalid numbers in nearby ticket "..tostring(i)..":", table.unpack(list_invalid_numbers))
	end
	--]]
end

--[[ "That's not the right answer."
for invalid_num,_ in pairs(overall_invalid_numbers) do
	sum_invalid_numbers = sum_invalid_numbers + invalid_num
end	]]
print("What is your ticket scanning error rate?", sum_invalid_numbers)
