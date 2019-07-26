module Incubator.Todoist.Item exposing (Due, ISODateString, Item, ItemID, Priority(..), UserID, decodeDue, decodeItem, decodePriority, encodeDue, encodeItem, encodePriority, fromRFC3339Date, toRFC3339Date)

import Dict exposing (Dict)
import Http
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Maybe.Extra as Maybe
import Porting exposing (..)
import SmartTime.Human.Moment as HumanMoment
import Url
import Url.Builder


{-| Todoist uses large integers for item IDs. It would nice to use type-safe Elm goodness here, but we want to stick to the API, so this is just a helpfully-named alias for `Int`.
-}
type alias ItemID =
    Int


type alias UserID =
    Int


type alias ISODateString =
    String


{-| Item
-}
type alias Item =
    { id : ItemID
    , user_id : UserID
    , project_id : Int
    , content : String
    , due : Maybe Due
    , priority : Priority
    , parent_id : Maybe ItemID
    , child_order : Int
    , day_order : Int
    , collapsed : BoolFromInt
    , children : List ItemID
    , assigned_by_uid : UserID
    , responsible_uid : Maybe UserID
    , checked : Bool
    , in_history : BoolFromInt
    , is_deleted : BoolFromInt
    , is_archived : BoolFromInt
    , date_added : ISODateString
    }


decodeItem : Decoder Item
decodeItem =
    decode Item
        |> required "id" int
        |> required "user_id" int
        |> required "project_id" int
        |> required "content" string
        |> required "due" (nullable decodeDue)
        |> ignored "indent"
        |> required "priority" decodePriority
        |> required "parent_id" (nullable int)
        |> required "child_order" int
        -- API docs has incorrect "item_order" in example code (only)
        |> required "day_order" int
        |> required "collapsed" decodeBoolFromInt
        |> optional "children" (list int) []
        |> ignored "labels"
        |> optional "assigned_by_uid" int 0
        |> required "responsible_uid" (nullable int)
        |> required "checked" decodeBoolFromInt
        |> required "in_history" decodeBoolFromInt
        |> required "is_deleted" decodeBoolFromInt
        |> optional "is_archived" decodeBoolFromInt False
        -- API docs do not indicate this is an optional field
        |> required "date_added" string
        |> optionalIgnored "legacy_id"
        |> optionalIgnored "legacy_project_id"
        |> optionalIgnored "legacy_parent_id"
        |> optionalIgnored "sync_id"
        |> optionalIgnored "date_completed"
        |> optionalIgnored "has_more_notes"
        |> optionalIgnored "section_id"
        -- only shows up during deletions?
        |> optionalIgnored "due_is_recurring"


encodeItem : Item -> Encode.Value
encodeItem record =
    Encode.object
        [ ( "id", Encode.int <| record.id )
        , ( "user_id", Encode.int <| record.user_id )
        , ( "project_id", Encode.int <| record.project_id )
        , ( "content", Encode.string <| record.content )
        , ( "due", Encode.maybe encodeDue <| record.due )
        , ( "priority", encodePriority <| record.priority )
        , ( "parent_id", Encode.maybe Encode.int <| record.parent_id )
        , ( "child_order", Encode.int <| record.child_order )
        , ( "day_order", Encode.int <| record.day_order )
        , ( "collapsed", encodeBoolToInt <| record.collapsed )
        , ( "children", Encode.list Encode.int <| record.children )
        , ( "assigned_by_uid", Encode.int <| record.assigned_by_uid )
        , ( "responsible_uid", Encode.maybe Encode.int <| record.responsible_uid )
        , ( "checked", encodeBoolToInt <| record.checked )
        , ( "in_history", encodeBoolToInt <| record.in_history )
        , ( "is_deleted", encodeBoolToInt <| record.is_deleted )
        , ( "is_archived", encodeBoolToInt <| record.is_archived )
        , ( "date_added", Encode.string <| record.date_added )
        ]


type Priority
    = Priority Int


decodePriority : Decoder Priority
decodePriority =
    oneOf
        [ check int 4 <| succeed (Priority 1)
        , check int 3 <| succeed (Priority 2)
        , check int 2 <| succeed (Priority 3)
        , check int 1 <| succeed (Priority 4)
        ]


encodePriority : Priority -> Encode.Value
encodePriority priority =
    case priority of
        Priority 1 ->
            Encode.int 4

        Priority 2 ->
            Encode.int 3

        Priority 3 ->
            Encode.int 2

        _ ->
            Encode.int 1



--- DUE OBJECTS


type alias Due =
    { date : String
    , timezone : Maybe String
    , string : String
    , lang : String
    , isRecurring : Bool
    }


decodeDue : Decoder Due
decodeDue =
    decode Due
        |> required "date" string
        |> required "timezone" (nullable string)
        |> required "string" string
        |> required "lang" string
        |> required "is_recurring" bool


encodeDue : Due -> Encode.Value
encodeDue record =
    Encode.object
        [ ( "date", Encode.string <| record.date )
        , ( "timezone", Encode.maybe Encode.string <| record.timezone )
        , ( "string", Encode.string <| record.string )
        , ( "lang", Encode.string <| record.lang )
        , ( "is_recurring", Encode.bool <| record.isRecurring )
        ]


fromRFC3339Date : String -> Maybe HumanMoment.FuzzyMoment
fromRFC3339Date =
    Result.toMaybe << HumanMoment.fuzzyFromString


toRFC3339Date : HumanMoment.FuzzyMoment -> String
toRFC3339Date dateString =
    HumanMoment.fuzzyToString dateString
