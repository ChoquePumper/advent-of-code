-- Advent of Code 2021, day 16, part 2
local hex_to_bin = {
	["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
	["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
	["8"] = "1000", ["9"] = "1001", ["A"] = "1010", ["B"] = "1011",
	["C"] = "1100", ["D"] = "1101", ["E"] = "1110", ["F"] = "1111",
}

function bin2dec(bin_num)
	local num_digits = #bin_num
	assert(num_digits > 0)
	local res = 0
	for i=1, num_digits do
		res = res + (tonumber(bin_num:sub(i,i)) * 2^(num_digits-i))
	end
	return math.floor(res)
end

function packet2string(packet)
	local s = string.format("Packet: version %d, type_id %d", packet.version, packet.type_id)
	local s2 = {""}
	if packet.type_id==4 then
		table.insert(s2, packet[1])
	else
		table.insert(s2, "length_type_id "..packet.length_type_id)
		for i,v in ipairs(packet) do
			table.insert(s2, string.format("%d={%s}", i,packet2string(v)))
		end
	end
	return s .. table.concat(s2,", ")
end

function printPacket(packet)
	print(packet2string(packet))
end

function parsePacket(bin_string)
	--print("Parsing ", bin_string)
	local version = bin2dec( string.sub(bin_string, 1,3) )
	local type_id = bin2dec( string.sub(bin_string, 4,6) )
	--print("v",version, "t",type_id)
	local packet = { version=version, type_id=type_id, --[[i, i+1, ...]] }
	local p_end_at = 6 -- 3 bits for version + 3 bits for type ID
	local bits = bin_string:sub(p_end_at+1)
	if type_id == 4 then -- Packets with type ID 4 represent a literal value.
		local bin_num = {}
		local bits = bits .. string.rep("0", (#bits%4 > 0 and (4-#bits%4) or 0))
		local i = 5
		while i <= #bits do
			local group = bits:sub(i-4, i)
			table.insert(bin_num, group:sub(2))
			if group:sub(1,1)=="0" then
				break
			end
			i = i + 5
		end
		bin_num = bin2dec(table.concat(bin_num))
		packet[1] = bin_num
		p_end_at = p_end_at + i
	else -- Operator packet
		local length_type_id = assert(tonumber(bits:sub(1,1)))
		assert(length_type_id==1 or length_type_id==0)
		--print("length_type_id", length_type_id)
		packet.length_type_id = length_type_id
		local size_bits_len = (length_type_id==0 and 15 or 11)
		local bits_L = bin2dec(bits:sub(2,1+size_bits_len))
		--print("bits_L", bits_L, bits:sub(2,1+size_bits_len), size_bits_len)
		local packet_min_size = 11
		local remaining_bits = bits:sub(1+size_bits_len+1)
		p_end_at = p_end_at + 1 + size_bits_len
		if length_type_id==1 then -- Number of sub-packets
			local last_sub_packet_end_pos = 0
			for i=1, bits_L do
				local next_at = 1 + last_sub_packet_end_pos
				local bits_sub_packet = remaining_bits:sub(next_at)
				local sub_packet, ended_at = parsePacket(bits_sub_packet)
				table.insert(packet, sub_packet)
				last_sub_packet_end_pos = last_sub_packet_end_pos + ended_at
				p_end_at = p_end_at + ended_at
			end
		else -- Sub-packets within size
			remaining_bits = remaining_bits:sub(1,bits_L)
			local next_at = 1
			while next_at <= #remaining_bits do
				local bits_sub_packet = remaining_bits:sub(next_at)
				local sub_packet, ended_at = parsePacket(bits_sub_packet)
				table.insert(packet, sub_packet)
				next_at = next_at + ended_at
				p_end_at = p_end_at + ended_at
			end
		end
	end
	return packet, p_end_at
end

local function sumVerIDs(packet)
	if packet.type_id == 4 then
		return packet.version
	else
		local sum = packet.version
		for i,sub_packet in ipairs(packet) do
			sum = sum + sumVerIDs(sub_packet)
		end
		return sum
	end
end

function computePacket(packet)
	local operator = packet.type_id
	if operator == 4 then -- literal value
		return packet[1]
	elseif operator == 0 then -- sum
		local sum = 0
		for i,sub_packet in ipairs(packet) do
			sum = sum + computePacket(sub_packet)
		end
		return sum
	elseif operator == 1 then -- product
		local product = 1
		for i,sub_packet in ipairs(packet) do
			product = product * computePacket(sub_packet)
		end
		return product
	elseif operator == 2 then -- minimum
		local minimum = math.huge
		for i,sub_packet in ipairs(packet) do
			minimum = math.min(minimum, computePacket(sub_packet))
		end
		return minimum
	elseif operator == 3 then -- maximum
		local maximum = -math.huge
		for i,sub_packet in ipairs(packet) do
			maximum = math.max(maximum, computePacket(sub_packet))
		end
		return maximum
	elseif operator == 5 then -- greater than
		assert(#packet == 2, "This packet must have exactly two sub-packets. It has"..tostring(#packet))
		return computePacket(packet[1]) > computePacket(packet[2]) and 1 or 0
	elseif operator == 6 then -- less than
		assert(#packet == 2, "This packet must have exactly two sub-packets. It has"..tostring(#packet))
		return computePacket(packet[1]) < computePacket(packet[2]) and 1 or 0
	elseif operator == 7 then -- equal to
		assert(#packet == 2, "This packet must have exactly two sub-packets. It has"..tostring(#packet))
		return computePacket(packet[1]) == computePacket(packet[2]) and 1 or 0
	end
end

function solvePart2(input)
	local bin_string = string.gsub(input,"(%w)",hex_to_bin)
	local packet, ended_at = parsePacket(bin_string)
	--printPacket(packet)
	-- Return the answer
	return computePacket(packet)
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input = f:read("*a")
	f:close()
	local part2answer = solvePart2(input)
	print("Part 2: answer", part2answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart2(test_input)
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %s", expected_value))
end

if arg then
	local test_inputs = {
		{"C200B40A82", 3}, -- sum: 1, 2
		{"04005AC33890", 54}, -- product: 6, 9
		{"880086C3E88112", 7}, -- minimum: 7, 8, 9
		{"CE00C43D881120", 9}, -- maximum: 7, 8, 9
		{"D8005AC2A8F0", 1},
		{"F600BC2D8F", 0},
		{"9C005AC2F8F0", 0},
		{"9C0141080250320F1802104A08",1},
	}
	for i,test_input in ipairs(test_inputs) do
		test(test_input[1], test_input[2]) -- Run a test
	end
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
