<div align="center">
<h3>:warning: This is a release candidate. :warning:</h3>
</div>

Facade
======

#### What Is It?

Facade is a [combinator](https://en.wikipedia.org/wiki/Combinator_library)-based [impure](https://en.wikipedia.org/wiki/Purely_functional_programming) [functional](https://en.wikipedia.org/wiki/Functional_programming) programming language presented as a set of libraries.  Semantically, it resembles [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language)) without macros and with combinators instead of lambda.


#### Why Would Anyone Use It?

It uses syntax familiar to AutoHotkey programmers, integrates seamlessly with other code, and solves many problems of AutoHotkey v1.

<table>
  <tr>
    <th>Problem</th>
    <th>Solution</th>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey ignores errors when possible.</p>
      <p>This maximizes the destructiveness of defects and the difficulty of debugging.</p>
    </td>
    <td><p>Facade reports errors when possible.</p></td>
  </tr>
  <tr>
    <td><p>AutoHotkey corrupts hexadecimal numbers with the sign bit set (e.g. <code>Op_Hex(0xDEBAC1E0DEC0DED0)</code> is <code>"0x7FFFFFFFFFFFFFFF"</code>).</p></td>
    <td><p>Facade does not corrupt numbers when converting Strings to numeric values, and it supports binary notation (e.g. <code>"0b101"</code>) and scientific notation without a decimal point (e.g. <code>"-1e1"</code>), unlike AutoHotkey.</p></td>
  </tr>
  <tr>
    <td><p><code>Object.Key</code> and <code>Object[Key]</code> mean the same thing because AutoHotkey conflates Objects’ interface and contents, so storing a key containing the name of a method clobbers that method.</p></td>
    <td><p>Facade uses <code>Get(Key)</code> and <code>Set(Key, Value)</code> methods on random access types to avoid conflating interface and contents.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey Arrays can have missing elements.</p>
      <p>This destroys useful semantics of most Array operations (e.g. reversing does not change the length and sorting ordered values is always possible).</p>
    </td>
    <td><p>Facade exclusively uses Arrays without missing elements, except for functions used to convert from and to Arrays with missing elements and supporting applying functions with optional parameters to Arrays with missing elements to cope with AutoHotkey’s design.</p></td>
  </tr>
  <tr>
    <td><p><code>{"Key1": "Value1", "Key2": "Value2"}</code> constructs an Object because AutoHotkey conflates Objects with dictionaries, but Objects associate Floats by their current String representation and String keys are case-folded, so they are unsuitable for use as dictionaries.</p></td>
    <td><p>Dicts associate Floats and Strings by their value.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey contains operators that are defective:
        <ul>
          <li><code>~X</code> does not reliably bitwise not (e.g. <code>~95288014</code> is <code>4199679281</code> instead of <code>-95288015</code>)</li>
          <li><code>X // Y</code> does not floor divide and return an Integer (e.g. <code>-3 // 2</code> is <code>-1</code> instead of <code>-2</code> and <code>-3.0 // 2</code> is <code>-2.000000</code> instead of <code>-2</code>)</li>
          <li><code>X &lt;&lt; N</code> returns incorrect results when <code>N</code> is ≥ the word size (e.g. <code>-2 &lt;&lt; 64</code> is <code>-2</code> instead of <code>0</code>)</li>
          <li><code>X &gt;&gt; N</code> returns incorrect results when <code>N</code> is ≥ the word size (e.g. <code>-2 &gt;&gt; 64</code> is <code>-2</code> instead of <code>-1</code>)</li>
          <li>the bitwise operators truncate incorrectly (e.g. <code>1.1e1 &amp; -1</code> is <code>1</code> instead of <code>11</code>)</li>
        </ul>
      </p>
    </td>
    <td><p>Facade contains equivalent functions that are correct.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey contains functions that are defective:
        <ul>
          <li><code>Mod(X, Y)</code> is actually the Rem function (e.g. <code>Mod(-7, 3)</code> is <code>-1</code> instead of <code>2</code>)</li>
          <li><code>Round(X [, N])</code> uses biased rounding (e.g. <code>Round(2.5)</code> is <code>3</code> instead of <code>2</code>)</li>
        </ul>
      </p>
    </td>
    <td><p>Facade contains equivalent functions that are correct.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey uses mutable state pervasively.</p>
      <p>This makes code difficult to test, debug, reuse, and optimize.</p>
      <p>AutoHotkey is effectively multithreaded, so mutation is likely to cause race conditions.</p>
    </td>
    <td><p>Facade does not use mutable state, except in the Random library.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey is inconsistent.</p>
      <p>This requires the programmer to remember things that have nothing to do with solving the problem their program is meant to solve and to write code to abstract over differences that should not exist.</p>
    </td>
    <td><p>Facade is consistent.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey’s function objects’ <code>Bind(Args*)</code> method returns a function object without a <code>Bind(Args*)</code> method.</p>
      <p>This is just one example of AutoHotkey’s inconsistency.  It makes AutoHotkey’s function objects less useful.</p>
    </td>
    <td><p>Facade’s function objects’ <code>Bind(Args*)</code> method always returns a function object with a <code>Bind(Args*)</code> method.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey uses 1-based Array indexing.</p>
      <p>This avoids the problem of inexperienced programmers having to spend a few minutes to learn the difference between counting and Array indexing by causing the problem of experienced programmers having to forever make adjustments wherever Array indexing is used.</p>
      <p>An Array’s length is the count of its elements.</p>
      <p>An Array index is the distance in elements from the first element, and the distance from the first element to the first element is 0.  Therefore, 0 is the only correct Array index base.</p>
    </td>
    <td>
      <p>Facade makes it possible to avoid using Array indexing most of the time by operating on entire Arrays.</p>
      <p>Facade uses 0-based Array indexing when necessary.  This is an illusion maintained for the programmer’s sake.  Arrays constructed by Facade are still 1-based so that they are compatible with the rest of AutoHotkey.</p>
    </td>
  </tr>
  <tr>
    <td><p>Objects store most items in sorted order because AutoHotkey conflates Objects with Arrays, but that does not work for items with object keys.</p></td>
    <td><p>Dicts store all items in insertion order because that is occasionally useful (e.g. to report definitions in the order they appear in source code) and it works for items with any type of key.</p></td>
  </tr>
  <tr>
    <td>
      <p>AutoHotkey is verbose.</p>
      <p>This makes writing code difficult by requiring the programmer to write more to describe the same behavior and makes reading code difficult by limiting how much of it the programmer can see at once.</p>
    </td>
    <td><p>Code written atop Facade is less verbose.</p></td>
  </tr>
</table>


[Design](docs/Design.md) contains the reasons for the design decisions.


<details>
  <summary><strong>Table of Contents</strong> (click to expand)</summary>

* [Installation](#installation)
* [Usage](#usage)
  * [Intention](#intention)
  * [Op](#op)
  * [Func](#func)
  * [Math](#math)
  * [String](#string)
  * [Array](#array)
  * [List](#list)
  * [Stream](#stream)
  * [Dict](#dict)
  * [Random](#random)
</details>


## Installation

[Type Checking](https://github.com/Shambles-Dev/AutoHotkey-Type_Checking) must be installed, and the files in [src](src) must be placed in a [library directory](https://www.autohotkey.com/docs/Functions.htm#lib).


## Usage

Directly calling a function will cause its library to be auto-included.  If the function is only called dynamically or indirectly, its library must be explicitly included.


### Intention

Facade is intended to replace AutoHotkey’s processing constructs.  To benefit the most from it, most of your code should consist of calls to its functions.  You are intended to define functions to use with it.

Functional Programming Means
* Functions can be constructed at run-time and passed as arguments, stored in variables or data structures, and returned, like any other value.  This can drastically reduce the number of functions that must be manually written by making it possible to write functions that write functions.  It is roughly equivalent to composition and polymorphism in object-oriented programming.
* Construct new values instead of mutating existing values.  This prevents defects caused by mutating a value used by other code written with the expectation that the value would not be mutated.
* Concentrate observable side effects into execution entry and exit points.  This makes most code (code without any observable side effects) easy to test (no mock objects are necessary), debug (arguments that cause a failure do so reliably), reuse (it composes), and optimize (it can be eliminated or reordered if the same value can still be returned for the same arguments).

Facade was designed to coexist with side effects instead of eradicate them.  Some functional programming aficionados have unfairly demonized all side effects.  Not all side effects are dangerous.  Non-local side effects (e.g. mutating global variables or values, mutating argument values, or performing input/output) are dangerous.  Local side effects (e.g. mutating local variables or values or mutating a data structure as it is constructed) often make it possible to write shorter, easier to understand, and more efficient algorithms.  This decision affected Facade’s data structures and algorithms, and it affects how Facade should be used.

Facade avoids introducing new types when possible.  It is better to have a small number of types and a large number of procedures that work with each type than to have a large number of types and a small number of procedures that work with each type.  This encourages reuse.

Facade uses AutoHotkey’s Array and its own Dict types, both of which can be mutated efficiently.  They cannot be copied efficiently.  A data structure can be designed to be mutated efficiently or to eliminate the need for copying by structure sharing, but not both.

Reusing AutoHotkey’s Array type makes other reuse easier.  If an immutable array-like type were introduced, it would be necessary to convert it to an Array to pass it to preexisting functions.

Introducing the Dict type is necessary because using AutoHotkey’s Object type as a dictionary is unsafe.  If Dict were immutable, it would be unusable for imperative programming.

Dict has the following methods:
```AutoHotkey
Count()
HasKey(Key)
Get(Key)
Set(Key, Value)
Delete(Key)
Clone()
_NewEnum()
```

`Get(Key)` reads the value associated with a key.

`Set(Key, Value)` writes the value associated with a key.  Be aware that Dicts store items in the order they were defined, not mutated!

The other methods have the same semantics as those on AutoHotkey’s [Object](https://www.autohotkey.com/docs/objects/Object.htm) type.  This makes it possible to reuse some code designed to be used with AutoHotkey’s Object type.

Facade functions that can return a different Array or Dict than they were passed (e.g. `Array_Sort(Pred, Array)`) always return a copy, even when they contain the same values in the same order (e.g. when sorting an Array containing < 2 elements).  This prevents defects caused by assuming the common case is the universal case in the face of mutation.

Facade’s List and Stream types can be enumerated (i.e. they can be used with `for` loops).  This is occasionally useful when performing side effects using their elements.  Their enumerators produce 1-based Key values to cope with AutoHotkey’s design.  This does not imply that those types can be randomly accessed like an Array.

Suggested Use
* Construct functions at run-time only when it is more maintainable than manually writing the functions.
* Use folds, filters, and maps instead of multiple sets, updates, and deletes, and make wise use of local side effects.  This avoids unnecessary copying.
* Concentrate observable side effects into your main procedure (e.g. in the auto-execute section in a silent install script) or event handlers (e.g. in the functions used for handling controls’ events in a script with a GUI).


### Op

This library contains functions that perform primitive operations.  Most of them correspond to AutoHotkey’s referentially transparent operators.  They are useful as building blocks for constructing functions at run-time.

Functions corresponding to the `%Func%(Args*)`, `not`, `and`, `or` and `?:` operators are in the [Func](#func) library.

String concatenation and case-insensitive relational predicates are in the [String](#string) library.

Facade’s relational predicates are unusual.  If < 2 arguments are passed to them, they return `true`.  If > 2 arguments are passed to them, they chain the relation.  This makes them easy to use to test if Array elements have the desired relations (e.g. `Op_Le(Array*)` tests if `Array` is sorted in ascending order) or if a value is between bounds (e.g. `Op_Le(0, X, 9)` tests if `X` is in the closed interval [0, 9]).  They are case-sensitive because case often matters.  They are defined recursively for sequences so that they can be used to sort Arrays of sequences.  They compare dictionaries as sets by treating their values as extensions of their keys because that is safe and useful.  They only compare dictionaries’ items, not their order, because ordered dictionary comparison is almost always surprising and useless.

Facade provides the two kinds of equality tests programmers need: value (a.k.a. structural) and identity (a.k.a. physical).  `Op_Eq(Args*)` tests if its arguments currently have the same value by comparing the values for all types.  `Op_IdEq(Args*)` tests if its arguments will always have the same value by comparing the values for immutable types and the addresses for mutable types.  Value equality is used more often, so it has the shorter name in Facade.

`Op_Bin(X)` converts the Integer `X` to a String containing its representation in binary.  It is useful for observing the results of bitwise operations.

`Op_Hex(X)` converts the Integer `X` to a String containing its representation in hexadecimal.

`Op_Integer(X)` converts the numeric value or String containing a representation of a numeric value `X` to an Integer.  It can convert Strings containing a representation of an Integer in binary (e.g. `"0b101"`) or hexadecimal (without corrupting it if the sign bit is set), or a floating-point number with only an exponent (e.g. `"-1e1"`).  Floats are truncated.

`Op_Float(X)` converts the numeric value or String containing a representation of a numeric value `X` to a Float.  It can convert Strings containing a representation of an Integer in binary (e.g. `"0b101"`) or hexadecimal (without corrupting it if the sign bit is set), or a floating-point number with only an exponent (e.g. `"-1e1"`), negative or positive infinity (e.g. `"-inf"` and `"inf"` respectively), or NaN (e.g. `"nan"`).

`Op_GetProp(Prop, Obj)` evaluates `Obj.Prop`.

`Op_Get(Key, Obj)` returns the value associated with `Key` in `Obj`.  It uses a `Get(Key)` method if present.

`Op_Expt(X, Y)` evaluates `X ** Y`.  0⁰ is defined as 1 for discrete (Integer), not continuous (Float), exponents, as in math.

`Op_BNot(X)` bitwise nots the Integer `X`.

`Op_Mul(Numbers*)` multiplies the numbers passed to it.  If no numbers are passed to it, it returns `1`, its identity element.

`Op_Div(Numbers*)` divides the numbers passed to it from left to right.  At least 1 number must be passed to it.  If only 1 number is passed to it, it evaluates `1 / Number`.

`Op_FloorDiv(X, Y)` returns `X` floor divided by `Y`.

`Op_Add(Numbers*)` adds the numbers passed to it.  If no numbers are passed to it, it returns `0`, its identity element.

`Op_Sub(Numbers*)` subtracts the numbers passed to it from left to right.  At least 1 number must be passed to it.  If only 1 number is passed to it, it evaluates `0 - Number` (i.e. it negates the number).

`Op_BAsl(X, N)` performs arithmetic shift left on the Integer `X` `N` places.

`Op_BAsr(X, N)` performs arithmetic shift right on the Integer `X` `N` places.

`Op_BLsr(X, N)` performs logical shift right on the Integer `X` `N` places.

`Op_BAnd(Integers*)` bitwise ands the Integers passed to it.  If no Integers are passed to it, it returns `-1`, its identity element.

`Op_BXor(Integers*)` bitwise xors the Integers passed to it.  If no Integers are passed to it, it returns `0`, its identity element.

`Op_BOr(Integers*)` bitwise ors the Integers passed to it.  If no Integers are passed to it, it returns `0`, its identity element.

`Op_Lt(Args*)` tests < or ⊂ for all consecutive pairs of its arguments.

`Op_Gt(Args*)` tests > or ⊃ for all consecutive pairs of its arguments.

`Op_Le(Args*)` tests ≤ or ⊆ for all consecutive pairs of its arguments.

`Op_Ge(Args*)` tests ≥ or ⊇ for all consecutive pairs of its arguments.

`Op_Eq(Args*)` tests = for all its arguments.

`Op_IdEq(Args*)` tests identity equality for all its arguments.


### Func

This library contains functions that construct and apply functions.

`Func_DllFunc(NameOrPtr, Types*)` returns a function object that calls the function identified by `NameOrPtr` with the `Types*` specified for its arguments and return value (e.g. `Func_DllFunc("msvcrt\ceil", "Double", "Double").Call(2.3)` returns `3.0`).  It is based on [`DllCall("[DllFile\]Function" [, Type, Arg…, ReturnType])`](https://www.autohotkey.com/docs/commands/DllCall.htm) and uses the same type specifiers.  `"UPtr"` and `"CDecl"` are intentionally omitted because they do nothing in modern AutoHotkey.

`Func_Bind(Func, Args*)` returns a copy of `Func` with any provided arguments bound.  It is useful for partial application.

`Func_MethodCaller(Name, Args*)` returns a function object that calls the method identified by `Name` with any provided arguments on an object passed to it.  If more than 1 argument is passed to the resulting function object, those arguments will be positioned after any arguments provided when it was constructed.

`Func_Applicable(Obj)` converts `Obj` to a function object that maps a key argument to a value return value.  Be aware that the resulting function object will not perform index adjustment if `Obj` is an Array!  Use `Func_Flip(Func("Array_Get")).Bind(Array)` instead in that case.  It is useful when a function requires a function object to process data but a lookup in a data structure is desired.  `Func_FailSafe(Func_Applicable(Dict), Func("Func_Id"))` can be used to selectively replace values with values from `Dict`.

`Func_Apply(Func, Args)` is the A combinator.  It evaluates `Func` with the `Args` Array contents as its arguments.  `Args` can have missing elements.

`Func_ApplyArgsWith(Func, ArgsFuncs)` accepts a `Func` function object that accepts the same number of arguments as the elements of the `ArgsFuncs` Array that contains `F(Args*)` function objects and returns a function object that applies each function object in `ArgsFuncs` to the arguments passed to it to construct an Array by setting the same index to the value returned then applies `Func` with that Array’s contents as its arguments.  `ArgsFuncs` can have missing elements.  It is useful when mapping a function that requires multiple arguments that can be accessed or computed from a single argument.

`Func_ApplyRespWith(Func, RespFuncs)` accepts a `Func` function object that accepts the same number of arguments as the elements of the `RespFuncs` Array that contains `F(X)` function objects and returns a function object that applies each function object in `RespFuncs` to the respective argument passed to it to construct an Array by setting the same index to the value returned then applies `Func` with that Array’s contents as its arguments.  `RespFuncs` can have missing elements.  It is useful for pre-processing arguments.

`Func_Comp(Funcs*)` is the B combinator.  It returns a function object that is the composition of the function objects passed to it.  If no function objects are passed to it, it returns `Func_Id(X)`, its identity element.  Its arguments should be arranged from outermost (leftmost) to innermost (rightmost), as in mathematics.

`Func_Rearg(Func, Positions)` adapts `Func` to have rearranged arguments as specified by Integers in the `Positions` Array.  `Positions` can have missing elements.  Positions are 0-based.  To omit a parameter, do not specify a position for it.  To duplicate arguments, specify the same position for multiple parameters.  Arguments after the highest specified position are passed in the order they were received so that it can be applied to variadic functions.  It is useful for adapting a function object to the signature required or to move parameters to be bound to the beginning of the signature.

`Func_Flip(F)` is the C combinator.  It adapts the `F(X, Y)` function object to have its first and second arguments flipped.  It is useful for adapting a function object to the signature required or to move a parameter to be bound to the beginning of the signature.

`Func_HookL(F, G)` accepts the function objects `F(X, Y)` and `G(X)` and returns a function object that accepts the arguments `X` and `Y` and evaluates `F(X, G(Y))`.  It is useful for constructing combining functions for left folding and predicates for filtering with `X` bound.

`Func_HookR(F, G)` accepts the function objects `F(X, Y)` and `G(X)` and returns a function object that accepts the arguments `X` and `Y` and evaluates `F(G(X), Y)`.  It is useful for constructing combining functions for right folding.

`Func_Id(X)` is the I combinator.  It returns `X`.  It is useful when a function requires a function object to process data but no processing is desired.

`Func_Const(X)` is the K combinator.  It returns a function object that ignores its arguments and returns `X`.  It is useful when a function requires a function object to process data but the data is irrelevant.

`Func_On(F, G)` is the P combinator (a.k.a. ψ combinator).  It accepts the function objects `F(X, Y)` and `G(X)` and returns a function object that accepts the arguments `X` and `Y` and evaluates `F(G(X), G(Y))`.  It is useful for constructing predicates for sorting.

`Func_CNot(Pred)` accepts the `Pred(Args*)` function object and returns a function object that accepts an arbitrary number of arguments `Args*` and evaluates `not Pred(Args*)`.

`Func_CNotRel(RelPred)` is like `Func_CNot(Pred)` except that the resulting function object returns `true` if < 2 arguments are passed to it.  It is useful for constructing logically complemented relational predicates.

`Func_CAnd(Preds*)` returns a function object that accepts an arbitrary number of arguments and evaluates the `Preds*` function objects from left to right with those arguments until a predicate returns `false`, in which case it returns `false`, or it runs out of predicates, in which case it returns `true`.  This short-circuit evaluation is sometimes required for termination.  If no function objects are passed to `Func_CAnd(Preds*)`, it returns `Func_Const(true)`, its identity element.

`Func_COr(Preds*)` returns a function object that accepts an arbitrary number of arguments and evaluates the `Preds*` function objects from left to right with those arguments until a predicate returns `true`, in which case it returns `true`, or it runs out of predicates, in which case it returns `false`.  This short-circuit evaluation is sometimes required for termination.  If no function objects are passed to `Func_COr(Preds*)`, it returns `Func_Const(false)`, its identity element.

`Func_CIf(Pred, ThenFunc, ElseFunc)` accepts the `Pred(Args*)`, `ThenFunc(Args*)`, and `ElseFunc(Args*)` function objects and returns a function object that accepts an arbitrary number of arguments `Args*` and evaluates `Pred(Args*) ? ThenFunc (Args*) : ElseFunc(Args*)`.  `Func_CIf(Pred, Func("FixIt"), Func("Func_Id"))` can be used to selectively replace values with values computed by `FixIt(X)`.

`Func_CCond(Clauses*)` accepts clauses represented as Arrays containing a test function object and an expression function object, in that order, and returns a function object that accepts an arbitrary number of arguments and evaluates the tests with those arguments in order until a test returns `true`, in which case it returns the respective expression’s return value when evaluated with those arguments, or it runs out of clauses, in which case it returns the empty String.  If no clauses are passed to `Func_CCond(Clauses*)`, it returns `Func_Const("")`.  It is less verbose and more efficient than chaining `Func_CIf(Pred, ThenFunc, ElseFunc)`.

`Func_FailSafe(Funcs*)` returns a function object that accepts an arbitrary number of arguments and evaluates the `Funcs*` function objects from left to right with those arguments until a function succeeds (does not throw an exception), in which case it returns that function’s return value, or it runs out of functions, in which case it throws the exception the last function threw.  At least 1 function object must be passed to it.  It is useful for specifying fail-safes for partial functions and functions that might experience system errors.

`Func_Default(Func, Default)` adapts `Func` to return `Default` instead of failing noisily (throwing an exception) or silently (returning the empty String).  It can be used to construct accessor functions that do not fail.


### Math

This library contains constants and functions corresponding to AutoHotkey’s [math](https://www.autohotkey.com/docs/commands/Math.htm) functions with corrections and error reporting.  Prepend `Math_` to a math function’s name to use the improved version.  Differences are documented below.

`e` [𝑒](https://mathworld.wolfram.com/e.html) is Euler’s number.

`phi` [𝜙](https://mathworld.wolfram.com/GoldenRatio.html) is the golden ratio.

`pi` [π](https://mathworld.wolfram.com/Pi.html) is the ratio of a circle’s circumference to its diameter.

`Math_Mod(X, Y)` returns `X` modulo `Y`.  It is the genuine modulo function.

`Math_Round(X [, N])` is like AutoHotkey’s `Round(X [, N])` except that it uses the unbiased round half to even tie-breaking rule.


### String

This library contains functions that construct and process Strings.

Be aware that the relational predicates compare dictionary items case-sensitively!

`String_Concat(Strings*)` returns a String that is the concatenation of the Strings passed to it.  If no String is passed to it, it returns the empty String, its identity element.  It is more efficient to concatenate > 2 Strings with a single call because it only allocates and copies once.

`String_CiLt(Args*)` is like `Op_Lt(Args*)` except that it compares Strings case-insensitively.

`String_CiGt(Args*)` is like `Op_Gt(Args*)` except that it compares Strings case-insensitively.

`String_CiLe(Args*)` is like `Op_Le(Args*)` except that it compares Strings case-insensitively.

`String_CiGe(Args*)` is like `Op_Ge(Args*)` except that it compares Strings case-insensitively.

`String_CiEq(Args*)` is like `Op_Eq(Args*)` except that it compares Strings case-insensitively.

`String_IsNatSorted(Args*)` is like `Op_Le(Args*)` except that it compares Strings according to natural sort order.  It is useful for sorting an Array of Strings containing unsigned integers (e.g. file system paths) the way a human would, where the values of the embedded numbers are compared, instead of lexicographically.


### Array

This library contains functions that construct and process Arrays.

`Array_FromBadArray(Func, Array [, Length])` returns a copy of `Array` with missing elements filled with the value returned by the `Func(I)` function object, where `I` is the 0-based index.  The `Length` optional parameter can be used to fill trailing missing elements.  It is useful for adapting an Array for use with Facade.

`Array_ToBadArray(Pred, Array)` returns a copy of `Array` with missing elements where the `Pred(I, X)` function object returned `true`, where `I` is the 0-based index and `X` is the value.  `Array` can have missing elements.  It is useful for adapting an Array for use with AutoHotkey procedures that require missing elements.

`Array_IsArray(Value)` returns whether `Value` is an Array.  Be aware that this is not an efficient operation, unlike `List_IsList(Value)`, `Stream_IsStream(Value)`, and `Dict_IsDict(Value)`!

`Array_IsEmpty(Value)` returns whether `Value` is an empty Array.

`Array_Count(Array)` returns the count of the elements in `Array`.

`Array_Get(I, Array)` returns the value at the 0-based index `I` in `Array`.  Negative indices are relative to the end of the Array.  It is useful when the index is computed (e.g. when using modulo to access an Array like a circular buffer).

`Array_Interpose(Between, Array [, BeforeLast])` returns a copy of `Array` with `Between` between each element.  `BeforeLast` will appear before the last element instead of `Between` if it is provided and not the empty String.  It is useful for interposing commas and "and" or "or" in an Array of Strings to be concatenated.

`Array_Concat(Arrays*)` returns an Array that is the concatenation of the Arrays passed to it.  If no Array is passed to it, it returns an empty Array, its identity element.  It is more efficient to concatenate > 2 Arrays with a single call because it only allocates and copies once.

`Array_Flatten(Array)` returns an Array containing the elements of `Array` in order with any nesting removed.

`Array_All(Pred, Array)` tests ∀𝑥∈𝑋 𝑃(𝑥), where 𝑋 is `Array` and 𝑃 is `Pred` (i.e. it returns whether the `Pred(X)` function object returns `true` for all elements of `Array`).  Elements are tested in order until `Pred(X)` returns `false`, in which case it returns `false`, or it runs out of elements, in which case it returns `true`.  If `Array` is empty, it returns `true`.

`Array_Exists(Pred, Array)` tests ∃𝑥∈𝑋 𝑃(𝑥), where 𝑋 is `Array` and 𝑃 is `Pred` (i.e. it returns whether there exists an element of `Array` for which the `Pred(X)` function object returns `true`).  Elements are tested in order until `Pred(X)` returns `true`, in which case it returns `true`, or it runs out of elements, in which case it returns `false`.  If `Array` is empty, it returns `false`.

`Array_FoldL(Func, Init, Array)` returns the result of applying the `Func(A, X)` combining function object, where `A` is the accumulator and `X` is the value, recursively to the elements of `Array` from left (first) to right (last).  The accumulator is on the left so that the recursive explanation of the expression tree makes sense.  `Init` is often `Func(A, X)`’s identity element.  If `Array` is empty, `Init` is returned.  If `Array` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over an Array.

`Array_FoldR(Func, Init, Array)` returns the result of applying the `Func(X, A)` combining function object, where `X` is the value and `A` is the accumulator, recursively to the elements of `Array` from right (last) to left (first).  The accumulator is on the right so that the recursive explanation of the expression tree makes sense.  `Init` is often `Func(X, A)`’s identity element.  If `Array` is empty, `Init` is returned.  If `Array` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over an Array.

`Array_FoldL1(Func, Array)` is like `Array_FoldL(Func, Init, Array)` except that the initial value of the accumulator is the leftmost (first) element of `Array`.  `Array` must not be empty.  If `Array` contains 1 element, that element is returned.  It is useful when `Func(A, X)` has no identity element.

`Array_FoldR1(Func, Array)` is like `Array_FoldR(Func, Init, Array)` except that the initial value of the accumulator is the rightmost (last) element of `Array`.  `Array` must not be empty.  If `Array` contains 1 element, that element is returned.  It is useful when `Func(X, A)` has no identity element.

`Array_ScanL(Func, Init, Array)` is like `Array_FoldL(Func, Init, Array)` except that it returns an Array of cumulative results.

`Array_ScanR(Func, Init, Array)` is like `Array_FoldR(Func, Init, Array)` except that it returns an Array of cumulative results.

`Array_ScanL1(Func, Array)` is like `Array_FoldL1(Func, Array)` except that it returns an Array of cumulative results.  If `Array` is empty, it returns an empty Array.

`Array_ScanR1(Func, Array)` is like `Array_FoldR1(Func, Array)` except that it returns an Array of cumulative results.  If `Array` is empty, it returns an empty Array.

`Array_MinBy(Func, Array)` returns the first minimum element from `Array`, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  `Array` must not be empty.  Be aware that it cannot find minimum keys in posets, like floating-point values that include NaN or dictionaries!

`Array_MaxBy(Func, Array)` returns the first maximum element from `Array`, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  `Array` must not be empty.  Be aware that it cannot find maximum keys in posets, like floating-point values that include NaN or dictionaries!

`Array_MinKBy(Func, K, Array)` returns an Array containing the first minimum up to `K` elements from `Array` from least to greatest, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  Elements with equal keys appear in order, like a stable sort.  If `Array` contains < `K` elements, the result will contain any available elements.  Be aware that it cannot find minimum keys in posets, like floating-point values that include NaN or dictionaries!

`Array_MaxKBy(Func, K, Array)` returns an Array containing the first maximum up to `K` elements from `Array` from greatest to least, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  Elements with equal keys appear in order, like a stable sort.  If `Array` contains < `K` elements, the result will contain any available elements.  Be aware that it cannot find maximum keys in posets, like floating-point values that include NaN or dictionaries!

`Array_Filter(Pred, Array)` returns an Array constructed by folding over `Array` and appending values for which the `Pred(X)` function object returns `true`, where `X` is the value.

`Array_FilterApply(Pred, Array)` filters an `Array` of Arrays by applying `Pred` to its elements.  It is useful when arguments have already been computed (e.g. when using the list of successes technique).

`Array_DedupBy(Func, Array)` returns an Array containing the unique elements from `Array` in order, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object (e.g. to remove duplicate Strings case-insensitively and correctly handle Greek sigma, use `Array_DedupBy(Func("Format").Bind("{:U}"), Array)`).  Non-consecutive duplicates are removed.

`Array_Map(Func, Array)` returns an Array constructed by folding over `Array` and setting the same index to the value returned by the `Func(X)` function object, where `X` is the value.

`Array_MapApply(Func, Array)` maps the application of `Func` over an `Array` of Arrays.  It is useful when arguments have already been computed (e.g. when using the list of successes technique).

`Array_ZipWith(Func, Arrays*)` maps the application of `Func` over an Array of Arrays, where the nth Array contains the nth element from each Array in `Arrays*` in order.  The mapping terminates after processing the last element of the shortest Array in `Arrays*`.  At least 1 Array must be passed to it.  It is useful for constructing Dicts (e.g. `Dict(Array_ZipWith(Func("Array"), ["a", "b", "c"], [1, 2, 3])*)` returns `Dict(["a", 1], ["b", 2], ["c", 3])`) and using Facade like an array programming language (e.g. `Array_ZipWith(Func("Op_Add"), [1, 2, 3], [4, 5, 6])` returns `[5, 7, 9]`).

`Array_ConcatZipWith(Func, Arrays*)` concatenates the Arrays resulting from zipwithing `Func` over `Arrays*`.  At least 1 Array must be passed to it.  It is useful when `Func` needs to return a number of results that might not be singular.

`Array_Reverse(Array)` returns an Array constructed by folding over `Array` to reverse the order of the elements.  It is useful for correcting the order of the elements in an Array that was constructed by appending because prepending is less efficient.

`Array_Sort(Pred, Array)` returns a copy of `Array` sorted according to the `Pred(A, B)` ≤ function object by ensuring it returns `true` for all consecutive pairs of elements (e.g. to sort an Array of numbers in descending order, use `Array_Sort(Func("Op_Ge"), Array)`).  It is a stable sort (i.e. it will only move an element if it is in the wrong order), so it can be used to sort within different criteria (e.g. to sort by grade within age, first sort by grade, then sort by age).  Be aware that it cannot sort posets, like floating-point values that include NaN or dictionaries!

`Array_GroupBy(Func, Array)` returns a Dict, where the keys are accessed or computed from each element in `Array` using the `Func(X)` function object and the values are Arrays containing those elements in order.  The Dict has keys in the order they first appear in `Array`.

`Array_GroupByWMap(ByFunc, MapFunc, Array)` returns a Dict, where the keys are accessed or computed from each element in `Array` using the `ByFunc(X)` function object and the values are Arrays containing values accessed or computed from each element in `Array` using the `MapFunc(X)` function object in order.  The Dict has keys in the order they first appear in `Array`.  It is useful for constructing Dicts from Arrays of decorated elements.

`Array_GroupByWFoldL1Map(ByFunc, FoldLFunc, MapFunc, Array)` returns a Dict, where the keys are accessed or computed from each element in `Array` using the `ByFunc(X)` function object and the values are accessed or computed from each element in `Array` using the `MapFunc(X)` function object.  If a key already exists, the `FoldLFunc(A, X)` combining function object is used to compute its new value, where `A` is the existing value and `X` is the value returned by the `MapFunc(X)` function object.  The Dict has keys in the order they first appear in `Array`.  It is useful for constructing Dicts in complex ways (e.g. to construct a Dict where the keys are the elements in `Array` and the values are the count of their occurrences, use `Array_GroupByWFoldL1Map(Func("Func_Id"), Func("Op_Add"), Func_Const(1), Array)`).


### List

This library contains functions that construct and process singly linked lists.  Singly linked lists are useful as a functional alternative to stacks.

`List(Args*)` is the List constructor.  It returns a List containing the values passed to it.  To convert an Array to a List, apply it to the Array.

`List_Prepend(First, Rest)` returns a List containing the `First` value prepended to the `Rest` List.  It can be used to push a value onto a stack implemented as a List.

`List_IsList(Value)` returns whether `Value` is a List.

`List_IsEmpty(Value)` returns whether `Value` is the empty List.

`List_First(List)` returns the first value in the List.  `List` must not be empty.  It can be used to peek at the top of a stack implemented as a List.

`List_Rest(List)` returns the rest of the List after the first value.  `List` must not be empty.  It can be used to drop the top of a stack implemented as a List.

`List_ToArray(List)` converts `List` to an Array.


### Stream

This library contains functions that construct and process Streams.  Streams are useful as a functional alternative to Enumerators.

Facade’s Streams are inspired by Scheme’s [SRFI-41](https://srfi.schemers.org/srfi-41/srfi-41.html).  Semantically, they are lazily evaluated singly linked lists.  Operationally, they are memoized thunks that return a constant singleton empty Stream value or a record with a "first" field containing a memoized thunk that computes the element’s value and a "rest" field containing a Stream.

Facade’s Streams are even streams (i.e. the first element is not eagerly evaluated).  This avoids off-by-one errors.

The advantage Streams have over Enumerators is a Stream can be resumed at an element by retaining a reference to that element.  Be aware that retaining a reference to an element then computing a lot of succeeding elements might consume a lot of memory!

Streams are useful for computing sequences, avoiding constructing intermediate data structures, and constraint and logic programming.

The list of successes technique is used to implement constraint and logic programming in programming languages without built-in Prolog-like search and backtracking.  What follows is a concise explanation of the technique.

Success is modeled as a sequence of ≥ 1 answers.

Failure is modeled as an empty sequence.  Failure is not a defect.  It is the absence of answers, and it is often expected.  This is the reason many of Facade’s functions that return sequences return an empty sequence in corner cases or when passed an empty sequence.

Logical not is modeled as attempting to compute answers then returning an empty sequence if a non-empty sequence was returned or returning a sequence containing true otherwise.

Logical and is modeled as returning an empty sequence when passed any empty sequences or returning a sequence of answers, the unprocessed last sequence or sequences combined by a function (e.g. Cartesian product), otherwise.

Logical or is modeled as returning an empty sequence when passed all empty sequences or returning a sequence of answers, the unprocessed first non-empty sequence or sequences combined by a function (e.g. concatenate), otherwise.

The search order is determined by the order in which answers are computed.

Backtracking is implemented by attempting to generate answers a different way when an empty sequence is returned or filtering to remove answers that would be incorrect.

This technique might be used in AutoHotkey to install or configure a combination of software to satisfy requirements.

```AutoHotkey
; This is SRFI-41's example of the list of successes technique, ported to
; Facade, with significant differences explained.

; This code solves the 8 Queens problem.  Solving the problem requires placing 8
; chess queens on a chessboard such that no queen threatens another.

#Include <Op>

IsCheck(I, J, M, N)
{
    ; This predicate returns whether a single existing queen threatens the
    ; position we are trying to place a queen at.  I and J are the 1-based
    ; column and row (respectively) of an existing queen and M and N are the
    ; 1-based column and row (respectively) of the position we are trying to
    ; place a queen at.
    local
    ; The placement algorithm ensures that each queen is on a different column.
    return    J == N          ; Check if they are on the same row.
           or I + J == M + N  ; Check if they are on the same diagonal.
           or I - J == M - N  ; "
}

; Stream_All(Pred, Stream) can replace SRFI-41's (stream-and strm).

IsSafe(P, N)
{
    ; This predicate returns whether no existing queens threaten the position we
    ; are trying to place a queen at.  P is a Stream containing queens that have
    ; already been placed and N is the 1-based row we are trying to place a
    ; queen at.
    local
    ; It works by evaluating IsCheck(I, J, M, N) with all queens that have
    ; already been placed and the position we are trying to place a queen at.
    ;
    ; Stream_ZipWith(Func, Streams*) and Stream_Cycle(Array) can replace
    ; SRFI-41's usage of (stream-of expr clause ...) in this function.
    M := Stream_Count(P) + 1
    return Stream_All(Func("Op_Eq").Bind(true)
                     ,Stream_ZipWith(Func_CNot(Func("IsCheck"))
                                    ,Stream_HoIntvl(1, M)
                                    ,P
                                    ,Stream_Cycle([M])
                                    ,Stream_Cycle([N])))
}

GenerateNs(P, N)
{
    ; This function returns a Stream of Arrays containing a Stream of queens
    ; that have already been placed and a rank, in that order.  Each Stream of
    ; queens will be paired with all ranks.  See the comments in Queens(M) for
    ; an explanation of why it is needed.
    local
    ; It works similarly to two nested for-each loops.
    return Stream_ConcatZipWith(Func_Comp(Func_Rearg(Func("Stream_ZipWith"), [0, 2, 1])
                                                    .Bind(Func("Array"), N)
                                         ,Func("Stream_Cycle")
                                         ,Func("Array"))
                               ,P)
}

Queens(M)
{
    ; This function returns a Stream of Streams, where each inner Stream
    ; represents a solution as the rank (row as located by a 1-based index
    ; relative to the bottom of the board) for each file (column) from left to
    ; right.
    local
    ; It works by recurring to handle each file such that the first call handles
    ; the last file.  Each call generates all ranks for each Stream of queens
    ; that have already been placed by previous recursive calls (if any), then
    ; filters the ranks such that only the safe ones remain, and then appends
    ; those ranks to their respective Stream of queens.  If a Stream of queens
    ; that have already been placed cannot be safely paired with any rank, they
    ; will be filtered out, thus ensuring incomplete answers are not returned.
    ;
    ; Unfortunately, there is no simple replacement for SRFI-41's usage of
    ; (stream-of expr clause ...) in this function.  You need Lisp macros to
    ; create new binding forms.  However, code can be written to do what
    ; (stream-of expr clause ...) did in this function.  That is why
    ; GenerateNs(P, N) is needed.  Although this code does not look similar to
    ; SRFI-41's, it works the same way.
    FilterNs := Func("Stream_FilterApply")
                    .Bind(Func("IsSafe"))
   ,AppendNs := Func("Stream_MapApply")
                    .Bind(Func_HookL(Func("Stream_Concat")
                                    ,Func("Stream")))
    return M == 0 ? Stream(Stream())
         : AppendNs.Call(FilterNs.Call(GenerateNs(Queens(M - 1)
                                                 ,Stream_HoIntvl(1, 9))))
}

StreamRepr(Stream)
{
    ; AutoHotkey lacks both a REPL and the necessary infrastructure to support
    ; one, so we need this function to be able to see what we are doing.
    local
    return String_Concat(Array_Flatten(["Stream(", Array_Interpose(", ", Stream_ToArray(Stream)), ")"])*)
}

; To see the first solution to the 8 Queens problem, execute
MsgBox % StreamRepr(Stream_First(Queens(8)))

; To see all 92 solutions, execute
for _, Value in Queens(8)
{
    MsgBox % StreamRepr(Value)
}
```


#### Sources

Sources construct Streams.

`Stream(Args*)` is the Stream constructor.  It returns a Stream containing the values passed to it.  To convert an Array to a Stream, apply it to the Array.

`Stream_Prepend(First, Rest)` returns a Stream containing the `First` value prepended to the `Rest` Stream.

`Stream_Unfold(MapFunc, Pred, GenFunc, Init)` returns a Stream of the mapping of the `MapFunc(X)` function object over the cumulative results of recursively applying the `GenFunc(X)` function object to `Init`.  The Stream terminates when the `Pred(X)` function object returns `false` for a value before it is mapped.

`Stream_Gen(Func, Init)` returns a Stream of the cumulative results of recursively applying the `Func(X)` function object to `Init`.

`Stream_HbIntvl(Start [, Step])` returns a Stream containing the half-bound interval from `Start` at every `Step`.  `Step`’s default value is 1.  `Step` must not be 0.  If `Start` and `Step` are Integers, the elements will be Integers.  Otherwise, the elements will be Floats.

`Stream_HoIntvl(Start, Stop [, Step])` returns a Stream containing the half-open interval from `Start`, inclusive, to `Stop`, exclusive, at every `Step`.  `Step`’s default value is 1.  `Step` must not be 0.  If `Start` is < `Stop` and `Step` is negative or `Start` is > `Stop` and `Step` is positive, the result will be the empty Stream.  If `Start`, `Stop`, and `Step` are Integers, the elements will be Integers.  Otherwise, the elements will be Floats.

`Stream_Cycle(Array)` returns a Stream that cycles through the elements of `Array`.  If `Array` is empty, it returns the empty Stream.

`Stream_Perm(K, Array)` returns a Stream of Arrays containing the permutations of `K` elements of `Array` in lexicographic order.  If `K` is `0`, the result will be `Stream([])`.  If `K` > the count of the elements in `Array`, the result will be the empty Stream.  It is useful for constraint programming.

`Stream_PermWRep(K, Array)` returns a Stream of Arrays containing the permutations with repetition of `K` elements of `Array` in lexicographic order.  If `K` is `0`, the result will be `Stream([])`.  If `K` > the count of the elements in `Array`, the result will be the empty Stream.  It is useful for constraint programming.

`Stream_Comb(K, Array)` returns a Stream of Arrays containing the combinations of `K` elements of `Array` in lexicographic order.  If `K` is `0`, the result will be `Stream([])`.  If `K` > the count of the elements in `Array`, the result will be the empty Stream.  It is useful for constraint programming.

`Stream_CombWRep(K, Array)` returns a Stream of Arrays containing the combinations with repetition of `K` elements of `Array` in lexicographic order.  If `K` is `0`, the result will be `Stream([])`.  If `K` > the count of the elements in `Array`, the result will be the empty Stream.  It is useful for constraint programming.

`Stream_PowerSet(Array)` returns a Stream of Arrays containing the power set of `Array` in lexicographic order.  It is useful for constraint programming.

`Stream_CartProd(Arrays*)` returns a Stream of Arrays containing the Cartesian product of the Arrays passed to it in lexicographic order.  If no Arrays are passed to it, the result will be `Stream([])` because that maintains the invariants that the Cartesian product have a cardinality equal to its arguments’ cardinality raised to the power of the number of arguments passed (0⁰ = 1) and each element of the Cartesian product have a cardinality equal to the number of arguments passed.  If an empty Array is passed to it, the result will be the empty Stream, as expected.  It is useful for constraint programming.


#### Flows

Flows process Streams lazily.

`Stream_Take(K, Stream)` returns a Stream containing the first up to `K` elements from `Stream`.  If `Stream` contains < `K` elements, the result will contain any available elements.

`Stream_TakeWhile(Pred, Stream)` returns a Stream containing the elements from `Stream` while the `Pred(X)` function object returns `true`, where `X` is the value.

`Stream_Drop(K, Stream)` returns the rest of `Stream` after dropping up to `K` elements.  If `Stream` contains < `K` elements, the result will be the empty Stream.

`Stream_DropWhile(Pred, Stream)` returns the rest of `Stream` after dropping elements while the `Pred(X)` function object returns `true`, where `X` is the value.

`Stream_Concat(Streams*)` returns a Stream that is the concatenation of the Streams passed to it.  If no Stream is passed to it, it returns the empty Stream, its identity element.

`Stream_Flatten(Stream)` returns a Stream containing the elements of `Stream` in order with any nesting removed.

`Stream_ScanL(Func, Init, Stream)` is like `Stream_FoldL(Func, Init, Stream)` except that it returns a Stream of cumulative results.

`Stream_ScanL1(Func, Stream)` is like `Stream_FoldL1(Func, Stream)` except that it returns a Stream of cumulative results.  If `Stream` is empty, it returns the empty Stream.

`Stream_Filter(Pred, Stream)` returns a Stream containing the values from `Stream` for which the `Pred(X)` function object returns `true`, where `X` is the value.

`Stream_FilterApply(Pred, Stream)` filters a `Stream` of Arrays by applying `Pred` to its elements.  It is useful when arguments have already been computed (e.g. when using the list of successes technique).

`Stream_DedupBy(Func, Stream)` returns a Stream containing the unique elements from `Stream` in order, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object (e.g. to remove duplicate Strings case-insensitively and correctly handle Greek sigma, use `Stream_DedupBy(Func("Format").Bind("{:U}"), Stream)`).  Non-consecutive duplicates are removed.

`Stream_Map(Func, Stream)` returns a Stream containing the values from `Stream` processed by the `Func(X)` function object, where `X` is the value.

`Stream_MapApply(Func, Stream)` maps the application of `Func` over a `Stream` of Arrays.  It is useful when arguments have already been computed (e.g. when using the list of successes technique).

`Stream_ZipWith(Func, Streams*)` maps the application of `Func` over a Stream of Arrays, where the nth Array contains the nth element from each Stream in `Streams*` in order.  The mapping terminates after processing the last element of the shortest Stream in `Streams*`.  At least 1 Stream must be passed to it.

`Stream_ConcatZipWith(Func, Streams*)` concatenates the Streams resulting from zipwithing `Func` over `Streams*`.  At least 1 Stream must be passed to it.  It is useful when `Func` needs to return a number of results that might not be singular.


#### Recognizers, Accessors, and Sinks

Recognizers (`Stream_IsStream(Value)` and `Stream_IsEmpty(Value)`), accessors (`Stream_First(Stream)` and `Stream_Rest(Stream)`), and sinks (the rest of this section) process Streams eagerly.

Sinks process entire Streams.  Be aware that they might not terminate when used on infinite Streams!

`Stream_IsStream(Value)` returns whether `Value` is a Stream.

`Stream_IsEmpty(Value)` returns whether `Value` is the empty Stream.

`Stream_First(Stream)` returns the first value in the Stream.  `Stream` must not be empty.

`Stream_Rest(Stream)` returns the rest of the Stream after the first value.  `Stream` must not be empty.

`Stream_Last(Stream)` returns the last value in the Stream.  `Stream` must not be empty.  It is useful when using `Stream_Unfold(MapFunc, Pred, GenFunc, Init)` to implement functions that use convergence.

`Stream_Count(Stream)` returns the count of the elements in `Stream`.  Be aware that this is not an efficient operation, unlike `Array_Count(Array)` and `Dict_Count(Dict)`!

`Stream_All(Pred, Stream)` tests ∀𝑥∈𝑋 𝑃(𝑥), where 𝑋 is `Stream` and 𝑃 is `Pred` (i.e. it returns whether the `Pred(X)` function object returns `true` for all elements of `Stream`).  Elements are tested in order until `Pred(X)` returns `false`, in which case it returns `false`, or it runs out of elements, in which case it returns `true`.  If `Stream` is empty, it returns `true`.

`Stream_Exists(Pred, Stream)` tests ∃𝑥∈𝑋 𝑃(𝑥), where 𝑋 is `Stream` and 𝑃 is `Pred` (i.e. it returns whether there exists an element of `Stream` for which the `Pred(X)` function object returns `true`).  Elements are tested in order until `Pred(X)` returns `true`, in which case it returns `true`, or it runs out of elements, in which case it returns `false`.  If `Stream` is empty, it returns `false`.

`Stream_FoldL(Func, Init, Stream)` returns the result of applying the `Func(A, X)` combining function object, where `A` is the accumulator and `X` is the value, recursively to the elements of `Stream` in order.  `Init` is often `Func(A, X)`’s identity element.  If `Stream` is empty, `Init` is returned.  If `Stream` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over a Stream.

`Stream_FoldL1(Func, Stream)` is like `Stream_FoldL(Func, Init, Stream)` except that the initial value of the accumulator is the first element of `Stream`.  `Stream` must not be empty.  If `Stream` contains 1 element, that element is returned.  It is useful when `Func(A, X)` has no identity element.

`Stream_MinBy(Func, Stream)` returns the first minimum element from `Stream`, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  `Stream` must not be empty.  Be aware that it cannot find minimum keys in posets, like floating-point values that include NaN or dictionaries!

`Stream_MaxBy(Func, Stream)` returns the first maximum element from `Stream`, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  `Stream` must not be empty.  Be aware that it cannot find maximum keys in posets, like floating-point values that include NaN or dictionaries!

`Stream_MinKBy(Func, K, Stream)` returns an Array containing the first minimum up to `K` elements from `Stream` from least to greatest, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  Elements with equal keys appear in order, like a stable sort.  If `Stream` contains < `K` elements, the result will contain any available elements.  Be aware that it cannot find minimum keys in posets, like floating-point values that include NaN or dictionaries!

`Stream_MaxKBy(Func, K, Stream)` returns an Array containing the first maximum up to `K` elements from `Stream` from greatest to least, where the keys to compare by are accessed or computed from each element using the `Func(X)` function object.  Elements with equal keys appear in order, like a stable sort.  If `Stream` contains < `K` elements, the result will contain any available elements.  Be aware that it cannot find maximum keys in posets, like floating-point values that include NaN or dictionaries!

`Stream_ToArray(Stream)` converts `Stream` to an Array.

`Stream_GroupBy(Func, Stream)` returns a Dict, where the keys are accessed or computed from each element in `Stream` using the `Func(X)` function object and the values are Arrays containing those elements in order.  The Dict has keys in the order they first appear in `Stream`.

`Stream_GroupByWMap(ByFunc, MapFunc, Stream)` returns a Dict, where the keys are accessed or computed from each element in `Stream` using the `ByFunc(X)` function object and the values are Arrays containing values accessed or computed from each element in `Stream` using the `MapFunc(X)` function object in order.  The Dict has keys in the order they first appear in `Stream`.  It is useful for constructing Dicts from Streams of decorated elements.

`Stream_GroupByWFoldL1Map(ByFunc, FoldLFunc, MapFunc, Stream)` returns a Dict, where the keys are accessed or computed from each element in `Stream` using the `ByFunc(X)` function object and the values are accessed or computed from each element in `Stream` using the `MapFunc(X)` function object.  If a key already exists, the `FoldLFunc(A, X)` combining function object is used to compute its new value, where `A` is the existing value and `X` is the value returned by the `MapFunc(X)` function object.  The Dict has keys in the order they first appear in `Stream`.  It is useful for constructing Dicts in complex ways (e.g. to construct a Dict where the keys are the elements in `Stream` and the values are the count of their occurrences, use `Stream_GroupByWFoldL1Map(Func("Func_Id"), Func("Op_Add"), Func_Const(1), Stream)`).


### Dict

This library contains functions that construct and process Dicts.  Dicts are useful for efficiently performing lookups by something other than consecutive Integers, preventing or removing duplicates by storing the values to be deduplicated as keys, representing configuration data, and representing finite sets.

Several functions in this library process items, key-value pairs.  An item is represented as an Array containing a key and a value, in that order.

Several functions in this library accept paths, a sequence of keys.  An empty path is valid.  A path is represented as an Array of keys.

`Dict(Items*)` is the Dict constructor.  It returns a Dict containing the items passed to it.

`Dict_FromObject(Object)` converts `Object` (a dictionary) to a Dict.

`Dict_ToObject(Dict)` converts `Dict` to an Object (a dictionary).  `Dict` must not contain keys that would collide when stored in an Object.

`Dict_IsDict(Value)` returns whether `Value` is a Dict.

`Dict_IsEmpty(Value)` returns whether `Value` is an empty Dict.

`Dict_Count(Dict)` returns the count of the items in `Dict`.  It returns the cardinality if `Dict` represents a finite set.

`Dict_Has(Key, Dict)` returns whether `Key` exists in `Dict`.  It tests set membership if `Dict` represents a finite set.

`Dict_Get(Key, Dict)` returns the value associated with `Key` in `Dict`.

`Dict_Set(Key, Value, Dict)` returns a copy of `Dict` with the value associated with `Key` set to `Value`.

`Dict_Update(Key, Func, Dict)` returns a copy of `Dict` with the value associated with `Key` set to the return value of the `Func(X)` function object, where `X` is the current value.  It is equivalent to `Dict_Set(Key, Func.Call(Dict_Get(Key, Dict)), Dict)`.

`Dict_Delete(Key, Dict)` returns a copy of `Dict` with the item indexed by `Key` deleted.

`Dict_CountIn(Path, Dict)` traverses the `Path` beginning at `Dict` and returns the count of the items in the Dict at the end.  If the `Path` is empty, it returns the count of the items in `Dict`.

`Dict_HasIn(Path, Dict)` returns whether the `Path` beginning at `Dict` exists.  If the `Path` is empty, it returns `true`.

`Dict_GetIn(Path, Dict)` traverses the `Path` beginning at `Dict` and returns the value associated with the key at the end.  If the `Path` is empty, it returns `Dict`.

`Dict_SetIn(Path, Value, Dict)` returns a copy of the nested Dicts along the `Path` beginning at `Dict` with the value associated with the key at the end set to `Value`.  If the `Path` is empty, it returns a copy of `Dict`.

`Dict_UpdateIn(Path, Func, Dict)` returns a copy of the nested Dicts along the `Path` beginning at `Dict` with the value associated with the key at the end set to the return value of the `Func(X)` function object, where `X` is the current value.  If the `Path` is empty, it returns a copy of `Dict`.  It is equivalent to `Dict_SetIn(Path, Func.Call(Dict_GetIn(Path, Dict)), Dict)`, but it is more efficient because it only performs one traversal.

`Dict_DeleteIn(Path, Dict)` returns a copy of the nested Dicts along the `Path` beginning at `Dict` with the item indexed by the key at the end deleted.  If the `Path` is empty, it returns a copy of `Dict`.

`Dict_Merge(Func, Dicts*)` merges the Dicts passed to it from left to right using the `Func(Key, AValue, XValue)` function object to compute the value of colliding keys, where `Key` is the key, `AValue` is the accumulated value, and `XValue` is the value just encountered.  The resulting Dict has keys in the order in which they were first encountered.  If no Dicts are passed to it, it returns an empty Dict, its identity element.

`Dict_Union(Dicts*)` computes the union of the Dicts passed to it from left to right.  The resulting Dict has keys in the order in which they were first encountered and values from the Dict in which they were last encountered.  If no Dicts are passed to it, it returns an empty Dict, its identity element.  It can be used to set many items (e.g. when the first Dict contains the default configuration settings and the other Dict contains the user’s configuration settings).

`Dict_Intersection(Dicts*)` computes the intersection of the Dicts passed to it from left to right.  The resulting Dict has keys in the order in which they were first encountered and values from the Dict in which they were last encountered.  At least 1 Dict must be passed to it because the universal set, its identity element, is not a finite set.  If only 1 Dict is passed to it, it returns a copy of that Dict.  It can be used to get many items (when an item might not exist).

`Dict_Difference(Dicts*)` computes the difference of the Dicts passed to it from left to right.  The resulting Dict has keys in the order in which they appear in the first Dict and values from that Dict.  At least 1 Dict must be passed to it.  If only 1 Dict is passed to it, it returns an empty Dict (consistent with `Op_Sub(Numbers*)`).  When flipped (see `Func_Flip(F)`), it can be used to delete many items (when an item might not exist).

`Dict_IsDisjoint(Dicts*)` tests whether the Dicts passed to it are mutually disjoint.  Values are ignored because that is the only definition that makes sense (e.g. `Dict_IsDisjoint(Dict_Union(A, B), A)` should always return `false`).  If < 2 Dicts are passed to it, it returns `true`.

`Dict_FoldL(Func, Init, Dict)` returns the result of applying the `Func(A, X)` combining function object, where `A` is the accumulator and `X` is the item, recursively to the items from `Dict` in order.  `Init` is often `Func(A, X)`’s identity element.  If `Dict` is empty, `Init` is returned.  If `Dict` is not empty, `Init` is the initial value of `A`.  It is useful for iterating over a Dict.

`Dict_FoldL1(Func, Dict)` is like `Dict_FoldL(Func, Init, Dict)` except that the initial value of the accumulator is the first item from `Dict`.  `Dict` must not be empty.  If `Dict` contains 1 item, that item is returned.  It is useful when `Func(A, X)` has no identity element.

`Dict_Filter(Pred, Dict)` returns a Dict constructed by folding over `Dict` and inserting items for which the `Pred(X)` function object returns `true`, where `X` is the item.

`Dict_KeyPred(Pred)` adapts the `Pred(X)` function object to operate on item keys.  It is useful for constructing predicates for filtering Dicts from existing predicates that were not designed to work with items.

`Dict_ValuePred(Pred)` adapts the `Pred(X)` function object to operate on item values.  It is useful for constructing predicates for filtering Dicts from existing predicates that were not designed to work with items.

`Dict_KeyValuePred(KeyPred, ValuePred)` adapts the `KeyPred(X)` and `ValuePred(X)` function objects to operate on item keys and values (respectively).  It is useful for constructing predicates for filtering Dicts from existing predicates that were not designed to work with items.

`Dict_Map(Func, Dict)` returns a Dict constructed by folding over `Dict` and inserting items returned by the `Func(X)` function object, where `X` is the item.  `Func(X)` must be injective for keys (i.e. it must not map multiple input keys to equal output keys).

`Dict_KeyFunc(Func)` adapts the `Func(X)` function object to operate on item keys.  It is useful for constructing functions for mapping over Dicts from existing functions that were not designed to work with items.

`Dict_ValueFunc(Func)` adapts the `Func(X)` function object to operate on item values.  It is useful for constructing functions for mapping over Dicts from existing functions that were not designed to work with items.

`Dict_KeyValueFunc(KeyFunc, ValueFunc)` adapts the `KeyFunc(X)` and `ValueFunc(X)` function objects to operate on item keys and values (respectively).  It is useful for constructing functions for mapping over Dicts from existing functions that were not designed to work with items.

`Dict_Invert(Dict)` maps over `Dict` to invert the items.  `Dict` must not contain duplicate values.  It is useful for implementing a bimap.

`Dict_Items(Dict)` returns an Array containing the items in `Dict`.

`Dict_Keys(Dict)` returns an Array containing the keys in `Dict`.

`Dict_Values(Dict)` returns an Array containing the values in `Dict`.


### Random

This library contains stochastic procedures.

`Random([Min, Max])` is a backport of v2’s [Random](https://lexikos.github.io/v2/docs/commands/Random.htm) function.

`RandomSeed(Seed)` is a backport of v2’s [RandomSeed](https://lexikos.github.io/v2/docs/commands/Random.htm#Seed) function.

`Random_Shuffle(Array)` returns a copy of `Array` with its elements in a random order.
