#Include <IsInteger>
#Include <IsString>
#Include <Type>
#Include <HasProp>
#Include <HasMethod>
#Include <_IsArray>
#Include <_Validate>

_Op_ArrayFoldL(Func, Init, Array)
{
    ; This is a redundant Array FoldL definition to avoid circular dependencies.
    local
    A     := Init
   ,Index := 1
    while (Index <= Array.Count())
    {
        A := Func.Call(A, Array[Index])
       ,++Index
    }
    return A
}

_Op_ArrayFoldL1(Func, Array)
{
    ; This is a redundant Array FoldL1 definition to avoid circular
    ; dependencies.
    local
    A     := Array[1]
   ,Index := 2
    while (Index <= Array.Count())
    {
        A := Func.Call(A, Array[Index])
       ,++Index
    }
    return A
}

Op_Bin(X)
{
    local
    static Sig := "Op_Bin(X)"
    _Validate_IntegerArg(Sig, "X", X)
    static Digits := {0x0 << 60: "0000"
                     ,0x1 << 60: "0001"
                     ,0x2 << 60: "0010"
                     ,0x3 << 60: "0011"
                     ,0x4 << 60: "0100"
                     ,0x5 << 60: "0101"
                     ,0x6 << 60: "0110"
                     ,0x7 << 60: "0111"
                     ,0x8 << 60: "1000"
                     ,0x9 << 60: "1001"
                     ,0xA << 60: "1010"
                     ,0xB << 60: "1011"
                     ,0xC << 60: "1100"
                     ,0xD << 60: "1101"
                     ,0xE << 60: "1110"
                     ,0xF << 60: "1111"}
    static Mask   :=  0xF << 60
    Result := "0b"
    loop 16
    {
        Result .= Digits[X << 4 * (A_Index - 1) & Mask]
    }
    return Result
}

Op_Hex(X)
{
    local
    static Sig := "Op_Hex(X)"
    _Validate_IntegerArg(Sig, "X", X)
    return Format("0x{:016X}", X)
}

Op_Integer(X)
{
    local
    static Sig := "Op_Integer(X)"
    if (X ~= "iS)^[ \t]*[-+]?0(?:b[01]+|x[0-9A-F]+)[ \t]*$")
    {
        static Digits := {"0":  0
                         ,"1":  1
                         ,"2":  2
                         ,"3":  3
                         ,"4":  4
                         ,"5":  5
                         ,"6":  6
                         ,"7":  7
                         ,"8":  8
                         ,"9":  9
                         ,"A": 10
                         ,"B": 11
                         ,"C": 12
                         ,"D": 13
                         ,"E": 14
                         ,"F": 15}
        RegExMatch(X, "OiS)(?<Sign>[-+]?)0(?<Radix>[bx])(?<Number>[0-9A-F]+)", Match)
       ,BitWidth := Match.Value("Radix") = "b" ? 1 : 4
       ,Number := Match.Value("Number")
       ,X := 0
        while (Number != "")
        {
            X <<= BitWidth
           ,X |= Digits[SubStr(Number, 1, 1) . ""]
           ,Number := SubStr(Number, 2)
        }
        X := Match.Value("Sign") == "-" ? -X : X
    }
    else if (X ~= "iS)^[ \t]*[-+]?(?:\d+e[-+]?\d+|inf(?:inity)?|nan(?:\(ind\))?)[ \t]*$")
    {
        X := Op_Float(X)
    }
    _Validate_FiniteNumberArg(Sig, "X", X)
    if X is Float
    {
        ; Removing the + 0.0 can result in defective truncation (e.g. 1.1e1 & -1
        ; is 1 instead of 11).
        X := X + 0.0 & -1
    }
    return X
}

Op_Float(X)
{
    local
    global inf, nan
    static Sig := "Op_Float(X)"
    if (X ~= "iS)^[ \t]*[-+]?0(?:b[01]+|x[0-9A-F]+)[ \t]*$")
    {
        X := Op_Integer(X)
    }
    else if (X ~= "iS)^[ \t]*[-+]?\d+e[-+]?\d+[ \t]*$")
    {
        X := StrReplace(X, "e", ".e")
    }
    else if (X ~= "iS)^[ \t]*[-+]?inf(?:inity)?[ \t]*$")
    {
        X := InStr(X, "-") ? -inf : inf
    }
    else if (X ~= "iS)^[ \t]*[-+]?nan(?:\(ind\))?[ \t]*$")
    {
        X := nan
    }
    _Validate_NumberArg(Sig, "X", X)
    return X + 0.0
}

Op_GetProp(Prop, Obj)
{
    local
    global PropError
    static Sig := "Op_GetProp(Prop, Obj)"
    _Validate_ObjArg(Sig, "Obj", Obj)
    if (    ComObjType(Obj) == ""
        and not (   HasProp(Obj, Prop)
                 or HasMethod(Obj, "HasProp") and Obj.HasProp(Prop)))
    {
        throw new PropError(Format("{1}  Prop not found.  Prop is {2}.", Sig, _Validate_ValueRepr(Prop)), -1)
    }
    return Obj[Prop]
}

Op_Get(Key, Obj)
{
    local
    global KeyError
    static Sig := "Op_Get(Key, Obj)"
    _Validate_ObjArg(Sig, "Obj", Obj)
   ,ComObjType := ComObjType(Obj)
    if (ComObjType == "" and not (HasMethod(Obj, "HasKey") and Obj.HasKey(Key)))
    {
        throw new KeyError(Format("{1}  Key not found.  Key is {2}.", Sig, _Validate_ValueRepr(Key)), -1)
    }
    return ComObjType == "" and HasMethod(Obj, "Get") ? Obj.Get(Key) : Obj[Key]
}

Op_Expt(X, Y)
{
    local
    global ValueError, DivisionByZeroError
    static Sig := "Op_Expt(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
   ,_Validate_NumberArg(Sig, "Y", Y)
    if (X < 0 and not IsInteger(Y))
    {
        throw new ValueError(Format("{1}  Negative base with a fractional exponent.  X is {2} and Y is {3}.", Sig, X, Y), -1)
    }
    if (X == 0)
    {
        if (Y < 0)
        {
            throw new DivisionByZeroError(Format("{1}  X is {2} and Y is {3}.", Sig, X, Y), -1)
        }
        if (Y == 0 and not IsInteger(Y))
        {
            throw new ValueError(Format("{1}  Zero base with a zero continuous exponent.", Sig), -1)
        }
    }
    return X ** Y
}

Op_BNot(X)
{
    local
    static Sig := "Op_BNot(X)"
    _Validate_IntegerArg(Sig, "X", X)
    return X ^ -1
}

_Op_MulAux(X, Y)
{
    local
    return X * Y
}

Op_Mul(Numbers*)
{
    local
    static Sig := "Op_Mul(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    return _Op_ArrayFoldL(Func("_Op_MulAux"), 1, Numbers)
}

_Op_DivAux(X, Y)
{
    local
    global DivisionByZeroError
    if (Y == 0)
    {
        throw new DivisionByZeroError()
    }
    return X / Y
}

Op_Div(Numbers*)
{
    local
    global ArgsUnderflowError, DivisionByZeroError
    static Sig := "Op_Div(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    try
    {
        if (Numbers.Count() == 0)
        {
            throw new ArgsUnderflowError()
        }
        else if (Numbers.Count() == 1)
        {
            if (Numbers[1] == 0)
            {
                throw new DivisionByZeroError()
            }
            Result := 1 / Numbers[1]
        }
        else
        {
            Result := _Op_ArrayFoldL1(Func("_Op_DivAux"), Numbers)
        }
    }
    catch Exc
    {
        throw Exc.__New(Sig, -1)
    }
    return Result
}

Op_FloorDiv(X, Y)
{
    local
    static Sig := "Op_FloorDiv(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
   ,_Validate_DivisorArg(Sig, "Y", Y)
    if (IsInteger(X) and IsInteger(Y))
    {
        ; // is intentionally used as truncating division.
        Q := X // Y
        ; An efficient C implementation would use X % Y below, where % is
        ; integer remainder, instead of Q * Y == X, and swap the branch paths,
        ; but AutHotkey's Mod(X, Y) is floating-point remainder.
       ,Result := Q * Y == X ? Q : Q - ((X < 0) ^ (Y < 0))
    }
    else
    {
        Result := Floor(X / Y)
    }
    return Result
}

_Op_AddAux(X, Y)
{
    local
    return X + Y
}

Op_Add(Numbers*)
{
    local
    static Sig := "Op_Add(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    return _Op_ArrayFoldL(Func("_Op_AddAux"), 0, Numbers)
}

_Op_SubAux(X, Y)
{
    local
    return X - Y
}

Op_Sub(Numbers*)
{
    local
    global ArgsUnderflowError
    static Sig := "Op_Sub(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    if (Numbers.Count() == 0)
    {
        throw new ArgsUnderflowError(Sig, -1)
    }
    else if (Numbers.Count() == 1)
    {
        Result := 0 - Numbers[1]
    }
    else
    {
        Result := _Op_ArrayFoldL1(Func("_Op_SubAux"), Numbers)
    }
    return Result
}

Op_BAsl(X, N)
{
    local
    static Sig := "Op_BAsl(X, N)"
    _Validate_IntegerArg(Sig, "X", X)
   ,_Validate_NonNegIntegerArg(Sig, "N", N)
    return N >= 64 ? 0 : X << N
}

Op_BAsr(X, N)
{
    local
    static Sig := "Op_BAsr(X, N)"
    _Validate_IntegerArg(Sig, "X", X)
   ,_Validate_NonNegIntegerArg(Sig, "N", N)
    return N >= 64 ? X >= 0 ? 0 : -1 : X >> N
}

Op_BLsr(X, N)
{
    local
    static Sig := "Op_BLsr(X, N)"
    _Validate_IntegerArg(Sig, "X", X)
   ,_Validate_NonNegIntegerArg(Sig, "N", N)
    return N >= 64 ? 0 : X >> N & Op_BNot(1 << 63 >> N << 1)
}

_Op_BAndAux(X, Y)
{
    local
    return X & Y
}

Op_BAnd(Integers*)
{
    local
    static Sig := "Op_BAnd(Integers*)"
    _Validate_IntegerArgs(Sig, Integers)
    return _Op_ArrayFoldL(Func("_Op_BAndAux"), -1, Integers)
}

_Op_BXorAux(X, Y)
{
    local
    return X ^ Y
}

Op_BXor(Integers*)
{
    local
    static Sig := "Op_BXor(Integers*)"
    _Validate_IntegerArgs(Sig, Integers)
    return _Op_ArrayFoldL(Func("_Op_BXorAux"), 0, Integers)
}

_Op_BOrAux(X, Y)
{
    local
    return X | Y
}

Op_BOr(Integers*)
{
    local
    static Sig := "Op_BOr(Integers*)"
    _Validate_IntegerArgs(Sig, Integers)
    return _Op_ArrayFoldL(Func("_Op_BOrAux"), 0, Integers)
}

_Op_Eq(ScalarEq, A, B)
{
    ; This function is necessary because performing an ordered comparison on
    ; types with undefined order should be a defect (even if their identities
    ; are equal), but performing an (in)equality test on all types should be
    ; valid.
    local
    TypeA := _Validate_TypeRepr(A)
   ,TypeB := _Validate_TypeRepr(B)
    if (ScalarEq.Call(A, B))
    {
        ; Identity, numeric, and string equality are conflated.
        Result := true
    }
    else if (   TypeA == "Stream" and TypeB == "Stream"
             or TypeA == "List"   and TypeB == "List"
             or _IsArray(A)       and _IsArray(B))
    {
        ; Arrays and Objects (dictionaries) are conflated, so comparing Arrays
        ; must come before comparing dictionaries.
        AEnum  := A._NewEnum()
       ,BEnum  := B._NewEnum()
       ,Result := true
        loop
        {
            AHadValue := AEnum.Next(_, AValue)
           ,BHadValue := BEnum.Next(_, BValue)
            if (AHadValue and BHadValue)
            {
                Result := _Op_Eq(ScalarEq, AValue, BValue)
            }
        }
        until (not Result or not AHadValue or not BHadValue)
        Result := Result and not AHadValue and not BHadValue
    }
    else if (   TypeA == "Dict"   and TypeB == "Dict"
             or TypeA == "Object" and TypeB == "Object")
    {
        Result := A.Count() == B.Count()
       ,AEnum  := A._NewEnum()
        while (Result and AEnum.Next(Key, Value))
        {
            Result := B.HasKey(Key) and Op_Eq(Value, Op_Get(Key, B))
        }
    }
    else
    {
        Result := false
    }
    return Result
}

_Op_Cmp(ScalarCmp, A, B)
{
    ; This function can return -1 (less than), 0 (equal), 1 (greater than), or
    ; "" (incomparable).  The existence of NaN makes floating point values
    ; partially ordered and the existence of non-empty disjoint sets makes
    ; dictionaries partially ordered, so an incomparable value is necessary.
    local
    global TypeError
    TypeA := _Validate_TypeRepr(A)
   ,TypeB := _Validate_TypeRepr(B)
    if (IsString(A) and IsString(B))
    {
        ; Numeric and string comparison are conflated.
        Result := ScalarCmp.Call(A, B)
    }
    else if (   TypeA == "Stream" and TypeB == "Stream"
             or TypeA == "List"   and TypeB == "List"
             or _IsArray(A)       and _IsArray(B))
    {
        ; Arrays and Objects (dictionaries) are conflated, so comparing Arrays
        ; must come before comparing dictionaries.
        AEnum  := A._NewEnum()
       ,BEnum  := B._NewEnum()
       ,Result := 0
        loop
        {
            AHadValue := AEnum.Next(_, AValue)
           ,BHadValue := BEnum.Next(_, BValue)
            if (AHadValue and BHadValue)
            {
                Result := _Op_Cmp(ScalarCmp, AValue, BValue)
            }
        }
        until (not Result == 0 or not AHadValue or not BHadValue)
        Result := Result == 0 ? AHadValue ?  1
                              : BHadValue ? -1
                              : 0
                : Result
    }
    else if (   TypeA == "Dict"   and TypeB == "Dict"
             or TypeA == "Object" and TypeB == "Object")
    {
        Result := (A.Count() > B.Count()) - (A.Count() < B.Count())
        if (Result == 1)
        {
            LesserEnum := B._NewEnum()
           ,Greater    := A
        }
        else
        {
            ; This also works in the = case.
            LesserEnum := A._NewEnum()
           ,Greater    := B
        }
        while (Result != "" and LesserEnum.Next(Key, Value))
        {
            Result := Greater.HasKey(Key) and Op_Eq(Value, Op_Get(Key, Greater)) ? Result
                    : ""
        }
    }
    else
    {
        throw new TypeError(Format("Ordered comparison is undefined between instances of {1} and {2}.", TypeA, TypeB))
    }
    return Result
}

_Op_TestArgs(Test, Args)
{
    local
    Result := true
   ,Index  := 1
    while (Result and Index + 1 <= Args.Count())
    {
        Result := Test.Call(Args[Index], Args[Index + 1])
       ,++Index
    }
    return Result
}

_Op_CsEq(A, B)
{
    local
    return A == B
}

_Op_CsCmp(A, B)
{
    local
    if (A != A or B != B)
    {
        ; NaN breaks the law of trichotomy, so it must be handled before
        ; comparing numbers.
        Result := ""
    }
    else
    {
        CaseSense := A_StringCaseSense
        StringCaseSense On
        Result := (A > B) - (A < B)
        StringCaseSense %CaseSense%
    }
    return Result
}

_Op_LtAux(ScalarCmp, A, B)
{
    local
    Cmp := _Op_Cmp(ScalarCmp, A, B)
    return Cmp == -1
}

Op_Lt(Args*)
{
    local
    static Sig := "Op_Lt(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_LtAux")
                                               .Bind(Func("_Op_CsCmp"))
                                          ,Args))
}

_Op_GtAux(ScalarCmp, A, B)
{
    local
    Cmp := _Op_Cmp(ScalarCmp, A, B)
    return Cmp == 1
}

Op_Gt(Args*)
{
    local
    static Sig := "Op_Gt(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_GtAux")
                                               .Bind(Func("_Op_CsCmp"))
                                          ,Args))
}

_Op_LeAux(ScalarCmp, A, B)
{
    local
    Cmp := _Op_Cmp(ScalarCmp, A, B)
    return Cmp != "" and Cmp <= 0
}

Op_Le(Args*)
{
    local
    static Sig := "Op_Le(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_LeAux")
                                               .Bind(Func("_Op_CsCmp"))
                                          ,Args))
}

_Op_GeAux(ScalarCmp, A, B)
{
    local
    Cmp := _Op_Cmp(ScalarCmp, A, B)
    return Cmp != "" and Cmp >= 0
}

Op_Ge(Args*)
{
    local
    static Sig := "Op_Ge(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_GeAux")
                                               .Bind(Func("_Op_CsCmp"))
                                          ,Args))
}

Op_Eq(Args*)
{
    local
    static Sig := "Op_Eq(Args*)"
    _Validate_Args(Sig, Args)
    return _Op_TestArgs(Func("_Op_Eq").Bind(Func("_Op_CsEq")), Args)
}

Op_IdEq(Args*)
{
    local
    static Sig := "Op_IdEq(Args*)"
    _Validate_Args(Sig, Args)
    return _Op_TestArgs(Func("_Op_CsEq"), Args)
}
