module Timeflow exposing (Msg(..), ViewState, init, resizeCmd, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Activity.Session as Session exposing (Session)
import Activity.Timeline as Timeline
import Browser.Dom as Dom
import Color exposing (Color)
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
import Html as H
import Html.Attributes as HA
import Html.Styled as SH
import ID
import Incubator.IntDict.Extra as IntDict
import IntDict exposing (IntDict)
import List.Extra as List
import Log
import Profile exposing (..)
import Refocus
import Replicated.Change as Change exposing (ChangeSet, Frame)
import Replicated.Op.OpID as OpID exposing (OpID)
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
import Task.AssignedAction as Task exposing (AssignedAction, AssignedActionSkel)
import Task.Entry as Task
import Task.Progress exposing (..)
import Task.Session as Task
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
    , widgetWidth : Int
    , widgetHeight : Int
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
    , rows = rowCount
    , widgetHeight = 1000
    , widgetWidth = 1000
    }


init : Profile -> Environment -> ( ViewState, Cmd Msg )
init profile environment =
    let
        ( widget1state, widget1init ) =
            Widget.init (toFloat initialSettings.widgetWidth) (toFloat initialWidgetHeight) "0"

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


view : ViewState -> Profile -> Environment -> SH.Html Msg
view vState profile env =
    SH.fromUnstyled <|
        layout [ width fill, height fill ] <|
            column [ width fill, height fill ]
                [ row [ width fill, height (px 30), Background.color (Element.rgb 0.5 0.5 0.5) ]
                    [ el [ centerX ] <| Element.text <| Calendar.toStandardString <| HumanMoment.extractDate env.timeZone env.time ]
                , row
                    [ width fill, height fill, htmlAttribute (HA.style "touch-action" "none"), htmlAttribute (HA.id "timeflow-container") ]
                    [ Element.html <| svgExperiment vState profile env ]
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



-- svgExperiment : ViewState -> Profile -> Environment -> ( widgetID, ( widgetState, widgetInitCmd ) )


svgExperiment state profile env =
    Widget.view
        state.widgetState
        [ graphPaperCustom 100 0.03 (GraphicSVG.rgb 20 20 20)
        , group (allShapes state profile env)
            |> move ( 0, toFloat state.settings.widgetHeight / 2 )
            |> notifyMouseMoveAt PointerMove
            |> notifyTouchMoveAt PointerMove
            |> notifyMouseUp MouseUp
            |> notifyTouchEnd MouseUp
        ]


allShapes state profile env =
    let
        boxHeight =
            toFloat <| List.length (Period.divide state.settings.hourRowSize state.settings.flowRenderPeriod) * state.settings.rowHeight

        hourOfDayAsPortion hour =
            ((hour - 3) / 24) * toFloat state.settings.widgetHeight
    in
    [ rect (toFloat state.settings.widgetWidth) boxHeight
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
        ++ List.map (blobToShape state env) (historyBlobs env profile state.settings.flowRenderPeriod)
        ++ [ timeLabel env state.settings.pivotMoment ]


timeLabel : Environment -> Moment -> Shape msg
timeLabel env stampMoment =
    GraphicSVG.text (HumanMoment.describeVsNow env.timeZone env.time stampMoment)
        |> fixedwidth
        |> size 1
        |> centered
        |> filled red
        |> move ( 0, -1 )


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
                |> List.groupsOf 2
                |> List.map
                    (\list ->
                        let
                            ( c, d ) =
                                Maybe.withDefault ( ( 0, 0 ), ( 0, 0 ) ) <| Helpers.listToTuple2 list
                        in
                        GraphicSVG.Pull c d
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


blobToShape : ViewState -> Environment -> FlowBlob -> Shape Msg
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
                            offset =
                                dragOffsetDur display start
                        in
                        -- this blob is being dragged, change period
                        ( { initialBlob
                            | start = Moment.future initialBlob.start offset
                            , end = Moment.future initialBlob.end offset
                          }
                        , True
                        )

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
                [ GraphicSVG.text (Clock.padInt (Clock.hour (HumanMoment.extractTime env.timeZone moment)))
                    |> size 0.7
                    |> filled black
                    |> move ( 0, 0 )
                , GraphicSVG.text (Clock.padInt (Clock.minute (HumanMoment.extractTime env.timeZone moment)))
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

            else
                GraphicSVG.rgba 255 255 255 0.55
    in
    group
        (List.filterMap identity <|
            [ theShell
                |> filled (graphColor blob.color)
                -- TODO: Consider flipping to black when blobs are old
                |> addOutline (GraphicSVG.solid 7) outlineColor
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
                |> Just
            ]
        )
        |> GraphicSVG.clip (filled black theShell)
        |> move ( toFloat display.settings.widgetWidth / -2, 0 )
        |> notifyMouseDownAt (MouseDownAt blob.id)
        |> notifyTouchStartAt (MouseDownAt blob.id)


blobToPoints : ViewSettings -> Environment -> FlowBlob -> { shell : Polygon, bestTextArea : ( Point, Point ), startCapTL : Point, endCapTL : Point }
blobToPoints displaySettings _ blob =
    let
        msBetweenWalls =
            Duration.inMs displaySettings.hourRowSize

        startMs =
            Duration.subtract (Moment.toDuration blob.start Moment.y2k)
                (Moment.toDuration displaySettings.pivotMoment Moment.y2k)
                |> Duration.inMs

        offsetFromPriorWall ms =
            -- TODO for negatives: mod or remainder
            modBy msBetweenWalls ms

        distanceToNextWall ms =
            msBetweenWalls - offsetFromPriorWall ms

        endMs =
            Duration.subtract (Moment.toDuration blob.end Moment.y2k)
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

        h =
            toFloat displaySettings.rowHeight

        startHeight =
            0 - toFloat (rowNumber firstRowStartWall) * h

        rowNumber wall =
            wall // msBetweenWalls

        isOddRow startWall =
            modBy 2 (rowNumber startWall) == 1

        offset =
            5

        clampWithOffset x =
            clampWidth <| x + offset

        clampWithOffsetNeg x =
            clampWidth <| x - offset

        clampWidth x =
            clamp 0 widgetWidth x

        widgetWidth =
            toFloat displaySettings.widgetWidth

        singleRowBlob =
            -- all Points are in clockwise order, starting with the top left point or the one before it
            if isOddRow firstRowStartWall then
                -- RTL row
                { shell =
                    [ ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - h )
                    , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - (h / 2) )
                    , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight )
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                    , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (h / 2) )
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - h )
                    ]
                , bestTextArea =
                    ( ( widgetWidth - ending * widgetWidth, startHeight )
                    , ( widgetWidth - starting * widgetWidth, startHeight - h )
                    )
                , startCapTL = ( (widgetWidth - starting * widgetWidth) - h, startHeight )
                , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight )
                }

            else
                -- LTR row
                { shell =
                    [ ( clampWidth (starting * widgetWidth), startHeight - h )
                    , ( clampWithOffset (starting * widgetWidth), startHeight - (h / 2) )
                    , ( clampWidth (starting * widgetWidth), startHeight )
                    , ( clampWidth (ending * widgetWidth), startHeight )
                    , ( clampWithOffset (ending * widgetWidth), startHeight - (h / 2) )
                    , ( clampWidth (ending * widgetWidth), startHeight - h )
                    ]
                , bestTextArea =
                    ( ( clampWidth <| (starting * widgetWidth), startHeight )
                    , ( clampWidth <| (ending * widgetWidth), startHeight - h )
                    )
                , startCapTL = ( starting * widgetWidth, startHeight )
                , endCapTL = ( (ending * widgetWidth) - h, startHeight )
                }

        twoRowBlob =
            if isOddRow firstRowStartWall then
                -- RTL row
                { shell =
                    -- share left wall
                    [ ( 0, startHeight - (2 * h) )
                    , ( 0, startHeight )

                    -- starting side, RTL row
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                    , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (h / 2) )
                    , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - h )

                    -- ending side, LTR row
                    , ( clampWidth (ending * widgetWidth), startHeight - h )
                    , ( clampWithOffset (ending * widgetWidth), startHeight - (1.5 * h) )
                    , ( clampWidth (ending * widgetWidth), startHeight - (2 * h) )
                    ]
                , bestTextArea =
                    -- no slash on left side shared wall
                    if (1 - starting) >= ending then
                        ( ( 0, startHeight )
                        , ( clampWidth <| (widgetWidth - starting * widgetWidth), startHeight - h )
                        )

                    else
                        ( ( 0, startHeight - h )
                        , ( clampWidth <| (ending * widgetWidth), startHeight - (2 * h) )
                        )
                , startCapTL = ( (widgetWidth - starting * widgetWidth) - h, startHeight )
                , endCapTL = ( (ending * widgetWidth) - h, startHeight - h )
                }

            else
                { shell =
                    [ ( clampWidth (starting * widgetWidth), startHeight - h )
                    , ( clampWithOffset (starting * widgetWidth), startHeight - (h / 2) )
                    , ( clampWidth (starting * widgetWidth), startHeight )

                    --
                    , ( widgetWidth, startHeight )
                    , ( widgetWidth, startHeight - (2 * h) )

                    -- RTL row
                    , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - (2 * h) )
                    , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - (1.5 * h) )
                    , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - h )
                    ]
                , bestTextArea =
                    -- no slash on right side shared wall
                    if (1 - starting) >= ending then
                        -- use top piece, there's more room
                        ( ( clampWidth <| (starting * widgetWidth), startHeight )
                        , ( widgetWidth, startHeight - h )
                        )

                    else
                        -- use bottom piece, there's more room
                        ( ( clampWidth <| (widgetWidth - ending * widgetWidth), startHeight - h )
                        , ( widgetWidth, startHeight - (2 * h) )
                        )
                , startCapTL = ( starting * widgetWidth, startHeight )
                , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight - h )
                }

        sandwichBlob middlePieces =
            case ( isOddRow firstRowStartWall, isOddRow lastRowStartWall ) of
                -- top row is LTR, bottom is RTL
                ( False, True ) ->
                    { shell =
                        -- start-side, LTR
                        [ ( clampWidth (starting * widgetWidth), startHeight - h )
                        , ( clampWithOffset (starting * widgetWidth), startHeight - (h / 2) )
                        , ( clampWidth (starting * widgetWidth), startHeight )

                        -- right wall
                        , ( widgetWidth, startHeight )
                        , ( widgetWidth, startHeight - ((2 + middlePieces) * h) )

                        -- end-side, RTL
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - ((middlePieces + 2) * h) )
                        , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - ((middlePieces + 1.5) * h) )
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - ((middlePieces + 1) * h) )

                        -- left wall
                        , ( 0, startHeight - ((1 + middlePieces) * h) )
                        , ( 0, startHeight - h )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - h ), ( widgetWidth, startHeight - ((1 + middlePieces) * h) ) )
                    , startCapTL = ( starting * widgetWidth, startHeight )
                    , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight - ((1 + middlePieces) * h) )
                    }

                -- top row is RTL, bottom is LTR
                ( True, False ) ->
                    { shell =
                        -- left wall
                        [ ( 0, startHeight - ((2 + middlePieces) * h) )
                        , ( 0, startHeight )

                        -- start-side, RTL
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                        , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (h / 2) )
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - h )

                        -- right wall
                        , ( widgetWidth, startHeight - h )
                        , ( widgetWidth, startHeight - (h * (middlePieces + 1)) )

                        -- end-side, LTR
                        , ( clampWidth (ending * widgetWidth), startHeight - (h * (middlePieces + 1)) )
                        , ( clampWithOffset (ending * widgetWidth), startHeight - (h * (middlePieces + 1.5)) )
                        , ( clampWidth (ending * widgetWidth), startHeight - (h * (middlePieces + 2)) )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - h ), ( widgetWidth, startHeight - ((1 + middlePieces) * h) ) )
                    , startCapTL = ( (widgetWidth - starting * widgetWidth) - h, startHeight )
                    , endCapTL = ( (ending * widgetWidth) - h, startHeight - ((1 + middlePieces) * h) )
                    }

                -- top row is LTR, bottom is LTR
                ( False, False ) ->
                    { shell =
                        -- start-side, LTR
                        [ ( clampWidth (starting * widgetWidth), startHeight - h )
                        , ( clampWithOffset (starting * widgetWidth), startHeight - (h / 2) )
                        , ( clampWidth (starting * widgetWidth), startHeight )

                        -- right wall
                        , ( widgetWidth, startHeight )
                        , ( widgetWidth, startHeight - ((1 + middlePieces) * h) )

                        -- end-side, also LTR
                        , ( clampWidth (ending * widgetWidth), startHeight - ((middlePieces + 1) * h) )
                        , ( clampWithOffset (ending * widgetWidth), startHeight - ((middlePieces + 1.5) * h) )
                        , ( clampWidth (ending * widgetWidth), startHeight - ((middlePieces + 2) * h) )

                        -- left wall
                        , ( 0, startHeight - ((2 + middlePieces) * h) )
                        , ( 0, startHeight - h )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - h ), ( widgetWidth, startHeight - ((1 + middlePieces) * h) ) )
                    , startCapTL = ( starting * widgetWidth, startHeight )
                    , endCapTL = ( (ending * widgetWidth) - h, startHeight - ((1 + middlePieces) * h) )
                    }

                -- top row is RTL, bottom is RTL
                ( True, True ) ->
                    { shell =
                        -- left wall
                        [ ( 0, startHeight - ((1 + middlePieces) * h) )
                        , ( 0, startHeight )

                        -- start-side, RTL
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight )
                        , ( clampWithOffsetNeg (widgetWidth - starting * widgetWidth), startHeight - (h / 2) )
                        , ( clampWidth (widgetWidth - starting * widgetWidth), startHeight - h )

                        -- right wall
                        , ( widgetWidth, startHeight - h )
                        , ( widgetWidth, startHeight - (h * (middlePieces + 2)) )

                        -- end-side, also RTL
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - (h * (middlePieces + 2)) )
                        , ( clampWithOffsetNeg (widgetWidth - ending * widgetWidth), startHeight - (h * (middlePieces + 1.5)) )
                        , ( clampWidth (widgetWidth - ending * widgetWidth), startHeight - (h * (middlePieces + 1)) )
                        ]
                    , bestTextArea =
                        ( ( 0, startHeight - h ), ( widgetWidth, startHeight - ((1 + middlePieces) * h) ) )
                    , startCapTL = ( (widgetWidth - starting * widgetWidth) - h, startHeight )
                    , endCapTL = ( widgetWidth - ending * widgetWidth, startHeight - ((1 + middlePieces) * h) )
                    }
    in
    case List.length wallsCrossed of
        0 ->
            singleRowBlob

        1 ->
            twoRowBlob

        x ->
            sandwichBlob (toFloat x - 1)


historyBlobs : Environment -> Profile -> Period -> List FlowBlob
historyBlobs env profile displayPeriod =
    let
        historyList =
            Timeline.historyLive env.time profile.timeline
    in
    List.map (makeHistoryBlob env profile.activities displayPeriod)
        (List.takeWhileRight
            (\sesh -> Period.haveOverlap displayPeriod (Session.getPeriod sesh))
            historyList
        )


{-| How much a blob moves (in time) while being dragged.
-}
dragOffsetDur : ViewState -> Point -> Duration
dragOffsetDur display ( startX, startY ) =
    let
        xOffset =
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
            xOffset / toFloat display.settings.widgetHeight

        xIfSameLineYOtherwise =
            if yOffsetInDoubleRowsRounded == 0 then
                0 - xOffsetAsPortion

            else
                yOffsetInDoubleRowsRounded
    in
    -- TODO
    -- Duration.scale display.settings.hourRowSize xIfSameLineYOtherwise
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
    column [ width (px 70), height fill, Border.color (Element.rgb 0.2 0.2 0.2), Border.width 1, Background.color (Element.rgb 0.5 0.5 0.5) ]
        [ paragraph [ centerX, centerY ] <|
            [ Element.text timeOfDayString ]
        ]


dayString : Environment -> Moment -> String
dayString env moment =
    Calendar.toStandardString (HumanMoment.extractDate env.timeZone moment)


makeHistoryBlob : Environment -> Activity.Store -> Period -> Session -> FlowBlob
makeHistoryBlob env activityStore displayPeriod session =
    let
        -- sessionPositions =
        --     getPositionInDay day.rowLength day.period sessionPeriod
        ( ( startDate, startTime ), ( endDate, endTime ) ) =
            ( HumanMoment.humanize env.timeZone (Session.getStart session)
            , HumanMoment.humanize env.timeZone (Session.getEnd session)
            )

        describeTiming =
            String.fromInt (round <| Duration.inMinutes (Period.length (Session.getPeriod session)))
                ++ "m "
                ++ activityIcon
                ++ activityName

        sessionActivity =
            Activity.getByID (Session.getActivityID session) activityStore

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
            Period.crop displayPeriod (Session.getPeriod session)

        stringID =
            HumanMoment.toStandardString (Session.getStart session)
    in
    FlowBlob (Period.start croppedSessionPeriod) (Period.end croppedSessionPeriod) activityColor describeTiming stringID


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
    | Refresh
    | ResetCoordinates Float Float


type alias Pointer =
    { x : Float
    , y : Float
    }


update : Msg -> Maybe ViewState -> Profile -> Environment -> ( Frame, ViewState, Cmd Msg )
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
                    ( Change.none, { state | settings = withNewPeriodToRender }, Cmd.none )

                WidgetMsg widgetMsg ->
                    let
                        ( newWidgetState, widgetOutCmds ) =
                            Widget.update widgetMsg state.widgetState
                    in
                    ( Change.none
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
                    ( Change.none, { state | pointer = newPointer }, Cmd.none )

                MouseDownAt itemID startPoint ->
                    let
                        dragState =
                            DraggingStarted { id = itemID, start = startPoint, current = startPoint }
                    in
                    ( Change.none
                    , { state | dragging = Just dragState }
                    , Cmd.none
                    )

                MouseUp ->
                    ( Change.none
                    , { state | dragging = Nothing }
                    , Cmd.none
                    )

                Refresh ->
                    ( Change.none
                    , { state | dragging = Nothing }
                    , Cmd.none
                    )

                ResetCoordinates width height ->
                    let
                        oldSettings =
                            state.settings

                        newSettings =
                            { oldSettings | widgetWidth = round width, widgetHeight = round height, rowHeight = round height // oldSettings.rows }

                        ( widget1state, widget1init ) =
                            Widget.init width height "0"
                    in
                    ( Change.none
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
            ( Change.none, initState, Cmd.batch [ initCmd, resizeCmd ] )


resizeCmd =
    let
        outcomeToMsg result =
            case result of
                Ok element ->
                    ResetCoordinates element.element.width element.element.height

                Err err ->
                    Tuple.second ( Log.log "problem fetching timeflow size!" err, MouseUp )
    in
    Dom.getElement "timeflow-container"
        |> Job.attempt outcomeToMsg


subscriptions : Profile -> Environment -> ViewState -> Sub Msg
subscriptions profile env vState =
    Sub.map WidgetMsg Widget.subscriptions
