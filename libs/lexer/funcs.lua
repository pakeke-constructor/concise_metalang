
local PATH = (...):gsub('%.[^%.]+$', '')


local LexObj = require(PATH..".lexObj")
local Token = require(PATH..".token")






local function tell(str)
    --[[
        Returns lexObj, start, finish of next lexObj on given string
    ]]
    local lexObjs = LexObj.lexObjs

    local top_matches = {}

    for pr = LexObj.max_priority, LexObj.min_priority, -1 do
        -- list of matches for this priority group
        local matches = { }

        -- Find match
        for _, lobj in lexObjs[pr] do
            local s, f = str:find(lobj.pattern)
            if s then
                table.insert(matches, {s=s,   f=f,
                                      str=str:sub(s,f),
                                      lobj=lobj}
                )
            end
        end

        -- Assert no conflicting matches
        local min_s = math.huge
        local winning_match = nil
        --[[
            Below here, this code goes through all LexObj matches
            and finds the match that is closest to the start of the string.
            if two matches have the same start location, and error is raised,
            as there is a confliction/
        ]]
        for _, match in ipairs(matches) do
            if min_s == match.s then
                return error(("Conflicting token matched: %s  ::  %s")
                             :format(winning_match.lobj.type, match.lobj.type))
            end

            if min_s > match.s then
                min_s = match.s
                winning_match = match
            end
        end
        -- Okay, so no problems. Add the top match.
        if winning_match then
            table.insert(top_matches, winning_match)
        end
    end

    local min_s = math.huge
    local best_match = nil

    for _, match in ipairs(top_matches) do
        if min_s > match.s then
            min_s = match.s
            best_match = match
        end
    end

    return best_match.lobj, best_match.s, best_match.f
end






local function insert(token, ins_tok)
    --[[
        inserts token into ASG after tok1

        ins_tok -> aft_tok
        ---->>>>
        ins_tok -> token -> aft_tok
    ]]
    local aft = ins_tok.next

    ins_tok.next = token
    token.last = ins_tok

    aft.last = token
end





local function push(ASG, token)
    --[[
        pushes token onto Abstract semantic graph
    ]]

    -- (insert will push onto ASG as its pretty much a doubly linked list)
    insert(ASG.last, token)

    -- Now special behaviour:
end





local function tok(lexObj, str, lnum)
    return Token(lexObj, str, lnum)
end




local nl_lobj = tell( "\n" )
local function newline(ASG, L, l_num)
    assert(L.current == l_num, "line number and current line conflict")

    local token = tok(nl_lobj, "\n", l_num)
    push(ASG, token)
    L.current = L.current + 1

    if l_num > L.len then
        return nil -- Have reached end of file. Don't push any more
    end

    if L[L.current]:gsub(" ", "") == "" then
        newline(ASG, L, l_num+1)
    end

    assert(L.current == l_num + 1, "line number and current line conflict")
    return l_num + 1, L[L.current]
end




local function expand(str)
    return " "..str.." "
end





local function next(token, type)
    --[[
        returns next token in ASG. (optional arg: `type`)
    ]]
    if type then
        local ntok = token.next
        if token.next then
            if type == ntok.lexObj.type then
                return ntok
            else
                next(ntok, type)
            end
        end
    else
        if token.next then
            return token
        end
    end
    return nil -- This means the token is the last in ASG!
end




local function last(token, type)
    --[[
        returns last token in ASG. (optional arg: `type`)
    ]]
    if type then
        local ntok = token.last
        if token.last then
            if type == ntok.lexObj.type then
                return ntok
            else
                last(ntok, type)
            end
        end
    else
        if token.last then
            return token
        end
    end
    return nil -- This means the token is the first in ASG!
end




local function dupe(tok)
    return tok(tok.lexObj, tok.str, tok.lnum)
end




local function syntax_error(ASG, line, err)
    local str = "in " .. ASG.filepath .. ", line "..tostring(line)..":\n"
    return str..err
end





local brackets = {
    ["("] = ")";
    ["<"] = ">";
    ["{"] = "}";
    ["["] = "]"
}
local function closer(token)
    --[[
        finds closing bracket token from opening bracket token
    ]]
    local found = false
    local type = token.str
    for _,e in pairs(brackets) do
        if e == type then
            found = true
            break
        end
    end
    if not found then
        error("This token is not a bracket...")
    end

    local find = brackets[type]

    local cur_tok = token
    local orig_tok = token

    while true do
        if not cur_tok.next then
            return syntax_error(orig_tok.line, "Closing bracket for "..type.." not found")
        elseif cur_tok.next.str == find then
            return cur_tok
        end
    end
end







return {
    tell = tell;
    insert = insert;
    tok = tok;
    newline = newline;
    expand = expand;
    next = next;
    last = last;
    dupe = dupe;
    syntax_error = syntax_error;
    closer = closer
}


