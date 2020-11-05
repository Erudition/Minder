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
import List.Nonempty exposing (Nonempty)
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
                    Period.fromStart dayStarted Duration.aDay

                dayStarted =
                    HumanMoment.clockTurnBack Clock.midnight env.timeZone env.time

                -- TODO
            in
            section
                [ id "timeline" ]
                [ viewChunkOfSessions env sessionList chunk
                , section [ css [ opacity (num 0.1) ] ]
                    [ text "Everything working well? Good."
                    ]
                ]


dayString : Environment -> Moment -> String
dayString env moment =
    Calendar.toStandardString (HumanMoment.extractDate env.timeZone moment)


viewChunkOfSessions : Environment -> List Task.FullSession -> Period -> Html msg
viewChunkOfSessions env sessionList dayPeriod =
    let
        sessionListToday =
            List.filter (\ses -> Period.isWithin dayPeriod (HumanMoment.fromFuzzy env.timeZone <| Tuple.first ses.session)) sessionList

        -- TODO that's the wrong place to do that
        rowMarkers =
            List.map markRow (Period.divide dayRowLength dayPeriod)

        dayWindowLength =
            -- Duration.aDay by default
            Period.length dayPeriod

        dayRowLength =
            -- TODO make configurable
            Duration.anHour

        markRow per =
            node "timeline-area"
                []
                [ text <| describeMoment <| Period.start per ]

        nowMarker =
            let
                markPosition =
                    List.Nonempty.head <|
                        getPositionInDay dayRowLength dayPeriod <|
                            Period.fromStart env.time <|
                                HumanDuration.toDuration (HumanDuration.Minutes 1)

                centerMarker =
                    markPosition.left - (markPosition.width / 2)
            in
            node "now-marker"
                [ css
                    [ top (pct markPosition.top)
                    , left (pct centerMarker)
                    , Css.height (pct markPosition.height)
                    , Css.width (pct markPosition.width)
                    ]
                ]
                []

        describeMoment mo =
            HumanMoment.extractTime env.timeZone mo |> Clock.toShortString
    in
    node "day"
        [ id <| "day" ++ dayString env env.time ]
        (rowMarkers ++ List.map (viewSession env dayPeriod) sessionListToday ++ [ nowMarker ])


viewSession : Environment -> Period -> Task.FullSession -> Html msg
viewSession env day fullSession =
    let
        ( sessionPeriodStart, sessionPeriodLength ) =
            fullSession.session

        sessionPeriod =
            Period.fromStart (HumanMoment.fromFuzzy env.timeZone sessionPeriodStart)
                sessionPeriodLength

        dayRowLength =
            -- TODO make configurable
            Duration.anHour

        sessionPositions =
            getPositionInDay dayRowLength day sessionPeriod

        ( ( startDate, startTime ), ( endDate, endTime ) ) =
            ( HumanMoment.humanize env.timeZone (Period.start sessionPeriod)
            , HumanMoment.humanize env.timeZone (Period.end sessionPeriod)
            )

        viewSessionSegment pos =
            node "segment"
                [ title <|
                    fullSession.class.title
                        ++ "\nFrom "
                        ++ Clock.toShortString startTime
                        ++ " to "
                        ++ Clock.toShortString endTime
                        ++ " ("
                        ++ HumanDuration.abbreviatedSpaced (HumanDuration.breakdownNonzero sessionPeriodLength)
                        ++ ")"
                , css
                    [ top (pct pos.top)
                    , left (pct pos.left)
                    , Css.width (pct pos.width)
                    , Css.height (pct pos.height)
                    ]
                ]
                [ node "activity-icon" [] []
                , label [] [ text fullSession.class.title ]
                ]
    in
    node "timeline-session"
        [ class "future" ]
    <|
        List.Nonempty.toList (List.Nonempty.map viewSessionSegment sessionPositions)


getPositionInDay : Duration -> Period -> Period -> Nonempty { top : Float, left : Float, height : Float, width : Float }
getPositionInDay rowLength day givenSession =
    let
        rows =
            Period.divide rowLength day

        rowCount =
            -- typically 24
            List.length rows

        startTimeAsDayOffset =
            -- Where the session starts relative to the day
            -- Subtract day start from session start, so day begins at 0
            Moment.difference (Period.start day) (Period.start givenSession)

        endTimeAsDayOffset =
            -- Where the session starts relative to the day
            -- Subtract day start from session start, so day begins at 0
            Moment.difference (Period.start day) (Period.end givenSession)

        targetRow =
            -- Which "row" (hour) does the session start in?
            -- Divide to see how many whole rows fit in before the session starts
            Duration.divide startTimeAsDayOffset rowLength

        rowStart =
            Duration.scale rowLength (toFloat targetRow)

        targetStartColumn =
            -- Which "column" does the session start in?
            -- Offset from the beginning of the row.
            Duration.subtract startTimeAsDayOffset rowStart

        rowEnd =
            Duration.scale rowLength (toFloat (targetRow + 1))

        fitsInRow =
            Duration.compare endTimeAsDayOffset rowEnd /= GT

        targetEndColumn =
            -- Which "column" does the session end in?
            -- Offset from the beginning of the row.
            if fitsInRow then
                -- session fits in this row.
                -- Offset from the beginning of the row.
                Duration.subtract endTimeAsDayOffset rowStart

            else
                rowEnd

        -- TODO intersect row list with session list instead
        targetRowPercent =
            (toFloat targetRow / toFloat rowCount) * 100

        heightPercent =
            (1 / toFloat rowCount) * 100

        targetStartColumnPercent =
            (toFloat (Duration.inMs targetStartColumn) / toFloat (Duration.inMs rowLength)) * 100

        widthPercent =
            (toFloat (Duration.inMs targetEndColumn - Duration.inMs targetStartColumn) / toFloat (Duration.inMs rowLength)) * 100

        rowEndAbsolute =
            Moment.future (Period.start day) rowEnd

        restOfSession =
            Period.fromPair ( rowEndAbsolute, Period.end givenSession )

        additionalSegments =
            if fitsInRow then
                []

            else
                List.Nonempty.toList <| getPositionInDay rowLength day restOfSession
    in
    List.Nonempty.Nonempty
        { top = targetRowPercent
        , left = targetStartColumnPercent
        , height = heightPercent
        , width = widthPercent
        }
        additionalSegments



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
