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
	for amount,color2,bag_word in string.gmatch(line:sub(i2+1),"(%d+) (%a+ %a+) (%a+)[,.]") do
		bag_content[color2] = tonumber(amount)
	end -- If the bag contains no other bags, the table will be empty.
	bags_content[color1] = bag_content
end
f:close() -- close file

local bag_colors_holding_a_shiny_gold_bag = {
	-- bag color as key, value is boolean
}
function ContainsBagColor(bag_color_to_check) --, bag_color_to_search_for)
	--print("Checking in color", bag_color_to_check)
	if type( bag_colors_holding_a_shiny_gold_bag[ bag_color_to_check ] ) == "boolean" then
		-- Save time and don't search if we already checked that bag color
		return bag_colors_holding_a_shiny_gold_bag[ bag_color_to_check ]
	else
		local bag_content = bags_content[ bag_color_to_check ]
		assert(type(bag_content)=="table", "bag_content must be a table (got "..type(bag_content)..")")
		-- Check the bag content
		if bag_content["shiny gold"] then -- If there is (at least) a shiny gold bag
			-- Add to the table and return
			bag_colors_holding_a_shiny_gold_bag[ bag_color_to_check ] = true
			return true
		else
			local flag_found = false
			for color,_ in pairs(bag_content) do
				flag_found = ContainsBagColor( color ) -- recursion
				-- Stop if we found the shiny gold
				if flag_found then break; end
			end
			bag_colors_holding_a_shiny_gold_bag[ bag_color_to_check ] = flag_found
			return flag_found
		end
	end
end

-- Check every bag color
local count_bag_colors = 0
for bag_color,bag_content in pairs(bags_content) do
	if ContainsBagColor( bag_color ) then
		count_bag_colors = count_bag_colors+1	-- count up
	end
end
print("How many bag colors can eventually contain at least one shiny gold bag?", count_bag_colors)
-- Nice.
