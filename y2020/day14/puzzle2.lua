
local input_file = arg[1]

-- functions
function numToBits(num, min_bits)
	min_bits = min_bits or 36
	local bits = ""
	while num > 0 do
		local remain = num % 2
		bits = tostring(remain) .. bits
		num = math.floor(num/2)
	end
	--return string.format("%036s", bits) -- actually the 0 doesn't work for formatting strings ('%s')
	return string.rep("0", min_bits-#bits) .. bits, #bits
end

function bitsToNum(bits)
	local total = 0
	for i=#bits, 1, -1 do
		total = total + tonumber(bits:sub(i,i)) * math.floor(2^(#bits-i))
	end
	return total
end

function applyMask(value, mask)
	assert(type(mask)=="string","Arg 2: mask must be a string (got "..type(mask)..")")
	assert(not string.find(mask,"[^01X]"), "Arg 2: invalid mask")
	local bits
	if type(value)=="number" then bits = numToBits(value);
	elseif type(value)=="string" then bits = numToBits(tonumber(value))
	else error("Arg 1: value's type isn't string or number")
	end
	
	local floating_bits_indexes = {}
	for i=#mask, 1, -1 do
		local mask_bit = mask:sub(i,i)
		if mask_bit ~= "0" then -- for part 2
			bits = bits:sub(1,i-1) .. mask_bit .. bits:sub(i+1)
			if mask_bit == "X" then
				table.insert(floating_bits_indexes, i)
			end
		end
	end
	return bits, floating_bits_indexes
		-- 2nd value = list of indexes of floating bits
end

function addressDecoderVer2(address, mask)
	--print("addressDecoderVer2", (numToBits(address)) )
	local address_bits, floating_bits_indexes = applyMask(address, mask)
	local total_combinations = math.floor(2^(#floating_bits_indexes))
	--print( "\tmask", "", mask )
	--print( "\taddress_bits", address_bits )
	--print( "\ttotal_combinations", total_combinations)
	if total_combinations == 1 then
		return { bitsToNum(address_bits) }
	end
	local list = {}
	for i=0, total_combinations-1 do
		local bits, num_bits = numToBits(i,#floating_bits_indexes)
		local combination = address_bits
		for j=1, #floating_bits_indexes do
			combination = combination:sub(1,floating_bits_indexes[j]-1) .. bits:sub(j,j) .. combination:sub(floating_bits_indexes[j]+1)
		end
		--print("*", combination )
		table.insert( list, bitsToNum(combination) )
	end
	return list
end

local mt_mem = {
	__newindex = function(self, address, value)
		--print("newindex metamethod.", mask)
		for i,address in ipairs(addressDecoderVer2(address,mask)) do
			rawset(self.actual_mem, address, value)
		end
	end,
	__index = function(self, address)
		-- if no value (nil) defined in address, return 0
		return self.actual_mem[address] or 0
	end,
}

-- global
mem = { actual_mem = {} }
mask = "000000000000000000000000000000000000"
setmetatable(mem, mt_mem)

-- Open the file
local f, err = io.open( input_file, "r" )
if not f then
	print("Error opening file "..input_file..":", err)	os.exit(1)
end
-- read the whole file
local file_content = f:read("*a")
f:close() -- close file

-- Set all mask values as string
local file_content = string.gsub(file_content,"mask = ([0-1X]+)", "mask = '%1'")

-- Load file_content as a lua script and run.
--Yeah. Why do I have to parse line by line if lua can do that for me? :)
if (_VERSION >= "Lua 5.3" and not loadstring) then loadstring = load; end
loadstring(file_content)()

-- Sum all values in memory
local total_sum = 0
for address,value in pairs(mem.actual_mem) do
	total_sum = total_sum+value
end

print("Answer:", total_sum)
