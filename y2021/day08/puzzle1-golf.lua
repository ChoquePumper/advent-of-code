-- Advent of Code 2021, day 08, part 1 (golf)
local c=0 for l in io.lines(arg[1]) do for w in l:sub(l:find("|")+1):gmatch("%S+") do if({0,2,3,4,0,0,7})[#w]==#w then c=c+1 end end end print(c)
