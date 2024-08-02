structure Evaluation = struct

  open Types
  open Environment

  fun applyValue func arg =
      case func of
          Closure (env, Abstraction (param, body)) => evaluate (extendEnv env param arg) body
        | _ => AppValue (func, arg)

  and evaluate env exp =
      case exp of
          Variable var => findInEnv var env
        | Application (exp1, exp2) => applyValue (evaluate env exp1) (evaluate env exp2)
        | LetBinding (var, expr1, _, expr3) => evaluate (extendEnv env var (evaluate env expr1)) expr3
        | BaseType => TypeValue
        | _ => Closure (env, exp)

  and normalFormValue value =
      case value of
          AppValue (func, arg) => applyValue (normalFormValue func) (normalFormValue arg)
        | Closure (env, body) => evaluate env body
        | _ => value

end