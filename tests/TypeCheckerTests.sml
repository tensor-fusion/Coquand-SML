structure TypeCheckerTests = struct

open Types
open Environment
open Evaluation
open TypeChecker

fun runTest name test =
    (print ("Running test: " ^ name ^ "... ");
     if test()
     then print "PASSED\n"
     else print "FAILED\n")

fun testIdentityFunction () =
    let
        val identityType = PiType ("A", BaseType, PiType ("x", Variable "A", Variable "A"))
        val identityTerm = Abstraction ("A", Abstraction ("x", Variable "x"))
    in
        typeCheck identityTerm identityType
    end

fun testApplication () =
    let
        val appType = PiType ("A", BaseType, 
                      PiType ("B", BaseType, 
                      PiType ("f", PiType ("x", Variable "A", Variable "B"), 
                      PiType ("a", Variable "A", Variable "B"))))
        val appTerm = Abstraction ("A", Abstraction ("B", Abstraction ("f", Abstraction ("a", Application (Variable "f", Variable "a")))))
    in
        typeCheck appTerm appType
    end

fun testSimpleDependentFunction () =
    let
        val depFuncType = PiType ("A", BaseType, PiType ("x", Variable "A", Variable "A"))
        val depFuncTerm = Abstraction ("A", Abstraction ("x", Variable "x"))
        val result = typeCheck depFuncTerm depFuncType
    in
        (print ("Simple Dependent Function result: " ^ Bool.toString result ^ "\n");
         result)
    end


fun runAllTests () = 
    (runTest "Identity Function" testIdentityFunction;
     runTest "Application" testApplication;
     runTest "Simple Dependent Function" testSimpleDependentFunction)

end

val _ = TypeCheckerTests.runAllTests()

