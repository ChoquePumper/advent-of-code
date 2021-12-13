-- Advent of Code 2021, day 12, part 2
local Location; Location = {
	canVisitMoreThanOnce = function(self) return self.multiple_visit end,
	connectToLocation = function(self, location)
		assert(location and getmetatable(location)==Location)
		table.insert(self.connected_to, location)
	end,
	isSmallCave = function(self) return self.is_small_cave end,
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
	new = function(name, is_small_cave)
		assert(type(name)=="string")
		return setmetatable({
			is_small_cave = is_small_cave,
			name = name,
			multiple_visit = (not is_small_cave) and not(name=="start" or name=="end"),
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

local function getCountVisited(dict_visited, name)
	return dict_visited[name] or 0
end

local function canMark(location, dict_visited)
	local name = location:getName()
	local count = getCountVisited(dict_visited,name) --dict_visited[name]
	return location:canVisitMoreThanOnce() or (count < 1)
end

function findAllRoutes(location, dict_visited, trace, all_routes, rules)
	assert(location)
	dict_visited = dict_visited or {}
	trace = trace or {}
	all_routes = all_routes or {}
	rules = rules or {small_cave_visited_twice=nil}
	local location_name = location:getName()
	--print(location_name, dict_visited, #trace, #all_routes)
	--assert(os.execute("sleep 0.02")==0)
	--print(dict_visited[location_name])
	local count_visited = getCountVisited(dict_visited,location_name) + 1
	dict_visited[location_name] = count_visited
	--print("visited times:", count_visited)
	table.insert(trace, location_name)
	if location_name~="end" then
		local directions = location:getLocationsConnected()
		for name,location in pairs(directions) do if name~="start" then 
			if canMark(location, dict_visited) then
				--if location:isSmallCave() and name~="end" then
					--if not rules.small_cave_able_visit_twice then
					--	local rules = copyTable(rules)
					--	rules.small_cave_able_visit_twice=name  rules.visited_twice=false
					--	findAllRoutes(location, copyTable(dict_visited), copyTable(trace), all_routes, rules)
					--end
				--end
				findAllRoutes(location, copyTable(dict_visited), copyTable(trace), all_routes, rules)
			elseif location:isSmallCave() and name~="end" and not rules.small_cave_visited_twice then
				--rules.visited_twice = true
				findAllRoutes(location, copyTable(dict_visited), copyTable(trace), all_routes, {small_cave_visited_twice=name})
			end
		end end
	else
		--print("reached to end:", table.concat(trace,","))
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
		return string.upper(name) ~= name
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
	local routes = findAllRoutes(dict_locations["start"])
	--for i,route in ipairs(routes) do
	--	local k = table.concat(route,",")
	--	routes[k] = (routes[k] or 0) + 1
	--end
	--for k,count in pairs(routes) do if type(k)=="string" then
	--	print("*", k, count)
	--end end
	return #routes
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
	test(test_input1, 36) -- Run a test
	test(test_input2, 103) -- Run another test
	test(test_input3, 3509) -- and run one more test
	-- Run with the specified input file from argument 1
	if arg[1] then main(arg[1]) end
end
