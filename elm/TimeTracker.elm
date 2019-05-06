module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, update, urlTriggers, view)

import Activity.Activity as Activity exposing (..)
import Activity.Measure as Measure exposing (..)
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
            , classList [ ( "current", (currentActivity app).id == activity.id ) ]
            , onClick (StartTracking activity.id)
            , title <| List.foldl (++) "" (List.map describeSession (Measure.sessions app.timeline activity.id))
            ]
            [ viewIcon activity.icon
            , div
                []
                [ text <| (writeActivityUsage app env activity ++ "m")
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
        lastPeriod =
            relevantTimeline app.timeline ( env.time, env.timeZone ) (Tuple.second activity.maxTime)
    in
    String.fromInt <| Measure.totalLive env.time lastPeriod activity.id // 60000



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
                updatedApp =
                    { app | timeline = Switch env.time activityId :: app.timeline }

                newActivity =
                    getActivity (allActivities app.activities) activityId

                oldActivity =
                    currentActivity app
            in
            ( state
            , updatedApp
            , Cmd.batch
                [ Commands.toast (switchPopup updatedApp.timeline newActivity oldActivity)
                , Commands.changeActivity (getName newActivity)
                    (writeActivityUsage app env newActivity)
                , Commands.hideWindow
                ]
            )


urlTriggers : AppData -> List (PQ.Parser (Maybe Msg))
urlTriggers app =
    let
        activitiesWithNames =
            List.concat <| List.map entriesPerActivity (allActivities app.activities)

        entriesPerActivity activity =
            List.map (\n -> ( n, StartTracking activity.id )) activity.names
                ++ List.map (\n -> ( String.toLower n, StartTracking activity.id )) activity.names
    in
    [ PQ.enum "start" <| Dict.fromList activitiesWithNames
    , PQ.enum "stop" <| Dict.fromList [ ( "stop", StartTracking dummy ) ]
    ]


switchPopup : Timeline -> Activity -> Activity -> String
switchPopup timeline new old =
    let
        timeSpentString num =
            String.fromInt num
                ++ " s spent, "

        timeSpent =
            Maybe.map (\n -> n // 1000) (List.head (Measure.sessions timeline old.id))

        total =
            Measure.total timeline old.id // 1000
    in
    getName old
        ++ " ➤ "
        ++ getName new
        ++ "\n"
        ++ Maybe.withDefault "" (Maybe.map timeSpentString timeSpent)
        ++ "new total "
        ++ String.fromInt total
        ++ " s"


currentActivity : AppData -> Activity
currentActivity app =
    Activity.currentActivity (allActivities app.activities) app.timeline
