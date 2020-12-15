
local input_file = arg[1]

-- functions
function numToBits(num)
	local bits = ""
	while num > 0 do
		local remain = num % 2
		bits = tostring(remain) .. bits
		num = math.floor(num/2)
	end
	--return string.format("%036s", bits) -- actually the 0 doesn't work for formatting strings ('%s')
	return string.rep("0", 36-#bits) .. bits
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
	
	for i=#mask, 1, -1 do
		local mask_bit = mask:sub(i,i)
		if mask_bit ~= "X" then
			bits = bits:sub(1,i-1) .. mask_bit .. bits:sub(i+1)
			--print(bits)
		end
	end
	return bits
end

local mt_mem = {
	__newindex = function(self, address, value)
		--print("newindex metamethod.", mask)
		rawset(self.actual_mem, address, bitsToNum(applyMask(value,mask)))
	end,
	__index = function(self, address)
		-- if no value (nil) defined in address, return 0
		return self.actual_mem[address] or 0
	end,
}

-- global
mem = { actual_mem = {} }
mask = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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

-- Load file_content as lua script and run.
--Yeah. Why do I have to parse manually line by line if lua can do it for me? :)
if (_VERSION >= "Lua 5.3" and not loadstring) then loadstring = load; end
loadstring(file_content)()

-- Sum all values in memory
local total_sum = 0
for address,value in pairs(mem.actual_mem) do
	total_sum = total_sum+value
end

print("Answer:", total_sum)
