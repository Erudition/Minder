module External.Todoist.Command exposing (Command(..), CommandError, CommandResult, CommandUUID, NewProject, ProjectChanges, ProjectID(..), RealProjectID, TempID, decodeCommandError, decodeCommandResult)

{-| A library for interacting with the Todoist API.

Allows efficient batch processing and incremental sync.

-}

import Dict exposing (Dict)
import External.Todoist.Item as Item exposing (..)
import Http
import ID
import IntDict exposing (IntDict)
import IntDictExtra as IntDict
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


{-| Command UUIDs are handled automatically.
Temp IDs coming soon.

Sadly, ProjectUpdate, ProjectMove are forced to be separate commands.

ProjectMove: First ID is the one you want to move. The second is the ID of the new parent project, wrapped in `Just` - or `Nothing` to move it to root.

-}
type Command
    = ProjectAdd NewProject
    | ProjectMove ProjectID (Maybe ProjectID)
    | ProjectDelete ProjectID
    | ProjectUpdate ProjectChanges
    | ReorderProjects (List ProjectOrder)
    | DayOrdersUpdate IDsToOrders
    | ItemAdd NewItem
    | ItemMoveProject (Maybe ProjectID)
    | ItemMoveParent (Maybe ItemID)
    | ItemDelete ItemID
    | ItemClose ItemID
    | ItemComplete ItemCompletion
    | ItemCompleteRecurring RecurringItemCompletion
    | ItemUncomplete ItemID
    | ItemArchive ItemID
    | ItemUnarchive ItemID
    | ItemUpdate ItemChanges
    | ReorderItems (List ItemOrder)


encodeCommand : Command -> Encode.Value
encodeCommand command =
    let
        encodeWrapper typeName args =
            encodeObjectWithoutNothings
                [ normal ( "type", Encode.string typeName )
                , normal ( "args", args )
                , normal ( "uuid", Encode.string "UUID" ) -- TODO
                , omittable ( "temp_id", Encode.string, Nothing ) -- TODO
                ]
    in
    case command of
        ProjectAdd new ->
            encodeWrapper "project_add" (encodeNewProject new)

        ProjectUpdate new ->
            encodeWrapper "project_update" (encodeProjectChanges new)

        ProjectMove id newParent ->
            encodeWrapper "project_move" <|
                encodeObjectWithoutNothings
                    [ normal ( "id", encodeProjectID id )
                    , omittable ( "parent_id", encodeProjectID, newParent )
                    ]

        ProjectDelete id ->
            encodeWrapper "project_delete" <| Encode.object [ ( "id", encodeProjectID id ) ]

        ReorderProjects orderList ->
            encodeWrapper "project_reorder" <| Encode.list encodeProjectOrder orderList

        DayOrdersUpdate _ ->
            Debug.todo "handle DayOrdersUpdate _"

        ItemAdd _ ->
            Debug.todo "handle ItemAdd _"

        ItemMoveProject _ ->
            Debug.todo "handle ItemMoveProject _"

        ItemMoveParent _ ->
            Debug.todo "handle ItemMoveParent _"

        ItemDelete _ ->
            Debug.todo "handle ItemDelete _"

        ItemClose _ ->
            Debug.todo "handle ItemClose _"

        ItemComplete _ ->
            Debug.todo "handle ItemComplete _"

        ItemCompleteRecurring _ ->
            Debug.todo "handle ItemCompleteRecurring _"

        ItemUncomplete _ ->
            Debug.todo "handle ItemUncomplete _"

        ItemArchive _ ->
            Debug.todo "handle ItemArchive _"

        ItemUnarchive _ ->
            Debug.todo "handle ItemUnarchive _"

        ItemUpdate _ ->
            Debug.todo "handle ItemUpdate _"

        ReorderItems _ ->
            Debug.todo "handle ReorderItems _"


type alias CommandUUID =
    String


type alias TempID =
    String


type alias BoolToInt =
    -- TODO remove this - just for reference
    Bool



---  PROJECTS


type ProjectID
    = RealProject RealProjectID
    | PlaceholderProject TempID


encodeProjectID : ProjectID -> Encode.Value
encodeProjectID realOrTemp =
    case realOrTemp of
        RealProject intID ->
            Encode.int intID

        PlaceholderProject tempID ->
            Encode.string tempID


{-| Todoist uses large integers for project IDs. It would nice to use type-safe Elm goodness here, but we want to stick to the API, so this is just a helpfully-named alias for `Int`.
-}
type alias RealProjectID =
    Int


{-| The fields required (and the only fields allowed) to ask the server to create a new Todoist "project", which can be done with the `ProjectAdd` `Command`.
-}
type alias NewProject =
    { temp_id : Maybe TempID
    , name : String
    , color : Maybe Int
    , parent_id : Maybe RealProjectID
    , child_order : Maybe Int
    , is_favorite : BoolToInt
    }


encodeNewProject : NewProject -> Encode.Value
encodeNewProject new =
    encodeObjectWithoutNothings
        [ omittable ( "temp_id", Encode.string, new.temp_id )
        , normal ( "name", Encode.string new.name )
        , omittable ( "color", Encode.int, new.color )
        , omittable ( "parent_id", Encode.int, new.parent_id )
        , omittable ( "child_order", Encode.int, new.child_order )
        , normal ( "is_favorite", Encode.bool new.is_favorite )
        ]


{-| The fields required (and the only fields allowed) to ask the server to update an existing (or queued) Todoist "project", which can be done with the `ProjectUpdate` `Command`.
-}
type alias ProjectChanges =
    { temp_id : Maybe TempID
    , name : String
    , color : Int
    , collapsed : BoolFromInt
    , is_favorite : BoolFromInt
    }


encodeProjectChanges : ProjectChanges -> Encode.Value
encodeProjectChanges new =
    encodeObjectWithoutNothings
        [ omittable ( "temp_id", Encode.string, new.temp_id )
        , normal ( "name", Encode.string new.name )
        , normal ( "color", Encode.int new.color )
        , normal ( "collapsed", Encode.bool new.collapsed )
        , normal ( "is_favorite", Encode.bool new.is_favorite )
        ]


{-| One entry in a reordering list of projects.
-}
type alias ProjectOrder =
    { id : RealProjectID
    , child_order : Int
    }


encodeProjectOrder : ProjectOrder -> Encode.Value
encodeProjectOrder v =
    Encode.object
        [ ( "id", Encode.int v.id )
        , ( "child_order", Encode.int v.child_order )
        ]



--- ITEMS


{-| The fields required (and the only fields allowed) to ask the server to create a new Todoist "item", which can be done with the `ItemAdd` `Command`.
-}
type alias NewItem =
    { temp_id : Maybe TempID
    , content : String
    , project_id : Maybe ProjectID
    , due : Maybe Due
    , priority : Priority
    , parent_id : Maybe ItemID
    , child_order : Maybe Int
    , day_order : Maybe Int
    , collapsed : Maybe BoolFromInt
    , auto_reminder : Maybe Bool
    }


encodeNewItem : NewItem -> Value
encodeNewItem new =
    encodeObjectWithoutNothings
        [ omittable ( "temp_id", Encode.string, new.temp_id )
        , normal ( "content", Encode.string new.content )
        , omittable ( "project_id", encodeProjectID, new.project_id )
        , omittable ( "due", encodeDue, new.due )
        , normal ( "priority", encodePriority new.priority )
        , omittable ( "parent_id", encodeItemID, new.parent_id )
        , omittable ( "child_order", Encode.int, new.child_order )
        , omittable ( "day_order", Encode.int, new.day_order )
        , omittable ( "collapsed", encodeBoolToInt, new.collapsed )
        , omittable ( "auto_reminder", Encode.bool, new.auto_reminder )
        ]


type ItemID
    = RealItem RealItemID
    | PlaceholderItem TempID


encodeItemID : ItemID -> Encode.Value
encodeItemID realOrTemp =
    case realOrTemp of
        RealItem intID ->
            Encode.int intID

        PlaceholderItem tempID ->
            Encode.string tempID


type alias ItemCompletion =
    { id : ItemID
    , date_completed : Maybe ISODateString
    , force_history : Bool
    }


encodeItemCompletion : ItemCompletion -> Encode.Value
encodeItemCompletion item =
    encodeObjectWithoutNothings
        [ normal ( "id", encodeItemID item.id )
        , omittable ( "date_completed", Encode.string, item.date_completed )
        , normal ( "force_history", Encode.bool item.force_history )
        ]


{-| API: Complete a recurring task, and the reason why this is a special case is because we need to mark a recurring completion (and using item\_update won’t do this). See also item\_close for a simplified version of the command.
-}
type alias RecurringItemCompletion =
    { id : ItemID
    , due : Maybe ISODateString
    }


encodeRecurringItemCompletion : RecurringItemCompletion -> Encode.Value
encodeRecurringItemCompletion item =
    encodeObjectWithoutNothings
        [ normal ( "id", encodeItemID item.id )
        , omittable ( "due", Encode.string, item.due )
        ]


{-| API: Updates task attributes. Please note that updating the parent, moving, completing or uncompleting tasks is not supported by item\_update, more specific commands have to be used instead.
-}
type alias ItemChanges =
    { id : ItemID
    , content : Maybe String
    , due : Maybe Due
    , priority : Maybe Priority
    , day_order : Maybe Int
    , collapsed : Maybe BoolFromInt
    }


encodeItemChanges : ItemChanges -> Value
encodeItemChanges item =
    encodeObjectWithoutNothings
        [ normal ( "id", encodeItemID item.id )
        , omittable ( "content", Encode.string, item.content )
        , omittable ( "due", encodeDue, item.due )
        , omittable ( "priority", encodePriority, item.priority )
        , omittable ( "day_order", Encode.int, item.day_order )
        , omittable ( "collapsed", encodeBoolToInt, item.collapsed )
        ]


type alias DayOrder =
    Int


{-| API says: A dictionary, where an item id is the key, and the day order its value: item\_id: day\_order.
-}
type alias IDsToOrders =
    IntDict DayOrder


{-| One entry in a reordering list of items.
-}
type alias ItemOrder =
    { id : RealItemID
    , child_order : Int
    }


encodeItemOrder : ItemOrder -> Encode.Value
encodeItemOrder order =
    Encode.object
        [ ( "id", Encode.int order.id )
        , ( "child_order", Encode.int order.child_order )
        ]



--- COMMAND OUTCOMES


{-| The `Result` of each `Todoist.Command` you tried to run.
Returns `Ok ()` for successful commands.

From the API docs : A dictionary object containing result of each command execution.

-}
type alias CommandResult =
    Result CommandError ()


decodeCommandResult : Decoder CommandResult
decodeCommandResult =
    Decode.oneOf
        [ Decode.check Decode.string "ok" <| succeed (Ok ())
        , Decode.map Err decodeCommandError
        ]


{-| The API docs only says this:

    an error object containings[sic] error information of a command.

-}
type alias CommandError =
    { error_code : Int
    , error : String
    }


decodeCommandError : Decoder CommandError
decodeCommandError =
    decode CommandError
        |> required "error_code" Decode.int
        |> required "error" Decode.string
