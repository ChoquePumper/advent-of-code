-- Advent of Code 2021, day 12, part 1
local Location; Location = {
	canVisitMoreThanOnce = function(self) return self.multiple_visit end,
	connectToLocation = function(self, location)
		assert(location and getmetatable(location)==Location)
		table.insert(self.connected_to, location)
	end,
	getLocationsConnected = function(self, as_list)
		if as_list then 
			return {unpack(self.connected_to)}
		end
		local dict_locations = {}
		for i,location in ipairs(self.connected_to) do
			dict_locations[location:getName()] = location
		end
		return dict_locations
	end,
	getName = function(self) return self.name end,
	new = function(name, multiple_visit)
		assert(type(name)=="string")
		assert(type(multiple_visit)=="boolean")
		if name=="start" then assert(multiple_visit==false) end
		return setmetatable({
			name = name,
			multiple_visit = multiple_visit,
			connected_to = {},
		}, Location)
	end
}
Location.__index = Location

function copyTable(t)
	local res = {}
	for k,v in pairs(t) do res[k] = v end
	return res
end

local function canMark(location, dict_visited)
	local name = location:getName()
	local count = dict_visited[name]
	return not count or location:canVisitMoreThanOnce() or (count < 1)
end

function findAllRoutes(location, dict_visited, trace, all_routes)
	assert(location)
	dict_visited = dict_visited or {}
	trace = trace or {}
	all_routes = all_routes or {}
	local location_name = location:getName()
	--print(location_name, dict_visited, #trace, #all_routes)
	--assert(os.execute("sleep 0.02")==0)
	--print(dict_visited[location_name])
	local count_visited = (dict_visited[location_name] or 0) + 1
	dict_visited[location_name] = count_visited
	--print("visited times:", count_visited)
	table.insert(trace, location_name)
	if location_name~="end" then
		local directions = location:getLocationsConnected()
		local trace_from_here = {}
		for name,location in pairs(directions) do
			if name~="start" and canMark(location, dict_visited) then
				findAllRoutes(location, copyTable(dict_visited), copyTable(trace), all_routes)
			end
		end
	else
		--print("reached to end")
		table.insert(all_routes, trace)
	end
	return all_routes
end

local function connectLocations(a, b)
	assert(a and b)
	a:connectToLocation(b)
	b:connectToLocation(a)
end

function solvePart1(input_table)
	local dict_locations = {}
	local function shouldBeMultipleVisit(name)
		return string.lower(name) ~= name
	end
	for _,line in ipairs(input_table) do
		local nameA, nameB = string.match(line, "(%w+)%-(%w+)")
		--print(line, nameA, nameB)
		local locationA = dict_locations[nameA] or Location.new(nameA, shouldBeMultipleVisit(nameA))
		local locationB = dict_locations[nameB] or Location.new(nameB, shouldBeMultipleVisit(nameB))
		dict_locations[nameA] = locationA
		dict_locations[nameB] = locationB
		connectLocations(locationA, locationB)
	end
	-- Return the answer
	return #findAllRoutes(dict_locations["start"])
end

function inputLinesToTable(input_iterable)
	local input_table = {} -- A list with the values
	for line in input_iterable do
		if string.len(line) > 1 then
			table.insert(input_table,line)
		end
	end
	return input_table
end

local function main(filename)
	local f = assert(io.open(filename)) -- Open file
	local input_table = inputLinesToTable(f:lines())
	f:close() -- Close file
	local part1answer = solvePart1(input_table)
	print("Part 1: answer", part1answer)
end

local function stringLineIterator(text)
	return string.gmatch(text,"([^\n]+)")
end

function test(test_input, expected_value)
	print("Running test...")
	local answer = solvePart1(inputLinesToTable(stringLineIterator(test_input)))
	print("Result from test:", answer)
	assert(answer==expected_value, string.format("Test failed! Expected value: %d", expected_value))
end

if arg then
	local test_input1 = [[start-A
						start-b
						A-c
						A-b
						b-d
						A-end
						b-end]]
	local test_input2 = [[dc-end
						HN-start
						start-kj
						dc-start
						dc-HN
						LN-dc
						HN-end
						kj-sa
						kj-HN
						kj-dc]]
	local test_input3 = [[fs-end
						he-DX
						fs-he
						start-DX
						pj-DX
						end-zg
						zg-sl
						zg-pj
						pj-he
						RW-he
						fs-DX
						pj-RW
						zg-RW
						start-pj
						he-WI
						zg-he
						pj-fs
						start-RW]]
	test(test_input1, 10) -- Run a test
	test(test_input2, 19) -- Run another test
	test(test_input3, 226) -- and run one more test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
