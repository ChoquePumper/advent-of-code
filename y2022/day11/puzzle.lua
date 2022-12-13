-- Advent Of Code 2022, day 11
require "common"

-- Helpers

---@return fun(old:integer):integer
local function makeLambda(expr)
	print("local old = ...; return " .. expr)
	return (loadstring or load)("local old = ...; return " .. expr)
end

local function isDivisibleBy(num, div) return (num % div) == 0 end

---@class Monkey
---@field items integer[]
---@field operation fun(old:integer):integer
---@field test_divisible integer
---@field test_true_dest_monkey any
---@field test_false_dest_monkey any
---@field inspect_count integer
local Monkey = {}; Monkey.__index = Monkey

---@param starting_items integer[]
---@param operation_expr string
---@param test_divisible integer
---@param test_true_dest any
---@param test_false_dest any
function Monkey.new(starting_items, operation_expr, test_divisible, test_true_dest, test_false_dest)
	return setmetatable({
		items = starting_items,
		operation = makeLambda(operation_expr),
		operation_expr = operation_expr,
		test_divisible = test_divisible,
		test_true_dest_monkey = test_true_dest,
		test_false_dest_monkey = test_false_dest,
		inspect_count = 0,
	}, Monkey)
end

function Monkey:doOperation(i_item)
	self:set(i_item, self.operation( self:get(i_item) ) )
end

function Monkey:get(i_item) return self.items[i_item] end

function Monkey:set(i_item, value) self.items[i_item] = value; end

function Monkey:testAndThrow(i_item)
	local dest = isDivisibleBy(self:get(i_item), self.test_divisible) and self.test_true_dest_monkey or self.test_false_dest_monkey
	return dest, table.remove(self.items, i_item)
end

function Monkey:grab(item)
	table.insert(self.items, item)
end

---@param monkeys Monkey[]
local function playRound(monkeys)
	for i=0, #monkeys do
		local monkey = monkeys[i]
		print("Monkey", i)
		for _=1, #monkey.items do
			monkey.inspect_count = monkey.inspect_count + 1
			print("  Monkey inspects an item with a worry level of", monkey:get(1))
			monkey:doOperation(1)
			print("    Worry level changed", monkey.operation_expr, "now", monkey:get(1))
			monkey:set(1, math.floor(monkey:get(1) / 3) )
			print("    Monkey gets bored with item. Worry level is divided by 3 to", monkey:get(1))
			local dest_monkey, item = monkey:testAndThrow(1)
			monkeys[dest_monkey]:grab(item)
		end
	end
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local monkeys = {}
	for line in input_iterable do
		if line:len() > 0 then
			local i_monkey = assert(tonumber( line:match("Monkey (%w+):") ))
			local starting_items = {}
			-- Get starting items
			local line_items = input_iterable()
			local _, end_label = line_items:find("  Starting items: ", 1, true)
			assert(_)
			for item in line_items:sub(end_label+1):gmatch('([^,]+)') do
				item = assert(tonumber(item))
				table.insert(starting_items, item)
			end
			-- Line Operation
			local line_op = input_iterable()
			_, end_label = line_op:find("  Operation: ", 1, true)
			assert(_)
			local operation_expr = line_op:sub(end_label+1):match("new = (.+)$")
			-- Test
			local test_divisible = input_iterable():match("  Test: divisible by (%d+)")
			test_divisible = assert(tonumber(test_divisible))
			local test_if_true = input_iterable():match("    If true: throw to monkey (%d+)")
			test_if_true = assert(tonumber(test_if_true))
			local test_if_false = input_iterable():match("    If false: throw to monkey (%d+)")
			test_if_false = assert(tonumber(test_if_false))

			monkeys[i_monkey] = Monkey.new(
				starting_items, operation_expr,
				test_divisible, test_if_true, test_if_false
			)
		end
	end
	return monkeys
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local monkeys = parseInput(input_iterable)
	for i=1, 20 do
		playRound(monkeys)
	end
	-- Find the 2 most active
	local list = {} ---@type Monkey[]
	for _,monkey in pairs(monkeys) do
		table.insert(list, monkey)
	end
	-- Sort
	table.sort(list, function(a,b) return a.inspect_count > b.inspect_count end)
	print(list[1].inspect_count, list[2].inspect_count, list[3].inspect_count, list[4].inspect_count)
	return list[1].inspect_count * list[2].inspect_count
end

---@param monkeys Monkey[]
local function playRoundPart2(monkeys)
	for i=0, #monkeys do
		local monkey = monkeys[i]
		--print("Monkey", i)
		for _=1, #monkey.items do
			monkey.inspect_count = monkey.inspect_count + 1
			--print("  Monkey inspects an item with a worry level of", monkey:get(1))
			monkey:doOperation(1)
			--print("    Worry level changed", monkey.operation_expr, "now", monkey:get(1))
			--monkey:set(1, math.floor(monkey:get(1) / 3) )
			--print("    Monkey gets bored with item. Worry level is divided by 3 to", monkey:get(1))
			local dest_monkey, item = monkey:testAndThrow(1)
			monkeys[dest_monkey]:grab(item)
		end
	end
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local monkeys = parseInput(input_iterable)
	for i=1, 10000 do
		print("Playing round", i)
		playRoundPart2(monkeys)
	end
	-- Find the 2 most active
	local list = {} ---@type Monkey[]
	for _,monkey in pairs(monkeys) do
		table.insert(list, monkey)
	end
	-- Sort
	table.sort(list, function(a,b) return a.inspect_count > b.inspect_count end)
	print(list[1].inspect_count, list[2].inspect_count, list[3].inspect_count, list[4].inspect_count)
	return list[1].inspect_count * list[2].inspect_count
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 11, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end