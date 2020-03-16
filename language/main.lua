




io.open("DEBUG.txt","w+"):close()
local print = function(...)
    local f = io.open("DEBUG.txt","a+")
    f:write("\n"..tostring(...))
    f:close()
end



--[[
global functions:
NV_setmeta --> To be used by engine only
NV_get_address --> To be used by engine only. Gets par identity.

object() --> to be used by user

]]



-- Global functions
do
    -- For special methods, keeps count of nested funcs to ensure argument signature is different.
    _NV_COUNTER = 0

    local function NV_setmeta(a,b)
        a.NV = b
        a.__index = a
        return setmetatable(a,b)
    end

    list = require('language/list')
    set = require("language/sets/sets")

    local t2at = {}
    local function NV_get_address(par)
        local addr = t2at[par]
        if addr == nil then
            addr = #t2at + 1
            t2at[par] = addr
            t2at[addr] = par
        end
        return addr
    end

    local function NV_to_string(a)
        return "<object {"..NV_get_address(a).."}>"
    end

    local NV_base_table = {__tostring=NV_to_string}

    _G.object = function(b)
        local a = {__tostring=NV_to_string}
        return NV_setmeta(a, b or NV_base_table)
    end
end


require("language/lang")


