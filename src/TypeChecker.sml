structure TypeChecker = struct

  open Types
  open Environment
  open Evaluation

  fun valuesEqual (index, val1, val2) =
      case (normalFormValue val1, normalFormValue val2) of
          (TypeValue, TypeValue) => true
      | (AppValue (fun1, arg1), AppValue (fun2, arg2)) =>
              valuesEqual (index, fun1, fun2) andalso valuesEqual (index, arg1, arg2)
      | (GenericValue k1, GenericValue k2) => k1 = k2
      | (Closure (env1, Abstraction (param1, body1)), Closure (env2, Abstraction (param2, body2))) =>
              let val newVal = GenericValue index
              in valuesEqual (index + 1,
                              Closure (extendEnv env1 param1 newVal, body1),
                              Closure (extendEnv env2 param2 newVal, body2))
              end
      | (Closure (env1, PiType (param1, type1, body1)), Closure (env2, PiType (param2, type2, body2))) =>
              let val newVal = GenericValue index
              in valuesEqual (index, Closure (env1, type1), Closure (env2, type2)) andalso
              valuesEqual (index + 1,
                              Closure (extendEnv env1 param1 newVal, body1),
                              Closure (extendEnv env2 param2 newVal, body2))
              end
      | _ => false

  (* Type checking and inference *)
  fun checkType (index, rho, gamma) exp = checkExpression (index, rho, gamma) exp TypeValue

  and checkExpression (index, rho, gamma) exp expectedType =
      case exp of
          Abstraction (param, body) =>
              (case normalFormValue expectedType of
                  Closure (env, PiType (paramType, domain, codomain)) =>
                      let val newVal = GenericValue index
                      in checkExpression (index + 1,
                                          extendEnv rho param newVal,
                                          extendEnv gamma param (Closure (env, domain)))
                                          body
                                          (Closure (extendEnv env param newVal, codomain))
                      end
              | _ => raise Fail "Expected PiType")
      | PiType (param, domain, codomain) =>
              (case normalFormValue expectedType of
                  TypeValue =>
                      checkType (index, rho, gamma) domain andalso
                      checkType (index + 1,
                                  extendEnv rho param (GenericValue index),
                                  extendEnv gamma param (Closure (rho, domain)))
                                  codomain
              | _ => raise Fail "Expected BaseType")
      | LetBinding (var, expr1, expr2, expr3) =>
              checkType (index, rho, gamma) expr2 andalso
              checkExpression (index,
                              extendEnv rho var (evaluate rho expr1),
                              extendEnv gamma var (evaluate rho expr2))
                              expr3
                              expectedType
      | _ => valuesEqual (index, inferType (index, rho, gamma) exp, expectedType)

  and inferType (index, rho, gamma) exp =
      case exp of
          Variable id => findInEnv id gamma
      | Application (exp1, exp2) =>
              (case normalFormValue (inferType (index, rho, gamma) exp1) of
                  Closure (env, PiType (param, domain, codomain)) =>
                      if checkExpression (index, rho, gamma) exp2 (Closure (env, domain))
                      then Closure (extendEnv env param (Closure (rho, exp2)), codomain)
                      else raise Fail "Application error"
              | _ => raise Fail "Application requires PiType")
      | BaseType => TypeValue
      | _ => raise Fail "Cannot infer type"

  fun typeCheck mainExpr typeExpr =
      checkType (0, [], []) typeExpr andalso
      checkExpression (0, [], []) mainExpr (Closure ([], typeExpr))

end