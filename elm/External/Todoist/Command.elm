module External.Todoist.Command exposing (Command(..), CommandError, CommandResult, CommandUUID, NewProject, ProjectChanges, ProjectID(..), RealProjectID, TempID, decodeCommandError, decodeCommandResult)

{-| A library for interacting with the Todoist API.

Allows efficient batch processing and incremental sync.

-}

import Dict exposing (Dict)
import Http
import ID
import IntDict exposing (IntDict)
import IntDictExtra as IntDict
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode2
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
    | ProjectUpdate ProjectChanges
    | ProjectMove ProjectID (Maybe ProjectID)
    | ProjectDelete ProjectID
    | ReorderProjects (List ProjectOrder)


encodeCommand : Command -> Encode.Value
encodeCommand command =
    let
        encodeWrapper typeName args =
            Encode.object <|
                omitNothings
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
                Encode.object
                    [ ( "id", encodeProjectID id )
                    , ( "parent_id", Encode2.maybe encodeProjectID newParent )
                    ]

        ProjectDelete id ->
            encodeWrapper "project_delete" <| Encode.object [ ( "id", encodeProjectID id ) ]

        ReorderProjects orderList ->
            Encode.string "ReorderProjects"


type alias CommandUUID =
    String


type alias TempID =
    String


type alias BoolToInt =
    -- TODO remove this - just for reference
    Bool



---  PROJECTS


type ProjectID
    = Real RealProjectID
    | Temp TempID


encodeProjectID : ProjectID -> Encode.Value
encodeProjectID realOrTemp =
    case realOrTemp of
        Real intID ->
            Encode.int intID

        Temp tempID ->
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
    , color : Int
    , parent_id : Maybe RealProjectID
    , child_order : Int
    , is_favorite : BoolToInt
    }


encodeNewProject : NewProject -> Encode.Value
encodeNewProject new =
    Encode.object <|
        omitNothings
            [ omittable ( "temp_id", Encode.string, new.temp_id )
            , normal ( "name", Encode.string new.name )
            , normal ( "color", Encode.int new.color )
            , normal ( "parent_id", Encode2.maybe Encode.int new.parent_id )
            , normal ( "child_order", Encode.int new.child_order )
            , normal ( "is_favorite", Encode.bool new.is_favorite )
            ]


{-| The fields required (and the only fields allowed) to ask the server to update an existing (or queued) Todoist "project", which can be done with the `ProjectUpdate` `Command`.
-}
type alias ProjectChanges =
    { temp_id : Maybe TempID
    , name : String
    , color : Int
    , collapsed : BoolToInt
    , is_favorite : BoolToInt
    }


encodeProjectChanges : ProjectChanges -> Encode.Value
encodeProjectChanges new =
    Encode.object <|
        omitNothings
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
