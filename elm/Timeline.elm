module Timeline exposing (Filter(..), Msg, ViewState(..), defaultView, routeView, update, view)

import Activity.Switching
import AppData exposing (..)
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Dict
import Environment exposing (..)
import External.Commands as Commands
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attr exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import ID
import Incubator.IntDict.Extra as IntDict
import Incubator.Todoist as Todoist
import Incubator.Todoist.Command as TodoistCommand
import IntDict
import Integrations.Todoist
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import Porting exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import String.Normalize
import Task as Job
import Task.Progress exposing (..)
import Task.Task as Task exposing (Instance)
import Url.Parser as P exposing ((</>), Parser, fragment, int, map, oneOf, s, string)
import VirtualDom



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type Filter
    = AllTasks
    | IncompleteTasksOnly
    | CompleteTasksOnly



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type ViewState
    = ShowSpan (Maybe Moment) (Maybe Moment)


routeView : Parser (ViewState -> a) a
routeView =
    P.map (ShowSpan Nothing Nothing) (P.s "timeline")


defaultView : ViewState
defaultView =
    ShowSpan Nothing Nothing


view : ViewState -> AppData -> Environment -> Html Msg
view state app env =
    let
        fullInstanceList =
            IntDict.values <| Task.buildFullInstanceDict ( app.taskEntries, app.taskClasses, app.taskInstances )

        sessionList =
            List.concatMap Task.getFullSessions fullInstanceList
    in
    case state of
        ShowSpan newStart newFinish ->
            let
                ( start, finish ) =
                    ( Maybe.withDefault env.time newStart, Maybe.withDefault env.time newFinish )

                chunk =
                    Period.fromStart env.time Duration.aDay

                -- TODO
            in
            section
                [ id "timeline" ]
                [ div
                    [ id <| "day" ++ dayString env env.time, class "day" ]
                    [ viewChunkOfSessions env sessionList chunk ]
                , section [ css [ opacity (num 0.1) ] ]
                    [ text "Everything working well? Good."
                    ]
                ]


dayString : Environment -> Moment -> String
dayString env moment =
    Calendar.toStandardString (HumanMoment.extractDate env.timeZone moment)


viewChunkOfSessions : Environment -> List Task.FullSession -> Period -> Html msg
viewChunkOfSessions env sessionList dayPeriod =
    div
        [ id <| "day" ++ dayString env env.time, class "day" ]
        (List.map (viewSession env dayPeriod) sessionList)


viewSession : Environment -> Period -> Task.FullSession -> Html msg
viewSession env dayPeriod fullSession =
    let
        sessionPeriod =
            Period.fromStart (HumanMoment.fromFuzzy env.timeZone (Tuple.first fullSession.session))
                (Tuple.second fullSession.session)

        dayWindowLength =
            -- Duration.aDay by default
            Period.length dayPeriod

        dayRowLength =
            -- TODO make configurable
            Duration.anHour

        dayPosition =
            -- Where the session starts relative to the day
            -- Subtract day start from session start, so day begins at 0
            Moment.difference (Period.start dayPeriod) (Period.start sessionPeriod)

        rowCount =
            -- How many rows are in a day?
            Duration.divide dayWindowLength dayRowLength

        targetRow =
            -- Which "row" (hour) does the session start in?
            -- Divide to see how many whole rows fit in before the session starts
            Duration.divide dayPosition dayRowLength

        targetColumn =
            -- Which "column" does the session start in?
            -- Offset from the beginning of the row.
            Duration.subtract dayPosition (Duration.scale dayRowLength (toFloat targetRow))

        targetRowPercent =
            (toFloat targetRow / toFloat rowCount) * 100

        targetColumnPercent =
            (toFloat (Duration.inMs dayRowLength) / toFloat (Duration.inMs targetColumn)) * 100
    in
    div
        [ class "session"
        , css
            [ top (pct targetRowPercent)
            , left (pct targetColumnPercent)
            , backgroundColor (rgb 55 0 0) -- red for now
            , borderRadius (px 20)
            ]
        ]
        [ sessionActivityIcon
        , text fullSession.class.title
        ]


sessionActivityIcon =
    span [] []



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = Move Moment Moment


update : Msg -> ViewState -> AppData -> Environment -> ( ViewState, AppData, Cmd Msg )
update msg state app env =
    case msg of
        Move newStart newFinish ->
            ( ShowSpan (Just newStart) (Just newFinish), app, Cmd.none )
