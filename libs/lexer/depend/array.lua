

local arr= {}

local arr_mt = {__index = arr;
                __newindex = function(t,_,v) t:add(v) end}




function arr.new(tabl)
    local new = setmetatable({len=0}, arr_mt)

    if tabl then
        for _,v in ipairs(tabl) do
            new:add(v)
        end
    end

    new.len = #new

    return new
end




function arr:add(item)
    self.len = self.len + 1
    rawset(self, self.len, item)
end



local er_1 = "index to pop out of range of array! Remember arrays cannot hold nil items"
function arr:pop(index)
    assert(self[index], er_1)
    self[index] = nil

    for i = index, self.len do
        self[i] = self[i + 1]
        self[i + 1] = nil
    end
end


-- { 1, 2, 3 }
-- { 1, 2, 3, 4 }

function arr:reverse()
    local len = self.len + 1
    for i = 1, math.ceil(arr.len/2) do
        arr[i], arr[len-i] = arr[len-i], arr[i]
    end
    return arr
end


function arr:copy()
    return arr.new(self)
end


return arr.new

