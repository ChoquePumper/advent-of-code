-- Day 25, part 1
local card_publickey =  5764801
local door_publickey = 17807724

local input_file = arg[1]
if input_file then
	-- Open the file
	local f, err = io.open( input_file, "r" )
	if not f then
		print("Error opening file "..input_file..":", err)	os.exit(1)
	end
	card_publickey = tonumber( f:read("*l") )
	door_publickey = tonumber( f:read("*l") )
	f:close()
	assert(card_publickey, "Invalid card's public key from file.")
	assert(door_publickey, "Invalid door's public key from file.")
end

local devices = {
	card = {
		public_key = card_publickey,
		loop_size = -1,
	},
	door = {
		public_key = door_publickey,
		loop_size = -1,
	}
}

function PerformHandshake(initial_value, subject_number)
	return (initial_value * subject_number) % 20201227
end
local card_handshake = 1
local loop_size = 0
while card_handshake ~= card_publickey do
	loop_size = loop_size + 1
	card_handshake = PerformHandshake( card_handshake, 7 )
end
devices.card.loop_size = loop_size
print("Card's loop size: "..tostring(loop_size), card_handshake)

local door_handshake = 1
loop_size = 0
while door_handshake ~= door_publickey do
	loop_size = loop_size + 1
	door_handshake = PerformHandshake( door_handshake, 7 )
end
devices.door.loop_size = loop_size
print("Door's loop size: "..tostring(loop_size), door_handshake)

-- Get encryption key
local encryption_key = 1
for i=1, devices.card.loop_size do
	encryption_key = PerformHandshake(encryption_key, devices.door.public_key)
end
print("Encryption key:", encryption_key)

encryption_key = 1
for i=1, devices.door.loop_size do
	encryption_key = PerformHandshake(encryption_key, devices.card.public_key)
end
print("Encryption key:", encryption_key)
