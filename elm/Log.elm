module Log exposing (..)

import Debug


{-| For dev mode:

1.  add `import Debug` to the top of this file
2.  set runningEnvironment to `Dev Debug.log Debug.todo`

For prod mode:

1.  remove `import Debug` from the top of this file
2.  set runningEnvironment to `Production`

-}
runningEnvironment : RunningEnvironment a
runningEnvironment =
    Dev Debug.log Debug.todo


type RunningEnvironment a
    = Production
    | Dev (Logger a) (Crasher a)


type alias Logger a =
    String -> a -> a


type alias Crasher a =
    String -> a


logMessageOnly : String -> a -> a
logMessageOnly msg thing =
    case runningEnvironment of
        Production ->
            thing

        Dev logger todo ->
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

        Dev logger todo ->
            logger label item


logSeparate label separateThing attachmentItem =
    case runningEnvironment of
        Production ->
            attachmentItem

        Dev logger todo ->
            Tuple.second ( logger label separateThing, attachmentItem )


crashInDev : String -> a -> a
crashInDev crashMessage a =
    case runningEnvironment of
        Production ->
            a

        Dev logger todo ->
            todo crashMessage
