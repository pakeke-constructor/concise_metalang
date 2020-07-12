

--- Data structure that allows O(1) removal at the cost of containing order.
-- Original by Tjakka5

local set = {}
set.__index = set

set.__newindex = function(s,_,v)
   s:add(v)
end

set.__len = function(s) return s.NV_len end


--- Creates a new set.
-- @treturn set; A new set
function set.new(...)
    local temp = {...}

    local new_set = setmetatable({
       objects  = {},
       pointers = {},
       NV_len   = #temp,
    }, set)

    for i=1,#temp do
       new_set:add(temp[i])
    end

    return new_set
end


-- Returns with set length
-- @treturn int; length of set
function set:length()
    return self.NV_len
end

--- Adds an object to the set.
-- Object must be of reference type
-- Object may not be the string 'NV_len'
-- @param obj Object to add
-- @treturn set self
function set:add(obj)
   local len = self.NV_len + 1

   self[len] = obj
   self[obj]  = len
   self.NV_len  = len

   return self
end

--- Removes an object from the set.
-- @param obj Object to remove
-- @treturn set self
function set:remove(obj)
   local index = self[obj]
   if not index then return end
   local NV_len  = self.NV_len

   if index == NV_len then
      self[NV_len] = nil
   else
      local other = self[NV_len]

      self[index] = other
      self[other] = index

      self[NV_len] = nil
   end

   self[obj] = nil
   self.NV_len = NV_len - 1

   return self
end

--- Clears the set completely.
-- @treturn set self
function set:clear()
   for i = 1, self.NV_len do
      local o = self[i]

      self[o] = nil
      self[i] = nil
   end

   self.NV_len = 0

   return self
end

--- Returns true if the set has the object.
-- @param obj Object to check for
-- @treturn boolean
function set:has(obj)
   return self[obj] and true or false
end

--- Returns the object at an index.
-- @number i Index to get from
-- @return Object at the index
function set:get(i)
   return self[i]
end

--- Returns the index of an object in the set.
-- @param obj Object to get index of
-- @treturn number index of object in the set.
function set:index(obj)
   if (not self[obj]) then
      error("bad argument #1 to 'set:index' (Object was not in set)", 2)
   end

   return self[obj]
end

return setmetatable(set, {
   __call = function(...)
      return set.new(...)
   end,
})


