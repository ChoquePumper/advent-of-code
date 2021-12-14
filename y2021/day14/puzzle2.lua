-- Advent of Code 2021, day 14, part 2
local pair_insertion_rules = {
  -- ["AB"] = "C", ...
}

local function getInsertion(pair)
	return pair_insertion_rules[pair]
end

local function getSidesOfPair(pair)
	assert(string.len(pair)==2)
	return pair:sub(1,1), pair:sub(2,2)
end

local Polymer; Polymer = {
	countElement = function(self, element)
		assert(string.len(element)==1)
		local l_count, r_count = 0, 0
		for pair,count in pairs(self.pairs_count) do
			local l,r = getSidesOfPair(pair)
			if l==element then l_count = l_count + count end
			if r==element then r_count = r_count + count end
		end
		if self.sides[1] == element then r_count = r_count+1 end
		if self.sides[2] == element then l_count = l_count+1 end
		return math.max(l_count, r_count)
	end,
	getAllElements = function(self)
		local elements = {}
		for pair,_ in pairs(self.pairs_count) do
			local l,r = getSidesOfPair(pair)
			elements[l] = true; elements[r] = true
		end
		local list = {}
		for element,_ in pairs(elements) do
			table.insert(list, element)
		end
		return list
	end,
	grow = function(self)
		local counts_to_change = {}
		for pair,count in pairs(self.pairs_count) do
			local ins = assert(getInsertion(pair), "No matching insertion for pair "..tostring(pair))
			local l,r = getSidesOfPair(pair)
			local pair1, pair2 = l..ins, ins..r
			counts_to_change[pair1] = (counts_to_change[pair1] or 0) + count
			counts_to_change[pair2] = (counts_to_change[pair2] or 0) + count
			counts_to_change[pair] = (counts_to_change[pair] or 0) - count
		end
		for pair,count in pairs(counts_to_change) do
			local set_to = (self.pairs_count[pair] or 0) + count
			assert(set_to >= 0, "Negative pairs? ("..tostring(set_to)..")")
			self.pairs_count[pair] = set_to
		end
	end,
	new = function(template)
		local pairs_count = {}
		for i=2, template:len() do
			local pair = template:sub(i-1, i)
			pairs_count[pair] = (pairs_count[pair] or 0) + 1
		end
		local self = setmetatable({
			template = template,
			pairs_count = pairs_count,
			sides = {template:sub(1,1), template:sub(#template)}
		}, Polymer)
		return self
	end
}
Polymer.__index = Polymer

function solvePart2(input_iterable, steps)
	local template = input_iterable():match("(%S+)")
	for line in input_iterable do if line:len()>0 then
		local pair, insertion = string.match(line, "(%w+) %-> (%w+)")
		assert(pair and pair:len()==2, "assertion failed: Line: "..line)
		assert(insertion and insertion:len()==1)
		pair_insertion_rules[pair] = insertion
	end end
	local polymer = Polymer.new(template)
	for i=1, steps do polymer:grow() end
	-- Get counts
	local quantity_least_common = math.huge
	local quantity_most_common = -math.huge
	for _,element in ipairs(polymer:getAllElements()) do
		local count = polymer:countElement(element)
		print(string.format("* ['%s'] = %d", element, count))
		quantity_least_common = math.min(quantity_least_common, count)
		quantity_most_common = math.max(quantity_most_common, count)
	end
	-- Return the answer
	return quantity_most_common - quantity_least_common
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part2answer = solvePart2(f:lines(), 40)
	f:close()
	print("Part 2: answer", part2answer)
end

local function stringLineIterator(text)
	return string.gmatch(text, "([^\n]+)")
end

function test(test_input, steps, expected_value)
	print("Running test...")
	local answer = solvePart2(stringLineIterator(test_input), steps)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[NNCB
	CH -> B
	HH -> N
	CB -> H
	NH -> C
	HB -> C
	HC -> B
	HN -> C
	NN -> C
	BH -> H
	NC -> B
	NB -> B
	BN -> B
	BB -> N
	BC -> B
	CC -> N
	CN -> C]]
	test(test_input, 40, 2188189693529) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
