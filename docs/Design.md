## The Name

Facade's name comes from the facade pattern.  It wraps some of AutoHotkey's APIs (specifically, most of the processing APIs) with better APIs to make them safer and easier to use.


## The Idea

After using AutoHotkey for gaming and Windows system administration for several years, I became extremely frustrated with its design.  Almost every feature is dangerous (e.g. the pervasive use of silent failure), impractical (e.g. Sort operates on the contents of a String), or interacts badly with other features (e.g. libraries and programming language 'configuration' like StringCaseSense).

I found no alternative that provided all of the features that I desire: keyboard, mouse, and gamepad remapping; keyboard, mouse, and gamepad hotkeys; a general-purpose programming language that supports defining data structures; image pattern recognition; GUI automation; and creating self-extracting archives with self-executing programs.

I noticed that everything that I liked involved AutoHotkey's I/O and self-extracting archive facilities and everything that I disliked involved its programming language.

I was aware that AutoHotkey.dll existed and that there were wrappers for it for acceptable programming languages.  I soon became aware that this was inadequate.  Most programming language implementations have no support for calling procedures in themselves directly from hooks in C like hotkeys require.  Most programming language implementations have no support for creating self-extracting archives with self-executing programs.

I read some of AutoHotkey's source code to determine if it would be practical to fix the programming language.  I found many bad decisions (e.g. making all values COM objects (necessitating reference counting instead of tracing garbage collection), abandoning any potential benefits of making all values COM objects by ignoring the OLE Automation interface standards (e.g. the Collection and IEnumVARIANT interfaces), unnecessary hard-coded limits (e.g. an expression length limit), and refusing to use the C++ STL (resulting in redundant, inefficient code)) and many comments describing workarounds necessitated by these bad decisions or Windows version variations.  It seems it would be easier to start over than fix all of these flaws, and understanding how the desirable features work would be extremely difficult.

I believed it might be possible to build something more usable atop AutoHotkey.

It is difficult to implement an interpreter or compiler in a programming language that is difficult to use for much simpler tasks, so I was limited to writing libraries.

I decided to use functional programming because eliminating unnecessary mutable state should make AutoHotkey's 'multithreaded' environment safer and AutoHotkey's functions work better than its objects.

AutoHotkey does not support closures, but it does support function objects.  I remembered that Moses Schönfinkel proved that lambda abstraction is unnecessary if you have the right combinators.  This led to developing the Func library that is the core of Facade.


## Guiding Principles

The principles are listed from most to least important.


Avoid Problems:

* Avoidable problems become more prevalent when solved.

  Facade avoids the problem of how to use mutable state safely in AutoHotkey's 'multithreaded' environment by not using mutable state (except in the Random library).  It could have solved the problem by using critical around the code in all classes' methods, but then anyone using it would have to do the same and latency would be worse.


Do Not Cause Problems:

* Do the safest thing.

  Facade halts execution if an unhandled error occurs.

  Mutability is not a bug, it's a feature, but it's the wrong default.  Facade's Dict type supports mutation, but Facade does not use mutable state (except in the Random library).

* Do the least surprising thing.

  Facade is consistent.

  Facade functions that can return a copy of a mutable data structure always return a copy so that mutating the result is never surprising.

* Do not break others' code.

  Facade avoids breaking others' code by prefixing its definitions and by not monkey patching.

* Do not cause unnecessary incompatibility.

  Facade does not define unnecessary incompatible types.  It does not model side effects and errors as types and return values.  It does not exclusively use immutable collections.  Its random access collections cannot also be used as functions.

  Facade's collections can be enumerated like AutoHotkey's built-in collections.

* Discourage misuse.

  What Facade does not include is as important as what it includes.  Operations omitted from each type guide the programmer to use appropriate types.


Solve Problems:

* Completeness is important.

  Facade includes rarely used functions, like Scans, for completeness.


Do Not Waste People's Time:

* The simplicity of the interface is more important than the simplicity of the implementation (i.e. it is better to waste programmers' time than users' time because there are more users, and sometimes programmers are users).

  I have made my best effort to provide a simple interface.

  Facade suffers from the expression problem.

  In theory, most of Facade's functions could be generic.  Functions could be closed (e.g. Concat("foo", "bar") could return "foobar" and Concat([0], [1]) could return [0, 1]) or prefer a type (e.g. Concat() could return the empty String and GroupBy(Func, Sequence) could return a Dict).  This would make code using Facade more concise and make it possible to use Facade with new types.

  Constructors, including Stream sources, are an exception.  There must be a way to specify the type to construct.  For example, someone might implement an Enumerator library that, other than Enumerator sources, uses generic functions.

  Error reporting could be implemented by requiring arguments be covariant (i.e. the same type or a subtype) relative to a specific type (e.g. Number for most math functions) or each other (e.g. Strings and Arrays can be concatenated, but Strings cannot be concatenated with Arrays).

  Single dispatch seems to be adequate.

  In practice, making most of Facade's functions generic is impossible because AutoHotkey's built-in types are outside its object system.  There is no way to define a subtype of a built-in type (e.g. there is no way to define a Rational type as a subtype of Float so that it would be possible to use Facade with fractions).  AutoHotkey v2 is not expected to correct this flaw.

* Conciseness and debuggability are more important than efficiency (i.e. it is better to waste computers' time than humans' time).

  Facade is an abstraction, and like all abstractions that do not compile to literals, it causes overhead.  In exchange, it reduces the amount of code the programmer must write and the time they spend debugging it.

* Explain errors (i.e. do not waste programmers' time).

  Facade reports errors in a precise, detailed, and helpful way.

* Design, but do not code, for change (i.e. do not waste your time).

  Designing with likely changes in mind makes it easier to adapt your code, but writing extra code to cope with changes that might never occur causes bloat.

  My previous attempt at a functional programming library was broken by the addition of the BoundFunc type because it does not retain the information the Func type does and I was using that information for validation.  It is tempting to assume that this was intentional, but I should probably apply Hanlon's razor.  I have intentionally written Facade in such a way that breaking it is likely to break a lot of other code, just in case it was intentional.

  I designed Facade with AutoHotkey v2 in mind.  The _Validate and Math libraries can be deleted with extensive but simple editing when AutoHotkey starts throwing its own exceptions.  Random([Min, Max]) and RandomSeed(Seed) can be deleted from the Random library and code using them can remain unchanged.


## Overarching Design

Facade is effectively a combinator-oriented programming language exposed as functions in AutoHotkey.

Combinatory logic was discovered while searching for the simplest foundation for all of mathematics.  It eliminates free variables.

We now know that all of mathematics can be expressed by a single combinator and Church encoding.  A computer based on such a model is known as a one instruction set computer (OISC) or ultimate reduced instruction set computer (URISC).  They are impractically inefficient in time and space.

Practical combinator-oriented programming languages provide many combinators drawn from patterns that occur in programs humans write so that they have concise, intention revealing source code and are efficient in time and space.

Combinator-oriented programming was pioneered in the APL programming language in 1966 and the Forth programming language in 1970.  Their conciseness, simple evaluation models, and encouragement of code reuse were valued in the time and space constrained early computing environment.

Function-level programming, a restricted form of combinator-oriented programming, was pioneered in the FP programming language in 1977.  It was hoped that correctness proofs would be made easier by limiting programs to being constructed by carefully designed combinators (e.g. if the combinators cannot express non-termination, all programs constructed by them are guaranteed to terminate).

I chose to make Facade Turing complete because I wanted it to express familiar programs in familiar ways.  Reasonable people, like John Backus -- the designer of the FP programming language, might disagree with this decision.

Turing completeness is usually defended by pointing out that most modern programs are not intended to self-terminate.  They are intended to terminate only upon receiving a message reserved for that purpose.

An astute observer might notice that most modern programs consist of event handlers that /are/ intended to self-terminate in a timely manner and that a regularly occurring event attached to a self-terminating event handler (like the timer interrupt handler) can perform Turing complete computations without presenting the risk of the program becoming unresponsive.  It is a short step to imagine an event-driven programming language with only finite loops and without recursion that could be statically analyzed for worst-case time consumption by exploring all execution paths.  This analysis could abort with an error as soon as an execution path breaches the tolerable limit.  Such a programming language could be further restricted by exclusively using static allocation to ensure tolerable worst-case space consumption.

Facade is not that programming language, and maybe it is worse for it.  It is what it was intended to be: an easy to implement, well-integrated abstraction atop AutoHotkey.

Facade is a mashup of constructs from many functional programming languages and libraries.  This presents the risk of making a maladroit mess and raises the question of scope.

The risk of making a maladroit mess is mitigated by relentlessly pursuing good naming, consistency, and elegance.  Facade's names are familiar and intention revealing (if you are a functional programmer) and short (so that expressions are readable).  Facade's library, function, and parameter order; naming; and processing of mutable values are consistent (so that nothing is surprising and no code needs to be written to abstract over inconsistencies).  Facade's elegance can be judged by its simplicity (it has few primitive constructs), generality (those primitive constructs can be used for many different purposes), composability (its constructs can be combined to produce more complex constructs), and the conciseness of code that uses it (code using Facade is usually shorter than the equivalent code written directly in AutoHotkey).  You do not need to learn a lot of different things to do a lot of different things with Facade.

Facade's scope is neither minimalist nor kitchen sink.  Minimalist designs often cause Turing tarpits.  Kitchen sink designs often cause difficulty finding the desired construct among the clutter.  I attempted to strike a balance by adding anything that seemed useful in most programs then removing anything experience proved to be redundant or useless.

Facade's String library's scope is minimalist because it did not seem useful to expand it.  AutoHotkey's built-in String processing functions seem adequate, though they suffer from the usual inconsistency.  Silent failures return the empty String, and the empty String is valid input to most String processing functions, so there is little opportunity for improved error reporting.

A date/time library is outside Facade's scope because it involves I/O (to read the current time) and developing a good one involves solving social problems (e.g. ambiguous and changing formatting, changing daylight saving time policies, and changing time zones) that even large organizations have found too difficult to solve.  It seems that the best way to handle date/time problems is to avoid them, but if you must solve them, keep everything in UTC format and convert it from and to the preferred local format only for I/O.  Anyone insisting on attempting such a library should probably clone java.time.

Facade's architectural style is inspired by production lines.  This analogy is recursive.  Both the libraries and the functions within them represent machines that are connected by variables that represent conveyor belts.  This analogy is strongest in streams.

The functions are usually grouped into libraries based on the type of their subject.  Most functions are closed (i.e. they return the type they operate on).

The libraries appear in topologically sorted order in the documentation because concepts that are foundational must be understood before concepts built atop them can be understood.

The functions appear in an order intended to reveal relationships between the libraries and functions because that eases understanding.  Related functions appear near one another.  Functions that adapt types for use by the library appear at the beginning.  Functions that adapt the library's type for use by other libraries appear at the end.  Other functions often appear in topologically sorted order (e.g. eager Filters and Maps are built atop Folds).

Some libraries have unique organizing principles.  The operator library is ordered by descending precedence.  The combinator library is ordered lexicographically by the combinators' names.  The stream library is broken down into sources, flows, and sinks because being aware of whether an operation is lazy or eager is necessary to avoid non-termination.

Most functions are named such that their names would not collide and would be intelligible without a library prefix.  This resulted in better names and a design that would be easier to make generic.

Functions are named via agglutination.  This is considered a bad practice by some.  I disagree because it makes relevant functions easy to find when searching and there is often no intention revealing name for a highly abstract function.  The agglutinative name reveals and reminds of the behavior of the function.  An "Is" prefix reveals that the function is a predicate (operators do not follow this convention).  A "By" component (usually a suffix) reveals that the function accepts a function object to access or compute key values.  A "With" component (usually a suffix) reveals that the function accepts a function object to apply to arguments it computes.  A "W" component (usually infix) means "with" without implying the behavior just described.  An "In" suffix reveals that the function accepts a path of keys to traverse.

Many names were improved via agglutinative renaming.  Converge became ApplyArgsWith, which reveals the relationships between Apply, ApplyRespWith, and itself and describes the function's behavior (it has nothing to do with convergence).  UseWith became ApplyRespWith, which reveals the relationships between Apply, ApplyArgsWith, and itself.  Uniq became DedupBy, which is a verb.  FlatMap became ConcatZipWith, which reveals the relationships between Concat, ZipWith, and itself and will not be mistaken for Flatten following Map (it only 'flattens' 1 level).  GroupMap became GroupByWMap, which reveals the relationship between GroupBy and itself and reminds of the separation between the By and Map computations.  GroupMapReduce became GroupByWFoldL1Map, which reveals the relationships between GroupBy, GroupByWMap, and itself and reminds of the separation between the By and FoldL1 following Map computations.  The new names are more consistent.

Parameters are ordered from most to least frequently bound.  This makes specializing functions with Bind as easy as possible.  It also results in a design where the index parameter comes before the collection parameter.  This might seem strange, but experience has proven this to be the most useful order.

Parameter names make use of AutoHotkey's separate function and variable namespaces.  Parameters are often named after their type.

There are several more cross-cutting concerns.

AutoHotkey is not a well-designed programming language.  Its fractal of bad design leaks through Facade.

How should testing the type of a value behave?

In a well-designed programming language, there would be a generic IsType function.

My Type Checking library provides one, but AutoHotkey conflates Objects (dictionaries) with Arrays.  The Array type has its own type checking function for that reason.  The other collections' type checking functions save you the effort of importing their class' global variable into your procedure's scope, but they mostly exist to provide some regularity to this irregularity.

How should floating-point operations behave?

The way IEEE 754 specifies is not the answer it might seem to be.  Some things are standardized but not widely implemented (e.g. trapping, fixups, signaling NaNs, NaN payloads, half-precision floating-point format, quadruple-precision floating-point format, and decimal64 floating-point format) and some things are widely implemented but not standardized (e.g. which situations signal an error instead of returning a NaN or infinity).

IEEE 754 also promotes some bad design decisions.  Chief among them is the use of silent failure by causing operations on invalid input to return NaN, overflow to return negative or positive infinity, and underflow to silently lose precision.  To make matters worse, the inclusion of NaN causes the real numbers to become a poset.  To compound the problem, NaNs, even with the same payload (and no one uses NaN payloads), are not equal to themselves (n.b. the infinities are equal to themselves despite also not necessarily representing the same value).

A programming language must cope with these problematic values because they can be returned by FFI calls to C and C++ code.  Facade does so by throwing exceptions instead of returning a NaN (or an infinity in the case of division by 0) when performing a floating-point operation on invalid input and otherwise conforming to IEEE 754.  IEEE 754 specifies case-insensitive "nan" and an optional sign followed immediately by "inf" or "infinity" as the correct way to input these values.  Facade follows the popular convention of outputting these values as "nan", "-inf", and "inf".  Facade always constructs NaNs with the sign bit set and the payload bits unset (i.e. it uses 'the NaN', not 'a NaN').  I believe this is the best way to allow interaction with foreign code without making the robustness problem worse.

How should NaN dictionary keys behave?

What follows is Facade's answer.  NaNs are indexed by their value (bitwise representation) like other floating-point values.  You can set items with NaN keys like other values.  You cannot get items with NaN keys because equality is not reflexive for NaNs.  All items with NaN keys will be enumerated by an Enumerator.  I believe these semantics are the most consistent possible given the irregular semantics of NaNs.

What collection types should be provided and what operations should they support?

Arrays are indexable mutable sequences and the preferred sequence type (e.g. they are used for variadic arguments and application).  Operations involving lookahead, reverse traversal, and random access of sequences are unique to them.

Lists are immutable sequences.  They are limited to being used as stacks to discourage unnecessary use because they are less time and space efficient than Arrays for most other purposes.

Streams are lazily evaluated immutable sequences.  Operations involving generating sequences are unique to them.

Dicts are mutable dictionaries.  Operations involving sets and key-value associations are unique to them.

I believe these collection types to be adequate because other types seem to be easy to construct atop them.

Should sets and dictionaries be different types?

Facade follows the Smalltalk model in that dictionaries are subtypes of sets that have values associated with their elements, but it goes further in that it does not include a set type.

Is this conflation no different from the kind I complain about in AutoHotkey?

Dictionaries are valid subtypes of sets, so no semantics are destroyed.  Sets and dictionaries are implemented the same way, so no efficiency is lost.  Set operations on dictionaries have practical uses.  I believe this conflation is different and desirable for those reasons.

How should immutable object dictionary keys behave?

In a well-designed programming language, fully immutable objects (n.b. an immutable collection, like a List, can contain a mutable collection, like an Array) used as dictionary keys would be indexed by their value, not their identity.

Facade Dicts index all objects by their identity because that eases the adoption of Facade.  AutoHotkey Objects index all objects by their identity.  If Facade Dicts indexed fully immutable objects by their value, there would be Objects that could not be converted to Dicts.  There is no common type hierarchy or interface that can be used to determine how to index arbitrary types, so it would be impossible to index fully immutable objects by their value reliably.  I am unsure that trading better semantics for easier adoption was the correct decision.

How should getting and setting behave?

In a well-designed programming language, there would be generic Get and Set functions that do not use paths and dictionary-specific GetIn and SetIn functions that use paths.  I adopted the Get and Set names from lens terminology (Set is assoc in Clojure), but I adopted the use of paths from Clojure (n.b. I did not adopt Clojure's surprising behavior for empty paths) because it is more powerful and less verbose than lenses.  It is theoretically possible to use paths with some other collection types (e.g. lists), but the resulting code tends to be incomprehensible.  There would be no properties because everything would be encapsulated (as in Smalltalk's object model).

Suitable interfaces to build these functions atop do not exist in AutoHotkey.  Reading the value of a property and reading the value at an index are conflated.  There is no way to clone arbitrary objects.  Op_GetProp(Prop, Obj) attempts to read the value of a property, but it might read the value at an index.  Op_Get(Key, Obj) attempts to read the value at an index (n.b. it will use a Get(Key) method if present, unlike Op_GetProp(Prop, Obj)), but it might read the value of a property.  These generic Get functions can be used with types Facade was not designed to work with, but they might fail silently.  Array_Get(I, Array) is like Op_Get(Key, Obj) except that it performs index adjustment so that the programmer can pretend Arrays are 0-based and it reliably reports errors.  Dict_Get(Key, Dict) is like Op_Get(Key, Obj) except that it reliably reports errors.  Dict_Set(Key, Value, Dict) is a referentially transparent equivalent to mutation for Dicts.  The GetIn and SetIn functions are built atop the Get and Set functions.

How should the relational operators behave?

Many programming languages perform recursive comparison, but none that I know of perform recursive ordered comparison of dictionaries.  I was inspired by Python's recursive ordered comparison of sets as (proper) (sub|super)sets and Smalltalk's modeling of dictionaries as sets.  When I tried to find a way to compare the values, I had the insight to treat the values as extensions of the respective keys (i.e. check that both dictionaries have the key with recursively equal values before considering the element to exist in both sets).

Dictionary comparison is always case-sensitive because key lookup is always case-sensitive.  If you want to compare only the values case-insensitively, it is easy to write code to do that.

Dictionary comparison is order-insensitive because order-sensitive dictionary comparison is almost always surprising and useless.

Identity comparison compares immutable objects by their identity, not their value, for the same reason that immutable object dictionary keys are indexed by their identity.  This is consistent, but not ideal.

Which is the best collection processing model: Reduces and variadic Map or fixed-arity Folds, fixed-arity Map, and ZipWith?

Fixed-arity Folds, fixed-arity Map, and ZipWith is the best because it can be used with more types and it makes it possible to reuse more code.  Folds do not require the initial value of the accumulator to be hard-coded or bound in the combining function and they do not require the combining function to be variadic, unlike Reduces.  Fixed-arity Folds and fixed-arity Map can be used with dictionaries, unlike Reduces and variadic Map.  Fixed-arity Folds following ZipWith can do anything Reduces can do.  ZipWith is variadic Map, so it can do anything variadic Map can do.

Most of the collection processing functions in Facade can be found in most other functional programming languages and libraries, but there are a few exceptions that are used with multiple types.

What follows is my best effort to attribute these ideas to their sources.

Scala (programming language)
* GroupByWMap  (groupMap in Scala)
* GroupByWFoldL1Map  (groupMapReduce in Scala)

My Invention
* FilterApply
* MapApply

They make it possible to write more concise and intention revealing code.


## _IsArray




## _Validate




## Op

This library is a Python and Lisp inspired conversion of operators to functions, along with some additional primitive functions.

It is useful to be able to obtain a reference to a function that is an operator for functional programming.

Python's operator library, often imported as op, inspired this library's concept and name.

Lisp inspired this library's semantics.

Which functions usually become operators?

Functions that correspond to a single instruction and are used by most programs.

AutoHotkey is missing several such operators, and several of its operators are defective, so I took this opportunity to provide the missing functions and correct the defective functions.  These are the operators as they should have been, not as they are.

You cannot design a high quality system (like a programming language) by designing high quality components in isolation.  The quality of a system is emergent.  It depends on how well the components work together.

As in Lisp, when it is possible and useful, functions are self-left-folding and the identity element is the initial value of the accumulator.  This makes them work well with Apply.

As in Lisp, when an identity element does not exist or cannot be represented, at least 1 argument must be passed and the most useful value is the initial value of the accumulator.  The initial value of the accumulator is often the identity element of the inverse function.  This sometimes reduces the functions needed (e.g. Sub with 1 argument negates, so a Neg function is not needed).


## Func

This library is my attempt to collect all combinators useful in most programs.  When everything has to be a nail, you better have a good toolbox of hammers!

What follows is my best effort to attribute these ideas to their sources.

Lisp (programming language)
* Func_Apply(Func, Args)

Miranda (programming language)
* Func_Id(X)
* Func_Const(X)

Haskell (programming language)
* Func_Flip(F)
* Func_On(F, G)

J (programming language)
* Func_HookL(F, G)
* Func_HookR(F, G)
* Func_FailSafe(Funcs*)  (adverse in J)

Joy (programming language)
* Func_CIf(Pred, ThenFunc, ElseFunc)  (ifte in Joy)
* Func_CCond(Clauses*)  (cond in Joy)

Clojure (programming language)
* Func_Applicable(Obj)  (just how random access collections work in Clojure)
* Func_Comp(Funcs*)
* Func_CNot(Pred)  (complement in Clojure)

Python (programming language)
* Func_MethodCaller(Method, Args*)

Lodash (JavaScript library)
* Func_Rearg(Func, Positions)

Ramda (JavaScript library)
* Func_ApplyArgsWith(Func, ArgsFuncs)  (converge in Ramda)
* Func_ApplyRespWith(Func, RespFuncs)  (useWith in Ramda)

AutoHotkey L (programming language)
* Func_Bind(Func, Args*)

AutoHotkey H (programming language)
* Func_DllFunc(NameOrPtr, Types*)  (DynaCall in AutoHotkey H)

My Invention
* Func_CNotRel(RelPred)
* Func_CAnd(Preds*)
* Func_COr(Preds*)
* Func_Default(Func, Default)

My inventions are obvious in light of the other combinators.

The mathematical inspiration for most of these combinators is mentioned in the documentation for users to improve searchability.  However, some of these combinators are similar to, but not the same as, combinators used in mathematics.

The HookL combinator is similar to the D combinator (D f x g y = f x (g y)).  The HookL combinator parameters are in an order more useful to programmers.  The D combinator is similar to the S combinator (S f g x = f x (g x)).

The ApplyArgsWith combinator is similar to the S' combinator (a.k.a. Φ combinator) (S' f g h x = f (g x) (h x)).  The ApplyArgsWith combinator is variadic.

The design of some combinators should be explained.

Should Bind, MethodCaller, and Apply accept individual arguments or an Array of arguments?

Bind and MethodCaller are used for partial application, so they should accept individual arguments.  Apply is used for whole application, so it should accept an Array of arguments.  Experience has proven this to be the most useful design (e.g. it minimizes the use of adapters).

MethodCaller can return function objects that accept additional arguments because this is consistent with Bind and often useful.

Clojure's random access collections can behave like functions.  Given that random access collections and functions map their domain to their image, it is surprising that this idea is not more widespread.  This feature is very useful, so I provided Applicable to make it possible to convert random access collections to functions.  I believe it would be more error-prone if conversion was unnecessary for Facade's random access collections, so they cannot behave like functions.

ApplyArgsWith is designed to extract arguments for a function from (usually singular) arguments.  Clojure uses juxt for the same purpose, but it does not finish the job.  The vector (array) juxt returns is almost always used as arguments for a function.  ApplyArgsWith finishes the job.

ApplyRespWith is designed to pre-process arguments for a function.  It is like ApplyArgsWith except that the functions that extract arguments apply to the respective argument.

Const returns variadic function objects because this makes it more useful.

Providing both CIf and CCond might seem redundant, but it makes it possible to trade specificity for conciseness and to improve space efficiency.  It is possible to specify the default case when using nested CIf, but it is not possible when using CCond.  Nested CIf consumes more call stack space the deeper evaluation descends into the nesting, but CCond consumes a constant amount of call stack space.


## Math




## String




## _Push




## _Dict




## _DedupBy




## _Sinks




## Array




## List




## Stream




## Dict




## Random


