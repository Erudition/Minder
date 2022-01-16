module Timeflow exposing (Msg, ViewState, defaultState, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Activity.Switching
import Activity.Timeline
import Browser
import Browser.Dom
import Css as C
import Date
import Dict exposing (Dict)
import Dict.Extra as Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Environment exposing (..)
import External.Commands as Commands
import GraphicSVG exposing (..)
import GraphicSVG.Widget as Widget
import HSLuv exposing (HSLuv, hsluv)
import Helpers exposing (..)
import Html.Attributes
import Html.Styled as SH exposing (Html)
import Html.Styled.Attributes as SHA
import Html.Styled.Events as SHE
import Html.Styled.Keyed as SHK
import Html.Styled.Lazy exposing (lazy, lazy2)
import ID
import Incubator.IntDict.Extra as IntDict
import Incubator.Todoist as Todoist
import Incubator.Todoist.Command as TodoistCommand
import IntDict exposing (IntDict)
import Integrations.Todoist
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import List.Extra as List
import List.Nonempty exposing (Nonempty)
import Profile exposing (..)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate)
import SmartTime.Human.Calendar.Week as Week
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import String.Normalize
import Task as Job
import Task.Entry as Task
import Task.Instance as Task exposing (Instance, InstanceSkel)
import Task.Progress exposing (..)
import Task.Session as Task
import Url.Parser as P exposing ((</>), Parser, fragment, int, map, oneOf, s, string)
import VirtualDom
import ZoneHistory



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type alias ChosenDayWindow =
    { period : Period
    , rowLength : Duration
    }



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type alias ViewState =
    { settings : ViewSettings
    , widgets : Dict WidgetID ( Widget.Model, Cmd Widget.Msg )
    , pointer : Pointer
    }


type alias WidgetID =
    String


type alias ViewSettings =
    { flowRenderPeriod : Period
    , hourRowSize : Duration
    , pivotMoment : Moment
    , rowHeight : Int
    }


updateViewSettings : Profile -> Environment -> ViewSettings
updateViewSettings profile env =
    let
        today =
            Period.fromPair
                ( HumanMoment.clockTurnBack chosenDayCutoffTime env.timeZone env.time
                , HumanMoment.clockTurnForward chosenDayCutoffTime env.timeZone env.time
                )

        week =
            Period.fromPair
                ( HumanMoment.fromDateAndTime env.timeZone (Calendar.toPrevious Week.Sun (HumanMoment.extractDate env.timeZone env.time)) chosenDayCutoffTime
                , HumanMoment.fromDateAndTime env.timeZone (Calendar.toNext Week.Sun (HumanMoment.extractDate env.timeZone env.time)) chosenDayCutoffTime
                )

        chosenDayCutoffTime =
            -- will be derived from profile settings
            HumanDuration.build [ HumanDuration.Hours 3 ]
    in
    { flowRenderPeriod = week
    , hourRowSize = Duration.fromMinutes 30
    , pivotMoment = HumanMoment.clockTurnBack chosenDayCutoffTime env.timeZone env.time
    , rowHeight = 40
    }


defaultState : Profile -> Environment -> ViewState
defaultState profile environment =
    { settings = updateViewSettings profile environment
    , widgets = Dict.fromList [ ( "0", Widget.init 100 100 "0" ) ]
    , pointer = { x = 0.0, y = 0.0 }
    }


routeView : Parser (Maybe ViewState -> a) a
routeView =
    P.map Nothing (P.s "timeflow")


view : Maybe ViewState -> Profile -> Environment -> SH.Html Msg
view maybeVState profile env =
    let
        vState =
            Maybe.withDefault (defaultState profile env) maybeVState
    in
    SH.fromUnstyled <|
        layoutWith { options = [ noStaticStyleSheet ] } [ width fill, height fill ] <|
            column [ width fill, height fill ]
                [ row [ width fill, height (fillPortion 1), Background.color (Element.rgb 0.5 0.5 0.5) ]
                    [ el [ centerX ] <| Element.text <| Calendar.toStandardString <| HumanMoment.extractDate env.timeZone env.time ]
                , row [ width (fillPortion 1), height (fillPortion 20), scrollbarY ]
                    [ timeFlowLayout vState.settings profile env
                    , column [ width (fillPortion 1) ] <| List.map (Element.html << svgExperiment vState profile env) (Dict.toList vState.widgets)
                    ]
                , row [ width fill, height (fillPortion 1), Background.color (Element.rgb 0.5 0.5 0.5) ]
                    [ el [ centerX ] <| Element.text "The future is below." ]
                ]


svgExperiment state profile env ( widgetID, ( widgetState, widgetInitCmd ) ) =
    Widget.view widgetState
        [ rect 100 100
            |> filled gray
            |> notifyMouseMoveAt PointerMove
        , circle 1
            |> filled blue
            |> move ( state.pointer.x / 4, state.pointer.y / 4 )
            |> notifyMouseMoveAt PointerMove
        , GraphicSVG.text "GraphicSVG side"
            |> fixedwidth
            |> size 2
            |> filled black
            |> move ( -25, 11 )
        ]


type alias FlowBlob =
    { start : Moment
    , end : Moment
    , color : Element.Color
    , label : String
    }


displayBlob : ViewSettings -> Environment -> FlowBlob -> Element Msg
displayBlob displayState env flowBlob =
    let
        msBetweenWalls =
            Duration.inMs displayState.hourRowSize

        startMs =
            Duration.subtract (Moment.toDuration flowBlob.start Moment.y2k)
                (Moment.toDuration displayState.pivotMoment Moment.y2k)
                |> Duration.inMs

        offsetFromPriorWall ms =
            -- TODO for negatives: mod or remainder
            modBy msBetweenWalls ms

        distanceToNextWall ms =
            msBetweenWalls - offsetFromPriorWall ms

        endMs =
            Duration.subtract (Moment.toDuration flowBlob.end Moment.y2k)
                (Moment.toDuration displayState.pivotMoment Moment.y2k)
                |> Duration.inMs

        firstWallAfterStart =
            startMs + distanceToNextWall startMs

        wallsCrossed =
            if firstWallAfterStart > endMs then
                []

            else
                List.iterate nextWallWithinBlob firstWallAfterStart

        nextWallWithinBlob ms =
            -- less than, not equal, so we don't start a new row of zero width
            if ms + msBetweenWalls < endMs then
                Just (ms + msBetweenWalls)

            else
                -- we've left the blob
                Nothing

        startsAtPortion =
            toFloat (offsetFromPriorWall startMs) / toFloat msBetweenWalls

        endsAtPortion =
            toFloat (offsetFromPriorWall endMs) / toFloat msBetweenWalls

        reverseMaybe shouldReverse elements =
            if shouldReverse then
                List.reverse elements

            else
                elements

        isOddRow startWall =
            let
                rowNumber =
                    startWall // msBetweenWalls
            in
            modBy 2 rowNumber == 1

        firstRowStartWall =
            startMs - offsetFromPriorWall startMs

        lastRowStartWall =
            endMs - offsetFromPriorWall endMs

        topRow =
            row [ width fill, height (px displayState.rowHeight), clipX ] <|
                reverseMaybe (isOddRow firstRowStartWall)
                    [ spacer (offsetFromPriorWall startMs)
                    , topPiece (distanceToNextWall startMs)
                    ]

        bottomRow =
            row [ width fill, height (px displayState.rowHeight), clipX ] <|
                reverseMaybe (isOddRow lastRowStartWall)
                    [ bottomPiece (offsetFromPriorWall endMs)
                    , spacer (distanceToNextWall endMs)
                    ]

        middleRow =
            row [ width fill, height (px displayState.rowHeight), clipX ] [ middlePiece ]

        rowWithBlobThatCrossesNoWalls =
            row [ width fill, height (px displayState.rowHeight) ] <|
                reverseMaybe (isOddRow lastRowStartWall)
                    [ spacer (offsetFromPriorWall startMs)
                    , floatingPiece (endMs - startMs)
                    , spacer (distanceToNextWall endMs)
                    ]

        spacer portion =
            el [ width (fillPortion portion), height fill, Element.clip, Background.color (Element.rgba 0.9 0.9 0.9 0) ] <| centeredText ""

        floatingPiece portion =
            el ([ width (fillPortion portion) ] ++ blobAttributes) <| centeredText flowBlob.label

        topPiece portion =
            el ([ width (fillPortion portion) ] ++ blobAttributes) <| centeredText flowBlob.label

        displayTime time =
            Clock.toShortString (HumanMoment.extractTime env.timeZone time)

        bottomPiece portion =
            el ([ width (fillPortion portion) ] ++ blobAttributes) <| centeredText ""

        middlePiece =
            el ([ width fill ] ++ blobAttributes) <|
                centeredText <|
                    "Middle"

        blobAttributes =
            [ Background.color flowBlob.color, height fill, Element.clip ]

        centeredText textToShow =
            el [ centerX, centerY ] <| Element.text textToShow
    in
    column [ width fill, height fill, clipX, Font.size 10 ] <|
        case wallsCrossed of
            [] ->
                --single row
                [ rowWithBlobThatCrossesNoWalls ]

            [ singleCrossing ] ->
                -- two rows
                [ topRow, bottomRow ]

            first :: moreCrossings ->
                [ topRow ] ++ List.repeat (List.length moreCrossings) middleRow ++ [ bottomRow ]


timeFlowLayout : ViewSettings -> Profile -> Environment -> Element Msg
timeFlowLayout vstate profile env =
    let
        allHourRowsPeriods : List Period
        allHourRowsPeriods =
            Period.divide vstate.hourRowSize vstate.flowRenderPeriod
    in
    column [ height fill, width fill, clipX ]
        (List.map (singleHourRow vstate profile env)
            allHourRowsPeriods
        )


historyBlobs env profile displayPeriod =
    let
        historyList =
            Activity.Timeline.switchListLiveToPeriods env.time profile.timeline

        activities =
            Activity.allActivities profile.activities
    in
    List.map (makeHistoryBlob env activities)
        (List.takeWhile
            (\( _, _, m ) -> Period.contains displayPeriod m)
            historyList
        )


singleHourRow : ViewSettings -> Profile -> Environment -> Period -> Element Msg
singleHourRow state profile env rowPeriod =
    row [ width fill, height (px state.rowHeight) ]
        [ timeLabelSidebar state profile env rowPeriod
        , hourRowContents state profile env rowPeriod
        ]


timeLabelSidebar : ViewSettings -> Profile -> Environment -> Period -> Element Msg
timeLabelSidebar state profile env rowPeriod =
    let
        startZone =
            Profile.userTimeZoneAtMoment profile env startMoment

        startMoment =
            Period.start rowPeriod

        startMomentAsTimeOfDay =
            HumanMoment.extractTime startZone startMoment

        usingTwelveHourClock =
            --TODO derive from user settings
            True

        timeOfDayString =
            case usingTwelveHourClock of
                True ->
                    Clock.toShortString startMomentAsTimeOfDay

                -- String.fromInt (Clock.hourOf12Raw startMomentAsTimeOfDay) ++ ":" ++ String.fromInt (Clock.minute startMomentAsTimeOfDay)
                False ->
                    Clock.toShortString startMomentAsTimeOfDay
    in
    column [ width (px 70), height fill, Border.color (Element.rgb 0.2 0.2 0.2), Border.width 1, Background.color (Element.rgb 0.5 0.5 0.5) ]
        [ paragraph [ centerX, centerY ] <|
            [ Element.text timeOfDayString ]
        ]


hourRowContents : ViewSettings -> Profile -> Environment -> Period -> Element Msg
hourRowContents viewSettings profile env rowPeriod =
    let
        planPillSegment minutes plan =
            el [ height fill, width (fillPortion minutes), Border.rounded 10, Background.color (Element.rgb 0.5 0.5 1) ] (Element.text plan.title)

        emptyTimeFlowSegment : Int -> Element msg
        emptyTimeFlowSegment minutes =
            el [ height fill, width (fillPortion minutes), Background.color (Element.rgb 0.7 0.7 0.7) ] (Element.text "")

        fillInTimeFlowSegment ( minutes, maybePlan ) =
            case maybePlan of
                Nothing ->
                    emptyTimeFlowSegment minutes

                Just plan ->
                    planPillSegment minutes plan

        fakePlans =
            [ ( 5, Just { title = "Shopping" } )
            , ( 20, Nothing )
            , ( 15, Just { title = "Dressing" } )
            , ( 5, Just { title = "Eating" } )
            , ( 35, Nothing )
            ]

        segmentsFromFakePlans : List (Element msg)
        segmentsFromFakePlans =
            List.map fillInTimeFlowSegment fakePlans

        testBulgingPlan =
            el [ htmlAttribute (Html.Attributes.style "z-index" "10"), height (px 400), width (fillPortion 20), Border.rounded 10, Background.color (Element.rgba 0 0 1 0.3) ] (Element.text "Bulging")

        overlayingRow =
            row [ width fill ]
                [ el [ width (fillPortion 20) ] (Element.text "")
                , el [ width (fillPortion 20) ] (Element.text "")
                ]

        demoBlob =
            { start = env.time, end = Moment.future env.time (Duration.fromMinutes 80), label = "the next 80 minutes", color = Element.rgb 0.1 0.8 0.4 }

        blobsDisplayed =
            List.filterMap displayIfStartsInThisRow ([ demoBlob ] ++ historyBlobs env profile viewSettings.flowRenderPeriod)

        displayIfStartsInThisRow blob =
            if Period.isWithin rowPeriod blob.start then
                Just (displayBlob viewSettings env blob)

            else
                Nothing
    in
    row
        [ width fill
        , height (px 0)
        , centerX
        , padding 4
        , below (row [ width fill, height fill ] blobsDisplayed)
        , alignTop
        ]
        []



--oldView : ViewSettings -> Profile -> Environment -> Html Msg
--oldView state profile env =
--    let
--        fullInstanceList =
--            instanceListNow profile env
--
--        plannedList =
--            List.concatMap Task.getFullSessions fullInstanceList
--
--        historyList =
--            Activity.Timeline.switchListLiveToPeriods env.time profile.timeline
--    in
--    case state of
--        ShowSpan newStart newFinish ->
--            let
--                ( start, finish ) =
--                    ( Maybe.withDefault env.time newStart, Maybe.withDefault env.time newFinish )
--
--                defaultChunk =
--                    { period = Period.fromStart dayStarted Duration.aDay -- today
--                    , rowLength = Duration.anHour
--                    }
--
--                dayStarted =
--                    HumanMoment.clockTurnBack Clock.midnight env.timeZone env.time
--
--                activities =
--                    Activity.allActivities profile.activities
--
--                -- TODO
--            in
--            section
--                [ id "timeline" ]
--                [ viewDay env defaultChunk activities plannedList historyList
--                , section [ css [ opacity (num 0.1) ] ]
--                    [ Html.text "Everything working well? Good."
--                    ]
--                ]


dayString : Environment -> Moment -> String
dayString env moment =
    Calendar.toStandardString (HumanMoment.extractDate env.timeZone moment)


viewDay : Environment -> ChosenDayWindow -> IntDict Activity -> List Task.FullSession -> List ( Activity.ActivityID, Period ) -> Html msg
viewDay env day activities sessionList historyList =
    let
        sessionListToday =
            List.filter (\ses -> Period.isWithin day.period (HumanMoment.fromFuzzy env.timeZone <| Tuple.first ses.session)) sessionList

        -- TODO that's the wrong place to do that
        rowPeriods =
            Period.divide day.rowLength day.period

        rowMarkers =
            List.map markRow rowPeriods

        markRow per =
            SH.node "timeline-area"
                [ SHA.classList [ ( "midnight", isMidnightRow (Period.start per) ) ] ]
                [ SH.text <| describeMoment <| Period.start per ]

        isMidnightRow rowPeriodStart =
            Clock.isMidnight (HumanMoment.extractTime env.timeZone rowPeriodStart)

        nowMarker =
            let
                markPosition =
                    List.Nonempty.head <|
                        getPositionInDay day.rowLength day.period <|
                            Period.fromStart env.time <|
                                HumanDuration.toDuration (HumanDuration.Minutes 1)

                centerMarker =
                    markPosition.left - (markPosition.width / 2)
            in
            SH.node "now-marker"
                [ SHA.css
                    [ C.top (C.pct markPosition.top)
                    , C.left (C.pct centerMarker)
                    , C.height (C.pct markPosition.height)
                    , C.width (C.pct markPosition.width)
                    ]
                ]
                []

        describeMoment mo =
            HumanMoment.extractTime env.timeZone mo |> Clock.toShortString
    in
    SH.node "day"
        [ SHA.id <| "day" ++ dayString env env.time ]
        (rowMarkers
            --++ List.map (viewHistorySession env day activities) historyList
            ++ List.map (viewPlannedSession env day activities) sessionListToday
            ++ [ nowMarker ]
        )


viewPlannedSession : Environment -> ChosenDayWindow -> IntDict Activity -> Task.FullSession -> Html msg
viewPlannedSession env day activities fullSession =
    let
        ( sessionPeriodStart, sessionPeriodLength ) =
            fullSession.session

        sessionPeriod =
            Period.fromStart (HumanMoment.fromFuzzy env.timeZone sessionPeriodStart)
                sessionPeriodLength

        sessionPositions =
            getPositionInDay day.rowLength day.period sessionPeriod

        ( ( startDate, startTime ), ( endDate, endTime ) ) =
            ( HumanMoment.humanize env.timeZone (Period.start sessionPeriod)
            , HumanMoment.humanize env.timeZone (Period.end sessionPeriod)
            )

        viewSessionSegment pos =
            SH.node "segment"
                [ SHA.title <|
                    fullSession.class.title
                        ++ "\nFrom "
                        ++ Clock.toShortString startTime
                        ++ " to "
                        ++ Clock.toShortString endTime
                        ++ " ("
                        ++ HumanDuration.abbreviatedSpaced (HumanDuration.breakdownNonzero sessionPeriodLength)
                        ++ ")"
                , SHA.css
                    [ C.top (C.pct pos.top)
                    , C.left (C.pct pos.left)
                    , C.width (C.pct pos.width)
                    , C.height (C.pct pos.height)
                    ]
                , SHA.classList
                    [ ( "past", Moment.compare env.time (Period.end sessionPeriod) /= Moment.Earlier )
                    , ( "future", Moment.compare env.time (Period.start sessionPeriod) /= Moment.Later )
                    ]
                ]
                [ SH.node "activity-icon" [] []
                , SH.label [] [ SH.text fullSession.class.title ]
                ]
    in
    SH.node "timeline-session"
        [ SHA.classList [ ( "planned", True ) ] ]
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

        rowStartOffsetFromDay =
            Duration.scale rowLength (toFloat targetRow)

        targetStartColumn =
            -- Which "column" does the session start in?
            -- Offset from the beginning of the row.
            Duration.subtract startTimeAsDayOffset rowStartOffsetFromDay

        rowEndOffsetFromDay =
            Duration.scale rowLength (toFloat (targetRow + 1))

        fitsInRow =
            Duration.compare endTimeAsDayOffset rowEndOffsetFromDay /= GT

        targetEndColumn =
            -- Which "column" does the session end in?
            -- Offset from the beginning of the row.
            if fitsInRow then
                -- session fits in this row.
                -- Offset from the beginning of the row.
                Duration.subtract endTimeAsDayOffset rowStartOffsetFromDay

            else
                rowLength

        -- TODO intersect row list with session list instead?
        targetRowPercent =
            (toFloat targetRow / toFloat rowCount) * 100

        heightPercent =
            (1 / toFloat rowCount) * 100

        targetStartColumnPercent =
            (toFloat (Duration.inMs targetStartColumn) / toFloat (Duration.inMs rowLength)) * 100

        widthPercent =
            (toFloat (Duration.inMs targetEndColumn - Duration.inMs targetStartColumn) / toFloat (Duration.inMs rowLength)) * 100

        rowEndAbsolute =
            Moment.future (Period.start day) rowEndOffsetFromDay

        restOfSession =
            Period.fromPair ( rowEndAbsolute, Period.end givenSession )

        additionalSegments =
            if fitsInRow then
                []

            else
                List.Nonempty.toList <| getPositionInDay rowLength day restOfSession

        debugMsg =
            "Row "
                ++ String.fromInt targetRow
                ++ " starts in column "
                ++ HumanDuration.withLetter (HumanDuration.inLargestWholeUnits rowStartOffsetFromDay)
                ++ ", ends in column "
                ++ HumanDuration.withLetter (HumanDuration.inLargestWholeUnits rowEndOffsetFromDay)
                ++ "\nSession Starts in column "
                ++ HumanDuration.withLetter (HumanDuration.inLargestWholeUnits targetStartColumn)
                ++ ", ends in column "
                ++ HumanDuration.withLetter (HumanDuration.inLargestWholeUnits targetEndColumn)
                ++ (if fitsInRow then
                        ""

                    else
                        ", does NOT fit.\n"
                   )
    in
    Debug.log debugMsg <|
        List.Nonempty.Nonempty
            { top = targetRowPercent
            , left = targetStartColumnPercent
            , height = heightPercent
            , width = widthPercent
            }
            additionalSegments


makeHistoryBlob : Environment -> IntDict Activity -> ( Activity.ActivityID, Maybe Task.InstanceID, Period ) -> FlowBlob
makeHistoryBlob env activities ( activityID, instanceIDMaybe, sessionPeriod ) =
    let
        -- sessionPositions =
        --     getPositionInDay day.rowLength day.period sessionPeriod
        ( ( startDate, startTime ), ( endDate, endTime ) ) =
            ( HumanMoment.humanize env.timeZone (Period.start sessionPeriod)
            , HumanMoment.humanize env.timeZone (Period.end sessionPeriod)
            )

        viewSessionSegment pos =
            SH.node "segment"
                [ SHA.title <|
                    "\nFrom "
                        ++ Clock.toShortString startTime
                        ++ " to "
                        ++ Clock.toShortString endTime
                        ++ " ("
                        ++ HumanDuration.abbreviatedSpaced (HumanDuration.breakdownNonzero (Period.length sessionPeriod))
                        ++ ")"
                , SHA.css
                    [ C.top (C.pct pos.top)
                    , C.left (C.pct pos.left)
                    , C.width (C.pct pos.width)
                    , C.height (C.pct pos.height)
                    , C.backgroundColor <| C.hsla (activityHue * 360) 0.5 0.5 0.5
                    ]
                , SHA.classList
                    [ ( "past", Moment.compare env.time (Period.end sessionPeriod) /= Moment.Earlier )
                    , ( "future", Moment.compare env.time (Period.start sessionPeriod) /= Moment.Later )
                    ]
                ]
                [ SH.node "activity-icon" [] [ activityIcon ]
                , SH.label [] [ SH.text activityName ]
                ]

        sessionActivity =
            getActivity activityID activities

        activityName =
            Maybe.withDefault "Unnamed Activity" <| List.head sessionActivity.names

        activityIcon =
            case sessionActivity.icon of
                File svgPath ->
                    SH.img
                        [ SHA.class "activity-icon"
                        , SHA.src ("media/icons/" ++ svgPath)
                        ]
                        []

                Emoji singleEmoji ->
                    SH.text singleEmoji

                _ ->
                    SH.text "⚪"

        activityHue =
            toFloat (ID.read activityID) / toFloat (IntDict.size activities)

        activityColor =
            elementColor
                { hue = activityHue
                , saturation = 1
                , lightness = 0.5
                , alpha = 0.5
                }
    in
    FlowBlob (Period.start sessionPeriod) (Period.end sessionPeriod) activityColor activityName


blockBrokenCoord coord =
    if isInfinite coord || isNaN coord then
        0

    else
        coord



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = ChangeTimeWindow Moment Moment
    | WidgetMsg WidgetID Widget.Msg
    | PointerMove ( Float, Float )


type alias Pointer =
    { x : Float
    , y : Float
    }


update : Msg -> ViewState -> Profile -> Environment -> ( ViewState, Profile, Cmd Msg )
update msg state profile env =
    case Debug.log "timeflow update" msg of
        ChangeTimeWindow newStart newFinish ->
            let
                withoutNewPeriodToRender =
                    updateViewSettings profile env

                withNewPeriodToRender =
                    { withoutNewPeriodToRender | flowRenderPeriod = Period.fromPair ( newStart, newFinish ) }
            in
            ( { state | settings = withNewPeriodToRender }, profile, Cmd.none )

        WidgetMsg widgetID widgetMsg ->
            case Dict.get widgetID state.widgets of
                Nothing ->
                    Debug.todo "Tried to update a widget that has no stored state"

                Just ( oldWidgetState, widgetInitCmd ) ->
                    let
                        ( newWidgetState, widgetOutCmds ) =
                            Widget.update widgetMsg oldWidgetState

                        newWidgetDict =
                            Dict.insert widgetID ( newWidgetState, widgetInitCmd ) state.widgets
                    in
                    ( { state | widgets = newWidgetDict }
                    , profile
                    , Cmd.map (WidgetMsg widgetID) widgetOutCmds
                    )

        PointerMove ( x, y ) ->
            let
                oldPointer =
                    state.pointer

                newPointer =
                    { oldPointer | x = blockBrokenCoord x, y = blockBrokenCoord y }
            in
            ( { state | pointer = newPointer }, profile, Cmd.none )


subscriptions : Profile -> Environment -> Maybe ViewState -> Sub Msg
subscriptions profile env maybeVState =
    let
        vState =
            Maybe.withDefault (defaultState profile env) maybeVState
    in
    Sub.batch <| List.map (\id -> Sub.map (WidgetMsg id) Widget.subscriptions) (Dict.keys vState.widgets)
