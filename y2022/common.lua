
local can_use_posix, posix_time = pcall(require,"posix.time")

function isFunction(v) return type(v)=="function" end
function isNumber(v) return type(v)=="number" end
function isString(v) return type(v)=="string" end
function isTable(v) return type(v)=="table" end

function assertArgNumber(arg_i, arg_value, arg_name)
	return (assert(isNumber(arg_value),
		string.format("arg %d%s must be a number, got %s", arg_i, arg_name and (" "..arg_name) or "", type(arg_value))))
end

local function timeSpecToNumber(timespec)
	return timespec.tv_nsec / 1000000000 + timespec.tv_sec
end

---@param func function
function execFuncAndMeasureTime(func, ...)
	local start_timespec, end_timespec, ret
	local CLOCK_REALTIME, clock_gettime
	if not can_use_posix then
		print("'posix.time' module not available. Cannot measure time.")
	else
		clock_gettime = posix_time.clock_gettime
		CLOCK_REALTIME = posix_time.CLOCK_REALTIME
		start_timespec = clock_gettime(CLOCK_REALTIME)
	end
	ret = func(...)
	if can_use_posix then
		end_timespec = clock_gettime(CLOCK_REALTIME)
		print("Elapsed time:", timeSpecToNumber(end_timespec)-timeSpecToNumber(start_timespec))
	end
	return ret
end

---@param main_func fun(args:string[])
function runMainFunc(main_func)
	local args = _G.arg
	_G.arg = nil
	main_func(args)
	_G.arg = args
end