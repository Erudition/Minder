module Timeflow exposing (Msg(..), ViewState, init, resizeCmd, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Activity.HistorySession as HistorySession exposing (HistorySession)
import Browser.Dom as Dom
import Color exposing (Color)
import Date
import Dict exposing (Dict)
import Dict.Extra as Dict
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import External.Commands as Commands
import GraphicSVG exposing (..)
import GraphicSVG.Widget as Widget
import HSLuv exposing (HSLuv, hsluv)
import Helpers exposing (..)
import Html as H
import Html.Attributes as HA
import Html.Events.Extra.Wheel
import Html.Styled as SH
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import List.Extra as List
import Log
import OldShared.Model exposing (..)
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (ChangeSet, Frame)
import Replicated.Op.ID as OpID exposing (OpID)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate, equal)
import SmartTime.Human.Calendar.Week as Week
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.Assignment as Assignment exposing (Assignment)
import Task.Layers exposing (ProjectLayers)
import Task.Progress exposing (..)
import Task.ProjectSkel as Project
import TimeTrackable exposing (TimeTrackable)
import Url.Parser as P exposing ((</>), Parser)
import VirtualDom
import ZoneHistory



--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL


type alias Point =
    ( Float, Float )


type alias Polygon =
    List Point


type alias FlowBlob =
    { start : Moment
    , end : Moment
    , color : Color.Color
    , label : String
    , id : String
    }


type DraggingStatus
    = DraggingStarted { id : String, start : Point, current : Point }



--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type alias ViewState =
    { settings : ViewSettings
    , widgetState : Widget.Model
    , widgetInit : Cmd Widget.Msg
    , pointer : Pointer
    , dragging : Maybe DraggingStatus
    }


type alias WidgetID =
    String


type alias ViewSettings =
    { flowRenderPeriod : Period
    , hourRowSize : Duration
    , pivotMoment : Moment
    , rowHeight : Int
    , rows : Int
    , widgetWidth : Float
    , widgetHeight : Float
    }


updateViewSettings : Profile -> Shared -> ViewSettings
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

        chosenPeriod =
            today

        chosenDayCutoffTime =
            -- will be derived from profile settings
            HumanDuration.build [ HumanDuration.Hours 3 ]

        timePerRow =
            Duration.fromMinutes 60

        rowHeight =
            30

        rowCount =
            List.length (Period.divide timePerRow chosenPeriod)
    in
    { flowRenderPeriod = chosenPeriod
    , hourRowSize = timePerRow
    , pivotMoment = HumanMoment.clockTurnBack chosenDayCutoffTime env.timeZone env.time
    , rowHeight = rowHeight
    , rows = rowCount - 1
    , widgetHeight = 1000
    , widgetWidth = 1000
    }


init : Profile -> Shared -> ( ViewState, Cmd Msg )
init profile environment =
    let
        ( widget1state, widget1init ) =
            Widget.init initialSettings.widgetWidth initialWidgetHeight "0"

        initialSettings =
            updateViewSettings profile environment

        initialWidgetHeight =
            initialSettings.widgetHeight
    in
    ( { settings = initialSettings
      , widgetState = widget1state
      , widgetInit = widget1init
      , pointer = { x = 0.0, y = 0.0 }
      , dragging = Nothing
      }
    , Cmd.batch [ resizeCmd ]
    )


routeView : Parser (Maybe ViewState -> a) a
routeView =
    P.map Nothing (P.s "timeflow")


view : ViewState -> Profile -> Shared -> SH.Html Msg
view vState profile env =
    let
        projectLayers =
            Task.Layers.buildLayerDatabase profile.projects
    in
    SH.fromUnstyled <|
        layout [ width fill, height fill ] <|
            column [ width fill, height fill ]
                [ row [ width fill, height (px 30), Background.color (Element.rgb 0.5 0.5 0.5) ]
                    [ el [ centerX ] <| Element.text <| Calendar.toStandardString <| HumanMoment.extractDate env.timeZone env.time ]
                , row
                    [ width fill, height fill, htmlAttribute (HA.style "touch-action" "none"), htmlAttribute (HA.id "timeflow-container"), clipY, htmlAttribute (Html.Events.Extra.Wheel.onWheel Wheel) ]
                    [ Element.html <| svgExperiment vState profile projectLayers env ]
                , row [ width fill, height (px 30), Background.color (Element.rgb 0.5 0.5 0.5) ]
                    [ el [ centerX ] <|
                        Element.text
                            (multiline
                                [ [ "Showing"
                                  , Period.length vState.settings.flowRenderPeriod
                                        |> HumanDuration.breakdownDH
                                        |> HumanDuration.trim
                                        |> HumanDuration.abbreviatedSpaced
                                  , "(from"
                                  , Period.start vState.settings.flowRenderPeriod
                                        |> HumanMoment.describeVsNow env.timeZone env.time
                                  , "through"
                                  , Period.end vState.settings.flowRenderPeriod
                                        |> HumanMoment.describeVsNow env.timeZone env.time
                                  , ")"
                                  ]
                                ]
                            )
                    ]
                ]



-- svgExperiment : ViewState -> Profile -> Shared -> ( widgetID, ( widgetState, widgetInitCmd ) )


svgExperiment state profile projectLayers env =
    Widget.view
        state.widgetState
        [ graphPaperCustom 100 0.03 (GraphicSVG.rgb 20 20 20)
        , group (allShapes state profile projectLayers env)
            |> move ( 0, state.settings.widgetHeight / 2 )
            |> notifyMouseMoveAt PointerMove
            |> notifyTouchMoveAt PointerMove
            |> notifyMouseUp MouseUp
            |> notifyTouchEnd MouseUp
        ]


allShapes state profile projectLayers env =
    let
        boxHeight =
            toFloat <| List.length (Period.divide state.settings.hourRowSize state.settings.flowRenderPeriod) * state.settings.rowHeight

        hourOfDayAsPortion hour =
            ((hour - 3) / 24) * state.settings.widgetHeight
    in
    [ rect state.settings.widgetWidth boxHeight
        |> filled
            (rotateGradient (turns 0.75) <|
                gradient
                    [ stop black 0
                    , stop grey (hourOfDayAsPortion 6)
                    , stop white (hourOfDayAsPortion 12)
                    , stop grey (hourOfDayAsPortion 15)
                    , stop black (hourOfDayAsPortion 21)
                    ]
            )
        |> makeTransparent 0.5
        |> move ( 0, -boxHeight / 2 )

    -- , polygon
    --    demoPolygonPoints
    --    |> filled blue
    --    |> move ( -50, 0 )
    --    |> notifyMouseMoveAt PointerMove
    -- , roundedPolygon 2 demoPolygonPoints
    --    |> filled green
    --    |> move ( -50, 0 )
    --    |> notifyMouseMoveAt PointerMove
    -- , circle 1
    --    |> filled blue
    --    |> move ( state.pointer.x / 4, state.pointer.y / 4 )
    --    |> notifyMouseMoveAt PointerMove
    ]
        ++ List.map (blobToShape state env) (historyBlobs env profile projectLayers state.settings.flowRenderPeriod)
        ++ [ timeLabel env state.settings.pivotMoment ]


timeLabel : Shared -> Moment -> Shape msg
timeLabel env stampMoment =
    GraphicSVG.text (HumanMoment.describeVsNow env.timeZone env.time stampMoment)
        |> fixedwidth
        |> size 16
        |> centered
        |> filled red
        |> move ( 0, -16 )


distanceBetweenPoints : Point -> Point -> Float
distanceBetweenPoints ( x1, y1 ) ( x2, y2 ) =
    sqrt ((x2 - x1) ^ 2 + (y2 - y1) ^ 2)


{-| Given a list of points, returns a Stencil shape that represents the
polygon but with rounded corners. To do this, we need to extend the
polygon by two points, and then generate the rounded corners.
-}
roundedPolygon : Float -> Polygon -> Stencil
roundedPolygon radii cornerList =
    let
        allThePoints =
            cornerList
                -- Extend list by two points to close the polygon
                |> List.cycle (List.length cornerList + 2)
                |> Helpers.cycleGroupWithStep 3 1
                |> List.map (\e -> Maybe.withDefault ( ( 0, 0 ), ( 0, 0 ), ( 0, 0 ) ) <| Helpers.listToTuple3 e)
                |> List.map (\( a, b, c ) -> roundCorner radii a b c)
                |> List.concat

        pullerList =
            allThePoints
                |> List.greedyGroupsOf 2
                |> List.map
                    (\list ->
                        case list of
                            [ a, b ] ->
                                GraphicSVG.Pull a b

                            _ ->
                                GraphicSVG.Pull ( 0, 0 ) ( 0, 0 )
                                    |> Log.crashInDev "This should never happen"
                    )
    in
    curve
        (Maybe.withDefault ( 0, 0 ) <| List.head allThePoints)
        pullerList


{-| roundedCorner is a simple function that takes a radius and 3 points.
It returns a new list of points that represents a rounded corner.
Todo this, we need to return 4 points, where the first and third points
are the 'control points', and the second and fourth points are normal points.
-}
roundCorner : Float -> Point -> Point -> Point -> Polygon
roundCorner radii ( startX, startY ) ( middleX, middleY ) ( endX, endY ) =
    let
        midPoint =
            ( (startX + middleX) / 2, (startY + middleY) / 2 )

        controlPoint =
            ( middleX, middleY )

        -- The angle between the vector and a horizontal line from 0,0
        -- TODO: Consider if 'atan2 (middleY - middleY) (middleX - (middleX + 1))' should be replaced with 'pi'
        basis1 =
            atan2 (middleY - startY) (middleX - startX) - atan2 (middleY - middleY) (middleX - (middleX + 1))

        basis2 =
            atan2 (middleY - endY) (middleX - endX) - atan2 (middleY - middleY) (middleX - (middleX + 1))

        -- The angle between the vectors
        -- angleRad =
        --     -- Debug.log "angleRad" <|
        --     atan2 (middleY - endY) (middleX - endX)
        --         - atan2 (middleY - startY) (middleX - startX)
        minRadii =
            min radii <|
                min (distanceBetweenPoints ( startX, startY ) ( middleX, middleY ) / 2)
                    (distanceBetweenPoints ( endX, endY ) ( middleX, middleY ) / 2)

        x1 =
            minRadii * cos basis1

        y1 =
            minRadii * sin basis1

        x2 =
            minRadii * cos basis2

        y2 =
            minRadii * sin basis2

        firstPoint =
            ( middleX + x1, middleY + y1 )

        secondPoint =
            ( middleX + x2, middleY + y2 )
    in
    [ midPoint, firstPoint, controlPoint, secondPoint ]


blobToShape : ViewState -> Shared -> FlowBlob -> Shape Msg
blobToShape display env initialBlob =
    let
        ( blob, isDraggingMe ) =
            case display.dragging of
                Nothing ->
                    ( initialBlob, False )

                Just (DraggingStarted { id, start }) ->
                    if id /= initialBlob.id then
                        ( initialBlob, False )

                    else
                        let
                            defaultPlacement =
                                blobToPoints display.settings env initialBlob

                            displacedBlob =
                                { initialBlob
                                    | start = Moment.future initialBlob.start offset
                                    , end = Moment.future initialBlob.end offset
                                }

                            offset =
                                dragOffsetDur display defaultPlacement.midHeight defaultPlacement.reversed start
                        in
                        -- this blob is being dragged, change period
                        ( displacedBlob
                        , True
                        )

        isCurrentlyTracking =
            blob.end == env.time

        pointsOfInterest =
            blobToPoints display.settings env blob

        midPoint ( ( x1, y1 ), ( x2, y2 ) ) =
            ( (x1 + x2) / 2, (y1 + y2) / 2 )

        textSize =
            if textAreaW < 10 then
                toFloat display.settings.rowHeight / 4

            else if textAreaW < 40 then
                toFloat display.settings.rowHeight / 3

            else
                toFloat display.settings.rowHeight / 2

        textAreaW =
            (Tuple.first <| Tuple.second <| pointsOfInterest.bestTextArea)
                - (Tuple.first <| Tuple.first <| pointsOfInterest.bestTextArea)

        textAreaH =
            abs
                ((Tuple.second <| Tuple.second <| pointsOfInterest.bestTextArea)
                    - (Tuple.second <| Tuple.first <| pointsOfInterest.bestTextArea)
                )

        textAreaVisualizer =
            roundedRect textAreaW textAreaH 0.5
                |> filled black
                |> makeTransparent 0.3
                |> move textAreaMidpoint

        textAreaMidpoint =
            midPoint pointsOfInterest.bestTextArea

        theShell =
            roundedPolygon 7 pointsOfInterest.shell

        rotateIfSquished shape =
            if textAreaW > toFloat display.settings.rowHeight then
                shape

            else
                shape
                    |> GraphicSVG.rotate (degrees -90)
                    |> GraphicSVG.scale 0.5

        capLabel moment =
            group
                [ HumanMoment.extractTime env.timeZone moment
                    |> Clock.hour
                    |> Clock.padInt
                    |> GraphicSVG.text
                    |> size 0.7
                    |> filled black
                    |> move ( 0, 0 )
                , HumanMoment.extractTime env.timeZone moment
                    |> Clock.hour
                    |> Clock.padInt
                    |> GraphicSVG.text
                    |> size 0.7
                    |> filled black
                    |> move ( 0, -0.6 )
                ]
                |> makeTransparent 0.8

        ifBigEnoughForCaps keepShape =
            if textAreaW > 7 then
                Just keepShape

            else
                Nothing

        outlineColor =
            if isDraggingMe then
                GraphicSVG.rgba 255 255 255 1

            else if isCurrentlyTracking then
                GraphicSVG.rgba 0 255 0 0.55

            else
                GraphicSVG.rgba 255 255 255 0.4

        outlineThickness =
            if isDraggingMe then
                7

            else
                2

        outlineStyle =
            if isCurrentlyTracking then
                GraphicSVG.dashed outlineThickness

            else
                GraphicSVG.solid outlineThickness

        clipMask =
            ghost theShell
    in
    group
        (List.filterMap identity <|
            [ theShell
                |> filled (graphColor blob.color)
                -- TODO: Consider flipping to black when blobs are old
                |> addOutline outlineStyle outlineColor
                |> Just
            , capLabel blob.start
                |> move pointsOfInterest.startCapTL
                |> move ( 0.5, toFloat -display.settings.rowHeight / 2 )
                |> ifBigEnoughForCaps
            , capLabel blob.end
                |> move pointsOfInterest.endCapTL
                |> move ( 0.5, toFloat -display.settings.rowHeight / 2 )
                |> ifBigEnoughForCaps
            , GraphicSVG.text blob.label
                |> size textSize
                |> sansserif
                |> centered
                |> filled black
                |> rotateIfSquished
                |> move (midPoint pointsOfInterest.bestTextArea)
                |> move ( 0, -textSize / 2 )
                |> GraphicSVG.clip clipMask
                -- must be last
                |> Just
            ]
        )
        |> move ( display.settings.widgetWidth / -2, 0 )
        |> notifyMouseDownAt (MouseDownAt blob.id)
        |> notifyTouchStartAt (MouseDownAt blob.id)


blobToPoints : ViewSettings -> Shared -> FlowBlob -> { shell : Polygon, bestTextArea : ( Point, Point ), startCapTL : Point, endCapTL : Point, midHeight : Float, reversed : ( Bool, Bool ) }
blobToPoints displaySettings _ blob =
    let
        msBetweenWalls =
            Duration.inMs displaySettings.hourRowSize

        startMs =
            Duration.subtract
                (Moment.toDuration blob.start Moment.y2k)
                (Moment.toDuration displaySettings.pivotMoment Moment.y2k)
                |> Duration.inMs

        offsetFromPriorWall ms =
            -- TODO for negatives: mod or remainder
            modBy msBetweenWalls ms

        distanceToNextWall ms =
            msBetweenWalls - offsetFromPriorWall ms

        endMs =
            Duration.subtract
                (Moment.toDuration blob.end Moment.y2k)
                (Moment.toDuration displaySettings.pivotMoment Moment.y2k)
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

        starting =
            toFloat (offsetFromPriorWall startMs) / toFloat msBetweenWalls

        ending =
            toFloat (offsetFromPriorWall endMs) / toFloat msBetweenWalls

        reverseMaybe shouldReverse elements =
            if shouldReverse then
                List.reverse elements

            else
                elements

        firstRowStartWall =
            startMs - offsetFromPriorWall startMs

        lastRowStartWall =
            endMs - offsetFromPriorWall endMs

        startsOnWall =
            offsetFromPriorWall startMs == 0

        rowHeight =
            toFloat displaySettings.rowHeight

        startHeight =
            0 - toFloat (rowNumber firstRowStartWall) * rowHeight

        endHeight =
            0 - toFloat (rowNumber (lastRowStartWall + 1)) * rowHeight

        midHeight =
            -- for calculating which end is closer to pointer
            startHeight

        rowNumber wall =
            wall // msBetweenWalls

        isOddRow startWall =
            modBy 2 (rowNumber startWall) == 1

        arrowOffset =
            5

        clampWithOffset x =
            clampWidth <| x + arrowOffset

        clampWithOffsetNeg x =
            clampWidth <| x - arrowOffset

        clampWidth x =
            clamp 0 widgetWidth x

        widgetWidth =
            displaySettings.widgetWidth

        singleRowBlob =
            -- all Points are in clockwise order, starting with the top left point or the one before it
            if isOddRow firstRowStartWall then
                -- RTL row
                { shell =
                    [ ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - rowHeight )
                    , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - (rowHeight / 2) )
                    , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight )
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                    , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (rowHeight / 2) )
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - rowHeight )
                    ]
                , bestTextArea =
                    ( ( widgetWidth - ending * widgetWidth, startHeight )
                    , ( widgetWidth - starting * widgetWidth, startHeight - rowHeight )
                    )
                , startCapTL = ( (widgetWidth - starting * widgetWidth) - rowHeight, startHeight )
                , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight )
                , midHeight = midHeight
                , reversed = ( True, True )
                }

            else
                -- LTR row
                { shell =
                    [ ( clampWidth (starting * widgetWidth), startHeight - rowHeight )
                    , ( clampWithOffset (starting * widgetWidth), startHeight - (rowHeight / 2) )
                    , ( clampWidth (starting * widgetWidth), startHeight )
                    , ( clampWidth (ending * widgetWidth), startHeight )
                    , ( clampWithOffset (ending * widgetWidth), startHeight - (rowHeight / 2) )
                    , ( clampWidth (ending * widgetWidth), startHeight - rowHeight )
                    ]
                , bestTextArea =
                    ( ( clampWidth <| (starting * widgetWidth), startHeight )
                    , ( clampWidth <| (ending * widgetWidth), startHeight - rowHeight )
                    )
                , startCapTL = ( starting * widgetWidth, startHeight )
                , endCapTL = ( (ending * widgetWidth) - rowHeight, startHeight )
                , midHeight = midHeight
                , reversed = ( False, False )
                }

        twoRowBlob =
            if isOddRow firstRowStartWall then
                -- RTL row
                { shell =
                    -- share left wall
                    [ ( 0, startHeight - (2 * rowHeight) )
                    , ( 0, startHeight )

                    -- starting side, RTL row
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                    , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (rowHeight / 2) )
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - rowHeight )

                    -- ending side, LTR row
                    , ( clampWidth (ending * widgetWidth), startHeight - rowHeight )
                    , ( clampWithOffset (ending * widgetWidth), startHeight - (1.5 * rowHeight) )
                    , ( clampWidth (ending * widgetWidth), startHeight - (2 * rowHeight) )
                    ]
                , bestTextArea =
                    -- no slash on left side shared wall
                    if (1 - starting) >= ending then
                        ( ( 0, startHeight )
                        , ( clampWidth <| (widgetWidth - starting * widgetWidth), startHeight - rowHeight )
                        )

                    else
                        ( ( 0, startHeight - rowHeight )
                        , ( clampWidth <| (ending * widgetWidth), startHeight - (2 * rowHeight) )
                        )
                , startCapTL = ( (widgetWidth - starting * widgetWidth) - rowHeight, startHeight )
                , endCapTL = ( (ending * widgetWidth) - rowHeight, startHeight - rowHeight )
                , midHeight = midHeight
                , reversed = ( True, False )
                }

            else
                { shell =
                    [ ( clampWidth (starting * widgetWidth), startHeight - rowHeight )
                    , ( clampWithOffset (starting * widgetWidth), startHeight - (rowHeight / 2) )
                    , ( clampWidth (starting * widgetWidth), startHeight )

                    --
                    , ( widgetWidth, startHeight )
                    , ( widgetWidth, startHeight - (2 * rowHeight) )

                    -- RTL row
                    , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - (2 * rowHeight) )
                    , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - (1.5 * rowHeight) )
                    , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - rowHeight )
                    ]
                , bestTextArea =
                    -- no slash on right side shared wall
                    if (1 - starting) >= ending then
                        -- use top piece, there's more room
                        ( ( clampWidth <| (starting * widgetWidth), startHeight )
                        , ( widgetWidth, startHeight - rowHeight )
                        )

                    else
                        -- use bottom piece, there's more room
                        ( ( clampWidth <| (widgetWidth - ending * widgetWidth), startHeight - rowHeight )
                        , ( widgetWidth, startHeight - (2 * rowHeight) )
                        )
                , startCapTL = ( starting * widgetWidth, startHeight )
                , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight - rowHeight )
                , midHeight = midHeight
                , reversed = ( False, True )
                }

        sandwichBlob middlePieces =
            case ( isOddRow firstRowStartWall, isOddRow lastRowStartWall ) of
                -- top row is LTR, bottom is RTL
                ( False, True ) ->
                    { shell =
                        -- start-side, LTR
                        [ ( clampWidth (starting * widgetWidth), startHeight - rowHeight )
                        , ( clampWithOffset (starting * widgetWidth), startHeight - (rowHeight / 2) )
                        , ( clampWidth (starting * widgetWidth), startHeight )

                        -- right wall
                        , ( widgetWidth, startHeight )
                        , ( widgetWidth, startHeight - ((2 + middlePieces) * rowHeight) )

                        -- end-side, RTL
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - ((middlePieces + 2) * rowHeight) )
                        , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - ((middlePieces + 1.5) * rowHeight) )
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - ((middlePieces + 1) * rowHeight) )

                        -- left wall
                        , ( 0, startHeight - ((1 + middlePieces) * rowHeight) )
                        , ( 0, startHeight - rowHeight )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - rowHeight ), ( widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) ) )
                    , startCapTL = ( starting * widgetWidth, startHeight )
                    , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) )
                    , midHeight = midHeight
                    , reversed = ( False, True )
                    }

                -- top row is RTL, bottom is LTR
                ( True, False ) ->
                    { shell =
                        -- left wall
                        [ ( 0, startHeight - ((2 + middlePieces) * rowHeight) )
                        , ( 0, startHeight )

                        -- start-side, RTL
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                        , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (rowHeight / 2) )
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - rowHeight )

                        -- right wall
                        , ( widgetWidth, startHeight - rowHeight )
                        , ( widgetWidth, startHeight - (rowHeight * (middlePieces + 1)) )

                        -- end-side, LTR
                        , ( clampWidth (ending * widgetWidth), startHeight - (rowHeight * (middlePieces + 1)) )
                        , ( clampWithOffset (ending * widgetWidth), startHeight - (rowHeight * (middlePieces + 1.5)) )
                        , ( clampWidth (ending * widgetWidth), startHeight - (rowHeight * (middlePieces + 2)) )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - rowHeight ), ( widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) ) )
                    , startCapTL = ( (widgetWidth - starting * widgetWidth) - rowHeight, startHeight )
                    , endCapTL = ( (ending * widgetWidth) - rowHeight, startHeight - ((1 + middlePieces) * rowHeight) )
                    , midHeight = midHeight
                    , reversed = ( True, False )
                    }

                -- top row is LTR, bottom is LTR
                ( False, False ) ->
                    { shell =
                        -- start-side, LTR
                        [ ( clampWidth (starting * widgetWidth), startHeight - rowHeight )
                        , ( clampWithOffset (starting * widgetWidth), startHeight - (rowHeight / 2) )
                        , ( clampWidth (starting * widgetWidth), startHeight )

                        -- right wall
                        , ( widgetWidth, startHeight )
                        , ( widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) )

                        -- end-side, also LTR
                        , ( clampWidth (ending * widgetWidth), startHeight - ((middlePieces + 1) * rowHeight) )
                        , ( clampWithOffset (ending * widgetWidth), startHeight - ((middlePieces + 1.5) * rowHeight) )
                        , ( clampWidth (ending * widgetWidth), startHeight - ((middlePieces + 2) * rowHeight) )

                        -- left wall
                        , ( 0, startHeight - ((2 + middlePieces) * rowHeight) )
                        , ( 0, startHeight - rowHeight )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - rowHeight ), ( widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) ) )
                    , startCapTL = ( starting * widgetWidth, startHeight )
                    , endCapTL = ( (ending * widgetWidth) - rowHeight, startHeight - ((1 + middlePieces) * rowHeight) )
                    , midHeight = midHeight
                    , reversed = ( False, False )
                    }

                -- top row is RTL, bottom is RTL
                ( True, True ) ->
                    { shell =
                        -- left wall
                        [ ( 0, startHeight - ((1 + middlePieces) * rowHeight) )
                        , ( 0, startHeight )

                        -- start-side, RTL
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                        , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (rowHeight / 2) )
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - rowHeight )

                        -- right wall
                        , ( widgetWidth, startHeight - rowHeight )
                        , ( widgetWidth, startHeight - (rowHeight * (middlePieces + 2)) )

                        -- end-side, also RTL
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - (rowHeight * (middlePieces + 2)) )
                        , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - (rowHeight * (middlePieces + 1.5)) )
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - (rowHeight * (middlePieces + 1)) )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - rowHeight ), ( widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) ) )
                    , startCapTL = ( (widgetWidth - starting * widgetWidth) - rowHeight, startHeight )
                    , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight - ((1 + middlePieces) * rowHeight) )
                    , midHeight = midHeight
                    , reversed = ( True, True )
                    }
    in
    case List.length wallsCrossed of
        0 ->
            singleRowBlob

        1 ->
            twoRowBlob

        x ->
            sandwichBlob (toFloat x - 1)


historyBlobs : Shared -> Profile -> ProjectLayers -> Period -> List FlowBlob
historyBlobs env profile projectLayers displayPeriod =
    let
        historyList =
            RepList.listValues profile.timeline
    in
    List.map (makeHistoryBlob env profile projectLayers displayPeriod)
        (List.filter
            (\sesh -> Period.haveOverlap displayPeriod (HistorySession.getPeriodWithDefaultEnd env.time sesh))
            historyList
        )


{-| How much a blob moves (in time) while being dragged.
-}
dragOffsetDur : ViewState -> Float -> ( Bool, Bool ) -> Point -> Duration
dragOffsetDur display midBlobHeight ( topReversed, bottomReversed ) ( startX, startY ) =
    let
        startYInBlobCoordinates =
            toFloat display.settings.rowHeight * (startY - (display.settings.widgetHeight / 2))

        shouldReverse =
            if startYInBlobCoordinates > midBlobHeight then
                -- Debug.log
                --     ("start.y "
                --         ++ String.fromFloat startYInBlobCoordinates
                --         ++ " is above midheight "
                --         ++ String.fromFloat midBlobHeight
                --         ++ ". Reverse:"
                --     )
                topReversed

            else
                -- Debug.log
                --     ("start.y "
                --         ++ String.fromFloat startYInBlobCoordinates
                --         ++ " is BELOW midheight "
                --         ++ String.fromFloat midBlobHeight
                --         ++ ". Reverse:"
                --     )
                -- TODO bottomReversed
                topReversed

        xOffset =
            if shouldReverse then
                display.pointer.x - startX

            else
                startX - display.pointer.x

        yOffset =
            startY - display.pointer.y

        yOffsetInDoubleRows =
            yOffset / doubleRowHeightInMouseCoords

        yOffsetInDoubleRowsRounded =
            (round yOffsetInDoubleRows * 2) |> toFloat

        doubleRowHeightInMouseCoords =
            toFloat display.settings.rowHeight * 2

        xOffsetAsPortion =
            xOffset / display.settings.widgetWidth
    in
    Duration.scale display.settings.hourRowSize (yOffsetInDoubleRowsRounded - xOffsetAsPortion)


timeLabelSidebar : ViewSettings -> Profile -> ( Moment, HumanMoment.Zone ) -> Period -> Element Msg
timeLabelSidebar state profile ( time, timeZone ) rowPeriod =
    let
        startZone =
            Profile.userTimeZoneAtMoment profile ( time, timeZone ) startMoment

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
    column
        [ width (px 70)
        , height fill
        , Border.color (Element.rgb 0.2 0.2 0.2)
        , Border.width 1
        , Background.color (Element.rgb 0.5 0.5 0.5)
        ]
        [ paragraph [ centerX, centerY ]
            [ Element.text timeOfDayString ]
        ]


dayString : Shared -> Moment -> String
dayString env moment =
    Calendar.toStandardString (HumanMoment.extractDate env.timeZone moment)


makeHistoryBlob : Shared -> Profile -> ProjectLayers -> Period -> HistorySession -> FlowBlob
makeHistoryBlob env profile projectLayers displayPeriod session =
    let
        sessionPeriod =
            HistorySession.getPeriodWithDefaultEnd env.time session

        -- sessionPositions =
        --     getPositionInDay day.rowLength day.period sessionPeriod
        ( ( startDate, startTime ), ( endDate, endTime ) ) =
            ( HumanMoment.humanize env.timeZone (Period.start sessionPeriod)
            , HumanMoment.humanize env.timeZone (Period.end sessionPeriod)
            )

        describeTiming =
            (sessionPeriod
                |> Period.length
                |> Duration.inMinutes
                |> round
                |> String.fromInt
            )
                ++ "m "
                ++ activityIcon
                ++ Maybe.withDefault activityName sessionProjectName

        sessionActivity =
            Activity.getByID (HistorySession.getActivityID session) profile.activities

        sessionProjectMaybe =
            Maybe.andThen (Task.Layers.getAssignmentByID projectLayers) (TimeTrackable.getAssignmentID session.tracked)

        sessionProjectName =
            -- TODO
            Maybe.map Assignment.title sessionProjectMaybe

        activityName =
            Activity.getName sessionActivity

        activityIcon =
            case Activity.getIcon sessionActivity of
                File svgPath ->
                    ""

                Emoji singleEmoji ->
                    singleEmoji

                _ ->
                    "⚪"

        activityHue =
            toFloat (String.length (Activity.getName sessionActivity)) / 10

        activityColor =
            hsluv
                { hue = activityHue
                , saturation = 1
                , lightness = 0.5
                , alpha = 0.8
                }
                |> HSLuv.toColor

        croppedSessionPeriod =
            Period.crop displayPeriod sessionPeriod

        stringID =
            HumanMoment.toStandardString (Period.start sessionPeriod)
    in
    FlowBlob
        (Period.start croppedSessionPeriod)
        (Period.end croppedSessionPeriod)
        activityColor
        describeTiming
        stringID


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
    | WidgetMsg Widget.Msg
    | PointerMove ( Float, Float )
    | MouseDownAt String ( Float, Float )
    | MouseUp
    | ResetCoordinates Float Float
    | Wheel Html.Events.Extra.Wheel.Event


type alias Pointer =
    { x : Float
    , y : Float
    }


update : Msg -> Maybe ViewState -> Profile -> Shared -> ( Frame, ViewState, Cmd Msg )
update msg stateMaybe profile env =
    case stateMaybe of
        Just state ->
            case msg of
                ChangeTimeWindow newStart newFinish ->
                    let
                        withoutNewPeriodToRender =
                            updateViewSettings profile env

                        withNewPeriodToRender =
                            { withoutNewPeriodToRender | flowRenderPeriod = Period.fromPair ( newStart, newFinish ) }
                    in
                    ( Change.emptyFrame, { state | settings = withNewPeriodToRender }, Cmd.none )

                Wheel wheelEvent ->
                    let
                        oldSettings =
                            state.settings

                        forwardOrBack =
                            if wheelEvent.deltaY > 0 then
                                2

                            else
                                -2

                        shiftMoment oldMoment =
                            Moment.future oldMoment (Duration.scale state.settings.hourRowSize forwardOrBack)

                        ( oldStart, oldFinish ) =
                            Period.toPair oldSettings.flowRenderPeriod

                        newSettings =
                            { oldSettings | flowRenderPeriod = Period.fromPair ( shiftMoment oldStart, shiftMoment oldFinish ), pivotMoment = shiftMoment oldSettings.pivotMoment }
                    in
                    ( Change.emptyFrame, { state | settings = newSettings }, Cmd.none )

                WidgetMsg widgetMsg ->
                    let
                        ( newWidgetState, widgetOutCmds ) =
                            Widget.update widgetMsg state.widgetState
                    in
                    ( Change.emptyFrame
                    , { state | widgetState = newWidgetState }
                    , Cmd.map WidgetMsg widgetOutCmds
                    )

                PointerMove ( x, y ) ->
                    let
                        oldPointer =
                            state.pointer

                        newPointer =
                            { oldPointer | x = blockBrokenCoord x, y = blockBrokenCoord y }
                    in
                    ( Change.emptyFrame, { state | pointer = newPointer }, Cmd.none )

                MouseDownAt itemID startPoint ->
                    let
                        dragState =
                            DraggingStarted { id = itemID, start = startPoint, current = startPoint }

                        newPointer =
                            -- make sure drag start location agrees with pointer location
                            { x = Tuple.first startPoint, y = Tuple.second startPoint }
                    in
                    ( Change.emptyFrame
                    , { state | dragging = Just dragState, pointer = newPointer }
                    , Cmd.none
                    )

                MouseUp ->
                    ( Change.emptyFrame
                    , { state | dragging = Nothing }
                    , Cmd.none
                    )

                ResetCoordinates width height ->
                    let
                        oldSettings =
                            state.settings

                        ( newWidth, newHeight ) =
                            if width > 0 && height > 0 then
                                ( width, height )

                            else
                                ( oldSettings.widgetWidth, oldSettings.widgetHeight )

                        newSettings =
                            { oldSettings | widgetWidth = newWidth, widgetHeight = newHeight, rowHeight = round newHeight // oldSettings.rows }

                        ( widget1state, widget1init ) =
                            Widget.init newWidth newHeight "0"
                    in
                    ( Change.emptyFrame
                    , { settings = newSettings
                      , widgetState = widget1state
                      , widgetInit = widget1init
                      , pointer = { x = 0.0, y = 0.0 }
                      , dragging = Nothing
                      }
                    , Cmd.map WidgetMsg widget1init
                    )

        Nothing ->
            let
                ( initState, initCmd ) =
                    init profile env
            in
            ( Change.emptyFrame, initState, Cmd.batch [ initCmd, resizeCmd ] )


resizeCmd =
    let
        outcomeToMsg result =
            case result of
                Ok element ->
                    ResetCoordinates element.element.width element.element.height

                Err err ->
                    Tuple.second ( Log.log "problem fetching timeflow size!" err, ResetCoordinates 0 0 )
    in
    Dom.getElement "timeflow-container"
        |> Job.attempt outcomeToMsg


subscriptions : Profile -> Shared -> ViewState -> Sub Msg
subscriptions profile env vState =
    Sub.map WidgetMsg Widget.subscriptions
