

|*
functions and objects are equivalent, only mutable datatype.

MUST BE AN ELEGANT WAY TO CREATE FUNCTIONS THEN !!!

ideas::
*|


$ay = @      | creates object, __call  =  (function() end)

$obj = @pa   | creates object with parent `pa`




| syntax:
$ function =  a,b,c @ <statement>       | Note: statement ends after the first comma



| example,
| add function:
$ addition =  x, y @ ->  x+y



| example of multi-line funciton
$ee = a,b @ {
    -> 2* (a+b)
}


| another example of multi-line function:

$ another = a,b @ (
    -> a^b
)


|*


