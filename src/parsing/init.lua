
local PATH = (...):gsub('%.[^%.]+$', '')

local parsing_funcs = {
    "macro";
    "send"
}


local parsing = {}

for _, v in ipairs(parsing_funcs) do
    parsing[v] = require(PATH..".".."v")
end




return parsing
