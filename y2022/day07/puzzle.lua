-- Advent Of Code 2022, day 07
require "common"

local function newDir()
	return {type="dir", contents={}}
end

---@param size integer
local function newFile(size)
	return {type="file", size=size}
end

local function getDirectory(filesystem_root, absolute_path)
	assert(absolute_path:find("/")==1)
	local current_dir = filesystem_root
	if absolute_path ~= "/" then
		for dirname in string.gmatch(absolute_path, "([^/]+)", 2) do
			current_dir = current_dir.contents[dirname]
			assert(current_dir, string.format("vfs:%s : No such directory", absolute_path))
		end
	end
	return current_dir
end

---@param input_iterable fun():string
local function parseInput(input_iterable)
	local filesystem_root = newDir()
	local current_dir = filesystem_root
	local current_path = "/"
	--local commands = {}
	local current_cmd
	---@param path string
	local function changeDirectory(path)
		if path == "/" then
			current_dir = filesystem_root
			current_path = "/"
		elseif path == ".." then
			print(current_path)
			local res_path = current_path:sub(1, current_path:find("/(%w+)$")-1)
			res_path = res_path=="" and "/" or res_path
			current_dir = getDirectory(filesystem_root, res_path)
			current_path = res_path
		else
			current_dir = current_dir.contents[path]
			current_path = current_path .. (current_path=="/" and "" or "/") .. path
			assert(current_dir, assert(current_dir, string.format("vfs:%s : No such directory", current_path)))
			assert(current_dir.type=="dir", path .. "is NOT a directory")
		end
	end
	local function interpretCommand(command)
		print(command[1], command[2])
		if command[1] == "cd" then
			changeDirectory( command[2] )
		elseif command[1] == "ls" then
			for _,line in ipairs(command.output_lines) do
				local col1, name = string.match(line, "(%w+)%s([%w%.]+)")
				if col1 == "dir" then
					current_dir.contents[name] = newDir()
				else
					local file_size = assert(tonumber(col1))
					current_dir.contents[name] = newFile(file_size)
				end
			end
		end
	end
	local count_line = 0
	for line in input_iterable do
		count_line = count_line + 1
		print("Parsing line", count_line)
		if line:find("$",1,true) == 1 then
			if current_cmd then
				--table.insert(commands, current)
				interpretCommand(current_cmd)
				current_cmd = nil
			end
			local command = {}
			for arg in line:sub(2):gmatch("(%S+)") do
				table.insert(command, arg)
			end
			current_cmd = command
			current_cmd.output_lines = {}
		else
			table.insert(current_cmd.output_lines, line)
		end
	end
	if current_cmd then
		interpretCommand(current_cmd)
	end
	return filesystem_root
end

local function getDirectorySize(directory)
	local total_size = 0
	for _,element in pairs(directory.contents) do
		if element.type == "dir" then
			total_size = total_size + getDirectorySize(element)
		else
			total_size = total_size + element.size
		end
	end
	directory.cached_total_size = total_size
	return total_size
end

---@param input_iterable fun():string
function solvePart1(input_iterable)
	local filesystem_root = parseInput(input_iterable)
	getDirectorySize(filesystem_root)
	local sum_sizes = 0
	local function addDirToList(directory)
		if directory.cached_total_size <= 100000 then
			sum_sizes = sum_sizes + directory.cached_total_size
		end
		for _,element in pairs(directory.contents) do
			if element.type == "dir" then
				addDirToList(element)
			end
		end
	end
	addDirToList(filesystem_root)
	return sum_sizes
end

---@param input_iterable fun():string
function solvePart2(input_iterable)
	local filesystem_root = parseInput(input_iterable)
	local filesystem_capacity = 70000000 -- 70 MB
	local free_space_required = 30000000 -- 30 MB
	local used_space = getDirectorySize(filesystem_root)
	print("Filesystem capacity", filesystem_capacity)
	print("Used space:       ", used_space)
	local current_free_space = filesystem_capacity - used_space
	print("Current free space:", current_free_space)
	local space_to_free_up = free_space_required - current_free_space
	print("Space to free up:", space_to_free_up)
	local selected_directory = filesystem_root
	local function selectDirectoryToDelete(directory)
		if directory.cached_total_size >= space_to_free_up then
			if directory.cached_total_size < selected_directory.cached_total_size then
				selected_directory = directory
			end
		end
		for _,element in pairs(directory.contents) do
			if element.type == "dir" then
				selectDirectoryToDelete(element)
			end
		end
	end
	selectDirectoryToDelete(filesystem_root)
	return selected_directory.cached_total_size
end

local function main(args)
	local input_file = assert(args[1])
	local solverFunction = _G[args[2]] ---@type function
	local result = execFuncAndMeasureTime(solverFunction, io.lines(input_file) )
	print("Day 07, "..args[2].." result:", result)
end

if _G.arg then runMainFunc(main) end