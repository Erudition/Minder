module ParserExtra exposing (deadEndsToString, paddedInt, realDeadEndsToString, strictPaddedInt)

import Parser exposing (..)


paddedInt : Parser Int
paddedInt =
    getChompedString (chompWhile Char.isDigit)
        |> Parser.andThen digitStringToInt


{-| Like `paddedInt`, but fails if the integer was not padded enough to meet a minimum length.

Perhaps you want to parse the time of day:

    "1:05" -- allowed

    "1:5" -- not allowed

Note: there is no maximum length check, but you can just check the successfully parsed `Int` if it's greater than you prefer. For example, you can use this to parse the year `2004` and `0098` while failing on `98`, but the year `12004` will always succeed (it's a valid year!) because you could always do `yearInt <= 9999` if you want to exclude 5-digit years.

-}
strictPaddedInt : Int -> Parser Int
strictPaddedInt minLength =
    let
        checkSize : String -> Parser String
        checkSize digits =
            if String.length digits >= minLength then
                Parser.succeed digits

            else
                Parser.problem <| "Found number: " ++ digits ++ " but it was not padded to a minimum of " ++ String.fromInt minLength ++ " digits long."
    in
    getChompedString (chompWhile Char.isDigit)
        |> Parser.andThen checkSize
        |> Parser.andThen digitStringToInt



-- From https://github.com/elm/parser/pull/16/files


deadEndsToString : List DeadEnd -> String
deadEndsToString deadEnds =
    String.concat (List.intersperse "; " (List.map deadEndToString deadEnds))


{-| Just an alias for `deadEndsToString` , in case you've imported this module `as Parser` and Elm would have defaulted to the broken one in `elm/parser` that this is a stopgap for.
-}
realDeadEndsToString : List DeadEnd -> String
realDeadEndsToString =
    deadEndsToString


deadEndToString : DeadEnd -> String
deadEndToString deadend =
    problemToString deadend.problem ++ " at row " ++ String.fromInt deadend.row ++ ", col " ++ String.fromInt deadend.col


problemToString : Problem -> String
problemToString p =
    case p of
        Expecting s ->
            "expecting '" ++ s ++ "'"

        ExpectingInt ->
            "expecting int"

        ExpectingHex ->
            "expecting hex"

        ExpectingOctal ->
            "expecting octal"

        ExpectingBinary ->
            "expecting binary"

        ExpectingFloat ->
            "expecting float"

        ExpectingNumber ->
            "expecting number"

        ExpectingVariable ->
            "expecting variable"

        ExpectingSymbol s ->
            "expecting symbol '" ++ s ++ "'"

        ExpectingKeyword s ->
            "expecting keyword '" ++ s ++ "'"

        ExpectingEnd ->
            "expecting end"

        UnexpectedChar ->
            "unexpected char"

        Problem s ->
            "Problem parsing: " ++ s

        BadRepeat ->
            "bad repeat"



-- Internal


digitStringToInt : String -> Parser Int
digitStringToInt numbers =
    -- should never fail ever, so default is meaningless
    Maybe.withDefault impossibleIntFailure <|
        Maybe.map Parser.succeed <|
            String.toInt numbers


impossibleIntFailure : Parser Int
impossibleIntFailure =
    Parser.problem "This should be impossible: a string of digits (verified with Char.isDigit) could not be converted to a valid `Int` (with String.fromInt)."
