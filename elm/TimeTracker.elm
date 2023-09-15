module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, update, urlTriggers, view)

import Activity.Activity as Activity exposing (..)
import Activity.HistorySession as Timeline exposing (HistorySession, Timeline)
import Activity.Template
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import External.Commands as Commands exposing (..)
import External.Tasker as Tasker
import Helpers exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (..)
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (ChangeSet)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.Model exposing (..)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Human.Moment as HumanMoment
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.Layers
import Time
import TimeTrackable exposing (TimeTrackable)
import Url.Parser as P exposing ((</>), (<?>), Parser, fragment, int, map, oneOf, s, string)
import Url.Parser.Query as PQ
import VirtualDom
import VitePluginHelper



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type ViewState
    = Normal



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


routeView : Parser (ViewState -> a) a
routeView =
    P.map Normal (P.s "timetracker")


defaultView : ViewState
defaultView =
    Normal


view : ViewState -> Profile -> Shared -> Html Msg
view state app env =
    case state of
        Normal ->
            div
                []
                [ section
                    [ class "activity-screen" ]
                    [ lazy2 viewActivities ( env.time, env.timeZone ) app
                    ]
                , section [ css [ opacity (num 0.1) ] ]
                    [ text "Quite Ambitious."
                    ]
                ]


viewActivities : ( Moment, HumanMoment.Zone ) -> Profile -> Html Msg
viewActivities ( time, timeZone ) app =
    section
        [ class "main" ]
        [ ul [ class "activity-list" ] <|
            List.map (viewActivity app ( time, timeZone )) (Activity.allUnhidden app.activities)
        ]



-- VIEW INDIVIDUAL ENTRIES
-- viewKeyedActivity : Profile -> Shared -> Activity -> ( String, Html Msg )
-- viewKeyedActivity app env activity =
--     let
--         key =
--             Activity.getName activity ++ active
--
--         active =
--             if currentActivityID app.timeline == activity.id then
--                 String.fromInt <| totalLive env.time app.timeline activity.id
--
--             else
--                 ""
--     in
--     ( key, viewActivity app env activity )


viewActivity : Profile -> ( Moment, HumanMoment.Zone ) -> Activity -> Html Msg
viewActivity app ( time, timeZone ) activity =
    let
        describePeriod sesh =
            Timeline.inHoursMinutes (Period.length sesh) ++ "\n"

        filterPeriod =
            Period.between Moment.zero time

        trackingFlipID =
            if Profile.currentActivityID app == Activity.getID activity then
                attribute "data-flip-key" "current"

            else
                class "not-current"
    in
    li
        [ class "activity" ]
        [ button
            [ class "activity-button"
            , classList [ ( "current", Profile.currentActivityID app == Activity.getID activity ) ]
            , onClick (StartTracking (Activity.getID activity))
            , trackingFlipID
            , title <| List.foldl (++) "" (List.map describePeriod (Timeline.periodsOfActivity filterPeriod (RepList.listValues app.timeline) (Activity.getID activity)))
            ]
            [ viewIcon (Activity.getIcon activity)
            , div []
                [ text (writeActivityUsage app ( time, timeZone ) activity)
                ]
            , div []
                [ text (writeActivityToday app ( time, timeZone ) activity)
                ]
            , label
                []
                [ text (Activity.getName activity)
                ]
            ]
        ]


writeTime : Shared -> String
writeTime env =
    let
        nowClock =
            HumanMoment.extractTime env.timeZone env.time
    in
    String.fromInt (Clock.hour nowClock) ++ ":" ++ String.fromInt (Clock.minute nowClock)


viewIcon : Activity.Icon -> Html Msg
viewIcon getIcon =
    case getIcon of
        File svgPath ->
            img
                [ class "activity-icon"
                , src ("/media/icons/" ++ svgPath)
                , css [ Css.float left ]
                ]
                []

        Ion ->
            text ""

        Other ->
            text ""

        Emoji singleEmoji ->
            text singleEmoji


writeActivityUsage : Profile -> ( Moment, HumanMoment.Zone ) -> Activity -> String
writeActivityUsage app ( time, timeZone ) activity =
    let
        maxTimeDenominator =
            Tuple.second (Activity.getMaxTimePortion activity)

        lastPeriod =
            Period.fromEnd time maxTimeDenominator

        total =
            Timeline.activityTotalDuration lastPeriod (RepList.listValues app.timeline) (Activity.getID activity)

        totalMinutes =
            Duration.inMinutesRounded total
    in
    if inMs total > 0 then
        String.fromInt totalMinutes ++ "/" ++ String.fromInt (inMinutesRounded maxTimeDenominator) ++ "m"

    else
        ""


writeActivityToday : Profile -> ( Moment, HumanMoment.Zone ) -> Activity -> String
writeActivityToday app ( time, timeZone ) activity =
    Timeline.inHoursMinutes (Timeline.justTodayTotal (RepList.listValues app.timeline) ( time, timeZone ) (Activity.getID activity))


exportActivityViewModel : Profile -> ( Moment, HumanMoment.Zone ) -> Encode.Value
exportActivityViewModel appData ( time, timeZone ) =
    let
        encodeActivityVM activity =
            Encode.object
                [ ( "name", Encode.string <| Activity.getName activity )
                , ( "excusedUsage", Encode.string <| writeActivityUsage appData ( time, timeZone ) activity )
                , ( "totalToday", Encode.string <| writeActivityUsage appData ( time, timeZone ) activity )
                ]
    in
    Encode.list encodeActivityVM <|
        List.filter Activity.isShowing <|
            Activity.allUnhidden appData.activities



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = NoOp
    | StartTracking ActivityID
    | ExportVM


update : Msg -> ViewState -> Profile -> ( Moment, HumanMoment.Zone ) -> ( Change.Frame, ViewState, Cmd Msg )
update msg state profile ( time, timeZone ) =
    case msg of
        NoOp ->
            ( Change.none
            , state
            , Cmd.none
            )

        StartTracking activityId ->
            let
                projectLayers =
                    Task.Layers.buildLayerDatabase profile.projects

                newTrackable =
                    TimeTrackable.TrackedActivityID activityId

                ( changes, cmds ) =
                    Refocus.switchActivity newTrackable profile projectLayers ( time, timeZone )
            in
            ( Change.saveChanges "Started tracking" changes
            , state
            , Cmd.batch
                [ cmds

                -- , Tasker.variableOut ( "activities", Encode.encode 0 <| exportActivityViewModel updatedApp env )
                ]
            )

        ExportVM ->
            ( Change.none
            , state
            , Tasker.variableOut ( "activities", Encode.encode 0 <| exportActivityViewModel profile ( time, timeZone ) )
            )


urlTriggers : Profile -> List ( String, Dict.Dict String Msg )
urlTriggers app =
    let
        activitiesWithNames =
            List.concat <| List.map entriesPerActivity (Activity.allUnhidden app.activities)

        entriesPerActivity activity =
            List.map (\nm -> ( nm, StartTracking (Activity.getID activity) )) (Activity.getNames activity)
                ++ List.map (\nm -> ( String.toLower nm, StartTracking (Activity.getID activity) )) (Activity.getNames activity)
    in
    [ ( "start", Dict.fromList activitiesWithNames )
    , ( "stop", Dict.fromList [ ( "stop", StartTracking Activity.unknown ) ] )
    , ( "export", Dict.fromList [ ( "all", ExportVM ) ] )
    ]
