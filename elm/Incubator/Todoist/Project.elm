module Incubator.Todoist.Project exposing (Project, ProjectID, decodeProject, encodeProject)

import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode
import Porting exposing (..)


{-| Todoist uses large integers for project IDs. It would nice to use type-safe Elm goodness here, but we want to stick to the API, so this is just a helpfully-named alias for `Int`.
-}
type alias ProjectID =
    Int


{-| A Todoist "project", represented exactly the way the API describes it.
-}
type alias Project =
    { id : ProjectID
    , name : String
    , color : Int
    , parent_id : Maybe ProjectID
    , child_order : Int
    , collapsed : Int
    , shared : Bool
    , is_deleted : BoolFromInt
    , is_archived : BoolFromInt
    , is_favorite : BoolFromInt
    , inbox_project : Bool
    , team_inbox : Bool
    }


decodeProject : Decoder Project
decodeProject =
    decode Project
        |> required "id" int
        |> required "name" string
        |> required "color" int
        |> required "parent_id" (nullable int)
        |> required "child_order" int
        |> required "collapsed" int
        |> required "shared" bool
        |> required "is_deleted" decodeBoolFromInt
        |> required "is_archived" decodeBoolFromInt
        |> required "is_favorite" decodeBoolFromInt
        |> optional "inbox_project" bool False
        |> optional "team_inbox" bool False
        |> optionalIgnored "legacy_parent_id"
        |> optionalIgnored "legacy_id"
        |> optionalIgnored "has_more_notes"


encodeProject : Project -> Encode.Value
encodeProject record =
    Encode.object
        [ ( "id", Encode.int <| record.id )
        , ( "name", Encode.string <| record.name )
        , ( "color", Encode.int <| record.color )
        , ( "parent_id", Encode.maybe Encode.int <| record.parent_id )
        , ( "child_order", Encode.int <| record.child_order )
        , ( "collapsed", Encode.int <| record.collapsed )
        , ( "shared", Encode.bool <| record.shared )
        , ( "is_deleted", encodeBoolToInt <| record.is_deleted )
        , ( "is_archived", encodeBoolToInt <| record.is_archived )
        , ( "is_favorite", encodeBoolToInt <| record.is_favorite )
        , ( "inbox_project", Encode.bool <| record.inbox_project )
        , ( "team_inbox", Encode.bool <| record.team_inbox )
        ]
