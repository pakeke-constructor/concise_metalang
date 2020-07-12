

local array = require("src.arrays.array")




return function( path )

    local file = io.open(path, "r")

    local lines = array()

    for line in io.readlines(file) do
        lines:add(line)
    end

    return lines
end


