#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then	-- End program if couldn't open the file
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

local bags_content = {	--[[ Example:
	["light red"] = { -- contains
		["bright white"] = 1,
		["muted yellow"] = 2,
	},
	["dark orange"] = { -- contains
		["bright white"] = 3,
		["muted yellow"] = 4,
	},
	... and so on ]]
}

-- Read and parse lines. It's regex time!
for line in f:lines() do
	local i1,i2,color1 = string.find(line,"(%a+ %a+) bags contain ")
	local bag_content = {}
	for quantity,color2,bag_word in string.gmatch(line:sub(i2+1),"(%d+) (%a+ %a+) (%a+)[,.]") do
		bag_content[color2] = tonumber(quantity)
	end -- If the bag contains no other bags, the table will be empty.
	bags_content[color1] = bag_content
end
f:close() -- close file

local bag_colors_total_other_bags = { --[[ bag color as key; quantity as value. Example:
	["vibrant plum"] = 11,
	["shiny gold"] = 32,
	["dark olive"] = 7, ...	]]
}

function GetNumberOfOtherBags(bag_color_to_check) --, bag_color_to_search_for)
	if type( bag_colors_total_other_bags[ bag_color_to_check ] ) == "number" then
		-- Save time and don't search if we already checked that bag color
		return bag_colors_total_other_bags[ bag_color_to_check ]
	else
		local bag_content = bags_content[ bag_color_to_check ]
		assert(type(bag_content)=="table", "bag_content must be a table (got "..type(bag_content)..")")
		-- Check the bag content
		local total = 0
		for color,quantity in pairs(bag_content) do
			total = total + quantity + quantity*GetNumberOfOtherBags( color ) -- recursion
		end
		bag_colors_total_other_bags[ bag_color_to_check ] = total
		return total
	end
end
print("How many individual bags are required inside your single shiny gold bag?", GetNumberOfOtherBags("shiny gold"))
--for k,v in pairs( bag_colors_total_other_bags ) do print(k,v) end -- for debugging
