#Include <Type>

_IsArray(Value)
{
    local
    ; Avoid calling methods.
    Result := Type(Value) == "Object"
    ; Test whether all indices exist.
   ,Index  := 1
    while (Result and Index <= ObjLength(Value))
    {
        Result := ObjHasKey(Value, Index)
       ,++Index
    }
    ; Test whether all keys are positive integers.
    if (Result)
    {
        Result := ObjLength(Value) == ObjCount(Value)
    }
    return Result
}
