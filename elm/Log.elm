module Log exposing (..)

import Debug


logMessage : String -> a -> a
logMessage label thing =
    if Debug.log label () == () then
        thing

    else
        thing


log label item =
    Debug.log label item


logSeparate label separateThing attachmentItem =
    Tuple.second ( Debug.log label separateThing, attachmentItem )
