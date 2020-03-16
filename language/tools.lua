

local t={file_table={}}

-- Custom iterator. This works, it has been tested.
t. gmatch_start_finish = function(str,pattern)
    local pos = 0
    return function()
        local s,f = str:find(pattern, pos+1)
        pos=f
        return s,f
    end
end

-- Cuts a string at a certain position
t. split = function(line, position)
  local file_table = t.file_table
  local l = file_table[line]
  file_table[line] = l:sub(1,position)
  table.insert(file_table, line+1, l:sub(position+1))
end

--gsub(pattern, repl)
-- Will return string with replaced in range.
function string:
  gsub_range
  (pattern, repl, start, finish, func)
  local str = self:sub(start,finish):gsub(pattern,repl,func)
  return self:sub(1,start-1)..str..self:sub(finish+1)
end



-- adaptive/dynamical version of above
t.  adaptive_gmatch_start_finish = function(line_number, pattern)
    local pos = 0
    local tabl = t.file_table
    return function()
      local s,f = tabl[line_number]:find(pattern, pos+1, false)
      pos = f
      return s,f
    end
end





function t.  find_closing_brace( line_num, brace_pos )
  local tabl = t.file_table
  local ctr = 1 -- ctr = counter; how many braces we need to find.

  -- First iteration (to account for starting position.)
  local start = tabl[line_num]:sub(brace_pos+1)
  -- gmatch_sf is custom iterator that returns start/finish pos of all matches.
  for st,fi in t.gmatch_start_finish(start, "[%{%}]") do
     if start:sub(st,st) == "{" then
        ctr = ctr + 1  -- Push.
     else
        ctr = ctr - 1  -- Else pop.
     end
     if ctr == 0 then return line_num, st+brace_pos end
  end

  for line=line_num+1, #tabl do
  -- Do not want to keep looking for brace after tabl end, in case there is no closer.
    local str = tabl[line]

    for s,f in t.gmatch_start_finish(str,"[%{%}]") do
      if str:sub(s,f) == "{" then
          ctr = ctr + 1 -- Push,
      else
          ctr = ctr - 1  -- Else pop.
      end
      if ctr == 0 then return line, s end
    end
  end
  error("No closing brace was found, starting from line: \n"..tostring(line_num))
end


function t.  find_closing_bracket( line_num, bracket_pos )
    local tabl = t.file_table
    local ctr = 1 -- ctr = counter; how many braces we need to find.

    -- First iteration (to account for starting position.)
    local start = tabl[line_num]:sub(bracket_pos+1)
    -- gmatch_sf is custom iterator that returns start/finish pos of all matches.
    for st,_ in t.gmatch_start_finish(start, "[%(%)]") do
       if start:sub(st,st) == "(" then
          ctr = ctr + 1  -- Push.
       else
          ctr = ctr - 1  -- Else pop.
       end
       if ctr == 0 then return line_num, st+bracket_pos end
    end

    for line=line_num+1, #tabl do
    -- Do not want to keep looking for brace after tabl end, in case there is no closer.
      local str = tabl[line]

      for s,f in t.gmatch_start_finish(str,"[%(%)]") do
        if str:sub(s,f) == "(" then
            ctr = ctr + 1 -- Push,
        else
            ctr = ctr - 1  -- Else pop.
        end
        if ctr == 0 then return line, s end
      end
    end
  end



  function t.  find_closing_square_bracket( line_num, square_bracket_pos )
    local tabl = t.file_table
    local ctr = 1 -- ctr = counter; how many braces we need to find.

    -- First iteration (to account for starting position.)
    local start = tabl[line_num]:sub(square_bracket_pos+1)
    -- gmatch_sf is custom iterator that returns start/finish pos of all matches.
    for st,_ in t.gmatch_start_finish(start, "[%[%]]") do
       if start:sub(st,st) == "[" then
          ctr = ctr + 1  -- Push.
       else
          ctr = ctr - 1  -- Else pop.
       end
       if ctr == 0 then return line_num, st+square_bracket_pos end
    end

    for line=line_num+1, #tabl do
    -- Do not want to keep looking for brace after tabl end, in case there is no closer.
      local str = tabl[line]

      for s,f in t.gmatch_start_finish(str,"[%[%]]") do
        if str:sub(s,f) == "[" then
            ctr = ctr + 1 -- Push,
        else
            ctr = ctr - 1  -- Else pop.
        end
        if ctr == 0 then return line, s end
      end
    end
  end


  function t.  find_closing_pointy_bracket( line_num, square_bracket_pos )
    local tabl = t.file_table
    local ctr = 1 -- ctr = counter; how many braces we need to find.

    -- First iteration (to account for starting position.)
    local start = tabl[line_num]:sub(square_bracket_pos+1)
    -- gmatch_sf is custom iterator that returns start/finish pos of all matches.
    for st,_ in t.gmatch_start_finish(start, "[<>]") do
       if start:sub(st,st) == "<" then
          ctr = ctr + 1  -- Push.
       else
          ctr = ctr - 1  -- Else pop.
       end
       if ctr == 0 then return line_num, st+square_bracket_pos end
    end

    for line=line_num+1, #tabl do
    -- Do not want to keep looking for brace after tabl end, in case there is no closer.
      local str = tabl[line]

      for s,f in t.gmatch_start_finish(str,"[<>]") do
        if str:sub(s,f) == "<" then
            ctr = ctr + 1 -- Push,
        else
            ctr = ctr - 1  -- Else pop.
        end
        if ctr == 0 then return line, s end
      end
    end
  end


--> Returns line number, start point, and end point.
function t.  find_next_occurance(line_number, current_position, pattern)
    local tabl = t.file_table
    local iter = 0
    local s,f = tabl[line_number]:find(pattern, current_position)
    if s and f then return line_number,s,f end
    line_number = line_number+1
    local max = #tabl
    while iter < max do
        iter = iter + 1
        if tabl[line_number]:match(pattern) then
            s,f = tabl[line_number]:find(pattern)
            return line_number, s, f
        end
        line_number = line_number + 1
    end
end


--> Returns   line number, line position
function t.find_ending_string(line_number, position_start,str_type)
  assert(str_type=="'" or str_type=='"', " str_type needs to be  \'  or  \" ")
  local tabl = t.file_table
  local iter = position_start+1
  local line
  for i=line_number,#tabl do
    line = tabl[i]
    while iter < #line+4 do
      if line:sub(iter,iter) == str_type then
        return i,iter
      elseif line:sub(iter,iter) == "\\" then
        iter = iter + 2
      else
        iter = iter+1
      end
    end
    iter = 1
  end
end



return t


