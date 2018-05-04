#Include <IsInteger>
#Include <IsNumber>
#Include <IsString>
#Include <Type>
#Include <IsInstance>
#Include <HasMethod>
#Include <_IsArray>

;-------------------------------------------------------------------------------
; Constants

global inf := 9.9 ** 999
global nan := inf - inf

;-------------------------------------------------------------------------------
; Types

class Exception
{
    Message := "Exception"

    __New(Extra := "", Offset := 0)
    {
        local
        this.Extra := Extra
       ,Exc := Exception("", Offset + -1)
       ,this.File := Exc.File
       ,this.Line := Exc.Line
       ,this.What := Exc.What
        return this
    }
}

class Error extends Exception
{
    Message := "Error"
}

class DefectError extends Error
{
    Message := "Defect Error"
}

class TypeError extends DefectError
{
    Message := "Type Error"
}

class MemberError extends TypeError
{
    Message := "Member Error"
}

class PropError extends MemberError
{
    Message := "Prop Error"
}

class MethodError extends MemberError
{
    Message := "Method Error"
}

class ValueError extends DefectError
{
    Message := "Value Error"
}

class DivisionByZeroError extends ValueError
{
    Message := "Division by Zero Error"
}

class LookupError extends ValueError
{
    Message := "Lookup Error"
}

class BoundsError extends LookupError
{
    Message := "Bounds Error"
}

class KeyError extends LookupError
{
    Message := "Key Error"
}

class CallError extends DefectError
{
    Message := "Call Error"
}

class ArityError extends CallError
{
    Message := "Arity Error"
}

class ArgsUnderflowError extends ArityError
{
    Message := "Args Underflow Error"
}

class ArgsOverflowError extends ArityError
{
    Message := "Args Overflow Error"
}

class MissingArgError extends CallError
{
    Message := "Missing Arg Error"
}

class SystemError extends Error
{
    Message := "System Error"
}

class Termination extends Exception
{
    Message := "Termination"
}

class GoodFunc
{
    __New(Func, Args*)
    {
        local
        global GoodFunc
        if (IsInstance(Func, GoodFunc))
        {
            if (Args.Length() == 0)
            {
                Result := Func
            }
            else
            {
                this._Func     := Func._Func
               ,this._Bindings := []
               ,this._Bindings.Push(Func._Bindings*)
               ,this._Bindings.Push(Args*)
               ,Result := this
            }
        }
        else
        {
            this._Func     := Func
           ,this._Bindings := []
           ,this._Bindings.Push(Args*)
           ,Result := this
        }
        return Result
    }

    Bind(Args*)
    {
        local
        global GoodFunc
        return new GoodFunc(this, Args*)
    }

    Call(Args*)
    {
        local
        FullArgs := []
       ,FullArgs.Push(this._Bindings*)
       ,FullArgs.Push(Args*)
        return this._Func.Call(FullArgs*)
    }

    __Get(Key)
    {
        local
        if (Key != "base" and not this.base.HasKey(Key))
        {
            ; Members we did not override pass through.
            return this._Func[Key]
        }
    }

    __Call(Method, Args*)
    {
        local
        if (Method == "")
        {
            ; %Func%(Args*)
            return this.Call(Args*)
        }
    }
}

;-------------------------------------------------------------------------------
; Auxiliary Functions

_Validate_TypeRepr(Value)
{
    local
    static TypeNames := {"ListNull":    "List"
                        ,"ListCons":    "List"
                        ,"StreamThunk": "Stream"
                        ,"StreamNull":  "Stream"
                        ,"StreamCons":  "Stream"}
    return TypeNames.HasKey(Type := Type(Value)) ? TypeNames[Type] : Type
}

_Validate_ValueRepr(Value)
{
    local
    if (IsObject(Value))
    {
        Result := _Validate_TypeRepr(Value)
    }
    else if (IsNumber(Value))
    {
        ; AutoHotkey represents -inf and inf as desired, but not nan.
        Result := Value != Value ? "nan" : Value
    }
    else
    {
        static EscSeqs := {"`a": "``a"
                          ,"`b": "``b"
                          ,"`t": "``t"
                          ,"`n": "``n"
                          ,"`v": "``v"
                          ,"`f": "``f"
                          ,"`r": "``r"
                          ,"""": """"""
                          ,"``": "````"}
        Result := """"
        for _, Char in StrSplit(Value)
        {
            Result .= EscSeqs.HasKey(Char) ? EscSeqs[Char]
                    : Char
        }
        Result .= """"
    }
    return Result
}

;-------------------------------------------------------------------------------
; Type Error Reporting

_Validate_NumberArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not IsNumber(Value))
    {
        throw new TypeError(Format("{1}  {2} is not a number.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_NumberArgs(Sig, Args)
{
    local
    global MissingArgError, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not IsNumber(Args[A_Index]))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

_Validate_IntegerArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not IsInteger(Value))
    {
        throw new TypeError(Format("{1}  {2} is not an Integer.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_IntegerArgs(Sig, Args)
{
    local
    global MissingArgError, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not IsInteger(Args[A_Index]))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

_Validate_StringArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not IsString(Value))
    {
        throw new TypeError(Format("{1}  {2} is not a String.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_StringArgs(Sig, Args)
{
    local
    global MissingArgError, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not IsString(Args[A_Index]))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

_Validate_FuncArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not (ComObjType(Value) == "" and HasMethod(Value, "Call")))
    {
        throw new TypeError(Format("{1}  {2} is not a Func.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_FuncArgs(Sig, Args)
{
    local
    global MissingArgError, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not (ComObjType(Args[A_Index]) == "" and HasMethod(Args[A_Index], "Call")))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

_Validate_ObjArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not IsObject(Value))
    {
        throw new TypeError(Format("{1}  {2} is not an object.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_ObjectArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not Type(Value) == "Object")
    {
        throw new TypeError(Format("{1}  {2} is not an Object.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_BadArrayArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not Type(Value) == "Object")
    {
        throw new TypeError(Format("{1}  {2} is not an Array.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_FuncBadArrayArg(Sig, Var, Value)
{
    local
    global TypeError
    try
    {
        _Validate_BadArrayArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    for _, Element in Value
    {
        if (not (ComObjType(Element) == "" and HasMethod(Element, "Call")))
        {
            throw new TypeError(Format("{1}  {2} contains an invalid element {3}.", Sig, Var, _Validate_TypeRepr(Element)), -2)
        }
    }
}

_Validate_ArrayArg(Sig, Var, Value)
{
    local
    global TypeError
    if (not _IsArray(Value))
    {
        throw new TypeError(Format("{1}  {2} is not an Array.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_ArrayArgs(Sig, Args)
{
    local
    global MissingArgError, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not _IsArray(Args[A_Index]))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

_Validate_ListArg(Sig, Var, Value)
{
    local
    global List, TypeError
    if (not IsInstance(Value, List))
    {
        throw new TypeError(Format("{1}  {2} is not a List.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_StreamArg(Sig, Var, Value)
{
    local
    global Stream, TypeError
    if (not IsInstance(Value, Stream))
    {
        throw new TypeError(Format("{1}  {2} is not a Stream.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_StreamArgs(Sig, Args)
{
    local
    global MissingArgError, Stream, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not IsInstance(Args[A_Index], Stream))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

_Validate_DictArg(Sig, Var, Value)
{
    local
    global Dict, TypeError
    if (not IsInstance(Value, Dict))
    {
        throw new TypeError(Format("{1}  {2} is not a Dict.  {2}'s type is {3}.", Sig, Var, _Validate_TypeRepr(Value)), -2)
    }
}

_Validate_DictArgs(Sig, Args)
{
    local
    global MissingArgError, Dict, TypeError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
        if (not IsInstance(Args[A_Index], Dict))
        {
            throw new TypeError(Format("{1}  Invalid argument {2}.", Sig, _Validate_TypeRepr(Args[A_Index])), -2)
        }
    }
}

;-------------------------------------------------------------------------------
; Value Error Reporting

_Validate_FiniteNumberArg(Sig, Var, Value)
{
    local
    global inf, ValueError
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value == -inf or Value == inf or Value != Value)
    {
        throw new ValueError(Format("{1}  {2} cannot be converted to an Integer.  {2} is {3}.", Sig, Var, _Validate_ValueRepr(Value)), -2)
    }
}

_Validate_DivisorArg(Sig, Var, Value)
{
    local
    global DivisionByZeroError
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value == 0)
    {
        throw new DivisionByZeroError(Sig, -2)
    }
}

_Validate_NonZeroNumberArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value == 0)
    {
        throw new ValueError(Format("{1}  {2} is 0.", Sig, Var), -2)
    }
}

_Validate_NonNegNumberArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value < 0)
    {
        throw new ValueError(Format("{1}  {2} is negative.  {2} is {3}.", Sig, Var, Value), -2)
    }
}

_Validate_NonNegIntegerArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_IntegerArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value < 0)
    {
        throw new ValueError(Format("{1}  {2} is negative.  {2} is {3}.", Sig, Var, Value), -2)
    }
}

_Validate_PosNumberArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value <= 0)
    {
        throw new ValueError(Format("{1}  {2} is not positive.  {2} is {3}.", Sig, Var, Value), -2)
    }
}

_Validate_Neg1To1NumberArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_NumberArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value == Value and not (-1 <= Value and Value <= 1))
    {
        throw new ValueError(Format("{1}  {2} is not in the interval [-1, 1].  {2} is {3}.", Sig, Var, Value), -2)
    }
}

_Validate_IdentifierArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_StringArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (not Value ~= "S)^[\p{L}_][\p{Xan}_]*$")
    {
        throw new ValueError(Format("{1}  {2} is not an identifier.  {2} is {3}.", Sig, Var, _Validate_ValueRepr(Value)), -2)
    }
}

_Validate_NonEmptyArrayArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_ArrayArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value.Count() == 0)
    {
        throw new ValueError(Format("{1}  {2} is an empty Array.", Sig, Var), -2)
    }
}

_Validate_NonEmptyListArg(Sig, Var, Value)
{
    local
    global ListNull, ValueError
    try
    {
        _Validate_ListArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value == ListNull)
    {
        throw new ValueError(Format("{1}  {2} is the empty List.", Sig, Var), -2)
    }
}

_Validate_NonEmptyStreamArg(Sig, Var, Value)
{
    local
    global StreamNull, ValueError
    try
    {
        _Validate_StreamArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value == StreamNull)
    {
        throw new ValueError(Format("{1}  {2} is the empty Stream.", Sig, Var), -2)
    }
}

_Validate_NonEmptyDictArg(Sig, Var, Value)
{
    local
    global ValueError
    try
    {
        _Validate_DictArg(Sig, Var, Value)
    }
    catch Exc
    {
        throw Exc.__New(Exc.Extra, -2)
    }
    if (Value.Count() == 0)
    {
        throw new ValueError(Format("{1}  {2} is an empty Dict.", Sig, Var), -2)
    }
}

;-------------------------------------------------------------------------------
; Call Error Reporting

_Validate_Args(Sig, Args)
{
    local
    global MissingArgError
    loop % Args.Length()
    {
        if (not Args.HasKey(A_Index))
        {
            throw new MissingArgError(Sig, -2)
        }
    }
}

;-------------------------------------------------------------------------------
; Error Rewriting

_Validate_BlameOrdCmp(Sig, Func)
{
    local
    try
    {
        Result := Func.Call()
    }
    catch Exc
    {
        RegExMatch(Exc.Extra, "S)Ordered comparison is undefined between instances of .+ and .+\.$", Match)
        throw Exc.__New(Format("{1}  {2}", Sig, Match), -2)
    }
    return Result
}

_Validate_BlameKey(Sig, Func)
{
    local
    global KeyError
    try
    {
        Result := Func.Call()
    }
    catch Exc
    {
        if (IsInstance(Exc, KeyError))
        {
            RegExMatch(Exc.Extra, "S)Key not found.  Key is .+\.$", Match)
            throw Exc.__New(Format("{1}  {2}", Sig, Match), -2)
        }
        else
        {
            throw Exc
        }
    }
    return Result
}

_Validate_BlamePath(Sig, Func)
{
    local
    global TypeError, KeyError
    try
    {
        Result := Func.Call()
    }
    catch Exc
    {
        if (IsInstance(Exc, TypeError) or IsInstance(Exc, KeyError))
        {
            throw Exc.__New(Format("{1}  Invalid Path.", Sig), -2)
        }
        else
        {
            throw Exc
        }
    }
    return Result
}
