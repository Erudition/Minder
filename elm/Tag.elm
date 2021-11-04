module Tag exposing (..)

import Dict exposing (Dict)


type Tag
    = Tag { label : String, aliases : List String, externalIDs : Dict String String }
