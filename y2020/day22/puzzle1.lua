-- Day 22, part 1
if _VERSION < "Lua 5.2" and not table.unpack then table.unpack = unpack end
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end
local f_iter = f:lines()

function ReadDeck(f_iter)
	local deck = {}
	print("Reading deck:", f_iter())
	for line in f_iter do
		if #line < 1 then break; end
		local num = tonumber(line)
		assert(num)
		table.insert(deck,num)
	end
	assert(#deck > 0)
	return deck
end

local player1_deck = ReadDeck(f_iter)
local player2_deck = ReadDeck(f_iter)
f:close() -- close file

function Play(p1_deck, p2_deck)
	local function DrawCards()
		local p1_num = table.remove(p1_deck,1)
		local p2_num = table.remove(p2_deck,1)
		if	p1_num > p2_num then	return 1, p1_num, p2_num;
		elseif	p1_num < p2_num then	return 2, p1_num, p2_num;
		else	return 0, p1_num, p2_num;	end
	end
	local round = 0
	while #p1_deck>0 and #p2_deck>0 do
		round = round+1
		local result, num1, num2 = DrawCards()
		print("Round "..tostring(round), num1,num2)
		if result == 1 then
			table.insert(p1_deck,num1)
			table.insert(p1_deck,num2)
		elseif result == 2 then
			table.insert(p2_deck,num2)
			table.insert(p2_deck,num1)
		else
			error("Undefined behavior for result="..tostring(result),num1,num2)
		end
	end
	local winner
	if #p1_deck == 0 and #p2_deck > 0 then
		-- Player 2 wins
		winner = p2_deck
		winner.name = "Player 2"
	elseif #p2_deck == 0 and #p1_deck > 0 then
		-- Player 1 wins
		winner = p1_deck
		winner.name = "Player 1"
	else
		error("Something went wrong here")
	end
	print(string.format("%s wins!",winner.name))
	print("Winner's deck:", table.concat(winner,", ") )
	-- Calculate score
	local num_cards = #winner
	local score = 0
	for i=1,num_cards do
		score = score + winner[i] * (num_cards-(i-1))
	end
	return winner.name, score, round
end

local winner,score,rounds = Play(player1_deck,player2_deck)
print(string.format("%s wins after %d rounds with score %d",winner,rounds,score))