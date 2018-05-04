#Include <IsInteger>
#Include <_Validate>
#Include <Op>

global e   := 2.718281828459045
global phi := 1.618033988749895
global pi  := 3.141592653589793

Math_Abs(X)
{
    local
    global ValueError
    static Sig := "Math_Abs(X)"
    _Validate_NumberArg(Sig, "X", X)
    if (IsInteger(X) and X == -9223372036854775808)
    {
        throw new ValueError(Format("{1}  X has no 64-bit non-negative equal in magnitude.  X is -9223372036854775808.", Sig), -1)
    }
    return Abs(X)
}

Math_Ceil(X)
{
    local
    static Sig := "Math_Ceil(X)"
    _Validate_FiniteNumberArg(Sig, "X", X)
    return Ceil(X)
}

Math_Exp(X)
{
    local
    static Sig := "Math_Exp(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Exp(X)
}

Math_Floor(X)
{
    local
    static Sig := "Math_Floor(X)"
    _Validate_FiniteNumberArg(Sig, "X", X)
    return Floor(X)
}

Math_Log(X)
{
    local
    static Sig := "Math_Log(X)"
    _Validate_PosNumberArg(Sig, "X", X)
    return Log(X)
}

Math_Ln(X)
{
    local
    static Sig := "Math_Ln(X)"
    _Validate_PosNumberArg(Sig, "X", X)
    return Ln(X)
}

Math_Max(Numbers*)
{
    local
    global ArgsUnderflowError
    static Sig := "Math_Max(Numbers*)"
    if (Numbers.Count() == 0)
    {
        throw new ArgsUnderflowError(Sig, -1)
    }
    _Validate_NumberArgs(Sig, Numbers)
    return Max(Numbers*)
}

Math_Min(Numbers*)
{
    local
    global ArgsUnderflowError
    static Sig := "Math_Min(Numbers*)"
    _Validate_NumberArgs(Sig, Numbers)
    if (Numbers.Count() == 0)
    {
        throw new ArgsUnderflowError(Sig, -1)
    }
    return Min(Numbers*)
}

Math_Mod(X, Y)
{
    local
    static Sig := "Math_Mod(X, Y)"
    _Validate_NumberArg(Sig, "X", X)
   ,_Validate_DivisorArg(Sig, "Y", Y)
    return X - Y * Op_FloorDiv(X, Y)
}

_Math_CeilF(X)
{
    local
    return DllCall("msvcrt\ceil", "Double", X, "Double")
}

_Math_FloorF(X)
{
    local
    return DllCall("msvcrt\floor", "Double", X, "Double")
}

Math_Round(X, N := 0)
{
    local
    global inf
    static Sig := "Math_Round(X [, N])"
    _Validate_NumberArg(Sig, "X", X)
   ,_Validate_IntegerArg(Sig, "N", N)
    if (X == -inf or X == inf or X != X)
    {
        if (N > 0)
        {
            Result := X
        }
        else
        {
            _Validate_FiniteNumberArg(Sig, "X", X)
        }
    }
    else
    {
        ; Mod(X, Y) is intentionally used as floating-point remainder.  Genuine
        ; floating-point modulo would also work.
        Multiplier    := N == 0 ? 1 : 10 ** (N + 0.0)
       ,MovedPoint    := X * Multiplier
       ,EMod          := Mod(Abs(MovedPoint), 1)
        ; DLLCalls are used to avoid integer overflow.
       ,Rounded       := EMod < 0.5 ? X >= 0 ? _Math_FloorF(MovedPoint) : _Math_CeilF(MovedPoint)
                       : EMod > 0.5 ? X >= 0 ? _Math_CeilF(MovedPoint)  : _Math_FloorF(MovedPoint)
                       : Mod(_Math_FloorF(MovedPoint), 2) == 0 ? _Math_FloorF(MovedPoint) : _Math_CeilF(MovedPoint)
       ,RestoredPoint := Rounded / Multiplier
        if (N > 0)
        {
            ; Format does not work.
            Halves := StrSplit(RestoredPoint, ".")
           ,Halves[2] := SubStr(Halves[2], 1, N)
            while (StrLen(Halves[2]) < N)
            {
                Halves[2] .= "0"
            }
            Result := Halves[1] . "." . Halves[2]
        }
        else
        {
            Result := RestoredPoint & -1
        }
    }
    return Result
}

Math_Sqrt(X)
{
    local
    static Sig := "Math_Sqrt(X)"
    _Validate_NonNegNumberArg(Sig, "X", X)
    return Sqrt(X)
}

Math_Sin(X)
{
    local
    static Sig := "Math_Sin(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Sin(X)
}

Math_Cos(X)
{
    local
    static Sig := "Math_Cos(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Cos(X)
}

Math_Tan(X)
{
    local
    static Sig := "Math_Tan(X)"
    _Validate_NumberArg(Sig, "X", X)
    return Tan(X)
}

Math_ASin(X)
{
    local
    static Sig := "Math_ASin(X)"
    _Validate_Neg1To1NumberArg(Sig, "X", X)
    return ASin(X)
}

Math_ACos(X)
{
    local
    static Sig := "Math_ACos(X)"
    _Validate_Neg1To1NumberArg(Sig, "X", X)
    return ACos(X)
}

Math_ATan(X)
{
    local
    static Sig := "Math_ATan(X)"
    _Validate_NumberArg(Sig, "X", X)
    return ATan(X)
}
