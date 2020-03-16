io.open("DEBUG.lua",'w'):close() -- clears file

local string=string
local print = function (...)
    local f = io.open("DEBUG.lua","a+")
    f:write(tostring(...))
    f:close()
end


local parse_path = "language/test2.txt"

local file = [[]]

for line in io.lines(parse_path) do
    file = file..("\n"..line)
end

local tools = require("language/tools")

setmetatable({tools.file_table},{__index = function(t,k) t[k] = '' return t[k] end})
local file_table = tools.file_table

local gmatch_sf = tools.gmatch_start_finish
local find_closing_brace = tools.find_closing_brace
local find_closing_bracket = tools.find_closing_bracket --> ( line_num, bracket_pos )
local find_closing_square_bracket = tools.find_closing_square_bracket
local find_closing_pointy_bracket = tools.find_closing_pointy_bracket
local find_next_occurance = tools.find_next_occurance --> ( line_number, current_position, pattern )
local find_ending_string = tools.find_ending_string
local adaptive_gmatch_sf = tools.adaptive_gmatch_start_finish
local split = tools.split

for line in file:gmatch('[^\n]+') do
    file_table[#file_table+1] = line
end

local strings = {}
local str_ctr = 1
for i,line in pairs(file_table) do
    file_table[i] = line:gsub("%[[\"']%]", "??tostr??")
    for s,f in adaptive_gmatch_sf(i, "['\"]") do
        local type = file_table[i]:sub(s,f)
        local _,pos = find_ending_string(i, f, type)
        assert(_ == i, " Multi-line strings are not allowed.")
        local str = line:sub(s,pos)
        file_table[i] = line:sub(1,s-1).."<**"..tostring(str_ctr).."**>"..line:sub(pos+1)
        strings[str_ctr] = str
        str_ctr = str_ctr + 1
    end
    file_table[i] = file_table[i]:gsub("%?%?tostr%?%?", "[']")
end



-- Getting rid of lua keywords, extra parsing
do
    for i,line in pairs(file_table) do
        local l
        l=line:gsub("%Wlocal%W", "_NVlocal")
        l=l:gsub(":{", ":{;")
        l=l:gsub("break%W","_NV_break")
        l=l:gsub("elif", "elseif")
        l=l:gsub("repeat%W","_NVrepeat")
        l=l:gsub("until%W","_NVuntil")
        l=l:gsub("do%W","_NVdo")
        l=l:gsub("end%W","_NVend")
        l=l:gsub("then%W","_NVthen")
        l=l:gsub("local%W","_NVlocal")
        l=l:gsub("let%W","local")
        l=l:gsub("return%W","_NVreturn")
        l=l:gsub("->"," return ")
        l=l:gsub("(%W)f%(",function(str) return str:sub(1,1).."\\(" end)
        if l:sub(1,2) == "f(" then l = "\\("..l:sub(3) end
        file_table[i] = l
    end
end


-- Line breaks for ;;
do
    local i=1
    while #file_table >= i do
        local line = file_table[i]
        local st = line:find(";")
        if st then
            file_table[i] = line:sub(1,st-1)
            table.insert(file_table,i+1, line:sub(st+1))
        end
        i=i+1
    end
end


local operators = {"+","-","/","^","*","/%/"}

-- COMMENT PARSER
for i,line in ipairs(file_table) do
    -- comment parser
    do
        local comment_start = line:find("\\\\")
        if comment_start then
            file_table[i] = line:sub(1,comment_start-1)
        end
    end
    do
        if line:match("{") then
            split(i, line:find("{"))
        end
    end
end

-- PRE-BIG PARSER
for i,line in ipairs(file_table) do
    do
        if line:match("(.+)()") then

        end
    end
end

-- BIG PARSER!
for i,line in ipairs(file_table) do
    -- Syntax sugar for metamethods.
    do
        line = line:gsub("%[%+%]",".__add")
        line = line:gsub("%[%-%]",".__sub")
        line = line:gsub("%[%*%]",".__mul")
        line = line:gsub("%[%/%]",".__div")
        line = line:gsub("%[%/%/%]",".__idiv")
        line = line:gsub("%[%%%]",".__mod")
        line = line:gsub("%[%^%]",".__pow")
        line = line:gsub("%[#%]", ".__len")
        line = line:gsub("%[%?%]",".__index")
        line = line:gsub("%[=%]",".__newindex")
        line = line:gsub("%[%(%)%]",".__call")
        line = line:gsub("%['%]",".__tostring")
        line = line:gsub('%["%]',".__tostring")
        line = line:gsub("%[<%]",".__lt")
        line = line:gsub("%[<=%]",".__le")
        line = line:gsub("%[==%]",".__eq")
        line = line:gsub("%[%.%]",".__mode")
        file_table[i] = line
    end
    -- Syntax sugar allowing +=, -= etc.
    do
        local line = file_table[i]
        for _,v in ipairs(operators) do -- !!!   Enabling +=   !!!
            if line:match("%"..v.."%=") then
                line = line:gsub("%"..v.."%=", "%=".."%"..v) -- reverses, so now is  =+
                local var = line:sub(1, line:find("=")-1)
                line = line:gsub("=", "= "..var)
            end
        end
        file_table[i] = line
    end
    -- Syntax sugar   x ?= y  --->>>   x = x or y
    do
        local line = file_table[i]
        if line:find("?=",1,true) then
            local add_local = line:match("local ") or ""
            local temp = line:gsub("local ","")
            local var = temp:sub(1, temp:find("?")-1)
            line = add_local..var.." = "..var.." or "..line:sub(line:find("?=")+2)
        end
        file_table[i] = line
    end
    -- lists
    do
        local line = file_table[i]
        if line:match("([=*/^}{ %(%)])(%[)") then
            for s, f in adaptive_gmatch_sf(i, "([=*/^}{ %(%)])(%[)") do
                line = file_table[i]
                line = line:sub(1,s).." list( "..line:sub(f+1)
                file_table[i] = line
                local sq_line, sq_pos = find_closing_square_bracket(i, s+3)
                local temp = file_table[sq_line]
                file_table[sq_line] = temp:sub(1,sq_pos-1)..")"..temp:sub(sq_pos+1)
            end
        end
        if line:sub(1,1) == "[" then
            file_table[i] = "list("..line:sub(2)
            local sq_line,sq_pos = find_closing_square_bracket(i, 1)
            local temp = file_table[sq_line]
            file_table[sq_line] = temp:sub(1,sq_pos-1)..")"..temp:sub(sq_pos+1)
        end
    end
    -- sets (DEFINITELY UNFINISHED)
    do
        local line = file_table[i]
        if line:match("<<") then
            for s, f in adaptive_gmatch_sf(i, "<<") do
                line = file_table[i]
                line = line:sub(1,s-1).." set( "..line:sub(f+1)
                file_table[i] = line
                local b_line, b_pos = find_closing_pointy_bracket(i, s)
                local temp = file_table[b_line]
                print("b_line:  "..b_line)
                print("\nb_pos:  "..b_pos )
                file_table[b_line] = temp:sub(1,b_pos-2)..")"..temp:sub(b_pos+1)
            end
        end
        --[[
        if line:sub(1,2) == "<<" then
            file_table[i] = "set("..line:sub(2)
            local sq_line,sq_pos = find_closing_pointy_bracket(i, 1)
            local temp = file_table[sq_line]
            file_table[sq_line] = temp:sub(1,sq_pos-2)..")"..temp:sub(sq_pos+1)
        end
        ]]
    end
    -- static functions
    do
        local line = file_table[i]
        if line:match("\\%(") then
            for s,f in adaptive_gmatch_sf(i, "\\%(") do
                local line_num,to_end = find_closing_bracket(i,f)
                local l = file_table[line_num]
                file_table[line_num] = l:sub(1,to_end-1).." end) "..l:sub(to_end+1)
                local line = file_table[i]
                line = line:sub(1,s-1).." (function "..line:sub(f+1)
                file_table[i] = line
            end
        end
    end
    -- argless functions
    do
        local line = file_table[i]
        if line:match("!%(") then
            for s,f in adaptive_gmatch_sf(i, "!%(") do
                local line_num,to_end = find_closing_bracket(i,f)
                local l = file_table[line_num]
                file_table[line_num] = l:sub(1,to_end-1).." end) "..l:sub(to_end+1)
                local line = file_table[i]
                line = line:sub(1,s-1).." (function()"..line:sub(f+1)
                file_table[i] = line
            end
        end
    end
    -- iterator functions
    do
        local line = file_table[i]
        if line:match("(.+)(=)(.+)(%$%()") then
            for s,f in adaptive_gmatch_sf(i, "!%(") do
                local line_num,to_end = find_closing_bracket(i,f)
                local l = file_table[line_num]
                file_table[line_num] = l:sub(1,to_end-1).." end) "..l:sub(to_end+1)
                local line = file_table[i]
                line = line:sub(1,s-1).." (function()"..line:sub(f+1)
                file_table[i] = line
            end
        end
    end
    -- ! syntax for argless funcs (and calling argless funcs)
    do
        file_table[i] = file_table[i]:gsub("!","()")
    end
    --  special methods (MAY BE REMOVED)
    do
        local line = file_table[i]
        if line:match(":%(") then
            local var = "_NV_SELF"..tostring(_NV_COUNTER)
            local s,f = line:find(":%(")
            local line_end,pos_end = find_closing_bracket(i,f)
            local temp = file_table[line_num]
            file_table[line_end] = temp:sub(1,pos_end-1).."} end) "..temp:sub(pos_end+1)
            local line = file_table[i]

            line = line:sub(1,s-1).." (function("..var..")"..line:sub(f+1)
            file_table[i] = line
        end
    end

    --Pushing and popping scopes
    --!!!!!
    -- MAKE IT SO IT AUTOMATICALLY CHECKS WHETHER IT SHOULD USE _ENV OR setfenv!!!!!!!
    --!!!!!  (you can check version using _VERSION)
    do
        local line = file_table[i]
        if line:match("push") then
            local _,fi = line:find("push")
            local var = line:sub(fi+1)
            line = "local"..var.."="..var..
            " or {}\ntable.insert(STACK,"..var..")"..var..
            ".STACK = STACK\n_ENV=setmetatable("..var..",{__index=STACK[#STACK-1]})\n"
        elseif line:match("pop") then
            line = line:gsub("pop", "\n\nlocal _NV_C=#STACK\n_ENV=STACK[_NV_C-1]\nSTACK[_NV_C]=nil \n")
        end
        file_table[i] = line
    end
    --       object assignment syntax.  obj:{  .x = 10  }
    do
        local line = file_table[i]
        if line:match(":{") then
            local temp_colon_brace_pos,temp_open_brace_pos = line:find(":{")
            -- Finding var name
            local var
            if line:match"%Wlocal%W" then -- Temporarily removing "local"
                line = line:gsub("%Wlocal%W",function(str) return str:sub(1,1).."<$$$>"..str:sub(#str,#str) end)
            end
            local has_equals_sign = false
            if line:match"=" then
                has_equals_sign = true
                local eq = line:find("=")
                --local _,last_comma = line:sub(1,eq):find("[(,.+,)((%W)(local)(%W))]")
                local _,last_comma = line:sub(1,eq):find("(,.+,)")
                last_comma = last_comma or 1
                if last_comma == 1 then
                    var = line:sub(1,eq-1)
                else
                    var = line:sub(last_comma+1,eq-1)
                end
            else
                var = line:sub(1,temp_colon_brace_pos-1)
            end
            line = line:gsub("<%$%$%$>", "local")
            var=var:gsub(" ","")
            if has_equals_sign then
                file_table[i] = line:sub(1,temp_colon_brace_pos-1)
            else
                file_table[i] = ""
            end
            table.insert(file_table, i+1," do  "..line:sub(temp_open_brace_pos+1))
            local close_brace_line,close_brace_pos = find_closing_brace(i,temp_open_brace_pos)

            local n = i+1

            while n<=close_brace_line do
                line = file_table[n]

                local line_start_char = line:sub(1,2)

                if line_start_char:sub(1,1) == "." then
                    line = var..line
                elseif line_start_char:sub(1,1) == "[" then
                    line = var..line
                elseif line_start_char == "::" then
                    line = var..line:sub(3)
                elseif line_start_char:sub(1,1) == ":" then
                    line = var..line
                end
                line = line:gsub("::",var)

                line = line:gsub("([ =%({%+%-%*/%^%%><])(%.)",function(str) return str..var.."." end)
                line = line:gsub(":%(","<!<_NV_METHOD_DECLARE>!>")
                line = line:gsub("([ =%({%+%-%*/%^%%><])(:)",function(str) return str..var..":" end)
                line = line:gsub("<!<_NV_METHOD_DECLARE>!>",":(")
                file_table[n] = line

                if line:match(":%(") then
                    local _,brace_f = line:find(":%(")
                    n = find_closing_bracket(n, brace_f)
                end

                n=n+1
            end
            local close_brace_line,close_brace_pos = find_closing_brace(i,temp_open_brace_pos)
            local l = file_table[close_brace_line]
            file_table[close_brace_line] = l:sub(1,close_brace_pos-1).." end "..l:sub(close_brace_pos+1)

        end
    end
    -- object parent getting:  obj[@] = t  and t = obj[@]
    do
        local line = file_table[i]
        if line:match("%[@%]") then
            local temp_tabl = {}
            local temp_iter = 1
            for s,f in gmatch_sf(line, "%[@%]") do
                temp_tabl[temp_iter] = {s,f}
                temp_iter = temp_iter + 1
            end
            --for s,f in gmatch_sf(line,"%[@%]") do
            for indx=#temp_tabl,1,-1 do
                local s = temp_tabl[indx][1]
                local f = temp_tabl[indx][2]
                --local _,eq = line:sub(f+1):find("([^%.^%s^%w^%[^%]]+)(=)")
                local _,eq = line:sub(s):find("(%[@%])(%s+)(=)")
                if (eq) then
                    local eq_pos = line:find("=")
                    if line:find(",") then
                        error("Multi-assignments (a,b = b,a) not allowed with object[@] parent setting.")
                    end
                    local before_len = #line
                    line = "_NVsetmeta("..line:sub(1,s-1)..", "..line:sub(eq_pos+1)..")"
                    local after_len = #line
                else -- Will be ~=, ==, etc.
                    line = line:sub(1,s-1).."._NV"..line:sub(f+1)
                end
            end
        end
        file_table[i] = line
    end
end


table.insert( file_table, 1, " local STACK = {_NV_FILE_}\n\n\n\n")
table.insert(file_table, 1, "local _NV_FILE_ = setmetatable({}, {__index = _G})\n _ENV = _NV_FILE_\n")
file_table[#file_table+1] = "\n\n\n\nreturn STACK[#STACK]"

local long_str = ""
for k,v in pairs(file_table) do
    long_str = "\n"..long_str..v.."\n"
end
for i,v in pairs(strings) do
    long_str = long_str:gsub("<%*%*"..tostring(i).."%*%*>", v)
end

local final = io.open("DEBUG.lua","a+")
final:write(long_str)
final:close()