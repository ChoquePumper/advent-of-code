-- Advent Of Code 2022, day 13
require "common"

---@param a integer|table
---@param b integer|table
---@return "-1"|"0"|"1"
local function compare(a,b)
	if (not isTable(a)) and (not isTable(b)) then
		return a==b and 0 or ((a<b) and -1 or 1)
	elseif isTable(a) and isTable(b) then
		local i = 1
		local result = nil
		while not isNumber(result) do
			local left, right = a[i], b[i]
			if not right then
				result = (not left) and 0 or 1
			elseif not left then
				result = -1
			else
				local res = compare(left,right)
				if res~=0 then result = res end
			end
			i = i+1
		end
		return result
	else
		return compare((not isTable(a)) and {a} or a, (not isTable(b)) and {b} or b)
	end
end

local function toLuaObject(code)
	return load( "return " .. code)()
end

local repl = { ["["] = "{", ["]"] = "}" }

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local list_of_pairs = {} ---@type {[1]:table,[2]:table}
	for line in input_iterable do
		if(line:len() > 0) then
			-- Hehe. Replace each [] for {} and parse the line as lua code
			local list1 = toLuaObject( line:gsub("[%[%]]", repl) )
			local list2 = toLuaObject( input_iterable():gsub("[%[%]]", repl) )
			table.insert(list_of_pairs, {list1,list2})
		end
	end
	return list_of_pairs
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local list_of_pairs = parseInput(input_iterable)
	local answer = 0 -- sum of indices
	for i, pair in ipairs(list_of_pairs) do
		print("Comparing pair", i, pair)
		if compare(pair[1],pair[2]) <= 0 then
			answer = answer + i
			print("Pair is in the right order")
		else
			print("Pair is NOT in the right order")
		end
	end
	return answer
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local list_of_pairs = parseInput(input_iterable)
	local list_of_packets = {} ---@type integer|table[]
	local divider_packets = { {{2}}, {{6}} } ---@type table[]
	for _,pair in ipairs(list_of_pairs) do
		table.insert(list_of_packets, pair[1])
		table.insert(list_of_packets, pair[2])
	end
	table.insert(list_of_packets, divider_packets[1])
	table.insert(list_of_packets, divider_packets[2])
	table.sort(list_of_packets, function(a,b)
		return compare(a,b) < 0
	end)
	-- Find the decoder key
	local answer = 1
	for _,divider_packet in ipairs(divider_packets) do
		for i,packet in ipairs(list_of_packets) do
			local res = compare(packet, divider_packet)
			if res == 0 then
				answer = answer * i
			end
			if res >= 0 then break end
		end
	end
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 13, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end