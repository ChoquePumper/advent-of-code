-- Advent Of Code 2022, day 06
require "common"

---@param line string
---@param count_distinct integer
---@return integer
local function findMarker(line, count_distinct)
	assert(isString(line))
	assert(isNumber(count_distinct))
	assert(count_distinct > 1)
	local i = 1
	local count = 0
	local marker_found = false
	while i <= line:len() do
		if count >= (count_distinct-1) then
			marker_found = true
			break
		end
		local i_char_repeated = string.find(line, line:sub(i,i), i+1, true)
		if i_char_repeated then
			local distance = i_char_repeated - i
			count = (distance > ((count_distinct-1)-count)) and (count + 1) or 0
		else
			count = count + 1
		end
		i = i + 1
	end
	return marker_found and i or nil
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	return findMarker( input_iterable(), 4 )
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	return findMarker( input_iterable(), 14 )
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 06, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end