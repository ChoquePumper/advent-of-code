-- Day 18, part 2. Alternative version. ;)
-- I wanted to join to this kind of solution: "Use eval() with patched operators"
if _VERSION >="Lua 5.3" and not loadstring then loadstring = load end

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

local mt_no = {
	__add = function(a,b)	return N(a.n*b.n);	end,
	__mul = function(a,b)	return N(a.n+b.n);	end,
	__tostring = function(a) return tostring(a.n) end
}
function N(o)	-- No
	return setmetatable({n=o},mt_no) -- no
end

local total_sum = 0

-- Replacements
local replacements = { ["+"]="*", ["*"]="+" }
--[[
function EvaluateExpression(line)
	print("EvaluateExpression:", line)
	local line_alt = string.gsub(line,"([%+%*])", replacements)
	line_alt = string.gsub(line_alt,"(%d+)", "N(%1)")
	print(line_alt)
	return loadstring("return "..line_alt)() -- equivalent to eval function
end

for i,line in ipairs(lines) do
	local result = EvaluateExpression(line)
	print( string.format("Result %d: %s", i, tostring(result)) )
	total_sum = total_sum + result.n	-- result is a table
end
--]]
-- Even faster
local full_expr = ("return ( "..table.concat(lines," )+( ").." )")
	:gsub("([%+%*])",replacements)	-- replace "+" and "*"
	:gsub("(%d+)","N(%1)") -- For each number make a table with mt_no metatable
total_sum = loadstring(full_expr)().n
--]]
print("Sum of the resulting values:", total_sum)
