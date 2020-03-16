
local list = {}
list.__index = list
list._NV = list
list.__newindex = function(t,_,v)
    t:add(v)
end
list.__len = function(t)
    return t.len 
end

list.new = function(...)
    return setmetatable({..., len=#{...}},list)
end

function list:add(value)
    self.len = self.len + 1
    self[self.len] = value
end

function list:reverse()
    local i,_i = 1,self.len
    while i < _i do
        self[i],self[_i] = self[_i],self[i]
        i = i+1
        _i = _i-1
    end
end

local tableremove = table.remove
function list:pop(index)
    local i = index or self.len
    tableremove(self, i)
    self.len = self.len - 1
end

local tableinsert = table.insert
function list:insert(item, index)
    tableinsert(self, index, item)
    self.len = self.len + 1
end



return list

