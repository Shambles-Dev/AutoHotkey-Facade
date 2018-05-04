_DedupBy(Dict, Func, X)
{
    local
    FX := Func.Call(X)
    if (Dict.HasKey(FX))
    {
        Result := false
    }
    else
    {
        Result := true
       ,Dict.Set(FX, "")
    }
    return Result
}
