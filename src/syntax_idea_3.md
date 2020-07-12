

|*
real basic syntax, with keywords.



*|
```lua





lambda Double (str) {
    return str .. str
}



{
    lambda Do(){
        if math.random() < 0.5 {
            Do()
        }
}


array = [1,2,3,4]


object = struct {
    x = 1
    y = 2
    z = 3
    u,v = 1,2
    [1] = 1
    [2] = 2
    [3] = 3
}



while (condition) {
    for (x = 1,10) {
    -- for x = 1, 10, 1
    }
}







lambda wrap(func) {
    obj[#obj + 1] = func
    return func
}


@wrap
lambda something( ){
    return nil
}




```








