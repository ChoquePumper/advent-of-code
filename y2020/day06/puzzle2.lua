#!/usr/bin/env lua
local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end
local f_iter = f:lines() -- get iterator

-- Read lines
function ReadGroup() -- Copy/pasted partial code from day 4
	local line = f_iter()	-- read first line
	local letters = {}
	local num_questions = 0
	local num_people_in_group = 0
	while line and line:len() > 0 do
		num_people_in_group = num_people_in_group+1
		for char in string.gmatch(line,"(%a)") do -- for each char in line
			if not letters[char] then	letters[char] = 1
			else letters[char] = letters[char] + 1 -- count up
			end
		end
		line = f_iter() -- get next line
	end
	for letter, num in pairs(letters) do
		if num==num_people_in_group then
			num_questions = num_questions+1
		end
	end
	return num_questions, line==nil
end
-- Same logic from part 1
local stop = false
local i, sum_questions = 1, 0
print("Number of questions which everyone answered 'yes':")
while not stop do
	local num_questions, flag = ReadGroup()
	print(string.format("* For group %d: %d", i, num_questions))
	sum_questions = sum_questions+num_questions
	i, stop = i+1, flag
end
f:close()

print("Sum of the counts:", sum_questions)
