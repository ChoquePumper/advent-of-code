-- Advent of Code 2021, day 21, part 1

local function newDeterministicDie()
	local num, count_roll = 1, 0
	return function(a)
		if a=="query_roll" then
			return count_roll
		end
		local ret = num
		num = 1 + num%100
		count_roll = count_roll+1
		return ret
	end
end

---@class Board
local Board = {}
Board.__index = Board
function Board:getPosFrom(from, spaces)
	return 1 + (from-1+spaces) % #self
end
function Board:getScore(pos) return self[pos] end
function Board.new()
	return setmetatable({1,2,3,4,5,6,7,8,9,10}, Board)
end

---@class Player
---@field board Board
---@field score number
---@field pawn_pos number
local Player = {}
Player.__index = Player
---@param die fun():number
function Player:playTurn(die)
	-- Roll dice 3 times
	local spaces = 0
	for i=1, 3 do
		spaces = spaces + die()
	end
	-- Move
	self.pawn_pos = self.board:getPosFrom(self.pawn_pos, spaces)
	-- Add score
	self:addScore(self.board:getScore(self.pawn_pos))
	return self
end
function Player:addScore(amount)
	self.score = self.score + amount
	return self:getScore()
end
function Player:getScore() return self.score end
function Player.new(board, starting_pos)
	return setmetatable({board=board, score=0, pawn_pos=starting_pos}, Player)
end

function solvePart1(input_iterable)
	local board = Board.new()
	local players = {next=1}
	local die = newDeterministicDie()
	local reach_score_to_win = 1000
	for line in input_iterable do
		if line:len()>0 then
			local i_player, pos = line:match("Player (%d+) starting position: (%d+)")
			pos = assert(tonumber(pos))
			table.insert(players, Player.new(board, pos))
		end
	end
	assert(#players == 2)
	---@return Player, number
	local function nextPlayer(players)
		local i = players.next
		local pl = players[i]
		players.next = 1 + players.next % #players
		return pl, i
	end
	-- Play the game
	local winner, i_winner = nil, nil
	while not winner do
		local pl,i = nextPlayer(players)
		if pl:playTurn(die):getScore() >= reach_score_to_win then
			winner, i_winner = pl, i
		end
	end
	local loser = players[players.next]
	-- Return the answer
	return loser:getScore() * die("query_roll")
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close()
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	return string.gmatch(text, "([^\n]+)")
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[Player 1 starting position: 4
	Player 2 starting position: 8]]
	test(test_input, 739785) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
