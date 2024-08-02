structure Environment = struct

  open Types

  fun extendEnv env var value = (var, value) :: env

  fun findInEnv var [] = raise Fail ("Variable not found: " ^ var)
    | findInEnv var ((key, value) :: env) = 
        if var = key then value
        else findInEnv var env

end