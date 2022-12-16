-- Advent Of Code 2022, day 15
require "common"
local Gridmap = require "day15.gridmap"
local Point = require "day15.point"
local MultipleRanges = require "day15.ranges"

---@class Sensor
---@field radio_closest_beacon integer|nil
---@field closest_beacon Point
local Sensor = {}; Sensor.__index = Sensor
setmetatable(Sensor, Point)

function Sensor:getRange(radio, rel_y) ---@return Range
	rel_y = rel_y or 0
	return {min=self.x-radio + math.abs(rel_y), max=self.x+radio - math.abs(rel_y)}
end

function Sensor:getVerticalRange(radio, rel_x) ---@return Range
	rel_x = rel_x or 0
	return {min=self.y-radio + math.abs(rel_x), max=self.y+radio - math.abs(rel_x)}
end

function Sensor.new(x,y)
	return setmetatable(Point.new(x,y), Sensor)
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local map, list_sensors, list_beacons = Gridmap.new({0,0},{0,0}), {}, {}
	for line in input_iterable do
		-- Sensor at x=3972136, y=2425195: closest beacon is at x=4263070, y=2991690
		local sensor_x, sensor_y, beacon_x, beacon_y = line:match(
			"Sensor at x=(%-?%d+), y=(%-?%d+): closest beacon is at x=(%-?%d+), y=(%-?%d+)")
		assert(sensor_x)
		local sensor = Sensor.new(sensor_x, sensor_y)
		map:set(sensor.x, sensor.y, "S")
		table.insert(list_sensors, sensor)

		local beacon = Point.new(beacon_x, beacon_y)
		if map:get(beacon:unpack()) ~= "B" then
			map:set(beacon.x, beacon.y, "B")
			table.insert(list_beacons, beacon)
		end
		sensor.closest_beacon = beacon
		local distance = beacon:distance(sensor)
		sensor.radio_closest_beacon = math.abs(distance.x) + math.abs(distance.y)
	end
	return map, list_sensors, list_beacons
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local map, list_sensors, list_beacons = parseInput(input_iterable)
	local y_pos = 2000000
	local total_ranges = MultipleRanges.new()
	for i,sensor in ipairs(list_sensors) do
		local range = sensor:getRange(sensor.radio_closest_beacon, sensor.y-y_pos)
		total_ranges:addRange(range)
	end
	local answer = 0
	for x,_ in total_ranges:walk() do
		answer = map:get(x,y_pos) ~= "B" and (answer+1) or answer
	end
	return answer
end

function createRange(list_sensors, y_pos)
	local res = MultipleRanges.new()
	for i,sensor in ipairs(list_sensors) do
		local range = sensor:getRange(sensor.radio_closest_beacon, sensor.y-y_pos)
		res:addRange(range)
	end
	return res
end

function createVerticalRange(list_sensors, x_pos)
	local res = MultipleRanges.new()
	for i,sensor in ipairs(list_sensors) do
		local range = sensor:getVerticalRange(sensor.radio_closest_beacon, sensor.x-x_pos)
		res:addRange(range)
	end
	return res
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local map, list_sensors, list_beacons = parseInput(input_iterable)
	local candate_points = {}
	print("map", map.min_y, map.min_y)
	for y_pos=0, 4000000 do -- Unlikely that the answer is at the border
		if y_pos%100000 == 0 then
			print("For block", "y_pos=", y_pos)
		end
		--print("Creating range")
		local row_total_ranges = createRange(list_sensors, y_pos)
		-- Check candidates
		local last_two_coords = {}
		for x,_ in row_total_ranges:walkForHoles() do
			print(x,y_pos)
			table.insert( candate_points, Point.new(x, y_pos) )
		end
	end

	print("candate_points length", #candate_points)
	local point_found = nil ---@type Point
	for _,point in ipairs(candate_points) do
		local col_total_ranges = createVerticalRange(list_sensors, point.x)
		if col_total_ranges:isValueInRange(point.y-1) and col_total_ranges:isValueInRange(point.y+1) then
			point_found = point
		end
	end
	assert(point_found, "No point found")
	print("Point found", point_found:unpack())
	local answer = point_found.x * 4000000 + point_found.y
	return answer
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 15, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end