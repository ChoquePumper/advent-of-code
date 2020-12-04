
local valid_fields = {
	-- the boolean value means "is required?"
	byr=true,	iyr=true,	eyr=true,	hgt=true,
	hcl=true,	ecl=true,	pid=true,	cid=false,
}

local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end

local f_iter = f:lines()

local passports = {}
function ReadPassport()
	local passport = {}
	local line = f_iter()
	while line and line:len() > 0 do
		for keyval in string.gmatch(line,"([^% ]+)") do
			local key, value = string.match(keyval,"(%a+):([%a%d#]+)")
			if key and value then
				passport[key] = value
			else
				print("Warning: cannot parse "..keyval)
			end
		end
		line = f_iter() -- get next line
	end
	return passport, line==nil
end

function ValidPassport(passport)
	local flag = true
	for key,isrequired in pairs(valid_fields) do
		if isrequired and not passport[key] then
			flag = false
			break
		end
	end
	return flag
end

-- Get passports
local stop = false
while not stop do
	local passport, flag = ReadPassport()
	table.insert(passports, passport)
	stop = flag
end
f:close()

local count_valid = 0
for i,passport in ipairs(passports) do
	if ValidPassport(passport) then
		count_valid = count_valid+1
	end
end

print("Valid passports:",count_valid)
