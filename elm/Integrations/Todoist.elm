module Integrations.Todoist exposing (calcImportance, describeSuccess, devSecret, fetchUpdates, handle, itemToTask, sendChanges, timing)

import Activity.Activity as Activity exposing (Activity, ActivityID)
import AppData exposing (AppData, TodoistIntegrationData, saveError)
import Dict exposing (Dict)
import Http
import ID
import Incubator.IntDict.Extra as IntDict
import Incubator.Todoist as Todoist
import Incubator.Todoist.Command as TDCommand
import Incubator.Todoist.Item as Item exposing (Item)
import Incubator.Todoist.Project as Project exposing (Project)
import IntDict exposing (IntDict)
import Json.Decode.Exploration as Decode exposing (..)
import Json.Decode.Exploration.Pipeline exposing (..)
import Json.Encode as Encode
import Json.Encode.Extra as Encode2
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Maybe.Extra as Maybe
import Parser exposing ((|.), (|=), Parser, float, spaces, symbol)
import Porting exposing (..)
import Set
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment)
import Task.Progress
import Task.Task as Task exposing (TaskInstance, newTaskClass)
import Url
import Url.Builder


fetchUpdates : TodoistIntegrationData -> Cmd Todoist.Msg
fetchUpdates localData =
    Todoist.sync localData.cache devSecret [ Todoist.Items, Todoist.Projects ] []


sendChanges : TodoistIntegrationData -> List TDCommand.CommandInstance -> Cmd Todoist.Msg
sendChanges localData changeList =
    Todoist.sync localData.cache devSecret [ Todoist.Items, Todoist.Projects ] changeList


devSecret : Todoist.SecretToken
devSecret =
    "0bdc5149510737ab941485bace8135c60e2d812b"


handle : Todoist.Msg -> AppData -> ( AppData, String )
handle msg app =
    case Todoist.handleResponse msg app.todoist.cache of
        Ok ( newCache, changes ) ->
            let
                newMaybeParent =
                    -- uses old and new data to try to find the parent project
                    tryGetTimetrackParentProject app.todoist newCache

                projectToActivityMapping =
                    -- a table of project-to-activity correspondence
                    -- TODO perf: only search new projects
                    detectActivityProjects newMaybeParent app newCache

                convertItemsToTasks =
                    -- ignores certain items (no Activity) during conversion
                    IntDict.filterMapValues (timetrackItemToTask projectToActivityMapping) newCache.items

                newTodoistData =
                    { cache = newCache
                    , parentProjectID = newMaybeParent
                    , activityProjectIDs = projectToActivityMapping
                    }
            in
            ( { app
                | todoist = newTodoistData
                , taskInstances =
                    -- TODO figure out deleted
                    IntDict.union convertItemsToTasks app.taskInstances
              }
            , describeSuccess changes
            )

        Err err ->
            let
                description =
                    Todoist.describeError err
            in
            ( saveError app description, description )


describeSuccess : Todoist.LatestChanges -> String
describeSuccess report =
    let
        ( projectsAdded, projectsDeleted, projectsModified ) =
            ( Set.size report.projectsAdded, Set.size report.projectsDeleted, Set.size report.projectsChanged )

        ( itemsAdded, itemsDeleted, itemsModified ) =
            ( Set.size report.itemsAdded, Set.size report.itemsDeleted, Set.size report.itemsChanged )

        totalProjectChanges =
            projectsAdded + projectsDeleted + projectsModified

        totalItemChanges =
            itemsAdded + itemsDeleted + itemsModified

        itemReport =
            if totalItemChanges > 0 then
                Just <|
                    String.fromInt totalItemChanges
                        ++ " items updated ("
                        ++ String.fromInt itemsAdded
                        ++ " created, "
                        ++ String.fromInt itemsDeleted
                        ++ " deleted)"

            else
                Nothing

        projectReport =
            if totalProjectChanges > 0 then
                Just <|
                    String.fromInt totalProjectChanges
                        ++ " projects updated ("
                        ++ String.fromInt projectsAdded
                        ++ " created, "
                        ++ String.fromInt projectsDeleted
                        ++ " deleted)"

            else
                Nothing

        reportList =
            List.filterMap identity [ itemReport, projectReport ]
    in
    "Todoist sync complete: "
        ++ (if totalProjectChanges + totalItemChanges == 0 then
                "Nothing changed since last sync."

            else
                (String.concat <| List.intersperse " and " reportList) ++ "."
           )


detectActivityProjects : Maybe Project.ProjectID -> AppData -> Todoist.Cache -> IntDict ActivityID
detectActivityProjects maybeParent app cache =
    case maybeParent of
        Nothing ->
            -- Still coudln't find parent ID. Give up with empty - no tasks will be matched with an Activity for now
            IntDict.empty

        Just parentProjectID ->
            let
                hasTimetrackAsParent : Project -> Bool
                hasTimetrackAsParent p =
                    Maybe.unwrap False ((==) parentProjectID) p.parent_id

                validActivityProjects =
                    IntDict.filterValues hasTimetrackAsParent cache.projects

                newActivityLookupTable =
                    filterActivityProjects validActivityProjects activities

                oldActivityLookupTable =
                    app.todoist.activityProjectIDs

                activities =
                    Activity.allActivities app.activities
            in
            -- add it to what we already know! TODO what if one is deleted?
            IntDict.union newActivityLookupTable oldActivityLookupTable


tryGetTimetrackParentProject : TodoistIntegrationData -> Todoist.Cache -> Maybe Project.ProjectID
tryGetTimetrackParentProject localData cache =
    case localData.parentProjectID of
        Just parentProjectID ->
            -- we already know it! just use that. If it changes later for some reason, the user will have to do a reset.
            Just parentProjectID

        Nothing ->
            -- we have yet to find the parentProjectID. Let's try again:
            List.head <| IntDict.keys <| IntDict.filter (\_ p -> p.name == "Timetrack") cache.projects


{-| Take our todoist-project dictionary and our activity dictionary, and create a translation table between them.
-}
filterActivityProjects : IntDict Project -> IntDict Activity -> IntDict ActivityID
filterActivityProjects projects activities =
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
        -- If for some reason there's multiple matches, choose the first. TODO save error instead
        -- If none matched, returns nothing (List.head) TODO save error instead
        pickFirstMatch nameToTest =
            List.head <| IntDict.values (activityNameMatches nameToTest)
    in
    -- For all projects, take the name and check it against the activityID dict
    IntDict.filterMap (\i p -> pickFirstMatch p.name) projects


timetrackItemToTask : IntDict ActivityID -> Item -> Maybe TaskInstance
timetrackItemToTask lookup item =
    -- Equivalent to the one-liner:
    --      Maybe.map (\act -> itemToTask act item) (IntDict.get item.project_id lookup)
    -- Just sayin'.
    case IntDict.get item.project_id lookup of
        Just act ->
            Just (itemToTask act item)

        Nothing ->
            Nothing


itemToTask : Activity.ActivityID -> Item -> TaskInstance
itemToTask activityID item =
    let
        base =
            newTaskClass (Task.normalizeTitle newName) item.id

        ( newName, ( minDur, maxDur ) ) =
            extractTiming2 item.content

        getDueDate due =
            Item.fromRFC3339Date due.date
    in
    { base
        | completion =
            if item.checked then
                Task.Progress.maximize base.completion

            else
                base.completion
        , tags = []
        , activity = Just activityID
        , minEffort = Maybe.withDefault base.minEffort minDur
        , maxEffort = Maybe.withDefault base.maxEffort maxDur
        , importance = calcImportance item
        , externalDeadline = Maybe.andThen getDueDate item.due
    }


calcImportance : Item -> Float
calcImportance { priority, day_order } =
    let
        (Item.Priority int) =
            priority

        priorityFactor =
            -- inverts priority back to greater number = higher priority
            (0 - toFloat int) + 4

        orderingFactor =
            if day_order == -1 then
                0

            else
                (0 - toFloat day_order * 0.01) + 0.99
    in
    priorityFactor + orderingFactor


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


extractTiming2 : String -> ( String, ( Maybe Duration, Maybe Duration ) )
extractTiming2 input =
    -- TODO optimize this sucker
    let
        chunk start =
            String.dropLeft start input

        withoutChunk chunkStart =
            String.dropRight (String.length (chunk chunkStart)) input

        default =
            ( input, ( Nothing, Nothing ) )
    in
    case List.last (String.indexes "(" input) of
        -- There were no left parens
        Nothing ->
            default

        -- found left parens! here's the index of the last one found
        Just chunkStart ->
            case Parser.run timing (chunk chunkStart) of
                Err _ ->
                    -- couldn't make out a valid glob, leave it be
                    default

                Ok ( num1, num2 ) ->
                    -- found a valid glob! remove it from title
                    ( withoutChunk chunkStart
                    , ( Just (Duration.fromMinutes num1), Just (Duration.fromMinutes num2) )
                    )


timing : Parser ( Float, Float )
timing =
    Parser.succeed Tuple.pair
        |. symbol "("
        |. spaces
        |= Parser.float
        -- TODO allow "m" after this one too
        |. symbol "-"
        |= Parser.float
        |. symbol "m"
        -- TODO allow "min" also
        |. spaces
        |. symbol ")"
