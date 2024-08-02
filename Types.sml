structure Types = struct

  type Identifier = string

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

end