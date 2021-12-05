module Tag exposing (..)

import Dict exposing (Dict)


type alias TagID =
    String


type Tag
    = Tag { label : String, aliases : List String, externalIDs : Dict String String }
