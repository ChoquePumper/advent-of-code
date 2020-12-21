-- Day 21, part 1
if _VERSION < "Lua 5.2" and not table.unpack then table.unpack = unpack end
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end

function ShowTable(t)
	print("ShowTable", t)
	for k,v in pairs(t) do
		local v_type = type(v)
		if v_type=="table" then
			v = TableConcat(v)
		end
		print("*",k, v, v_type)
	end
end

function TableConcat(t)
	local res, arg2 = pcall(table.concat, t, ",")
	if res then
		return "{"..arg2.."}"
	else
		return t
	end
end

-- Read and parse the lines
local overall_allergens = {
	-- contains the lines (by reference) which contains that allergen
	-- ["allergen_name"] = {{ingredients1},{ingredients2},...}
}
local list_food = {}
for line in f:lines() do
	local allergens = {}
	local i1, i2, str_contains = string.find(line,"%(contains (.+)%)")
	assert(str_contains)
	local ingredients = {}
	for ingredient in string.gmatch(line:sub(1,i1-1),"(%S+)") do
		table.insert(ingredients, ingredient)
	end
	for allergen in string.gmatch(str_contains,"(%w+)%,?") do
		table.insert(allergens, allergen)
		if not overall_allergens[allergen] then
			overall_allergens[allergen] = {}
		end
		table.insert(overall_allergens[allergen], ingredients)
	end
	ingredients.contains = allergens
	--
	table.insert(list_food, ingredients)
	--table.insert(messages, line)
end
f:close() -- close file

--ShowTable(list_food)
-- search for the ingredients in common
local overall_common_ingredients = {}
local common_ingredients_per_allergen = {}	-- dict
for allergen,list_food_where_contains in pairs(overall_allergens) do
	local common_ingredients = {} -- dictionary
	local max_number = 0
		--ShowTable(list_food_where_contains)
	for i,ingredients in ipairs(list_food_where_contains) do
		for j,ingredient in ipairs(ingredients) do
			if not common_ingredients[ingredient] then
				common_ingredients[ingredient] = 1
			else
				common_ingredients[ingredient] = common_ingredients[ingredient]+1
			end
			if common_ingredients[ingredient] > max_number then max_number = common_ingredients[ingredient] end
		end
	end
	local common_ingredients2 = {}
	print(allergen)--, "max_number", max_number)
	-- remove from the list of food
	for ingredient,number_of_times in pairs(common_ingredients) do
		if number_of_times == max_number then
			common_ingredients2[ingredient] = 0
		end
	end
	for i,ingredients in ipairs(list_food) do
		for j,ingredient in ipairs(ingredients) do
			if common_ingredients2[ingredient] then
				common_ingredients2[ingredient] = common_ingredients2[ingredient]+1
				overall_common_ingredients[ingredient] = true
			end
		end
	end
	ShowTable(common_ingredients2)
	common_ingredients_per_allergen[allergen] = common_ingredients2 -- for part 2
end
--ShowTable(tmp_list)
--ShowTable(list_food)
-- count the number of times
local total_times = 0
local ingredients_not_containing_allergen = {}
for i,ingredients in ipairs(list_food) do
	for j,ingredient in ipairs(ingredients) do
		if not overall_common_ingredients[ingredient] then
			local count = ingredients_not_containing_allergen[ingredient]
			if not count then
				ingredients_not_containing_allergen[ingredient] = 1
			else
				ingredients_not_containing_allergen[ingredient] = count+1
			end
			total_times = total_times+1
		end
	end
end
print("Ingredients cannot possibly contain any of the allergens:", total_times)

-- Part 2
-- Recycle the same logic from day 16
--[[ for k,v in pairs(common_ingredients_per_allergen) do
	print(k)
	ShowTable(v)
end --]]
local flag_found
local allergen_ingredient = {}
repeat
	flag_found = nil
	for allergen, common_ingredients in pairs(common_ingredients_per_allergen) do
		local count = 0
		local last_ingredient = nil
		for ingredient,_ in pairs(common_ingredients) do
			count = count+1
			last_ingredient = ingredient
		end
		if count == 1 then
			flag_found = last_ingredient
			allergen_ingredient[allergen] = last_ingredient
			break;
		end
	end
	--
	if flag_found then
		for allergen, common_ingredients in pairs(common_ingredients_per_allergen) do
			--if type(common_ingredients) == "table" then
				common_ingredients[flag_found] = nil
				--print(
				--print("===")
			--end
		end
	end
until not flag_found
print("--------")
ShowTable(allergen_ingredient)
local list_of_allergens = {}
for allergen in pairs(allergen_ingredient) do
	table.insert(list_of_allergens, allergen)
end
table.sort(list_of_allergens)
-- Replace every allergens by the matching ingredient
print("Allergens:", table.concat(list_of_allergens,","))
for i=1, #list_of_allergens do
	list_of_allergens[i] = allergen_ingredient[ list_of_allergens[i] ]
end
print("What is your canonical dangerous ingredient list?")
print("Ingredients:", table.concat(list_of_allergens,","))

