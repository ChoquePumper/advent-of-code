-- Advent of Code 2021, day 17, part 1
local function step(x,y, vel_x,vel_y)
	local dest_x, dest_y = x+vel_x, y+vel_y
	-- Returns: x and y of destination point
	--        : the next x and y velocity (current-1)
	return dest_x, dest_y, math.max(0,vel_x-1), vel_y-1
end

local function checkHitX(x, area)
	local hit_on_x = area.x1 <= x and x <= area.x2
	local miss_by_x_left = x - area.x1
	local miss_by_x_right = x - area.x2
	local miss_by_x = not hit_on_x and (miss_by_x_left<0 and miss_by_x_left or miss_by_x_right) or 0
	return hit_on_x, miss_by_x
end

local function checkHitY(y, area)
	local hit_on_y = area.y1 <= y and y <= area.y2
	local miss_by_y_down = y - area.y1
	local miss_by_y_up = y - area.y2
	local miss_by_y = not hit_on_y and (miss_by_y_down<0 and miss_by_y_down or miss_by_y_up) or 0
	return hit_on_y, miss_by_y
end

local function checkHit(x,y, area)
	local hit_on_x, miss_by_x = checkHitX(x, area)
	local hit_on_y, miss_by_y = checkHitY(y, area)
	return hit_on_x and hit_on_y, miss_by_x, miss_by_y
end

local function shotProbe(vel_x, vel_y, area)
	local ever_hit, flag_stop = false, false
	local x,y = 0,0
	local max_y = 0
	while not flag_stop do
		x,y,vel_x,vel_y = step(x,y,vel_x,vel_y)
		max_y = math.max(max_y, y)
		local miss_by_x, miss_by_y
		ever_hit, miss_by_x, miss_by_y = checkHit(vel_x, vel_y, area)
		flag_stop = ever_hit or miss_by_x>0 or miss_by_y<0
	end
	return ever_hit, max_y
end

function solvePart1(target_x1, target_x2, target_y1, target_y2)
	assert(target_x1 < target_x2)
	assert(target_y1 < target_y2)
	local area = {x1=target_x1, x2=target_x2, y1=target_y1, y2=target_y2}
	print("area", area.x1, area.x2, area.y1, area.y2)
	local probe_x, probe_y = 0, 0
	-- Find possible initial x velocities
	local vel_x_t = {}
	local flag_stop = false
	local tmp_x, tmp_vel_x = 0, 1
	repeat
		tmp_x = tmp_x + tmp_vel_x
		local hit, miss_by_x = checkHitX(tmp_x, area)
		if hit then
			table.insert(vel_x_t, tmp_vel_x)
		end
		flag_stop = miss_by_x > 0
		tmp_vel_x = tmp_vel_x + 1
	until flag_stop
	assert(#vel_x_t > 0, "No initial x velocities found.")

	-- Find
	local max_vel_y = 0
	for _,vel_x in ipairs(vel_x_t) do
		local tmp_vel_y = math.abs(area.y1)-1
		for vel_y=tmp_vel_y, tmp_vel_y-math.abs(area.y2-area.y1), -1 do
			local hit, max_y = shotProbe(vel_x, vel_y, area)
			max_vel_y = math.max(max_vel_y, max_y) -- WHAT! How this line placed here solves the puzzle?
			if hit then
				print("Trying with:", vel_x, vel_y, max_y)
				max_vel_y = math.max(max_vel_y, max_y) -- <-- this line
			end
		end
	end
	-- Return the answer
	return max_vel_y
end

if _VERSION>="Lua 5.3" and not unpack then unpack = table.unpack end
function inputToParams(input)
	local params = {string.match(input,"target area: x=([%-]?%d+)%.%.([%-]?%d+), y=([%-]?%d+)%.%.([%-]?%d+)")}
	for i,value in ipairs(params) do
		params[i] = assert(tonumber(value))
	end
	return unpack(params)
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input = f:read("*a") -- A list with the values
	f:close() -- Close file
	local part1answer = solvePart1(inputToParams(input))
	print("Part 1: answer", part1answer)
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(inputToParams(test_input))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input = "target area: x=20..30, y=-10..-5"
	test(test_input, 45) -- Run a test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
