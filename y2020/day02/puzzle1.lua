
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end

-- Read lines and parse
local count_total, count_valid = 0, 0
function CheckPassword(password, min, max, letter)
	assert( type(password)=="string", "argument 1 (password) must be string" )
	assert( type(min)=="number", "argument 2 (min) must be number" )
	assert( type(max)=="number", "argument 3 (max) must be number" )
	assert( type(letter)=="string", "argument 4 (letter) must be string" )
	local count_letter = 0
	-- count letters
	for _ in string.gmatch(password, letter) do
		count_letter = count_letter+1
	end
	-- return boolean result: is count_letter between min and max?
	return min <= count_letter and count_letter <= max
end
for line in f:lines() do
	local min,max,letter,password = string.match(line,"(%d+)-(%d+) (%a): (%a+)")
	if min and max and letter and password then
		count_total = count_total+1
		if CheckPassword(password,tonumber(min),tonumber(max),letter) then
			count_valid = count_valid+1
		end
	end
end
f:close() -- close the file

print(string.format("Valid passwords from input: %d/%d.", count_valid, count_total))
