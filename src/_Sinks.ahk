#Include <Op>
#Include <_Dict>

_Sinks_Count(Sequence)
{
    local
    Result := 0
    for Result in Sequence
    {
    }
    return Result
}

_Sinks_All(Pred, Sequence)
{
    local
    Result := true
   ,Enum   := Sequence._NewEnum()
    while (Result and Enum.Next(_, Value))
    {
        Result := Pred.Call(Value)
    }
    return Result
}

_Sinks_Exists(Pred, Sequence)
{
    local
    Result := false
   ,Enum   := Sequence._NewEnum()
    while (not Result and Enum.Next(_, Value))
    {
        Result := Pred.Call(Value)
    }
    return Result
}

_Sinks_MinMaxBy(Pred, Func, Sequence)
{
    local
    Enum := Sequence._NewEnum()
   ,Enum.Next(_, X)
   ,Cache  := Func.Call(X)
   ,Result := X
    while (Enum.Next(_, X))
    {
        FX := Func.Call(X)
        if (Pred.Call(FX, Cache))
        {
            Cache  := FX
           ,Result := X
        }
    }
    return Result
}

_Sinks_MinBy(Func, Sequence)
{
    local
    return _Sinks_MinMaxBy(Func("Op_Lt"), Func, Sequence)
}

_Sinks_MaxBy(Func, Sequence)
{
    local
    return _Sinks_MinMaxBy(Func("Op_Gt"), Func, Sequence)
}

_Sinks_MinMaxKBy(Pred, Func, K, Sequence)
{
    local
    ; Using heaps would be more efficient but less maintainable.
    Result := []
    if (K != 0)
    {
        Cache := []
        for _, X in Sequence
        {
            FX := Func.Call(X)
            if (Result.Count() != K or not Pred.Call(Cache[Cache.Count()], FX))
            {
                if (Result.Count() == 0)
                {
                    Cache[1]  := FX
                   ,Result[1] := X
                }
                else
                {
                    LowerBound := 1
                   ,UpperBound := Cache.Count()
                    loop
                    {
                        Guess := LowerBound + Op_FloorDiv(UpperBound - LowerBound, 2)
                        if (Pred.Call(Cache[Guess], FX))
                        {
                            LowerBound := Guess + 1
                        }
                        else
                        {
                            UpperBound := Guess - 1
                        }
                    }
                    until (LowerBound > UpperBound)
                    Cache.InsertAt(LowerBound, FX)
                   ,Result.InsertAt(LowerBound, X)
                    if (Result.Count() > K)
                    {
                        Cache.Pop()
                       ,Result.Pop()
                    }
                }
            }
        }
    }
    return Result
}

_Sinks_MinKBy(Func, K, Sequence)
{
    local
    return _Sinks_MinMaxKBy(Func("Op_Le"), Func, K, Sequence)
}

_Sinks_MaxKBy(Func, K, Sequence)
{
    local
    return _Sinks_MinMaxKBy(Func("Op_Ge"), Func, K, Sequence)
}

_Sinks_ToArray(Sequence)
{
    local
    Result := []
    for _, Value in Sequence
    {
        Result.Push(Value)
    }
    return Result
}

_Sinks_GroupByWMap(ByFunc, MapFunc, Sequence)
{
    local
    global Dict
    Result := new Dict()
    for _, X in Sequence
    {
        Key   := ByFunc.Call(X)
       ,Value := MapFunc.Call(X)
        if (Result.HasKey(Key))
        {
            Result.Get(Key).Push(Value)
        }
        else
        {
            Result.Set(Key, [Value])
        }
    }
    return Result
}

_Sinks_GroupByWFoldL1Map(ByFunc, FoldLFunc, MapFunc, Sequence)
{
    local
    global Dict
    Result := new Dict()
    for _, X in Sequence
    {
        Key   := ByFunc.Call(X)
       ,Value := MapFunc.Call(X)
        if (Result.HasKey(Key))
        {
            Result.Set(Key, FoldLFunc.Call(Result.Get(Key), Value))
        }
        else
        {
            Result.Set(Key, Value)
        }
    }
    return Result
}
