
local PATH = (...):gsub('%.[^%.]+$', ''):gsub(".lexBehaviour.","")

local LexObj = require(PATH..".lexBehaviour.lexObj")

--[[

How does this work??
A `LexObj` is created by passing in a table of the format:

local t = {
        pattern = "lua pattern match string",
        type = "TYPE",
        pr = <priority>
    }

LexObj(t)




list of types:

VAR         variable
BIND        binding to a variable (eg   obj.foo, .foo is BIND)
NL          newline
EQ          equals assignment
VAL         true, nil, false
SEP         field sep, ; or ,
OP          operator
GREEDY_OP   operator which requires evaluation of LHS and RHS first
            (==, ~=, +=, etc)
RESERVED    reserved keyword
MONAD       operators with 1 argument (eg,   -6,  `-` is monad)


Note that `pr` stands for priority.
High pr = favourability to get matched over 2 conflicting patterns

If a clash happens, (2 patterns are viable) an error should be raised.
]]

local LEXOBJS = {
    {
        pattern = "[%a_][%w_]+";
        type = "VAR";
        pr=1
    };
    {
        pattern = "[%.%:][%w_]+";
        type = "BIND";
        pr=1
    };
    {
        pattern = "\n";
        type = "NL";
        pr=1
    };
    {
        pattern = "%=";
        type = "EQ";
        pr=1
    };
    {
        --bool
        pattern = "^[%a_]true^[%w_]";
        type = "VAL";
        pr=1
    };
    {
        --bool
        pattern = "^[%a_]false^[%w_]";
        type = "VAL";
        pr=1
    };
    {
        -- nil
        pattern = "^[%a_]nil^[%w_]";
        type = "VAL";
        pr=1
    };
    {
        --number
        pattern = "%d[%.%dxe][%de]";
        type = "NUM";
        pr=1
    };
    {
        pattern = "%,";
        type = "SEP";
        pr=1
    };
    {
        pattern = "%;";
        type = "SEP";
        pr=1
    };
    {
        pattern = "%~";
        type = "MONAD";
        pr=1
    };
    {
        pattern = "^[%a_]and^[%w_]";
        type = "GREEDY_OP";
        pr=3
    };
    {
        pattern = "^[%a_]or^[%w_]";
        type = "GREED_OP";
        pr=3
    }
}

local OPEN_BR = {"(", "{", "["}
for _, br in ipairs(OPEN_BR) do
    table.insert(LEXOBJS,
    {
        pattern = "%" .. br;
        type = br
    })
end
local CLOSE_BR = {")", "]", "}"}
for _, br in ipairs(CLOSE_BR) do
    table.insert(LEXOBJS,
    {
        pattern = "%" + br;
        type = br;
        pr=1
    })
end


local OPS = {"*", "^", "/", "+", "-", "%"}
for _,op in ipairs(OPS) do
    table.insert(LEXOBJS,
    {
        pattern = "%" .. op .. "%=";
        type = "GREEDY_OP";
        pr=2
    })
    table.insert(LEXOBJS,
    {
        pattern = "%" .. op;
        type = "OP";
        pr=1
    })
end
local OPS2 = {"==", "~=", "<=", ">=", "and"}
for _, op in ipairs(OPS2) do
    table.insert(LEXOBJS,
    {
        pattern = "%" .. op:at(1) .. "%" .. op:at(2);
        type = "OP";
        pr=2
    })
end


local KEYWORD = {"lambda", "for", "while", "macro",
                "import", "export", "in", "as", "goto",
                "when", "unless", "elseif", "else", "label"}
for _, key in ipairs(KEYWORD) do
    table.insert(LEXOBJS,
    {
        pattern = "^[%a_]"..key.."^[%w_]";
        type = "RESERVED";
        pr=3
    })
end









for _, lobj in ipairs(LEXOBJS) do
    LexObj(lobj)
end
