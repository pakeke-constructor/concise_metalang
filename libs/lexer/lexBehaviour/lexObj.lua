
local PATH = (...):gsub('%.[^%.]+$', '')
local Token = require(PATH..".token")

local LexObj = {
    -- The max priority a token takes
    max_priority = -math.huge;
    -- The min priority a token takes
    min_priority = math.huge;
}


--2d array
-- This array is 2d, with the first index holding the priority of the lex obj
LexObj.lexObjs = setmetatable({}, {__index = function(t,k)
    t[k] = {} return t[k]
end})

-- keyworded lexobjs to type
LexObj.keyLexObjs = { }



function LexObj.new(_, tab, str)
    --[[
        tab of form:

        {
            pattern = "[%.%:%a_][%w_]+"
            type = "VAR"
            index = nil
            str = str
        }
    ]]

    -- modify max and min priority so can loop over easily
    LexObj.max_priority = math.max(LexObj.max_priority, tab.pr)
    LexObj.min_priority = math.min(LexObj.min_priority, tab.pr)

    tab.str = str

    local lobj = setmetatable(
        tab,
        LexObj
    )
    table.insert(LexObj.tokens[lobj.pr], lobj)
    return lobj
end


function LexObj:token(str, lnum)
    return Token:new(self,str, lnum)
end



return setmetatable(LexObj, {__call = LexObj.new})
