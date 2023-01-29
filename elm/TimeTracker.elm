module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, update, urlTriggers, view)

import Activity.Activity as Activity exposing (..)
import Activity.Template
import Activity.Timeline as Timeline exposing (Timeline)
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Environment exposing (..)
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
import SmartTime.Duration as Duration exposing (..)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (..)
import SmartTime.Human.Moment as HumanMoment
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
    P.map Normal (P.s "timetracker")


defaultView : ViewState
defaultView =
    Normal


view : ViewState -> Profile -> Environment -> Html Msg
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


viewActivities : Environment -> Profile -> Html Msg
viewActivities env app =
    section
        [ class "main" ]
        [ ul [ class "activity-list" ] <|
            List.map (viewActivity app env) (Activity.allUnhidden app.activities)
        ]



-- VIEW INDIVIDUAL ENTRIES
-- viewKeyedActivity : Profile -> Environment -> Activity -> ( String, Html Msg )
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


viewActivity : Profile -> Environment -> Activity -> Html Msg
viewActivity app env activity =
    let
        describeSession sesh =
            Timeline.inHoursMinutes sesh ++ "\n"
    in
    li
        [ class "activity" ]
        [ button
            [ class "activity-button"
            , classList [ ( "current", Profile.currentActivityID app == Activity.getID activity ) ]
            , onClick (StartTracking (Activity.getID activity))
            , title <| List.foldl (++) "" (List.map describeSession (Timeline.sessions (RepList.listValues app.timeline) (Activity.getID activity)))
            ]
            [ viewIcon (Activity.getIcon activity)
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
                , src ("media/icons/" ++ svgPath)
                , css [ Css.float left ]
                ]
                []

        Ion ->
            text ""

        Other ->
            text ""

        Emoji singleEmoji ->
            text singleEmoji


writeActivityUsage : Profile -> Environment -> Activity -> String
writeActivityUsage app env activity =
    let
        period =
            Tuple.second (Activity.getMaxTime activity)

        lastPeriod =
            Timeline.relevantTimeline app.timeline env.time period

        total =
            Timeline.totalLive env.time (RepList.listValues lastPeriod) (Activity.getID activity)

        totalMinutes =
            Duration.inMinutesRounded total
    in
    if inMs total > 0 then
        String.fromInt totalMinutes ++ "/" ++ String.fromInt (inMinutesRounded (toDuration period)) ++ "m"

    else
        ""


writeActivityToday : Profile -> Environment -> Activity -> String
writeActivityToday app env activity =
    Timeline.inHoursMinutes (Timeline.justTodayTotal app.timeline env (Activity.getID activity))


exportActivityViewModel : Profile -> Environment -> Encode.Value
exportActivityViewModel appData environment =
    let
        encodeActivityVM activity =
            Encode.object
                [ ( "name", Encode.string <| Activity.getName activity )
                , ( "excusedUsage", Encode.string <| writeActivityUsage appData environment activity )
                , ( "totalToday", Encode.string <| writeActivityUsage appData environment activity )
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


update : Msg -> ViewState -> Profile -> Environment -> ( Change.Frame, ViewState, Cmd Msg )
update msg state app env =
    case msg of
        NoOp ->
            ( Change.none
            , state
            , Cmd.none
            )

        StartTracking activityId ->
            let
                ( changes, cmds ) =
                    Refocus.switchActivity activityId app env
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
            , Tasker.variableOut ( "activities", Encode.encode 0 <| exportActivityViewModel app env )
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
