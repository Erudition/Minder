module Log exposing (..)

import Console
import Debug
import DebugToJson


{-| For dev mode:

1.  add `import Debug` to the top of this file
2.  set runningEnvironment to `Dev Debug.log Debug.todo`

For prod mode:

1.  remove `import Debug` from the top of this file
2.  set runningEnvironment to `Production`

-}
runningEnvironment : RunningEnvironment a
runningEnvironment =
    Dev Debug.log Debug.todo Debug.toString


type RunningEnvironment a
    = Production
    | Dev (Logger a) (Crasher a) (Stringifier a)


type alias Logger a =
    String -> a -> a


type alias Crasher a =
    String -> a


type alias Stringifier a =
    a -> String


logMessageOnly : String -> a -> a
logMessageOnly msg thing =
    case runningEnvironment of
        Production ->
            thing

        Dev logger _ _ ->
            let
                forceLogEvenWhenNotEvaluated : Logger Logged -> String -> thing -> thing
                forceLogEvenWhenNotEvaluated logger2 msg2 thing2 =
                    if logger2 msg2 Logged == Logged then
                        thing2

                    else
                        thing2
            in
            forceLogEvenWhenNotEvaluated logger msg thing


type Logged
    = Logged


log label item =
    case runningEnvironment of
        Production ->
            item

        Dev logger todo _ ->
            logger label item


logSeparate label thingToLog thingToIgnore =
    case runningEnvironment of
        Production ->
            thingToIgnore

        Dev logger todo _ ->
            Tuple.second ( logger label thingToLog, thingToIgnore )


crashInDev : String -> prodFallbackValue -> prodFallbackValue
crashInDev crashMessage a =
    case runningEnvironment of
        Production ->
            a

        Dev logger todo _ ->
            todo crashMessage


crashInDevProse : Prose -> prodFallbackValue -> prodFallbackValue
crashInDevProse prose =
    crashInDev (proseToString prose)


dump : a -> String
dump thing =
    case runningEnvironment of
        Production ->
            "Not in dev mode, no toString available."

        Dev _ _ stringifier ->
            stringifier thing
                |> DebugToJson.pp


type alias Prose =
    List (List String)


proseToString : Prose -> String
proseToString prose =
    String.join " \n" (List.map (String.join " ") prose)


int : Int -> String
int i =
    String.fromInt i


length : List a -> String
length l =
    String.fromInt <| List.length l


{-| Lets you specify a bad length to show up in red
-}
lengthWithBad : Int -> List a -> String
lengthWithBad bad list =
    let
        foundLength =
            List.length list

        output =
            String.fromInt foundLength
    in
    if List.length list == bad then
        Console.bgRed output

    else
        Console.green output
