#Include <IsInstance>
#Include <_Validate>
#Include <_Sinks>
#Include <Array>

class List
{
    ; This makes IsInstance(Value, Class) work correctly for Lists.

    class Enumerator
    {
        __New(List)
        {
            local
            this._Index := 1
           ,this._List  := List
            return this
        }

        Next(byref Index, byref Value := "")
        {
            local
            if (not List_IsEmpty(this._List))
            {
                Index       := this._Index
               ,Value       := List_First(this._List)
               ,this._Index := this._Index + 1
               ,this._List  := List_Rest(this._List)
               ,Result      := true
            }
            else
            {
                Result := false
            }
            return Result
        }
    }

    _NewEnum()
    {
        local
        global List
        return new List.Enumerator(this)
    }
}

class ListNull extends List
{
    ; This is the constant singleton empty List.
}

class ListCons extends List
{
    __New(First, Rest)
    {
        local
        this._First := First
       ,this._Rest  := Rest
        return this
    }
}

List(Args*)
{
    local
    global ListNull
    static Sig := "List(Args*)"
    _Validate_Args(Sig, Args)
    return Array_FoldR(Func("List_Prepend"), ListNull, Args)
}

List_Prepend(First, Rest)
{
    local
    global ListCons
    static Sig := "List_Prepend(First, Rest)"
    _Validate_ListArg(Sig, "Rest", Rest)
    return new ListCons(First, Rest)
}

List_IsList(Value)
{
    local
    global List
    return IsInstance(Value, List)
}

List_IsEmpty(Value)
{
    local
    global ListNull
    return Value == ListNull
}

List_First(List)
{
    local
    static Sig := "List_First(List)"
    _Validate_NonEmptyListArg(Sig, "List", List)
    return List._First
}

List_Rest(List)
{
    local
    static Sig := "List_Rest(List)"
    _Validate_NonEmptyListArg(Sig, "List", List)
    return List._Rest
}

List_ToArray(List)
{
    local
    static Sig := "List_ToArray(List)"
    _Validate_ListArg(Sig, "List", List)
    return _Sinks_ToArray(List)
}
