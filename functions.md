

What functions do I need?


' AST '    is token graph data structure.
    This data structure points to current token in question,
    and keeps track of current state. Note that each token will
    also hold it's current state, eg if a token is inside a function block,
    it will know.


' L '  is string table data structure. Each string corresponds to one line


```lua

-- returns < index, string > of new non-empty line
-- Every newline encounted, adds a newline token to stack.
newline(L, l_num)

-- returns a string with added spaces at start and end
expand(str)

-- tells what the next lexObj is, given a string. Returns nil if no lexObj on string
-- returns  < lexObj, start_pos, end_pos >
tell(str)

-- Constructs a token object from a lexObj
tok(lexObj, str, lnum)

-- pushes token object onto AST, modifies state (if required)
push(AST, token)





-- gets next token, of optional argument `type` (nil if none) 
next(token [,type])

-- gets last token of optional arg `type`
last(token [,type])



-- attaches token1 to token2, and token2 to token1
bind(tok1, tok2)

-- swaps positions of tok1 and tok2, !!! does not modify state!!!!
swap(tok1, tok2)

-- creates replica of token
dupe(tok)

-- finds closing bracket of this bracket token
-- (if this token isn't a bracket, raises compile-error)
closer(tok)

-- raises syntax error
syntax_error(line, err)


```