#Include <IsInteger>
#Include <IsString>
#Include <IsInstance>
#Include <HasMethod>
#Include <_Validate>
#Include <Op>
#Include <Array>

Func_DllFunc(NameOrPtr, Types*)
{
    local
    global TypeError, MissingArgError, ValueError
    static Sig := "Func_DllFunc(NameOrPtr, Types*)"
    if (not IsString(NameOrPtr))
    {
        throw new TypeError(Format("{1}  NameOrPtr is not a String or Integer.  NameOrPtr's type is {2}.", Sig, _Validate_TypeRepr(NameOrPtr)), -1)
    }
    loop % Types.Length()
    {
        if (not Types.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -1)
        }
        if (not IsString(Types[A_Index]))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Types[A_Index])), -1)
        }
        if (not Types[A_Index] ~= "iS)^(?:U?(?:Char|Short|Int|Int64)|Float|Double|[AW]?Str|Ptr)[\*P]?$")
        {
            throw new ValueError(Format("{1}  Invalid argument {2}.", Sig, _Validate_ValueRepr(Types[A_Index])), -1)
        }
    }
    Positions := [0]
    loop % Types.Count()
    {
        Positions.Push(A_Index)
       ,Positions.Push(A_Index + Types.Count())
    }
    Positions.Pop()
    return Func_Bind(Func_Rearg(Func("DllCall"), Positions), NameOrPtr, Types*)
}

Func_Bind(Func, Args*)
{
    local
    global GoodFunc
    static Sig := "Func_Bind(Func, Args*)"
    _Validate_FuncArg(Sig, "Func", Func)
    return new GoodFunc(Func, Args*)
}

_Func_MethodCallerAux(Name, Args, Obj, Rest*)
{
    local
    Args := Args.Clone()
   ,Args.Push(Rest*)
    return Obj[Name](Args*)
}

Func_MethodCaller(Name, Args*)
{
    local
    static Sig := "Func_MethodCaller(Name, Args*)"
    _Validate_IdentifierArg(Sig, "Name", Name)
    return Func_Bind(Func("_Func_MethodCallerAux"), Name, Args)
}

Func_Applicable(Obj)
{
    local
    static Sig := "Func_Applicable(Obj)"
    _Validate_ObjArg(Sig, "Obj", Obj)
    return Func_Flip(Func("Op_Get")).Bind(Obj)
}

Func_Apply(Func, Args)
{
    local
    static Sig := "Func_Apply(Func, Args)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_BadArrayArg(Sig, "Args", Args)
    return Func.Call(Args*)
}

_Func_ApplyArgsWithAux(Func, ArgsFuncs, Args*)
{
    local
    ResultArgs := []
    for Index, ArgsFunc in ArgsFuncs
    {
        ResultArgs[Index] := ArgsFunc.Call(Args*)
    }
    return Func.Call(ResultArgs*)
}

Func_ApplyArgsWith(Func, ArgsFuncs)
{
    local
    static Sig := "Func_ApplyArgsWith(Func, ArgsFuncs)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_FuncBadArrayArg(Sig, "ArgsFuncs", ArgsFuncs)
    return Func_Bind(Func("_Func_ApplyArgsWithAux"), Func, ArgsFuncs)
}

_Func_ApplyRespWithAux(Func, RespFuncs, Args*)
{
    local
    global MissingArgError
    ResultArgs := []
    for Index, RespFunc in RespFuncs
    {
        if (not Args.HasKey(Index))
        {
            throw new MissingArgError()
        }
        ResultArgs[Index] := RespFunc.Call(Args[Index])
    }
    return Func.Call(ResultArgs*)
}

Func_ApplyRespWith(Func, RespFuncs)
{
    local
    static Sig := "Func_ApplyRespWith(Func, RespFuncs)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_FuncBadArrayArg(Sig, "RespFuncs", RespFuncs)
    return Func_Bind(Func("_Func_ApplyRespWithAux"), Func, RespFuncs)
}

_Func_CompAux(Funcs, Args*)
{
    local
    Index  := Funcs.Count()
   ,Result := Funcs[Index].Call(Args*)
   ,--Index
    while (Index >= 1)
    {
        Result := Funcs[Index].Call(Result)
       ,--Index
    }
    return Result
}

Func_Comp(Funcs*)
{
    local
    static Sig := "Func_Comp(Funcs*)"
    _Validate_FuncArgs(Sig, Funcs)
    return Funcs.Count() == 0 ? Func_Bind(Func("Func_Id"))
         : Funcs.Count() == 1 ? Func_Bind(Funcs[1])
         : Func_Bind(Func("_Func_CompAux"), Funcs)
}

_Func_ReargAux(MaxPosition, Func, Positions, Args*)
{
    local
    NewArgs := []
    for Destination, Source in Positions
    {
        NewArgs[Destination] := Args[Source + 1]
    }
    while (MaxPosition + 1 < Args.Length())
    {
        ++MaxPosition
       ,++Destination
        if (Args.HasKey(MaxPosition + 1))
        {
            NewArgs[Destination] := Args[MaxPosition + 1]
        }
    }
    return Func.Call(NewArgs*)
}

Func_Rearg(Func, Positions)
{
    local
    global TypeError, ValueError
    static Sig := "Func_Rearg(Func, Positions)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_BadArrayArg(Sig, "Positions", Positions)
   ,MaxPosition       := 0
   ,FilteredPositions := []
    for Index, Value in Positions
    {
        if (    IsInteger(Index)
            and 1 <= Index)
        {
            if (not IsInteger(Value))
            {
                throw new TypeError(Format("{1}  Invalid position {2}.", Sig, _Validate_TypeRepr(Value)), -1)
            }
            if (not 0 <= Value)
            {
                throw new ValueError(Format("{1}  Invalid position {2}.", Sig, Value), -1)
            }
            MaxPosition              := Value > MaxPosition ? Value
                                      : MaxPosition
           ,FilteredPositions[Index] := Value
        }
    }
    return Func_Bind(Func("_Func_ReargAux"), MaxPosition, Func, FilteredPositions)
}

Func_Flip(F)
{
    local
    static Sig := "Func_Flip(F)"
    _Validate_FuncArg(Sig, "F", F)
    return Func_Rearg(F, [1, 0])
}

Func_HookL(F, G)
{
    local
    static Sig := "Func_HookL(F, G)"
    _Validate_FuncArg(Sig, "F", F)
   ,_Validate_FuncArg(Sig, "G", G)
    return Func_ApplyRespWith(F, [Func("Func_Id"), G])
}

Func_HookR(F, G)
{
    local
    static Sig := "Func_HookR(F, G)"
    _Validate_FuncArg(Sig, "F", F)
   ,_Validate_FuncArg(Sig, "G", G)
    return Func_ApplyRespWith(F, [G, Func("Func_Id")])
}

Func_Id(X)
{
    local
    return X
}

_Func_ConstAux(X, Args*)
{
    local
    return X
}

Func_Const(X)
{
    local
    return Func_Bind(Func("_Func_ConstAux"), X)
}

Func_On(F, G)
{
    local
    static Sig := "Func_On(F, G)"
    _Validate_FuncArg(Sig, "F", F)
   ,_Validate_FuncArg(Sig, "G", G)
    return Func_ApplyRespWith(F, [G, G])
}

_Func_CNotAux(Pred, Args*)
{
    local
    return not Pred.Call(Args*)
}

Func_CNot(Pred)
{
    local
    static Sig := "Func_CNot(Pred)"
    _Validate_FuncArg(Sig, "Pred", Pred)
    return Func_Bind(Func("_Func_CNotAux"), Pred)
}

_Func_CNotRelAux(RelPred, Args*)
{
    local
    return Args.Count() < 2 ? true
         : not RelPred.Call(Args*)
}

Func_CNotRel(RelPred)
{
    local
    static Sig := "Func_CNotRel(RelPred)"
    _Validate_FuncArg(Sig, "RelPred", RelPred)
    return Func_Bind(Func("_Func_CNotRelAux"), RelPred)
}

_Func_CAndAux(Preds, Args*)
{
    local
    Result := true
   ,Index  := 1
    while (Result and Index <= Preds.Count())
    {
        Result := Preds[Index].Call(Args*)
       ,++Index
    }
    return Result
}

Func_CAnd(Preds*)
{
    local
    static Sig := "Func_CAnd(Preds*)"
    _Validate_FuncArgs(Sig, Preds)
    return Preds.Count() == 0 ? Func_Const(true)
         : Preds.Count() == 1 ? Func_Bind(Preds[1])
         : Func_Bind(Func("_Func_CAndAux"), Preds)
}

_Func_COrAux(Preds, Args*)
{
    local
    Result := false
   ,Index  := 1
    while (not Result and Index <= Preds.Count())
    {
        Result := Preds[Index].Call(Args*)
       ,++Index
    }
    return Result
}

Func_COr(Preds*)
{
    local
    static Sig := "Func_COr(Preds*)"
    _Validate_FuncArgs(Sig, Preds)
    return Preds.Count() == 0 ? Func_Const(false)
         : Preds.Count() == 1 ? Func_Bind(Preds[1])
         : Func_Bind(Func("_Func_COrAux"), Preds)
}

_Func_CIfAux(Pred, ThenFunc, ElseFunc, Args*)
{
    local
    return Pred.Call(Args*) ? ThenFunc.Call(Args*) : ElseFunc.Call(Args*)
}

Func_CIf(Pred, ThenFunc, ElseFunc)
{
    local
    static Sig := "Func_CIf(Pred, ThenFunc, ElseFunc)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_FuncArg(Sig, "ThenFunc", ThenFunc)
   ,_Validate_FuncArg(Sig, "ElseFunc", ElseFunc)
    return Func_Bind(Func("_Func_CIfAux"), Pred, ThenFunc, ElseFunc)
}

_Func_CCondAux(Clauses, Args*)
{
    local
    Test   := false
   ,Index  := 1
   ,Result := ""
    while (not Test and Index <= Clauses.Count())
    {
        Test := Clauses[Index][1].Call(Args*)
        if (Test)
        {
            Result := Clauses[Index][2].Call(Args*)
        }
        ++Index
    }
    return Result
}

Func_CCond(Clauses*)
{
    local
    global MissingArgError, TypeError, ValueError
    static Sig := "Func_CCond(Clauses*)"
    loop % Clauses.Length()
    {
        if (not Clauses.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -1)
        }
        if (not Array_IsArray(Clauses[A_Index]))
        {
            throw new TypeError(Format("{1}  Invalid argument {2} (expected Array).", Sig, _Validate_TypeRepr(Clauses[A_Index])), -1)
        }
        if (not Clauses[A_Index].Count() == 2)
        {
            throw new ValueError(Format("{1}  Invalid argument contains {2} elements (expected 2).", Sig, Clauses[A_Index].Count()), -1)
        }
        if (   not (    ComObjType(Clauses[A_Index][1]) == ""
                    and HasMethod(Clauses[A_Index][1], "Call"))
            or not (    ComObjType(Clauses[A_Index][2]) == ""
                    and HasMethod(Clauses[A_Index][2], "Call")))
        {
            throw new TypeError(Format("{1}  Invalid argument contains {2} and {3} elements (expected function objects).", Sig, _Validate_TypeRepr(Clauses[A_Index][1]), _Validate_TypeRepr(Clauses[A_Index][2])), -1)
        }
    }
    return Clauses.Count() == 0 ? Func_Const("")
         : Func_Bind(Func("_Func_CCondAux"), Clauses)
}

_Func_FailSafeAux(Funcs, Args*)
{
    local
    Failed := true
   ,Index  := 1
    while (Failed and Index <= Funcs.Count())
    {
        try
        {
            Result := Funcs[Index].Call(Args*)
           ,Failed := false
        }
        catch Exc
        {
            ++Index
        }
    }
    if (Failed)
    {
        throw Exc
    }
    return Result
}

Func_FailSafe(Funcs*)
{
    local
    global ArgsUnderflowError
    static Sig := "Func_FailSafe(Funcs*)"
    _Validate_FuncArgs(Sig, Funcs)
    if (Funcs.Count() == 0)
    {
        throw new ArgsUnderflowError(Sig, -1)
    }
    else if (Funcs.Count() == 1)
    {
        Result := Func_Bind(Funcs[1])
    }
    else
    {
        Result := Func_Bind(Func("_Func_FailSafeAux"), Funcs)
    }
    return Result
}

Func_Default(Func, Default)
{
    local
    static Sig := "Func_Default(Func, Default)"
    _Validate_FuncArg(Sig, "Func", Func)
    return Func_Comp(Func_CIf(Func("Op_Eq").Bind("")
                             ,Func_Const(Default)
                             ,Func("Func_Id"))
                    ,Func_FailSafe(Func, Func_Const(Default)))
}
