
--[[

I don't know if this is actually how you write an abstract semantic graph,
but if it isn't, this seems to work decently, even if memory inefficient.

(After note:  It's pretty much just modified doubly linked list)



TODO: Will ASG cause OOM for large files?
Perhaps it is neccessary to split large files into chunks, and tokenize
seperately. This way ASG will also need to have a starting state value.
Hopefully that wont cause problems :/
]]




local function makeASG(filepath)
    local ASG = {
        file = filepath ;

        -- first token in graph struct
        first_tok = nil ;

        -- last token in graph struct   (current token)
        last_tok  = nil ;

        -- holds state of current position. (last_tok)
        -- For example, if   state = { <"FUNC_START"> , <"WHILE_START"> }
        -- and a `IF_START` token is pushed onto stack, state is modified, and becomes
        -- state = {  <"FUNC_START"> , <"WHILE_START"> , <"IF_START"> }
        --
        -- When a closer is brought in, eg, when "}" token is pushed,
        -- <"IF_START"> is popped off the stack.
        state    = { } ;

    }

    return ASG
end


return makeASG

