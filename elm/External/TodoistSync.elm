module External.TodoistSync exposing (Item, Project, TodoistMsg(..), handle, sync)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import AppData exposing (AppData, saveError)
import Dict exposing (Dict)
import Http
import ID
import IntDict exposing (IntDict)
import IntDictExtra as IntDict
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Decode.Extra exposing (fromResult)
import Json.Encode as Encode
import Json.Encode.Extra as Encode2
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Maybe.Extra as Maybe
import Parser exposing ((|.), (|=), Parser, float, spaces, symbol)
import Porting exposing (..)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import Task.Progress
import Task.Task exposing (Task, newTask)
import Url
import Url.Builder


syncUrl : Token -> Url.Url
syncUrl incrementalSyncToken =
    let
        allResources =
            """[%22all%22]"""

        someResources =
            """[%22items%22,%22projects%22]"""

        devSecret =
            "0bdc5149510737ab941485bace8135c60e2d812b"

        query =
            String.concat <|
                List.intersperse "&" <|
                    [ "token=" ++ devSecret
                    , "sync_token=" ++ incrementalSyncToken
                    , "resource_types=" ++ someResources
                    ]
    in
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
--     , Url.Builder.string "resource_type"  resources
--     ]
-- curl https://todoist.com/api/v8/sync \
--     -d token=0bdc5149510737ab941485bace8135c60e2d812b \
--     -d sync_token='*' \
--     -d resource_types='["all"]'


sync : Token -> Cmd TodoistMsg
sync incrementalSyncToken =
    Http.get
        { url = Url.toString <| syncUrl incrementalSyncToken
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
    , projects : List Project
    }


decodeResponse : Decoder Response
decodeResponse =
    decode Response
        |> required "sync_token" string
        |> required "full_sync" bool
        |> optional "items" (list decodeItem) []
        |> optional "projects" (list decodeProjectChanges) []
        |> optionalIgnored "collaborators"
        |> optionalIgnored "collaborator_states"
        |> optionalIgnored "day_orders"
        |> optionalIgnored "filters"
        |> optionalIgnored "labels"
        |> optionalIgnored "live_notifications"
        |> optionalIgnored "live_notifications_last_read_id"
        |> optionalIgnored "notes"
        |> optionalIgnored "project_notes"
        |> optionalIgnored "reminders"
        |> optionalIgnored "settings_notifications"
        |> optionalIgnored "temp_id_mapping"
        |> optionalIgnored "user"
        |> optionalIgnored "user_settings"
        |> optionalIgnored "sections"
        -- each item below not in spec!
        |> optionalIgnored "due_exceptions"
        |> optionalIgnored "day_orders_timestamp"
        |> optionalIgnored "incomplete_project_ids"
        |> optionalIgnored "incomplete_item_ids"
        |> optionalIgnored "stats"
        |> optionalIgnored "locations"
        |> optionalIgnored "tooltips"


handle : TodoistMsg -> AppData -> ( AppData, String )
handle (SyncResponded result) ({ tasks, activities, todoist } as app) =
    case result of
        Ok success ->
            let
                { sync_token, full_sync, items, projects } =
                    success

                projectsDict =
                    IntDict.fromList (List.map (\p -> ( p.id, p )) projects)

                updatedTimetrackParent =
                    List.head <| IntDict.keys <| IntDict.filter (\_ p -> p.name == "Timetrack") projectsDict

                timetrackParent =
                    Maybe.withDefault todoist.parentProjectID updatedTimetrackParent

                validActivityProjects =
                    IntDict.filter (\_ p -> p.parentId == timetrackParent) projectsDict

                activityLookupTable =
                    findActivityProjectIDs validActivityProjects filledInActivities

                itemsInTimetrackToTasks =
                    List.filterMap
                        (timetrackItemToTask activityLookupTable)
                        items

                filledInActivities =
                    Activity.allActivities activities

                generatedTasks =
                    IntDict.fromList <|
                        List.map (\t -> ( t.id, t )) <|
                            itemsInTimetrackToTasks
            in
            ( { app
                | todoist =
                    { syncToken = sync_token
                    , parentProjectID = timetrackParent
                    , activityProjectIDs = IntDict.union activityLookupTable todoist.activityProjectIDs
                    }
                , tasks =
                    IntDict.union generatedTasks tasks
              }
            , describeSuccess success
            )

        Err err ->
            let
                handleError description =
                    ( saveError app description, description )
            in
            case err of
                Http.BadUrl msg ->
                    handleError msg

                Http.Timeout ->
                    handleError "Timeout?"

                Http.NetworkError ->
                    handleError "Network Error"

                Http.BadStatus status ->
                    handleError <| "Got Error code" ++ String.fromInt status

                Http.BadBody string ->
                    handleError string


describeSuccess : Response -> String
describeSuccess success =
    if success.full_sync then
        "Did FULL Todoist sync: "
            ++ String.fromInt (List.length success.items)
            ++ " items, "
            ++ String.fromInt (List.length success.projects)
            ++ "projects retrieved!"

    else
        "Incremental Todoist sync complete: Updated "
            ++ String.fromInt (List.length success.items)
            ++ " items and "
            ++ String.fromInt (List.length success.projects)
            ++ "projects."


{-| Take our todoist-project dictionary and our activity dictionary, and create a translation table between them.
-}
findActivityProjectIDs : IntDict Project -> IntDict Activity -> IntDict ActivityID
findActivityProjectIDs projects activities =
    -- phew! this was a hard one conceptually :) Looks clean though!
    let
        -- The only part of our activities we care about here is the name field, so we reduce the activities to just their name list
        activityNamesDict =
            IntDict.mapValues .names activities

        -- Our IntDict's (Keys, Values) are (activityID, nameList). This function gets mapped to our dictionary to check for matches. what was once a dictionary of names is now a dictionary of Maybe ActivityIDs.
        matchToID nameToTest activityID nameList =
            if List.member nameToTest nameList then
                -- Wrap values we want to keep
                Just (ID.tag activityID)

            else
                -- No match, will be removed from the dict
                Nothing

        -- Try a given name with matchToID, filter out the nothings, which should either be all of them, or all but one.
        activityNameMatches nameToTest =
            IntDict.filterMap (matchToID nameToTest) activityNamesDict

        -- Convert the matches dict to a list and then to a single ActivityID, maybe.
        -- If for some reason there's multiple matches, choose the first.
        -- If none matched, returns nothing (List.head)
        pickFirstMatch nameToTest =
            List.head <| IntDict.values (activityNameMatches nameToTest)
    in
    -- For all projects, take the name and check it against the activityID dict
    IntDict.filterMap (\i p -> pickFirstMatch p.name) projects


timetrackItemToTask : IntDict ActivityID -> Item -> Maybe Task
timetrackItemToTask lookup item =
    -- Equivalent to the one-liner:
    --      Maybe.map (\act -> itemToTask act item) (IntDict.get item.project_id lookup)
    -- Just sayin'.
    case IntDict.get item.project_id lookup of
        Just act ->
            Just (itemToTask act item)

        Nothing ->
            Nothing


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
    , child_order : Int
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
        |> required "due" (nullable decodeDue)
        |> optional "indent" int 0
        |> required "priority" decodePriority
        |> required "parent_id" (nullable int)
        |> required "child_order" int
        -- API docs has incorrect "item_order" in example code (only)
        |> required "day_order" int
        |> required "collapsed" decodeBoolAsInt
        |> optional "children" (list int) []
        |> required "labels" (list int)
        |> optional "assigned_by_uid" int 0
        |> required "responsible_uid" (nullable int)
        |> required "checked" decodeBoolAsInt
        |> required "in_history" decodeBoolAsInt
        |> required "is_deleted" decodeBoolAsInt
        |> optional "is_archived" decodeBoolAsInt False
        -- API docs do not indicate this is an optional field
        |> required "date_added" string
        |> optionalIgnored "legacy_id"
        |> optionalIgnored "legacy_project_id"
        |> optionalIgnored "legacy_parent_id"
        |> optionalIgnored "sync_id"
        |> optionalIgnored "date_completed"
        |> optionalIgnored "has_more_notes"
        |> optionalIgnored "section_id"


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
        , ( "child_order", Encode.int <| record.child_order )
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


itemToTask : Activity.ActivityID -> Item -> Task
itemToTask activityID item =
    let
        base =
            newTask newName item.id

        ( newName, ( minDur, maxDur ) ) =
            extractTiming2 item.content

        ( finalMin, finalMax ) =
            ( Maybe.map HumanDuration.toDuration minDur
            , Maybe.map HumanDuration.toDuration maxDur
            )
    in
    { base
        | completion =
            if item.checked then
                Task.Progress.maximize base.completion

            else
                base.completion
        , tags = []
        , activity = Just activityID
        , minEffort = Maybe.withDefault base.minEffort finalMin
        , maxEffort = Maybe.withDefault base.maxEffort finalMax
    }


extractTiming : String -> ( String, ( Maybe HumanDuration, Maybe HumanDuration ) )
extractTiming name =
    let
        -- hehe, this should be fun
        lastWord =
            List.last (String.words name)

        -- All aboard the Maybe Train!
        -- result =
        --     List.foldl Maybe.andThen lastWord maybeTrain
        -- maybeTrain =
        --     [ checkParens, numberSegments, valueSegments ]
        checkParens chunk =
            if String.startsWith "(" chunk && String.endsWith ")" chunk then
                Just (String.slice 1 -1 chunk)

            else
                Nothing

        checkMinutesLabel chunk =
            let
                chunks =
                    segments chunk
            in
            if List.any (String.endsWith "m") chunks then
                Just (List.map (String.replace "m" "") chunks)

            else if List.any (String.endsWith "min") chunks then
                Just (List.map (String.replace "min" "") chunks)

            else
                Nothing

        segments chunk =
            String.split "-" chunk

        checkNumberSegments chunks =
            if List.all (String.all Char.isDigit) chunks then
                Just chunks

            else
                Nothing

        startsWithNumber chunk =
            Maybe.withDefault False <|
                Maybe.map Char.isDigit <|
                    Maybe.map Tuple.first <|
                        String.uncons chunk

        valueSegments chunks =
            List.Nonempty.fromList <| chunks

        maybeChain =
            lastWord
                |> Maybe.andThen checkParens
                |> Maybe.andThen checkMinutesLabel
                |> Maybe.andThen checkNumberSegments
                |> Maybe.andThen valueSegments
    in
    ( name, ( Nothing, Nothing ) )


extractTiming2 : String -> ( String, ( Maybe HumanDuration, Maybe HumanDuration ) )
extractTiming2 input =
    let
        chunk start =
            String.dropLeft start input

        withoutChunk chunkStart =
            String.dropRight (String.length (chunk chunkStart)) (chunk chunkStart)

        default =
            ( input, ( Nothing, Nothing ) )
    in
    case List.last (String.indexes "(" input) of
        Nothing ->
            default

        Just chunkStart ->
            case Parser.run timing (chunk chunkStart) of
                Err _ ->
                    default

                Ok ( num1, num2 ) ->
                    ( withoutChunk chunkStart
                    , ( Just (HumanDuration.Minutes num1), Just (HumanDuration.Minutes num2) )
                    )


timing : Parser ( Int, Int )
timing =
    Parser.succeed Tuple.pair
        |. symbol "("
        |. spaces
        |= Parser.int
        -- TODO allow "m" after this one too
        |. symbol "-"
        |= Parser.int
        -- TODO allow float
        |. symbol "m"
        -- TODO allow "min" also
        |. spaces
        |. symbol ")"


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


emptyProject : Int -> Project
emptyProject id =
    { id = id
    , name = ""
    , color = 0
    , parentId = 0
    , childOrder = 0
    , collapsed = 0
    , shared = False
    , isDeleted = 0
    , isArchived = 0
    , isFavorite = 0
    }


decodeProjectChanges : Decoder Project
decodeProjectChanges =
    decode Project
        |> required "id" int
        |> required "name" string
        |> required "color" int
        |> optional "parent_id" int 0
        |> required "child_order" int
        |> required "collapsed" int
        |> required "shared" bool
        |> required "is_deleted" int
        |> required "is_archived" int
        |> required "is_favorite" int
        |> optionalIgnored "legacy_parent_id"
        |> optionalIgnored "legacy_id"
        |> optionalIgnored "has_more_notes"
        |> optionalIgnored "inbox_project"



--should be id 1 anyway


encodeProject : Project -> Encode.Value
encodeProject record =
    Encode.object
        [ ( "id", Encode.int <| record.id )
        , ( "name", Encode.string <| record.name )
        , ( "color", Encode.int <| record.color )
        , ( "parent_id", Encode.int <| record.parentId )
        , ( "child_order", Encode.int <| record.childOrder )
        , ( "collapsed", Encode.int <| record.collapsed )
        , ( "shared", Encode.bool <| record.shared )
        , ( "is_deleted", Encode.int <| record.isDeleted )
        , ( "is_archived", Encode.int <| record.isArchived )
        , ( "is_favorite", Encode.int <| record.isFavorite )
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
        |> required "timezone" (nullable string)
        |> required "string" string
        |> required "lang" string
        |> required "is_recurring" bool


encodeDue : Due -> Encode.Value
encodeDue record =
    Encode.object
        [ ( "date", Encode.string <| record.date )
        , ( "timezone", Encode2.maybe Encode.string <| record.timezone )
        , ( "string", Encode.string <| record.string )
        , ( "lang", Encode.string <| record.lang )
        , ( "is_recurring", Encode.bool <| record.isRecurring )
        ]
