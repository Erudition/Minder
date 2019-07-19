module Nonnegative exposing
    ( value
    , from, force, abs
    , inc, add, difference, multiply, divide, divideInt, modBy, remainderBy
    , dec, subtract, map
    , tryDec, trySubtract, tryMap
    , forceSubtract, forceMap
    , absMap
    )

{-| A type representing nonnegative numbers. (Unlike positive numbers, a nonnegative number can also be zero.) This library is number-type agnostic: you can use it with `Int`s or `Float`s the same way.

@docs Nonnegative, value


# Create

@docs from, force, abs


# Guaranteed-safe Operations

@docs inc, add, difference, multiply, divide, divideInt, modBy, remainderBy


# Unsafe Operations

Theremaining few arithmetic functions, unfortunately, are not guaranteed to come back nonnegative. Therefore, we deal with them in the standard Elm way: either return `Just` the value we want, or `Nothing`. Great for the "fail fast" approach - you deal with problems as soon as the number is made, rather than later on when you're not sure where that negative number came from!

@docs dec, subtract, map


# Pretend it didn't happen

But what if you don't want to deal with `Maybe` values, and you'd rather get back something than `Nothing`?
This family of functions will only perform the operation on the given value if it's valid to do so. Otherwise, the `Nonnegative` passes through untouched.

@docs tryDec, trySubtract, tryMap


# Fail with Zero

This family of functions forces the operation on the given value, but also forces it to stay `Nonnegative`... which means negative numbers are clamped to zero. Sure, you don't have to deal with `Maybe`, but corrupt input becomes harder to debug!

@docs forceSubtract, forceMap


# Fail with Positive

Corrupt input data is hard to debug when it's propogated through your system via the "force" functions. "Where did all these zeros come from?!" To make it easier to identify the source, you can allow the positive (valid) version of the invalid (negative) numbers to propogate through instead, which still gives incorrect behavior but allows you to better identify where the corruption is coming from!

@docs absmap

-}


{-| -}
type Nonnegative number
    = Nonnegative number


{-| Safely try to create a `Nonnegative` number. Rejects corrupt input (negatives) with `Nothing`, otherwise you get `Just` the new `Nonnegative`.
-}
from : number -> Maybe (Nonnegative number)
from new =
    if new >= 0 then
        Just (Nonnegative new)

    else
        Nothing


{-| Forcibly create a `Nonnegative` number, without a `Maybe` output.

Negative input is clamped to 0. Great for setting hardcoded values you know are valid.

-}
force : number -> Nonnegative number
force new =
    if new >= 0 then
        Nonnegative new

    else
        Nonnegative 0


{-| Create a `Nonnegative` number with the given value, removing any negativity via absolute value.

A great way to reduce information loss on bad input, without having to deal with `Maybe`.

-}
abs : number -> Nonnegative number
abs new =
    Nonnegative (Basics.abs new)


{-| Treat a `Nonnegative` as a normal number. You can then use all other arithmetic functions on it.
-}
value : Nonnegative number -> number
value (Nonnegative n) =
    n


{-| Increments the given number.
-}
inc : Nonnegative number -> Nonnegative number
inc (Nonnegative n) =
    Nonnegative (n + 1)


{-| Add two `Nonnegative` values, which always produces another `Nonnegative`.
-}
add : Nonnegative number -> Nonnegative number -> Nonnegative number
add (Nonnegative a) (Nonnegative b) =
    Nonnegative (a + b)


{-| Decrements the given number if possible. Otherwise you get `Nothing`.
-}
dec : Nonnegative number -> Maybe (Nonnegative number)
dec (Nonnegative n) =
    if n == 0 then
        Nothing

    else
        Just (Nonnegative (n - 1))


{-| Decrements the given number if it's positive. Otherwise keep it at zero.
-}
tryDec : Nonnegative number -> Nonnegative number
tryDec (Nonnegative n) =
    if n == 0 then
        Nonnegative 0

    else
        Nonnegative (n - 1)


{-| Get the difference between two `Nonnegative` values, which is always another `Nonnegative`.
-}
difference : Nonnegative number -> Nonnegative number -> Nonnegative number
difference (Nonnegative a) (Nonnegative b) =
    Nonnegative (a - b)


{-| Subtract a normal number from a `Nonnegative` one, if the result is nonnegative. Otherwise you get `Nothing`.
-}
subtract : number -> Nonnegative number -> Maybe (Nonnegative number)
subtract a (Nonnegative b) =
    from (a - b)


{-| Try to subtract a normal number from a `Nonnegative` one, but get the original back if it's not possible.
-}
trySubtract : number -> Nonnegative number -> Nonnegative number
trySubtract a (Nonnegative b) =
    if a - b >= 0 then
        Nonnegative (a - b)

    else
        Nonnegative b


{-| Subtract a normal number from a `Nonnegative` one, without going negative (stops at zero).
-}
forceSubtract : number -> Nonnegative number -> Nonnegative number
forceSubtract a (Nonnegative b) =
    force (a - b)


{-| Multiply two `Nonnegative` values, which always produces another `Nonnegative`.
-}
multiply : Nonnegative number -> Nonnegative number -> Nonnegative number
multiply (Nonnegative a) (Nonnegative b) =
    Nonnegative (a * b)


{-| Divide two `Nonnegative` floating-point values, which always produces another `Nonnegative`.
-}
divide : Nonnegative Float -> Nonnegative Float -> Nonnegative Float
divide (Nonnegative a) (Nonnegative b) =
    Nonnegative (a / b)


{-| Divide two `Nonnegative` integer values, which always produces another `Nonnegative`.
-}
divideInt : Nonnegative Int -> Nonnegative Int -> Nonnegative Int
divideInt (Nonnegative a) (Nonnegative b) =
    Nonnegative (a // b)


{-| Perform the "modulus" operation on two `Nonnegative` integer values, which always produces another `Nonnegative`.

You can think of modular arithmetic as taking a number and "wrapping it around" some smaller number, so that every time you hit the smaller number you start over from zero. You already do this when you think about the clock! On a 24-hour clock, what time is one hour after midnight (24:00)? That's right, 01:00. 24 hours after that? Yep, still 01:00. It will never go past 24, because each time it does, you subtract 24! The time of day, therefore, is the number of hours `modulus` 24.

For Nonnegative numbers, this is mathematically equivalent to the remainder after division.

-}
modBy : Nonnegative Int -> Nonnegative Int -> Nonnegative Int
modBy (Nonnegative a) (Nonnegative b) =
    Nonnegative (Basics.modBy a b)


{-| Divide two `Nonnegative` integer values and get the `Nonnegative` remainder.
An alias for `modBy`, which is mathematically identical for all `Nonnegative` values.
-}
remainderBy : Nonnegative Int -> Nonnegative Int -> Nonnegative Int
remainderBy (Nonnegative a) (Nonnegative b) =
    Nonnegative (Basics.remainderBy a b)


{-| Transforms a Nonnegative value with a given function. If the value returned by the given function is less than 0, it will return a `Nonnegative` of zero.
-}
map : (number -> number) -> Nonnegative number -> Maybe (Nonnegative number)
map mapFn (Nonnegative n) =
    let
        done =
            mapFn n
    in
    if done >= 0 then
        Just (Nonnegative done)

    else
        Nothing


{-| Transforms a Nonnegative value with a given function. If the value returned by the given function is negative, it will return a `Nonnegative` of zero.
-}
tryMap : (number -> number) -> Nonnegative number -> Nonnegative number
tryMap mapFn (Nonnegative n) =
    let
        done =
            mapFn n
    in
    if done >= 0 then
        Nonnegative done

    else
        Nonnegative n


{-| Transforms a Nonnegative value with a given function. If the value returned by the given function is negative, it will return a `Nonnegative` of zero.
-}
forceMap : (number -> number) -> Nonnegative number -> Nonnegative number
forceMap mapFn (Nonnegative n) =
    force (mapFn n)


{-| Transforms a Nonnegative value with a given function. If the value returned by the given function is negative, it will be made positive.
-}
absMap : (number -> number) -> Nonnegative number -> Nonnegative number
absMap mapFn (Nonnegative n) =
    abs (mapFn n)
