-- Advent of Code 2021, day 04, part 1
local Board; Board =  {
	getRowCol = function(self,sel_number)
		local index = assert(self:getIndexForNumber(sel_number))
		local row = math.ceil(index / self.columns)
		local col = 1 + (index-1) % self.columns
		return row, col
	end,
	getIndexForNumber = function(self,sel_number)
		local index = nil
		for i,num in ipairs(self.number_list) do
			if num == sel_number then
				index = i;	break
			end
		end
		return index
	end,
	checkRow = function(self,row)
		assert(row <= self.rows)
		local starting_index = (row-1) * 5 + 1
		print("checkRow", starting_index)
		for i=starting_index, starting_index+self.columns-1 do
			--print(i)
			if not self:getMarkByIndex(i) then
				return false
			end
		end
		return true
	end,
	checkColumn = function(self,col)
		assert(col <= self.columns)
		local starting_index = col
		print("checkColumn", starting_index)
		for i=starting_index, starting_index+((self.rows-1)*self.columns), self.columns do
			--print(i)
			if not self:getMarkByIndex(i) then
				return false
			end
		end
		return true
	end,
	getMark = function(self, sel_number)
		assert(self.marks[sel_number]~=nil, "Invalid number: "..tostring(sel_number))
		return self.marks[sel_number]
	end,
	getMarkByIndex = function(self, index)
		return self:getMark(self.number_list[index])
	end,
	getScore = function(self)
		local list = {}
		local score = 0
		for i,num in ipairs(self.number_list) do
			if not self:getMark(num) then
				table.insert(list, num)
				score = score+num
			end
		end
		return score, list
	end,
	mark = function(self, sel_number)
		if self.marks[sel_number]~=nil then
			self.marks[sel_number] = true
			return true
		end
		return false
	end,
	new = function(rows,columns,number_list)
		assert(type(number_list)=="table")
		rows = assert(tonumber(rows))
		columns = assert(tonumber(columns))
		assert(#number_list == rows*columns)
		local marks = {}
		for i,num in ipairs(number_list) do
			marks[num] = false
		end
		return setmetatable({
			marks = marks,
			number_list = number_list,
			num_count = #number_list,
			rows = rows, columns = columns,
		},Board)
	end,
}
Board.__index = Board

function ParseBoard(lines_table)
	local rows = #lines_table
	local columns = nil
	local number_list = {}
	for i,line_table in ipairs(lines_table) do
		local count = 0
		for num in string.gmatch(line_table,"(%S+)") do
			table.insert(number_list,tonumber(num))
			count = count+1
		end
		if not columns then columns = count
		else assert(count == columns) end
	end
	return Board.new(rows,columns, number_list)
end

function playBingo(random_numbers, boards)
	assert(#random_numbers > 0, "No random numbers given") assert(#boards > 1,"Not enough boards")
	print("Let's play bingo.")
	local winner_board = nil
	local winner_board_index = 0
	local win_at_number = nil
	local score = nil
	for i,num in ipairs(random_numbers) do
		-- num = next number
		-- Check every board
		print("Next number:", num, "(",i,")")
		for j,board in ipairs(boards) do
			local mark_success = board:mark(num)
			if mark_success then
				local row,col = board:getRowCol(num)
				local bingo_flag = board:checkRow(row) or board:checkColumn(col)
				if bingo_flag then
					winner_board, winner_board_index = board, j; win_at_number = num;
					print("BINGO! "..string.format("at number %d. Board #%d", num,j))
					break;
				end
			end
		end
		if winner_board then break end
	end
	if winner_board then
		score = winner_board:getScore() * win_at_number
		return true, winner_board_index, win_at_number, score
	end
	return false
end

function solvePart1(input_iterable)
	local line1 = input_iterable()
	local random_numbers = {}
	for num in string.gmatch(line1,"(%d+),?") do
		table.insert(random_numbers, assert(tonumber(num)))
	end
	input_iterable() -- Line 2 is empty. Discard
	local boards = {}
	local lines = {}
	local function addBoard(boards_list, lines)
		assert(#lines > 1)
		table.insert(boards_list, ParseBoard(lines))
	end
	for line in input_iterable do
		print(line)
		if #line<1 then -- Empty line
			print("add board")
			addBoard(boards, lines)
			lines = {}
		else
			print("add line", #line)
			table.insert(lines,line)
		end
	end
	if #lines > 0 then addBoard(boards, lines) end
	-- Play bingo
	local win_flag, board_index, ended_at_num, score = playBingo(random_numbers, boards)
	assert(win_flag, "No winner?")
	return score
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local part1answer = solvePart1(f:lines())
	f:close() -- Close file
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	local next_i = 1
	return function()
		if not next_i then return nil end
		local line = nil
		local found_at = string.find(text,"(\n)", next_i)
		if found_at then
			line = text:sub(next_i, found_at-1)
			next_i = found_at+1
		else
			line = text:sub(next_i)
			next_i = nil
		end
		return line
	end
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(stringLineIterator(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = [[7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7]]
	test(test_input, 4512) -- 188 * 24
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
