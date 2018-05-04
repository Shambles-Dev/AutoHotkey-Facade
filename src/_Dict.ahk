#Include <_Validate>

class Dict
{
    __New(Items*)
    {
        local
        ; An AutoHotkey Array takes the place of the array that would normally
        ; be used to implement a hash table's buckets.
        ;
        ; Masking to remove the unwanted high bits to fit within the array
        ; bounds is unnecessary because AutoHotkey Arrays are sparse arrays that
        ; support negative indices.
        ;
        ; Rehashing everything and placing it in a new array that has the next
        ; highest power of 2 elements when over 3/4ths of the buckets are full
        ; is unnecessary for the same reason.
        ;
        ; Separate chaining (instead of Robin Hood hashing with a low probe
        ; count and backwards shift deletion) is used to resolve hash collisions
        ; because it is more time efficient when locality of reference is a lost
        ; cause.
        this._Buckets := []
       ,this._Count   := 0
        ; An AutoHotkey Array contains the items in the order they were defined
        ; (not mutated).  The hash table contains indices used to look up items
        ; in this Array.  The enumerator uses this Array to enumerate the items
        ; in order.
        ;
        ; Normally tombstones (usually nulls) would mark elements where items
        ; were deleted and a count of the tombstones would be maintained.  This
        ; would be used when compacting the items array when deleting (e.g. when
        ; tombstones >= 16 and tombstones > count / 2).  This is unnecessary
        ; because AutoHotkey Arrays are sparse arrays.  Items are simply
        ; deleted.  It is theoretically possible to run out of positive Integer
        ; indices, but if an index were wasted once every millisecond, it would
        ; take more than a lifetime to occur.
       ,this._Items   := []
        loop % Items.Count()
        {
            this.Set(Items[A_Index][1], Items[A_Index][2])
        }
        return this
    }

    Count()
    {
        local
        return this._Count
    }

    _GetHash(Key)
    {
        ; _GetHash(Key) is used to find the bucket an item's index would be
        ; stored in.
        local
        if (IsObject(Key))
        {
            Hash := &Key
        }
        else
        {
            if Key is integer
            {
                Hash := Key
            }
            else if Key is float
            {
                ; Canonicalize most of the bitwise representation and prevent
                ; defective truncation (e.g. 1.1e1 & -1 is 1 instead of 11).
                Key          := Key + 0.0
               ,TruncatedKey := Key & -1
                if (Key == TruncatedKey)
                {
                    Hash := TruncatedKey
                }
                else
                {
                    ; This reinterpret casts a floating point value to an
                    ; Integer with the same bitwise representation.
                    ;
                    ; Removing the first step will result in warnings about
                    ; reading an uninitialized variable if warnings are turned
                    ; on.
                    VarSetCapacity(Hash, 8)
                   ,NumPut(Key, Hash,, "Double")
                   ,Hash := NumGet(Hash,, "Int64")
                }
            }
            else
            {
                ; This is the String hashing algorithm used in Java.  It makes
                ; use of modular arithmetic via Integer overflow.
                Hash := 0
                for _, Char in StrSplit(Key)
                {
                    Hash := 31 * Hash + Ord(Char)
                }
            }
        }
        return Hash
    }

    HasKey(Key)
    {
        local
        Found := false
       ,Hash  := this._GetHash(Key)
       ,Node  := this._Buckets.HasKey(Hash) ? this._Buckets[Hash]
               : ""
        while (not Found and Node != "")
        {
            if (this._Items[Node.Index].Key == Key)
            {
                Found := true
            }
            else
            {
                Node := Node.Next
            }
        }
        return Found
    }

    Get(Key)
    {
        local
        global KeyError
        static Sig := "Dict.Get(Key)"
        Found      := false
       ,Hash       := this._GetHash(Key)
       ,Node       := this._Buckets.HasKey(Hash) ? this._Buckets[Hash]
                    : ""
        while (not Found)
        {
            if (Node == "")
            {
                throw new KeyError(Format("{1}  Key not found.  Key is {2}.", Sig, _Validate_ValueRepr(Key)), -1)
            }
            if (this._Items[Node.Index].Key == Key)
            {
                Value := this._Items[Node.Index].Value
               ,Found := true
            }
            else
            {
                Node := Node.Next
            }
        }
        return Value
    }

    Set(Key, Value)
    {
        local
        Found        := false
       ,Hash         := this._GetHash(Key)
       ,Node         := this._Buckets.HasKey(Hash) ? this._Buckets[Hash]
                      : ""
       ,PreviousNode := ""
        while (not Found and Node != "")
        {
            if (this._Items[Node.Index].Key == Key)
            {
                this._Items[Node.Index].Value := Value
                ; Perform chain reordering to speed up future lookups.
                if (PreviousNode != "")
                {
                    PreviousNode.Next   := Node.Next
                   ,Node.Next           := this._Buckets[Hash]
                   ,this._Buckets[Hash] := Node
                }
                Found := true
            }
            else
            {
                PreviousNode := Node
               ,Node         := Node.Next
            }
        }
        if (not Found)
        {
            Item                      := {}
           ,Item.Key                  := Key
           ,Item.Value                := Value
           ,Index                     := this._Items.Push(Item)
           ,Next                      := this._Buckets.HasKey(Hash) ? this._Buckets[Hash]
                                       : ""
           ,this._Buckets[Hash]       := {}
           ,this._Buckets[Hash].Index := Index
           ,this._Buckets[Hash].Next  := Next
           ,this._Count               += 1
        }
        return Value
    }

    Delete(Key)
    {
        local
        global KeyError
        static Sig   := "Dict.Delete(Key)"
        Found        := false
       ,Hash         := this._GetHash(Key)
       ,Node         := this._Buckets.HasKey(Hash) ? this._Buckets[Hash]
                      : ""
       ,PreviousNode := ""
        while (not Found)
        {
            if (Node == "")
            {
                throw new KeyError(Format("{1}  Key not found.  Key is {2}.", Sig, _Validate_ValueRepr(Key)), -1)
            }
            if (this._Items[Node.Index].Key == Key)
            {
                Value := this._Items[Node.Index].Value
               ,this._Items.Delete(Node.Index)
                if (PreviousNode == "")
                {
                    if (Node.Next == "")
                    {
                        this._Buckets.Delete(Hash)
                    }
                    else
                    {
                        this._Buckets[Hash] := Node.Next
                    }
                }
                else
                {
                    PreviousNode.Next := Node.Next
                }
                this._Count -= 1
               ,Found := true
            }
            else
            {
                PreviousNode := Node
               ,Node         := Node.Next
            }
        }
        return Value
    }

    Clone()
    {
        local
        global Dict
        Clone := new Dict()
        ; Avoid rehashing when cloning.
        for Hash, Node in this._Buckets
        {
            PreviousNodeClone := ""
            while (Node != "")
            {
                NodeClone := Node.Clone()
                if (PreviousNodeClone == "")
                {
                    Chain := NodeClone
                }
                else
                {
                    PreviousNodeClone.Next := NodeClone
                }
                PreviousNodeClone := NodeClone
               ,Node              := Node.Next
            }
            Clone._Buckets[Hash] := Chain
        }
        Clone._Count := this._Count
        for Index, Item in this._Items
        {
            Clone._Items[Index] := Item.Clone()
        }
        return Clone
    }

    class Enumerator
    {
        __New(Dict)
        {
            local
            this._ItemsEnum := Dict._Items._NewEnum()
            return this
        }

        Next(byref Key, byref Value := "")
        {
            local
            Result := this._ItemsEnum.Next(_, Item)
            if (Result)
            {
                Key   := Item.Key
               ,Value := Item.Value
            }
            return Result
        }
    }

    _NewEnum()
    {
        local
        global Dict
        return new Dict.Enumerator(this)
    }
}
