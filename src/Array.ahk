#Include <IsInteger>
#Include <Type>
#Include <_IsArray>
#Include <_Validate>
#Include <Op>
#Include <Func>
#Include <_Push>
#Include <_Dict>
#Include <_DedupBy>
#Include <_Sinks>

Array_FromBadArray(Func, Array, Length := "")
{
    local
    global ValueError
    static Sig := "Array_FromBadArray(Func, Array [, Length])"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_BadArrayArg(Sig, "Array", Array)
   ,Length := Length == "" ? Array.Length() : Length
   ,_Validate_NonNegIntegerArg(Sig, "Length", Length)
    if (Length < Array.Length())
    {
        throw new ValueError(Format("{1}  Length < Array length.", Sig), -1)
    }
    Result := []
    loop % Length
    {
        Result[A_Index] := Array.HasKey(A_Index) ? Array[A_Index]
                         : Func.Call(A_Index - 1)
    }
    return Result
}

Array_ToBadArray(Pred, Array)
{
    local
    static Sig := "Array_ToBadArray(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_BadArrayArg(Sig, "Array", Array)
   ,Result := []
    for Index, Value in Array
    {
        if (    IsInteger(Index)
            and 1 <= Index
            and not Pred.Call(Index - 1, Value))
        {
            Result[Index] := Value
        }
    }
    return Result
}

Array_IsArray(Value)
{
    local
    return _IsArray(Value)
}

Array_IsEmpty(Value)
{
    local
    return Type(Value) == "Object" and Value.Count() == 0
}

Array_Count(Array)
{
    local
    static Sig := "Array_Count(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
    return Array.Count()
}

Array_Get(I, Array)
{
    local
    global BoundsError
    static Sig := "Array_Get(I, Array)"
    _Validate_IntegerArg(Sig, "I", I)
   ,_Validate_ArrayArg(Sig, "Array", Array)
   ,BadIndex := I >= 0 ? 1 + I : Array.Count() + 1 + I
    if (not Op_Le(1, BadIndex, Array.Count()))
    {
        throw new BoundsError(Format("{1}  I is out of bounds.  I is {2}.", Sig, I), -1)
    }
    return Array[BadIndex]
}

Array_Interpose(Between, Array, BeforeLast := "")
{
    local
    static Sig := "Array_Interpose(Between, Array [, BeforeLast])"
    _Validate_ArrayArg(Sig, "Array", Array)
   ,Result := []
    loop % Array.Count()
    {
        if (A_Index != 1)
        {
            if (A_Index == Array.Count() and BeforeLast != "")
            {
                Result.Push(BeforeLast)
            }
            else
            {
                Result.Push(Between)
            }
        }
        Result.Push(Array[A_Index])
    }
    return Result
}

_Array_ConcatAux(A, X)
{
    local
    A.Push(X*)
    return A
}

Array_Concat(Arrays*)
{
    local
    static Sig := "Array_Concat(Arrays*)"
    _Validate_ArrayArgs(Sig, Arrays)
    return Array_FoldL(Func("_Array_ConcatAux"), [], Arrays)
}

_Array_FlattenAux(A, X)
{
    local
    if (Array_IsArray(X))
    {
        A.Push(Array_Flatten(X)*)
    }
    else
    {
        A.Push(X)
    }
    return A
}

Array_Flatten(Array)
{
    local
    static Sig := "Array_Flatten(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
   ,Result := Array_FoldL(Func("_Array_FlattenAux"), [], Array)
    return Result
}

Array_All(Pred, Array)
{
    local
    static Sig := "Array_All(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return _Sinks_All(Pred, Array)
}

Array_Exists(Pred, Array)
{
    local
    static Sig := "Array_Exists(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return _Sinks_Exists(Pred, Array)
}

Array_FoldL(Func, Init, Array)
{
    local
    static Sig := "Array_FoldL(Func, Init, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
   ,A     := Init
   ,Index := 1
    while (Index <= Array.Count())
    {
        A := Func.Call(A, Array[Index])
       ,++Index
    }
    return A
}

Array_FoldR(Func, Init, Array)
{
    local
    static Sig := "Array_FoldR(Func, Init, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
   ,A     := Init
   ,Index := Array.Count()
    while (Index >= 1)
    {
        A := Func.Call(Array[Index], A)
       ,--Index
    }
    return A
}

Array_FoldL1(Func, Array)
{
    local
    static Sig := "Array_FoldL1(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_NonEmptyArrayArg(Sig, "Array", Array)
   ,A     := Array[1]
   ,Index := 2
    while (Index <= Array.Count())
    {
        A := Func.Call(A, Array[Index])
       ,++Index
    }
    return A
}

Array_FoldR1(Func, Array)
{
    local
    static Sig := "Array_FoldR1(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_NonEmptyArrayArg(Sig, "Array", Array)
   ,A     := Array[Array.Count()]
   ,Index := Array.Count() - 1
    while (Index >= 1)
    {
        A := Func.Call(Array[Index], A)
       ,--Index
    }
    return A
}

_Array_ScanLAux(Func, A, X)
{
    local
    A.Push(Func.Call(A[A.Count()], X))
    return A
}

Array_ScanL(Func, Init, Array)
{
    local
    static Sig := "Array_ScanL(Func, Init, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_FoldL(Func("_Array_ScanLAux").Bind(Func)
                      ,[Init]
                      ,Array)
}

_Array_ScanRAux(Func, X, A)
{
    local
    A.Push(Func.Call(X, A[A.Count()]))
    return A
}

Array_ScanR(Func, Init, Array)
{
    local
    static Sig := "Array_ScanR(Func, Init, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_Reverse(Array_FoldR(Func("_Array_ScanRAux").Bind(Func)
                                    ,[Init]
                                    ,Array))
}

_Array_ScanL1Aux(Func, A, X)
{
    local
    if (A.Count() == 0)
    {
        A.Push(X)
    }
    else
    {
        A.Push(Func.Call(A[A.Count()], X))
    }
    return A
}

Array_ScanL1(Func, Array)
{
    local
    static Sig := "Array_ScanL1(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    if (Array.Count() > 0)
    {
        Result := Array_FoldL(Func("_Array_ScanL1Aux").Bind(Func)
                             ,[]
                             ,Array)
    }
    return Result
}

_Array_ScanR1Aux(Func, X, A)
{
    local
    if (A.Count() == 0)
    {
        A.Push(X)
    }
    else
    {
        A.Push(Func.Call(X, A[A.Count()]))
    }
    return A
}

Array_ScanR1(Func, Array)
{
    local
    static Sig := "Array_ScanR1(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    if (Array.Count() > 0)
    {
        Result := Array_Reverse(Array_FoldR(Func("_Array_ScanR1Aux").Bind(Func)
                                           ,[]
                                           ,Array))
    }
    return Result
}

Array_MinBy(Func, Array)
{
    local
    static Sig := "Array_MinBy(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_NonEmptyArrayArg(Sig, "Array", Array)
    return _Sinks_MinBy(Func, Array)
}

Array_MaxBy(Func, Array)
{
    local
    static Sig := "Array_MaxBy(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_NonEmptyArrayArg(Sig, "Array", Array)
    return _Sinks_MaxBy(Func, Array)
}

Array_MinKBy(Func, K, Array)
{
    local
    static Sig := "Array_MinKBy(Func, K, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_NonNegIntegerArg(Sig, "K", K)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return _Sinks_MinKBy(Func, K, Array)
}

Array_MaxKBy(Func, K, Array)
{
    local
    static Sig := "Array_MaxKBy(Func, K, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_NonNegIntegerArg(Sig, "K", K)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return _Sinks_MaxKBy(Func, K, Array)
}

_Array_FilterAux(Pred, A, X)
{
    local
    if (Pred.Call(X))
    {
        A.Push(X)
    }
    return A
}

Array_Filter(Pred, Array)
{
    local
    static Sig := "Array_Filter(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_ArrayArg(Sig, "Array", Array)
   ,Result := Array_FoldL(Func("_Array_FilterAux").Bind(Pred), [], Array)
    return Result
}

Array_FilterApply(Pred, Array)
{
    local
    static Sig := "Array_FilterApply(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_Filter(Func("Func_Apply").Bind(Pred), Array)
}

Array_DedupBy(Func, Array)
{
    local
    global Dict
    static Sig := "Array_DedupBy(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_Filter(Func("_DedupBy").Bind(new Dict(), Func), Array)
}

Array_Map(Func, Array)
{
    local
    static Sig := "Array_Map(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_ZipWith(Func, Array)
}

Array_MapApply(Func, Array)
{
    local
    static Sig := "Array_MapApply(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_Map(Func("Func_Apply").Bind(Func), Array)
}

Array_ZipWith(Func, Arrays*)
{
    local
    global ArgsUnderflowError
    static Sig := "Array_ZipWith(Func, Arrays*)"
    _Validate_FuncArg(Sig, "Func", Func)
    if (Arrays.Count() == 0)
    {
        throw new ArgsUnderflowError(Sig, -1)
    }
    _Validate_ArrayArgs(Sig, Arrays)
   ,Result := []
    loop % Array_MinBy(Func("Array_Count"), Arrays).Count()
    {
        N := A_Index
       ,Args := []
        loop % Arrays.Count()
        {
            Args.Push(Arrays[A_Index][N])
        }
        Result.Push(Func.Call(Args*))
    }
    return Result
}

Array_ConcatZipWith(Func, Arrays*)
{
    local
    global ArgsUnderflowError
    static Sig := "Array_ConcatZipWith(Func, Arrays*)"
    _Validate_FuncArg(Sig, "Func", Func)
    if (Arrays.Count() == 0)
    {
        throw new ArgsUnderflowError(Sig, -1)
    }
    _Validate_ArrayArgs(Sig, Arrays)
   ,Result := []
    loop % Array_MinBy(Func("Array_Count"), Arrays).Count()
    {
        N := A_Index
       ,Args := []
        loop % Arrays.Count()
        {
            Args.Push(Arrays[A_Index][N])
        }
        Result.Push(Func.Call(Args*)*)
    }
    return Result
}

Array_Reverse(Array)
{
    local
    static Sig := "Array_Reverse(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
    return Array_FoldR(Func_Flip(Func("_Push")), [], Array)
}

Array_Sort(Pred, Array)
{
    ; This is bottom-up merge sort.
    local
    ; Using Timsort would be more efficient but less maintainable.
    static Sig := "Array_Sort(Pred, Array)"
    _Validate_FuncArg(Sig, "Pred", Pred)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    ; Always return a copy.
   ,Result := Array.Clone()
    if (Array.Count() > 1)
    {
        RunLength := 1
       ,Index     := 1
       ,WorkArray := []
        while (RunLength < Array.Count())
        {
            while (Index <= Array.Count())
            {
                LeftFirst  := Index
               ,LeftLast   := Min(LeftFirst + RunLength - 1,  Array.Count())
               ,RightFirst := Min(LeftLast + 1,               Array.Count() + 1)
               ,RightLast  := Min(RightFirst + RunLength - 1, Array.Count())
                while (Index <= RightLast)
                {
                    if (    LeftFirst <= LeftLast
                        and (   RightFirst > RightLast
                             or Pred.Call(Result[LeftFirst], Result[RightFirst])))
                    {
                        WorkArray[Index] := Result[LeftFirst]
                       ,++LeftFirst
                    }
                    else
                    {
                        WorkArray[Index] := Result[RightFirst]
                       ,++RightFirst
                    }
                    ++Index
                }
            }
            RunLength *= 2
           ,Index     := 1
           ,Temp      := Result
           ,Result    := WorkArray
           ,WorkArray := Temp
        }
    }
    return Result
}

Array_GroupBy(Func, Array)
{
    local
    static Sig := "Array_GroupBy(Func, Array)"
    _Validate_FuncArg(Sig, "Func", Func)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return Array_GroupByWMap(Func, Func("Func_Id"), Array)
}

Array_GroupByWMap(ByFunc, MapFunc, Array)
{
    local
    static Sig := "Array_GroupByWMap(ByFunc, MapFunc, Array)"
    _Validate_FuncArg(Sig, "ByFunc", ByFunc)
   ,_Validate_FuncArg(Sig, "MapFunc", MapFunc)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return _Sinks_GroupByWMap(ByFunc, MapFunc, Array)
}

Array_GroupByWFoldL1Map(ByFunc, FoldLFunc, MapFunc, Array)
{
    local
    static Sig := "Array_GroupByWFoldL1Map(ByFunc, FoldLFunc, MapFunc, Array)"
    _Validate_FuncArg(Sig, "ByFunc", ByFunc)
   ,_Validate_FuncArg(Sig, "FoldLFunc", FoldLFunc)
   ,_Validate_FuncArg(Sig, "MapFunc", MapFunc)
   ,_Validate_ArrayArg(Sig, "Array", Array)
    return _Sinks_GroupByWFoldL1Map(ByFunc, FoldLFunc, MapFunc, Array)
}
