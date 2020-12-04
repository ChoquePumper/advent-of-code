
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end

local f_iter = f:lines()

local valid_ecl = {amb=true,blu=true,brn=true,gry=true,grn=true,hzl=true,oth=true}
local valid_fields = {
	-- the function value means the condition for valid data
	byr=function(val) val=tonumber(val) return 1920<=val and val<=2002 end,
	iyr=function(val) val=tonumber(val) return 2010<=val and val<=2020 end,
	eyr=function(val) val=tonumber(val) return 2020<=val and val<=2030 end,
	hgt=function(val)
		local num,measure = string.match(val,"(%d+)(%a+)")
		num = tonumber(num)
		if measure=="cm" then return 150<=num and num<=193
		elseif measure=="in" then return 59<=num and num<=76 end
		return false
	end,
	hcl=function(val)
		local i1,i2, val2 = string.find(val,"#(%x+)")
		return i1==1 and i2==val:len()
	end,
	ecl=function(val)
		return valid_ecl[val]
	end,
	pid=function(val)
		local i1,i2, val2 = string.find(val,"(%d+)")
		return string.len(val2)==9
	end,
	cid=false,
}

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
		if isrequired then
			local val = passport[key]
			if val then
				local func_condition = isrequired
				if type(func_condition)=="function" then
					flag = func_condition(val)
				end
				if not flag then print("Condition failed: key:",key,"value:",val) end
			else
				print("Condition failed: missing key:",key)
				flag = false
			end
		end
		if not flag then
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
