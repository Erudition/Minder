module Log exposing (..)

import Debug


logMessage label _ =
    Debug.log label ()


log label item =
    Debug.log label item


logSeparate label separateThing attachmentItem =
    Tuple.second ( Debug.log label separateThing, attachmentItem )
