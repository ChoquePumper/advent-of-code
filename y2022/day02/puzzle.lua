-- Advent Of Code 2022, day 02
require "common"
---@alias shape '"rock"'|'"paper"'|'"scissors"'
---@alias result '"win"'|'"lose"'|'"draw"'
local guide_opponent = { ["A"] = "rock", ["B"] = "paper", ["C"] = "scissors" }
local guide_you = { ["X"] = "rock", ["Y"] = "paper", ["Z"] = "scissors" }
local shape_defeats_to = { -- rock -> scissors -> paper -> rock -> ...
	["rock"] = "scissors",    ["paper"] = "rock",    ["scissors"] = "paper",
}

---@return result
local function play(you,opponent)
	assert(shape_defeats_to[you]~=nil)
	assert(shape_defeats_to[opponent]~=nil)
	if shape_defeats_to[you] == opponent then
		return "win"
	elseif shape_defeats_to[opponent] == you then
		return "lose"
	else
		return "draw"
	end
end
---@param result result
local function getPointsByResult(result)
	if     result=="win" then return 6
	elseif result=="draw" then return 3
	elseif result=="lose" then return 0
	else error("Unknown result: "..tostring(result))
	end
end

local function getPointsByShape(shape)
	if     shape=="rock" then return 1
	elseif shape=="paper" then return 2
	elseif shape=="scissors" then return 3
	else error("Unknown shape: "..tostring(shape))
	end
end

---@param line string -- Line format: "A B"
local function parseLine(line)
	-- Split between the space
	local opponent, you = string.match(line, "(%w+) (%w+)")
	return opponent, you
end

---@param input_iterable function
function solvePart1(input_iterable)
	local points = 0
	for line in input_iterable do
		local opponent, you = parseLine(line)
		assert(you) assert(opponent)
		local result = play(guide_you[you], guide_opponent[opponent])
		points = points + getPointsByShape(guide_you[you]) + getPointsByResult(result)
	end
	return points
end

---@param you
---| '"X"' # to lose
---| '"Y"' # to draw
---| '"Z"' # to win
---@return shape
local function resolveShape(you, opponent)
	assert(opponent)
	if you == "X" then
		return shape_defeats_to[guide_opponent[opponent]]
	elseif you=="Y" then
		return guide_opponent[opponent]
	elseif you=="Z" then
		return shape_defeats_to[shape_defeats_to[guide_opponent[opponent]]]
	else
		error("Unknown column value: "..tostring(you))
	end
end

---@param input_iterable function
function solvePart2(input_iterable)
	local points = 0
	for line in input_iterable do
		local opponent, you = parseLine(line)
		assert(you) assert(opponent)
		-- the second column says how the round needs to end
		you = resolveShape(you, opponent)
		local result = play(you, guide_opponent[opponent])
		points = points + getPointsByShape(you) + getPointsByResult(result)
	end
	return points
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 02, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end