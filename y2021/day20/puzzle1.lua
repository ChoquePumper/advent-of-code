-- Advent of Code 2021, day 20, part 1

---@class GridMap
local GridMap; GridMap = {}
---@param x number
---@param y number
function GridMap:get(x,y)
	local row = self[y]
	return row and row[x] or (self.out_bounds_lit and "#" or ".")
end
function GridMap:get3x3string(x,y)
	local values = {}
	for dy=-1, 1 do for dx=-1, 1 do
		table.insert(values, self:get(x+dx, y+dy))
	end end
	assert(#values==9)
	return table.concat(values)
end
function GridMap:getValuesSet()
	return self.values_set
end
function GridMap:getCountPixelsLit() return self.pixels_lit end
---@param x number
---@param y number
function GridMap:set(x,y, value)
	local row = self[y]
	if not row then
		row = {}
		self[y] = row
	end
	if not row[x] then self.values_set = self.values_set+1 end
	-- set value
	local whether_count_lit = (value~=self:get(x,y) and (value=="#" and 1 or -1) or 0)
	row[x] = value
	self.pixels_lit = self.pixels_lit+whether_count_lit
	-- update boundaries
	self.min_x = math.min(self.min_x, x) self.max_x = math.max(self.max_x, x)
	self.min_y = math.min(self.min_y, y) self.max_y = math.max(self.max_y, y)
end
function GridMap.new(input)
	local self = setmetatable({
		-- [-i ... +i] = rows
		min_x=0, max_x=0, min_y=0, max_y=0,
		values_set = 0, -- values that internally are not nil
		pixels_lit = 0,
		out_bounds_lit = false,
	},GridMap)
	if input then
		for y,row in ipairs(input) do for x,c in ipairs(row) do
			self:set(x-1, y-1, c)
		end end
	end
	return self
end
GridMap.__index = GridMap

function printMap(map)
	local lit = 0
	for y=map.min_y, map.max_y do
		for x=map.min_x, map.max_x do
			local c = map:get(x,y)
			io.write(c)
			lit = lit + (c=="#" and 1 or 0)
		end
		io.write("\n")
	end
	io.flush()
	print(lit)
end

function bin2dec(bin_num)
	local num_digits = #bin_num
	assert(num_digits > 0)
	local res = 0
	for i=1, num_digits do
		res = res + (tonumber(bin_num:sub(i,i)) * 2^(num_digits-i))
	end
	return math.floor(res)
end

local replacements = {["#"]="1", ["."]="0"}
---@param s string
local function mapStringToBin(s)
	return (string.gsub(s, ".", replacements))
end

---@param map GridMap
---@param enhancement_func fun(i:number):string
function applyEnhancement(map, enhancement_func)
	local list_points_to_apply = {}
	for y=map.min_y-1, map.max_y+1 do
		for x=map.min_x-1, map.max_x+1 do
			local c = enhancement_func(bin2dec(mapStringToBin(map:get3x3string(x,y))))
			table.insert(list_points_to_apply, {x=x, y=y, value=c})
		end
	end
	-- Set values to the map
	for _,point_value in ipairs(list_points_to_apply) do
		map:set(point_value.x, point_value.y, point_value.value)
	end
	if enhancement_func(0)=="#" then
		map.out_bounds_lit = not map.out_bounds_lit
	end
	return map
end

---@param enhancement_alg string
---@param input_image table
---@return number
function solvePart1(enhancement_alg, input_image)
	assert(type(enhancement_alg)=="string")
	local function enhancementFunc(i)
		local c = string.sub(enhancement_alg,i+1,i+1)
		assert(#c==1, "No valid value for i="..tostring(i))
		return c
	end
	local map = GridMap.new(input_image)
	print(string.format("Min x,y: %d,%d;\tMax x,y: %d,%d", map.min_x, map.min_y, map.max_x, map.max_y))
	printMap(map)
	-- Apply the image enhancement algorithm twice
	for i=1, 2 do
		print("Applying enhancement algorithm #"..tostring(i))
		applyEnhancement(map, enhancementFunc)
		printMap(map)
	end
	-- Get pixels lit
	-- Return the answer
	return map:getCountPixelsLit()
end

---@param input_iterable fun():string
local function parseInputData(input_iterable)
	io.write("Parsing input data... ") io.flush()
	local image_enhancement_algorithm = input_iterable()
	local input_image = {}
	input_iterable() -- discard second line which is empty
	for line in input_iterable do
		local row = {}
		for c in string.gmatch(line,"(%S)") do
			assert(c=="#" or c==".")
			table.insert(row, c)
		end
		table.insert(input_image, row)
	end
	print("Done.")
	return image_enhancement_algorithm, input_image
end

local function main(filename)
	assert(filename)
	local part1answer = solvePart1(parseInputData(io.lines(filename)))
	print("Part 1: answer", part1answer)
end

---@param test_input_file string
function test(test_input_file, expected_value)
	print("Running test...")
	local answer = solvePart1(parseInputData(io.lines(assert(test_input_file))))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	test("test_input.txt", 35) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
