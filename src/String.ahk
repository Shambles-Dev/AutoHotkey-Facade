#Include <_Validate>
#Include <Op>

String_Concat(Strings*)
{
    local
    static Sig := "String_Concat(Strings*)"
    _Validate_StringArgs(Sig, Strings)
   ,Result := ""
    for _, String in Strings
    {
        Result .= String
    }
    return Result
}

_String_CiEq(A, B)
{
    local
    CaseSense := A_StringCaseSense
    StringCaseSense Locale
    Result := A = B
    StringCaseSense %CaseSense%
    return Result
}

_String_CiCmp(A, B)
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
        StringCaseSense Locale
        Result := (A > B) - (A < B)
        StringCaseSense %CaseSense%
    }
    return Result
}

String_CiLt(Args*)
{
    local
    static Sig := "String_CiLt(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_LtAux")
                                               .Bind(Func("_String_CiCmp"))
                                          ,Args))
}

String_CiGt(Args*)
{
    local
    static Sig := "String_CiGt(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_GtAux")
                                               .Bind(Func("_String_CiCmp"))
                                          ,Args))
}

String_CiLe(Args*)
{
    local
    static Sig := "String_CiLe(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_LeAux")
                                               .Bind(Func("_String_CiCmp"))
                                          ,Args))
}

String_CiGe(Args*)
{
    local
    static Sig := "String_CiGe(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_GeAux")
                                               .Bind(Func("_String_CiCmp"))
                                          ,Args))
}

String_CiEq(Args*)
{
    local
    static Sig := "String_CiEq(Args*)"
    _Validate_Args(Sig, Args)
    return _Op_TestArgs(Func("_Op_Eq").Bind(Func("_String_CiEq")), Args)
}

_String_Path(Value)
{
    local
    RegExMatch(Value, "OiS)^(?|([/\\])|([A-Z]:)[/\\])", Root)
    if (Root.Value(1) != "")
    {
        Value := SubStr(Value, StrLen(Root.Value(0)) + 1)
    }
    Result := []
    for _, Component in StrSplit(Value, ["/", "\"])
    {
        if (Component == "..")
        {
            ; Rely on silent failure for excessive pops.
            Result.Pop()
        }
        else if (Component != "" and Component != ".")
        {
            Result.Push(Component)
        }
    }
    if (Root.Value(1) != "")
    {
        ; Insert the root here to prevent it from being lost due to excessive
        ; pops.
        Result.InsertAt(1, Root.Value(1) ~= "S)[/\\]" ? "" : Root.Value(1))
    }
    return Result
}

_String_NatSortCmp(A, B)
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
        Result := 0
       ,Index  := 1
        ; Split at directory separators.
       ,APath  := _String_Path(A)
       ,BPath  := _String_Path(B)
        while (    Result == 0
               and Index <= APath.Count() and Index <= BPath.Count())
        {
            AComponent := APath[Index]
           ,BComponent := BPath[Index]
           ,Toggle     := true
            while (    Result == 0
                   and AComponent != "" and BComponent != "")
            {
                if (Toggle)
                {
                    ; Parse string.
                    RegExMatch(AComponent, "S)^\P{Nd}*", AToken)
                   ,RegExMatch(BComponent, "S)^\P{Nd}*", BToken)
                   ,ATokenLength := StrLen(AToken)
                   ,BTokenLength := StrLen(BToken)
                    ; Do not compare whitespace.
                   ,AToken := RegExReplace(AToken, "S)\p{Xsp}")
                   ,BToken := RegExReplace(BToken, "S)\p{Xsp}")
                }
                else
                {
                    ; Parse unsigned integer.
                    RegExMatch(AComponent, "S)^\p{Nd}*", AToken)
                   ,RegExMatch(BComponent, "S)^\p{Nd}*", BToken)
                   ,ATokenLength := StrLen(AToken)
                   ,BTokenLength := StrLen(BToken)
                    ; Leading 0s are automatically trimmed.
                    ;
                    ; If a value is an empty string, AutoHotkey uses string
                    ; comparison that ensures the correct result.
                }
                Result     := _String_CiCmp(AToken, BToken)
               ,AComponent := SubStr(AComponent, ATokenLength + 1)
               ,BComponent := SubStr(BComponent, BTokenLength + 1)
               ,Toggle     := not Toggle
            }
            Result := Result == 0 ? AComponent != "" ?  1
                                  : BComponent != "" ? -1
                                  : 0
                    : Result
           ,++Index
        }
        Result := Result == 0 ? APath.Count() < BPath.Count() ? -1
                              : APath.Count() > BPath.Count() ?  1
                              : 0
                : Result
    }
    return Result
}

String_IsNatSorted(Args*)
{
    local
    static Sig := "String_IsNatSorted(Args*)"
    _Validate_Args(Sig, Args)
    return _Validate_BlameOrdCmp(Sig
                                ,Func("_Op_TestArgs")
                                     .Bind(Func("_Op_LeAux")
                                               .Bind(Func("_String_NatSortCmp"))
                                          ,Args))
}
