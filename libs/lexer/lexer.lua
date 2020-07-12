
local PATH = (...):gsub('%.[^%.]+$', '')


local funcs = require(PATH..".funcs")




function string:at(i)
    return self:sub(i,i)
end

function string:rem(a,b)
    --[[
        returns a string, minus the stuff between a,b
    ]]
    return self:sub(1,a) .. self:sub(b, self:len())
end



local function lex(L)

end








string.at = nil
string.rem = nil


return lex