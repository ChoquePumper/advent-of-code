-- Day 01, part 2
local input_file = arg[1]
function CalcFuelRequired(mass)
	local res = math.floor(mass/3) - 2
	if res > 0 then
		res = res + CalcFuelRequired(res)
	end
	return math.max(res,0)
end

-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end

local total_req_fuel = 0
-- Read lines
for line in f:lines() do
	local module_mass = tonumber(line)
	assert(module_mass)
	local fuel = CalcFuelRequired(module_mass)
	print("CalcFuelRequired", module_mass, fuel)
	total_req_fuel = total_req_fuel + fuel
end

print("Total fuel required:", total_req_fuel)