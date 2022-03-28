module Incubator.Safenums.Anynum exposing (..)

import Incubator.Safenums.Safenum exposing (..)



-- Creation


{-| Make a safe, finite `Anynum` from an unsafe native number type.

If the number is NaN or infinite, 0 will be used instead.
To specify a different fallback value, use `withDefault`.
If you're sure this check is unnecessary, consider using `trusted` instead for performance.

-}
forced : number -> Anynum number c
forced num =
    if isInvalidNumber num then
        Safenum 0

    else
        Safenum num


{-| You can represent numbers outside of this range, but not precisely.
<https://stackoverflow.com/questions/307179/what-is-javascripts-highest-integer-value-that-a-number-can-go-to-without-losin>
-}
isTooBigForPrecision : number -> Bool
isTooBigForPrecision number =
    abs number > 9007199254740991



-- TODO this only works for floats
-- {-| Make a safe, finite `Anynum` from an unsafe native number type.
--
-- If the number is NaN or infinite, the provided default Anynum will be used instead.
-- If you want to use Anynum.zero as your default, simply use `forced`.
--
-- -}
-- withDefault : Anynum number c -> number -> Anynum number c
-- withDefault fallback num =
--     if isInfinite num || isNaN num then
--         fallback
--
--     else
--         Safenum num
-- Basics


add : Anynum number c -> Anynum number c -> Anynum number c
add (Safenum pos1) (Safenum pos2) =
    Safenum (pos1 + pos2)


multiply : Anynum number c -> Anynum number c -> Anynum number c
multiply (Safenum pos1) (Safenum pos2) =
    Safenum (pos1 * pos2)


difference : Anynum number c -> Anynum number c -> Anynum number c
difference (Safenum pos1) (Safenum pos2) =
    Safenum (abs (pos1 - pos2))



-- MANUAL SAFETY


{-| Make any `Anynum` from a hardcoded value.
No runtime checks, so no runtime cost.
You must never pass in a value that is infinite or NaN, or you void your warranty (a.k.a. the safety guarantees of this library fail to hold).
The performance benefit may be negligible, so consider using `forced` instead.
-}
trusted : number -> Anynum number c
trusted num =
    Safenum num


{-| Wraps a valid Anynum, or crashes immediately if an invalid number is given. Only works in debug/dev environments, as you must pass in your `Debug.todo` function like so:
`orElseCrash Debug.todo potentiallyUnsafeNumber`
When you are confident that the crash will never trigger, you can switch to `trusted` instead.
-}
orElseCrash : (String -> number) -> number -> Anynum number c
orElseCrash crasher num =
    let
        crashMsg =
            "Tried to generate a safe number, but what I got was invalid"

        crash =
            modBy 0 1
    in
    if isInvalidNumber num then
        Safenum (crasher crashMsg)

    else
        Safenum num


isInvalidNumber num =
    let
        isInfiniteHack =
            -- currently isInfinite only works on floats
            -- this will also detect infinity
            isTooBigForPrecision

        isNaNHack maybeNaN =
            -- currently isNaN only works on floats
            -- it seems NaN are always == 0, even though they're not == each other
            maybeNaN == 0 && maybeNaN + 1 == 0
    in
    isInfiniteHack num || isNaNHack num
