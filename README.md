# Bidirectional dependent type checker in Standard ML

This is a Standard ML implementation of a bidirectional dependent type checker based on Coquand's algorithm [1].

## Type system

The type checker is quite simple, it implements a core dependent type system with just:

- Lambda abstractions (λ-terms)
- Let expressions
- Function application
- Dependent function types (Π-types)
- A single universe `Type`

## Core types

```sml
datatype Expression = 
    Variable of Identifier
    | Application of Expression * Expression
    | Abstraction of Identifier * Expression
    | LetBinding of Identifier * Expression * Expression * Expression
    | PiType of Identifier * Expression * Expression
    | BaseType

datatype Value = 
    GenericValue of int
    | AppValue of Value * Value
    | TypeValue
    | Closure of (Identifier * Value) list * Expression

```

The `expression` type represents the language AST and the `value` represents the semantic domain, using closures to handle envs for lexical scoping.

## Type checking algorithm

The core of the type checker uses a bidirectional approach implemented in the mutually recursive functions `checkExpression` and `inferExpression`. 

```sml
fun checkExpression (k, ρ, Γ) e A = ...
and inferExpression (k, ρ, Γ) e = ...
```

These correspond to the judgments:

$$
\Gamma \vdash e \Leftarrow A \text{ (checking)}
$$
$$
\Gamma \vdash e \Rightarrow A \text{ (inference)}
$$

## Normalization

The `weakHeadNormalForm` function implements a simple Normalization by Evaluation strategy to compare types up to β-equivalence.

   ```sml
   fun weakHeadNormalForm v =
       case v of
           AppliedValue (u, w) => applyValue (weakHeadNormalForm u) (weakHeadNormalForm w)
         | Closure (env, e) => evaluate env e
         | _ => v
   ```

## Example

Here's how we can represent and type-check the polymorphic identity function:

```sml
val identityFunction = Abstraction ("A", Abstraction ("x", Variable "x"))
val identityType = PiType ("A", TypeConstant, PiType ("x", Variable "A", Variable "A"))

val test = typecheck identityFunction identityType
```

This corresponds to the $\Pi$-type:

$$
\Pi (A : \textsf{Type}) . \Pi (x : A) . A
$$

## TODO
So far this just implements the paper but some stuff to add might be:

- [ ] Σ-types
- [ ] Agda-like hierarchy of universes
- [ ] Inductive types????

## References

[1] Coquand, T. (1996). An algorithm for type-checking dependent types