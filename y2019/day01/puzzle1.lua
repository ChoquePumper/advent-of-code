-- Day 01, part 1
local input_file = arg[1]
function CalcFuelRequired(mass)
	local res = math.floor(mass/3) - 2
	print("CalcFuelRequired", mass, res)
	return res
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
	total_req_fuel = total_req_fuel + CalcFuelRequired(module_mass)
end

print("Total fuel required:", total_req_fuel)