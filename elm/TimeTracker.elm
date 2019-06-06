module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, testMsg, update, urlTriggers, view)

import Activity.Activity as Activity exposing (..)
import Activity.Measure as Measure exposing (..)
import Activity.Switching as Switching
import Activity.Template
import AppData exposing (..)
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Environment exposing (..)
import External.Commands as Commands exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (..)
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (..)
import SmartTime.HumanDuration as HumanDuration exposing (..)
import Task as Job
import Time
import Url.Parser as P exposing ((</>), (<?>), Parser, fragment, int, map, oneOf, s, string)
import Url.Parser.Query as PQ
import VirtualDom



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type ViewState
    = Normal


testMsg : Msg
testMsg =
    StartTracking (Stock Activity.Template.FilmWatching)



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


routeView : Parser (ViewState -> a) a
routeView =
    P.map Normal (s "timetracker")


defaultView : ViewState
defaultView =
    Normal


view : ViewState -> AppData -> Environment -> Html Msg
view state app env =
    case state of
        Normal ->
            div
                []
                [ section
                    [ class "activity-screen" ]
                    [ lazy2 viewActivities env app
                    ]
                , section [ css [ opacity (num 0.1) ] ]
                    [ text "Quite Ambitious."
                    ]
                ]


viewActivities : Environment -> AppData -> Html Msg
viewActivities env app =
    section
        [ class "main" ]
        [ ul [ class "activity-list" ] <|
            List.map (viewActivity app env) (List.filter Activity.showing (allActivities app.activities))
        ]



-- VIEW INDIVIDUAL ENTRIES
-- viewKeyedActivity : AppData -> Environment -> Activity -> ( String, Html Msg )
-- viewKeyedActivity app env activity =
--     let
--         key =
--             Activity.getName activity ++ active
--
--         active =
--             if currentActivityId app.timeline == activity.id then
--                 String.fromInt <| totalLive env.time app.timeline activity.id
--
--             else
--                 ""
--     in
--     ( key, viewActivity app env activity )


viewActivity : AppData -> Environment -> Activity -> Html Msg
viewActivity app env activity =
    let
        describeSession sesh =
            Measure.inFuzzyWords sesh ++ "\n"
    in
    li
        [ class "activity" ]
        [ button
            [ class "activity-button"
            , classList [ ( "current", (Switching.currentActivityFromApp app).id == activity.id ) ]
            , onClick (StartTracking activity.id)
            , title <| List.foldl (++) "" (List.map describeSession (Measure.sessions app.timeline activity.id))
            ]
            [ viewIcon activity.icon
            , div []
                [ text (writeActivityUsage app env activity)
                ]
            , div []
                [ text (writeActivityToday app env activity)
                ]
            , label
                []
                [ text (Activity.getName activity)
                ]
            ]
        ]


writeTime : Environment -> String
writeTime env =
    String.fromInt (Time.toHour env.timeZone env.time) ++ ":" ++ String.fromInt (Time.toMinute env.timeZone env.time)


viewIcon : Activity.Icon -> Html Msg
viewIcon icon =
    case icon of
        File svgPath ->
            img
                [ class "activity-icon"
                , src ("media/icons/" ++ svgPath)
                , css [ Css.float left ]
                ]
                []

        Ion ->
            text ""

        Other ->
            text ""


writeActivityUsage : AppData -> Environment -> Activity -> String
writeActivityUsage app env activity =
    let
        period =
            Tuple.second activity.maxTime

        lastPeriod =
            relevantTimeline app.timeline ( env.time, env.timeZone ) period

        total =
            Measure.totalLive env.time lastPeriod activity.id

        totalMinutes =
            Duration.inMinutesRounded total
    in
    if inMs total > 0 then
        String.fromInt totalMinutes ++ "/" ++ String.fromInt (inMinutesRounded (toDuration period)) ++ "m"

    else
        ""


writeActivityToday : AppData -> Environment -> Activity -> String
writeActivityToday app env activity =
    Measure.inHoursMinutes (Measure.justTodayTotal app.timeline env activity)



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = NoOp
    | StartTracking ActivityId


update : Msg -> ViewState -> AppData -> Environment -> ( ViewState, AppData, Cmd Msg )
update msg state app env =
    case msg of
        NoOp ->
            ( state
            , app
            , Cmd.none
            )

        StartTracking activityId ->
            let
                ( updatedApp, cmds ) =
                    Switching.switchActivity activityId app env
            in
            ( state
            , updatedApp
            , cmds
            )


urlTriggers : AppData -> List (PQ.Parser (Maybe Msg))
urlTriggers app =
    -- let
    --     activitiesWithNames =
    --         List.concat <| List.map entriesPerActivity (allActivities app.activities)
    --
    --     entriesPerActivity activity =
    --         List.map (\n -> ( n, StartTracking activity.id )) activity.names
    --             ++ List.map (\n -> ( String.toLower n, StartTracking activity.id )) activity.names
    -- in
    -- [ PQ.enum "start" <| Dict.fromList activitiesWithNames
    -- , PQ.enum "stop" <| Dict.fromList [ ( "stop", StartTracking dummy ) ]
    -- ]
    []
