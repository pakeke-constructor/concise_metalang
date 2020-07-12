
local _T = {}

local syntaxError = _G._CMW_SYNTAXERROR


-- Custom iterator. This works, it has been tested.
function _T.gmatch_start_finish (str,pattern)
  local pos = 0
    return function()
        local s,f = str:find(pattern, pos+1)
        pos=f
        return s,f
    end
end



--gsub(pattern, repl)
-- Will return string with replaced in range.
function _T.gsub_range(str, pattern, repl, start, finish, func)
  local new = str:sub(start,finish):gsub(pattern,repl,func)
  return str:sub(1,start-1)..new..str:sub(finish+1)
end




--[[
  Finds position of closing bracket.
  bracket could be <, (, [, or {.
]]
local brackets = {
  ["("] = ")";
  ["<"] = ">";
  ["{"] = "}";
  ["["] = "]"
}

function _T.closer(K, lnum, pos, bracket) -- bracket optional argument
  bracket = bracket or K[lnum]
  local closer = brackets[bracket]

  local Klen = K.len
  for i = lnum, math.huge do
    if i > Klen then
      syntaxError("Missing ending bracket:  " .. bracket)
    end
    local str = K[i]
    local len = str:len()

    for ch_pos = 1, len do
      
    end

  end

  return lnum, pos
end




return _T
