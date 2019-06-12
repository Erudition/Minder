module External.TodoistSync exposing (Item, Project, TodoistMsg, sync)

import Dict exposing (Dict)
import Http
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Encode as Encode
import Json.Encode.Extra as Encode2
import Porting exposing (..)
import Url
import Url.Builder


syncUrl : Token -> String
syncUrl incrementalSyncToken =
    Url.Builder.crossOrigin "https://todoist.com"
        [ "api", "v8", "sync" ]
        [ Url.Builder.string "token" "0bdc5149510737ab941485bace8135c60e2d812b"
        , Url.Builder.string "sync_token" incrementalSyncToken
        , Url.Builder.string "resource_type" "[\"all\"]"
        ]


sync : Token -> Cmd TodoistMsg
sync incrementalSyncToken =
    Http.get
        { url = syncUrl incrementalSyncToken
        , expect = Http.expectJson SyncResponded (toClassic decodeResponse)
        }


type alias TodoistData =
    { sync_token : String
    , items : List Item
    , projects : List Project
    }


type alias Response =
    { sync_token : String
    , full_sync : Bool
    , items : List Item
    , projects : List ProjectChanges
    }


decodeResponse : Decoder Response
decodeResponse =
    decode Response
        |> required "sync_token" string
        |> required "full_sync" decodeBoolAsInt
        |> optional "items" (list decodeItem) []
        |> optional "projects" (list decodeProjectChanges) []
        |> ignored "collaborators"
        |> ignored "collaboratorStates"
        |> ignored "dayOrders"
        |> ignored "filters"
        |> ignored "labels"
        |> ignored "liveNotifications"
        |> ignored "liveNotificationsLastReadId"
        |> ignored "notes"
        |> ignored "projectNotes"
        |> ignored "reminders"
        |> ignored "settingsNotifications"
        |> ignored "tempIdMapping"
        |> ignored "user"
        |> ignored "userSettings"


handle : TodoistMsg -> a
handle (SyncResponded result) =
    case result of
        Ok data ->
            Debug.todo "String.String"

        Err err ->
            Debug.todo "Fail"


type TodoistMsg
    = SyncResponded (Result Http.Error Response)


type alias Token =
    String


type alias ItemID =
    Int


type alias LabelID =
    Int


type alias UserID =
    Int


type alias ISODateString =
    String


type alias BoolAsInt =
    Int


type alias DayOrders =
    Dict ItemID Int


type alias Item =
    { id : ItemID
    , user_id : UserID
    , project_id : Int
    , content : String
    , due : Maybe Due
    , indent : Int
    , priority : Priority
    , parent_id : Maybe ItemID
    , item_order : Int
    , day_order : Int
    , collapsed : Bool
    , children : List ItemID
    , labels : List LabelID
    , assigned_by_uid : UserID
    , responsible_uid : Maybe UserID
    , checked : Bool
    , in_history : Bool
    , is_deleted : Bool
    , is_archived : Bool
    , date_added : ISODateString
    }


decodeItem : Decoder Item
decodeItem =
    decode Item
        |> required "id" int
        |> required "user_id" int
        |> required "project_id" int
        |> required "content" string
        |> required "due" (maybe decodeDue)
        |> required "indent" int
        |> required "priority" decodePriority
        |> required "parent_id" (maybe int)
        |> required "item_order" int
        |> required "day_order" int
        |> required "collapsed" decodeBoolAsInt
        |> optional "children" (list int) []
        |> required "labels" (list int)
        |> required "assigned_by_uid" int
        |> required "responsible_uid" (maybe int)
        |> required "checked" decodeBoolAsInt
        |> required "in_history" decodeBoolAsInt
        |> required "is_deleted" decodeBoolAsInt
        |> required "is_archived" decodeBoolAsInt
        |> required "date_added" string


encodeItem : Item -> Encode.Value
encodeItem record =
    Encode.object
        [ ( "id", Encode.int <| record.id )
        , ( "user_id", Encode.int <| record.user_id )
        , ( "project_id", Encode.int <| record.project_id )
        , ( "content", Encode.string <| record.content )
        , ( "due", Encode2.maybe encodeDue <| record.due )
        , ( "indent", Encode.int <| record.indent )
        , ( "priority", encodePriority <| record.priority )
        , ( "parent_id", Encode2.maybe Encode.int <| record.parent_id )
        , ( "item_order", Encode.int <| record.item_order )
        , ( "day_order", Encode.int <| record.day_order )
        , ( "collapsed", encodeBoolAsInt <| record.collapsed )
        , ( "children", Encode.list Encode.int <| record.children )
        , ( "labels", Encode.list Encode.int <| record.labels )
        , ( "assigned_by_uid", Encode.int <| record.assigned_by_uid )
        , ( "responsible_uid", Encode2.maybe Encode.int <| record.responsible_uid )
        , ( "checked", encodeBoolAsInt <| record.checked )
        , ( "in_history", encodeBoolAsInt <| record.in_history )
        , ( "is_deleted", encodeBoolAsInt <| record.is_deleted )
        , ( "is_archived", encodeBoolAsInt <| record.is_archived )
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


type alias Project =
    { id : Int
    , name : String
    , color : Int
    , parentId : Int
    , childOrder : Int
    , collapsed : Int
    , shared : Bool
    , isDeleted : Int
    , isArchived : Int
    , isFavorite : Int
    }


type alias ProjectChanges =
    { id : Int
    , name : Updateable String
    , color : Updateable Int
    , parentId : Updateable Int
    , childOrder : Updateable Int
    , collapsed : Updateable Int
    , shared : Updateable Bool
    , isDeleted : Updateable Int
    , isArchived : Updateable Int
    , isFavorite : Updateable Int
    }


updateProject : Project -> ProjectChanges -> Project
updateProject original changes =
    { id = changes.id
    , name = applyChanges original.name changes.name
    , color = applyChanges original.color changes.color
    , parentId = applyChanges original.parentId changes.parentId
    , childOrder = applyChanges original.childOrder changes.childOrder
    , collapsed = applyChanges original.collapsed changes.collapsed
    , shared = applyChanges original.shared changes.shared
    , isDeleted = applyChanges original.isDeleted changes.isDeleted
    , isArchived = applyChanges original.isArchived changes.isArchived
    , isFavorite = applyChanges original.isFavorite changes.isFavorite
    }


decodeProjectChanges : Decoder ProjectChanges
decodeProjectChanges =
    decode ProjectChanges
        |> required "id" int
        |> updateable "name" string
        |> updateable "color" int
        |> updateable "parentId" int
        |> updateable "childOrder" int
        |> updateable "collapsed" int
        |> updateable "shared" bool
        |> updateable "isDeleted" int
        |> updateable "isArchived" int
        |> updateable "isFavorite" int


encodeProject : Project -> Encode.Value
encodeProject record =
    Encode.object
        [ ( "id", Encode.int <| record.id )
        , ( "name", Encode.string <| record.name )
        , ( "color", Encode.int <| record.color )
        , ( "parentId", Encode.int <| record.parentId )
        , ( "childOrder", Encode.int <| record.childOrder )
        , ( "collapsed", Encode.int <| record.collapsed )
        , ( "shared", Encode.bool <| record.shared )
        , ( "isDeleted", Encode.int <| record.isDeleted )
        , ( "isArchived", Encode.int <| record.isArchived )
        , ( "isFavorite", Encode.int <| record.isFavorite )
        ]


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
        |> required "timezone" (maybe string)
        |> required "string" string
        |> required "lang" string
        |> required "isRecurring" bool


encodeDue : Due -> Encode.Value
encodeDue record =
    Encode.object
        [ ( "date", Encode.string <| record.date )
        , ( "timezone", Encode2.maybe Encode.string <| record.timezone )
        , ( "string", Encode.string <| record.string )
        , ( "lang", Encode.string <| record.lang )
        , ( "isRecurring", Encode.bool <| record.isRecurring )
        ]
