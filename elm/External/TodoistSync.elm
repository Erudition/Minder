module External.TodoistSync exposing (Item, Project, TodoistMsg, handle, sync)

import AppData exposing (AppData, saveError)
import Dict exposing (Dict)
import Http
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Encode as Encode
import Json.Encode.Extra as Encode2
import Porting exposing (..)
import Task.Progress
import Task.Task exposing (Task, newTask)
import Url
import Url.Builder


syncUrl : Token -> Url.Url
syncUrl incrementalSyncToken =
    let
        resources =
            """[%22all%22]"""

        devSecret =
            "0bdc5149510737ab941485bace8135c60e2d812b"

        query =
            String.concat <|
                List.intersperse "&" <|
                    [ "token=" ++ devSecret
                    , "sync_token=" ++ incrementalSyncToken
                    , "resource_types=" ++ resources
                    ]
    in
    Debug.log "calling url:"
        { protocol = Url.Https
        , host = "todoist.com"
        , port_ = Nothing
        , path = "/api/v8/sync"
        , query = Just query
        , fragment = Nothing
        }



-- Fails due to percent-encoding of last field:
-- Url.Builder.crossOrigin "https://todoist.com"
--     [ "api", "v8", "sync" ]
--     [ Url.Builder.string "token" "0bdc5149510737ab941485bace8135c60e2d812b"
--     , Url.Builder.string "sync_token" incrementalSyncToken
--     , Url.Builder.string "resource_type" (Debug.log resources resources)
--     ]
-- curl https://todoist.com/api/v8/sync \
--     -d token=0bdc5149510737ab941485bace8135c60e2d812b \
--     -d sync_token='*' \
--     -d resource_types='["all"]'


sync : Token -> Cmd TodoistMsg
sync incrementalSyncToken =
    Http.get
        { url = Url.toString <| syncUrl incrementalSyncToken
        , expect = Http.expectJson SyncResponded (toClassicLoose decodeResponse)
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
        |> required "full_sync" bool
        |> optional "items" (list decodeItem) []
        |> optional "projects" (list decodeProjectChanges) []
        |> optionalIgnored "temp_id_mapping"
        |> optionalIgnored "collaborators"
        |> optionalIgnored "collaboratorStates"
        |> optionalIgnored "dayOrders"
        |> optionalIgnored "filters"
        |> optionalIgnored "labels"
        |> optionalIgnored "liveNotifications"
        |> optionalIgnored "liveNotificationsLastReadId"
        |> optionalIgnored "notes"
        |> optionalIgnored "projectNotes"
        |> optionalIgnored "reminders"
        |> optionalIgnored "settingsNotifications"
        |> optionalIgnored "tempIdMapping"
        |> optionalIgnored "user"
        |> optionalIgnored "userSettings"
        |> optionalIgnored "sections"


handle : TodoistMsg -> AppData -> AppData
handle (SyncResponded result) ({ tasks, activities, tokens } as app) =
    case result of
        Ok data ->
            { app
                | tokens = { todoistSyncToken = data.sync_token }
                , tasks = List.map itemToTask data.items
            }

        Err err ->
            case err of
                Http.BadUrl msg ->
                    saveError app msg

                Http.Timeout ->
                    saveError app "Timeout?"

                Http.NetworkError ->
                    saveError app "Network Error"

                Http.BadStatus status ->
                    saveError app <| "Got Error code" ++ String.fromInt status

                Http.BadBody string ->
                    saveError app string


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
        |> optional "indent" int 0
        |> required "priority" decodePriority
        |> required "parent_id" (maybe int)
        |> required "child_order" int
        -- API docs has incorrect "item_order" in example code (only)
        |> required "day_order" int
        |> required "collapsed" decodeBoolAsInt
        |> optional "children" (list int) []
        |> required "labels" (list int)
        |> optional "assigned_by_uid" int 0
        |> required "responsible_uid" (maybe int)
        |> required "checked" decodeBoolAsInt
        |> required "in_history" decodeBoolAsInt
        |> required "is_deleted" decodeBoolAsInt
        |> optional "is_archived" decodeBoolAsInt False
        -- API docs do not indicate this is an optional field
        |> required "date_added" string
        |> optionalIgnored "legacy_id"
        |> optionalIgnored "legacy_project_id"
        |> optionalIgnored "sync_id"


optionalIgnored : String -> Decoder a -> Decoder a
optionalIgnored field pipeline =
    Decode.oneOf
        [ Decode.field field (Decode.succeed ())
        , Decode.succeed ()
        ]
        |> Decode.andThen (\_ -> pipeline)


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


itemToTask : Item -> Task
itemToTask item =
    let
        base =
            newTask item.content item.id
    in
    { base
        | completion =
            if item.checked then
                Task.Progress.maximize base.completion

            else
                base.completion
        , tags = []
        , project = Just item.project_id
    }


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
