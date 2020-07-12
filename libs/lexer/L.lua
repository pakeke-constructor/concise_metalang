
local PATH = (...):gsub('%.[^%.]+$', '')

local array = require(PATH..".depend.array")

return array()



