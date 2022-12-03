-- Helpers
require "common"

---@param puzzle_luafile string -- The path to the lua file that solves the puzzle
---@param input_file string
---@param funcname string
---@param expected_answer any
---@return boolean, any -- Returns a boolean value whether the answer returned by the puzzle matches to the expected_answer value + the answer returned by the puzzle
function test_puzzle(puzzle_luafile, input_file, funcname, expected_answer, extra_param)
	assert( isString(input_file) and input_file:len()>0, "an input file must be set" )
	assert( isString(funcname) and funcname:len()>0, "funcname must tell the name of the function from puzzle_luafile that solves the puzzle" )
	-- Convert params to a number if possible
	expected_answer = tonumber(expected_answer) or expected_answer
	extra_param = tonumber(extra_param) or extra_param
	-- Load and run the file. It must have a global function called funcname
	dofile(puzzle_luafile)
	local solvePuzzleFunc = _G[funcname]
	assert(isFunction(solvePuzzleFunc), "no global function '"..funcname.."' found in lua file")
	print("Running test...")
	local ret = solvePuzzleFunc( io.lines(input_file), extra_param )
	print("End of function")
	return ret == expected_answer, ret
end

---@param arg string[]
local function main(arg)
	local lua_file = arg[1]
	local input_file = arg[2]
	local solver_funcname = arg[3]
	local expected_answer = arg[4]
	local extra_param = arg[5]
	print("Test:", lua_file)
	print("Input file:", input_file)
	local success, res, answer = xpcall(test_puzzle, debug.traceback,
		lua_file, input_file, solver_funcname, expected_answer, extra_param)
	if success then
		print("Result:", answer, type(answer))
		print("Expected answer:", arg[4])
		if res then
			print("Test success!")
		else
			print("Test failed!")
			os.exit(1)
		end
	else
		print("Error during the test.")
		print(res)
		os.exit(2)
	end
end
if _G.arg then runMainFunc(main) end
