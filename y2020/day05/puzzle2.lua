

local input_file = arg[1]
-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)
	os.exit(1)
end

local seatIDs = {}
-- Read lines
for line in f:lines() do
	assert(line:len()==10,"This solution works only with 7 F/B chars + 3 L/R")
	local row1, row2, length = 0, 127, 128
	for i=1, 7 do
		local char = line:sub(i,i)
		length = math.ceil(length/2)
		if char=="F" then
			row2 = row2-length
		elseif char=="B" then
			row1 = row1+length
		end
	end
	assert(row1==row2, "row1==row2 is not true.")
	length = 8
	local col1, col2 = 0, 7
	for i=8, 10 do
		local char = line:sub(i,i)
		length = math.ceil(length/2)
		if char=="L" then
			col2 = col2-length
		elseif char=="R" then
			col1 = col1+length
		end
	end
	assert(col1==col2, "col1==col2 is not true.")
	
	-- Add IDs to a list (table)
	local seatID = row1*8+col1
	table.insert(seatIDs,seatID)
end
f:close()

table.sort(seatIDs)
--print( table.concat(seatIDs,",") ) -- for debug
-- Find the seat
local last_seatID = seatIDs[1]
for i=2, #seatIDs do
	local id = seatIDs[i]
	if id - last_seatID == 2 then
		print("Seat found:",id-1)
	end
	last_seatID = id
end
