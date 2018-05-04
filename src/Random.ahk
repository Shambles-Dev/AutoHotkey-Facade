#Include <_Validate>

Random(Min := 0, Max := 2147483647)
{
    local
    static Sig := "Random([Min, Max])"
    _Validate_NumberArg(Sig, "Min", Min)
   ,_Validate_NumberArg(Sig, "Max", Max)
    Random Result, %Min%, %Max%
    return Result
}

RandomSeed(Seed)
{
    local
    static Sig := "RandomSeed(Seed)"
    _Validate_NonNegIntegerArg(Sig, "Seed", Seed)
    Random ,, %Seed%
    return Seed
}

Random_Shuffle(Array)
{
    ; This is the Fisher–Yates shuffle.
    local
    static Sig := "Random_Shuffle(Array)"
    _Validate_ArrayArg(Sig, "Array", Array)
   ,Result := Array.Clone()
    loop % Array.Count() - 1
    {
        J               := Random(A_Index, Array.Count())
       ,Temp            := Result[A_Index]
       ,Result[A_Index] := Result[J]
       ,Result[J]       := Temp
    }
    return Result
}
