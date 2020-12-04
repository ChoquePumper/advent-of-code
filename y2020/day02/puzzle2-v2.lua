
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end

-- Read lines and parse
local count_total, count_valid = 0, 0
function CheckPassword(password, pos1, pos2, letter)
	assert( type(password)=="string", "argument 1 (password) must be string" )
	assert( type(pos1)=="number", "argument 2 (pos1) must be number" )
	assert( type(pos2)=="number", "argument 3 (pos2) must be number" )
	assert( type(letter)=="string", "argument 4 (letter) must be string" )
	-- return boolean result: check1 xor check2?
	local check1 = password:sub(pos1,pos1) == letter
	local check2 = password:sub(pos2,pos2) == letter
	return (check1 or check2) and not(check1 and check2)
end
for line in f:lines() do
	local pos1,pos2,letter,password = string.match(line,"(%d+)-(%d+) (%a): (%a+)")
	if pos1 and pos2 and letter and password then
		count_total = count_total+1
		if CheckPassword(password,tonumber(pos1),tonumber(pos2),letter) then
			count_valid = count_valid+1
		end
	end
end
f:close() -- close the file

print(string.format("Valid passwords from input: %d/%d.", count_valid, count_total))
