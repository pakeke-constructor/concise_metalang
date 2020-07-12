

assert( _G._CMW_MACROS, "no macro table found" )

local MACROS = _G._CMW_MACROS


--[[

First macro in the form:

#macro (macro) (replace with)

Also can make macros like this:

#macro (set_xyz($*$)) (local x,y,z = $*$)

* matches anything inbetween.
]]

local function make_macro(line)
    local endln



    return endln
end



return function( K )

    local endln

    for n, line in ipairs( K ) do

        if line:match("macro") then
            endln = make_macro( line )
        end

        for i = n, endln do
            K[i] = ''
        end
    end

end







