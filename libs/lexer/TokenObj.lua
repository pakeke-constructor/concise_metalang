--[[

Token objs are created from lexobjs




]]

local PATH = (...):gsub('%.[^%.]+$', '')
local LexObj = require(PATH..".lexObj")



local Token = {}
local Token_mt = {__index = Token}



function Token:new(lexObj, str, lnum)
    --[[
        Token object is pretty much
        a doubly linked list node.
    ]]
    return setmetatable(
        {
            -- line number
            lnum = lnum;

            -- Parent lexObj
            lexObj = lexObj;

            -- next token
            next = nil;
            -- last token
            last = nil;

            -- matched string
            str = str;

            -- Current push state. This will only be set to a value
            -- if the token opens a branch, ie if the token is
            -- <FUNC_START>, push state will be derived from current AST state
            state = nil
        },
        Token_mt
    )

end




return Token
