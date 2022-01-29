module Timeflow exposing (Msg, ViewState, init, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Activity.Timeline
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
import Profile exposing (..)
import Refocus
import SmartTime.Duration as Duration exposing (Duration)
import SmartTime.Human.Calendar as Calendar exposing (CalendarDate, equal)
import SmartTime.Human.Calendar.Week as Week
import SmartTime.Human.Clock as Clock exposing (TimeOfDay)
import SmartTime.Human.Duration as HumanDuration exposing (HumanDuration)
import SmartTime.Human.Moment as HumanMoment exposing (FuzzyMoment(..), Zone)
import SmartTime.Moment as Moment exposing (Moment)
import SmartTime.Period as Period exposing (Period)
import Task as Job
import Task.Entry as Task
import Task.Instance as Task exposing (Instance, InstanceSkel)
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
    , rows : Int
    }


type alias Point =
    ( Float, Float )


type alias Polygon =
    List Point


type alias FlowBlob =
    { start : Moment
    , end : Moment
    , color : Color.Color
    , label : String
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
            week

        chosenDayCutoffTime =
            -- will be derived from profile settings
            HumanDuration.build [ HumanDuration.Hours 3 ]

        timePerRow =
            Duration.fromMinutes 30

        rowHeight =
            2

        rowCount =
            List.length (Period.divide timePerRow chosenPeriod) * rowHeight
    in
    { flowRenderPeriod = chosenPeriod
    , hourRowSize = timePerRow
    , pivotMoment = HumanMoment.clockTurnBack chosenDayCutoffTime env.timeZone env.time
    , rowHeight = rowHeight
    , rows = rowCount
    }


init : Profile -> Environment -> ( ViewState, Cmd Msg )
init profile environment =
    let
        ( widget1state, widget1init ) =
            Widget.init 100 1000 "0"

        initialSettings =
            updateViewSettings profile environment

        initialWidgetHeight =
            initialSettings.rowHeight * initialSettings.rows
    in
    ( { settings = initialSettings
      , widgets = Dict.fromList [ ( "0", ( widget1state, widget1init ) ) ]
      , pointer = { x = 0.0, y = 0.0 }
      }
    , Cmd.map (WidgetMsg "0") widget1init
    )


routeView : Parser (Maybe ViewState -> a) a
routeView =
    P.map Nothing (P.s "timeflow")


view : Maybe ViewState -> Profile -> Environment -> SH.Html Msg
view maybeVState profile env =
    let
        vState =
            Maybe.withDefault (Tuple.first (init profile env)) maybeVState
    in
    SH.fromUnstyled <|
        layoutWith { options = [ noStaticStyleSheet ] } [ width fill, height fill ] <|
            column [ width fill, height fill ]
                [ row [ width fill, height (px 30), Background.color (Element.rgb 0.5 0.5 0.5) ]
                    [ el [ centerX ] <| Element.text <| Calendar.toStandardString <| HumanMoment.extractDate env.timeZone env.time ]
                , row [ width (fillPortion 1), height fill, htmlAttribute (HA.style "max-height" "inherit") ]
                    -- [ timeFlowLayout vState.settings profile env
                    [ column [ width (px 30), height fill, Background.color <| elementColor Color.grey, Font.size 30 ]
                        [ el [ centerX, centerY ] <| Element.text "👋"
                        , el [ centerX, centerY ] <| Element.text "🖖"
                        , el [ centerX, centerY ] <| Element.text "👌"
                        , el [ centerX, centerY ] <| Element.text "🤞"
                        , el [ centerX, centerY ] <| Element.text "🖕"
                        ]
                    , column [ width fill, height fill ]
                        [ row
                            [ width fill, height (px <| 10 * (vState.settings.rowHeight * vState.settings.rows)), Element.clip, htmlAttribute (HA.style "flex-shrink" "1") ]
                            (List.map (Element.html << svgExperiment vState profile env) (Dict.toList vState.widgets))
                        ]
                    ]
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


svgExperiment state profile env ( widgetID, ( widgetState, widgetInitCmd ) ) =
    H.div [ HA.width 100, HA.height 1000 ]
        [ Widget.view
            widgetState
            [ graphPaperCustom 1 0.03 (GraphicSVG.rgb 20 20 20)
            , group (allShapes state profile env) |> move ( 0, 200 )
            ]
        ]


allShapes state profile env =
    let
        boxHeight =
            toFloat <| List.length (Period.divide state.settings.hourRowSize state.settings.flowRenderPeriod) * state.settings.rowHeight
    in
    [ rect 100 boxHeight
        |> filled black
        |> makeTransparent 0.9
        |> move ( 0, -boxHeight / 2 )
    , rect 100 boxHeight
        |> filled (GraphicSVG.hsl 180 1 0.1)
        |> move ( 0, -3 * boxHeight / 2 )

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
    , GraphicSVG.text (Clock.toShortString (HumanMoment.extractTime env.timeZone state.settings.pivotMoment))
        |> fixedwidth
        |> size 3
        |> centered
        |> filled red
        |> move ( 0, -5 )
    ]
        ++ List.map (blobToShape state.settings env) (historyBlobs env profile state.settings.flowRenderPeriod)


distanceBetweenPoints : Point -> Point -> Float
distanceBetweenPoints ( x1, y1 ) ( x2, y2 ) =
    sqrt ((x2 - x1) ^ 2 + (y2 - y1) ^ 2)



{-
   Given a list of points, returns a Stencil shape that represents the
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



{-
   roundedCorner is a simple function that takes a radius and 3 points.
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


blobToShape : ViewSettings -> Environment -> FlowBlob -> Shape Msg
blobToShape settings env flowBlob =
    let
        pointsOfInterest =
            blobToPoints settings env flowBlob

        midPoint ( ( x1, y1 ), ( x2, y2 ) ) =
            ( (x1 + x2) / 2, (y1 + y2) / 2 )

        textSize =
            toFloat settings.rowHeight / 2

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
            roundedPolygon 0.5 pointsOfInterest.shell

        rotateIfSquished shape =
            if textAreaW > toFloat settings.rowHeight then
                shape

            else
                shape
                    |> GraphicSVG.rotate (degrees -90)
                    |> GraphicSVG.scale 0.5
    in
    group
        [ theShell
            |> filled (graphColor flowBlob.color)
            -- TODO: Consider flipping to black when blobs are old
            |> addOutline (GraphicSVG.solid 0.5) (GraphicSVG.rgba 255 255 255 0.55)
            |> GraphicSVG.clip (filled black theShell)
        , GraphicSVG.text flowBlob.label
            |> size textSize
            |> sansserif
            |> centered
            |> filled black
            |> rotateIfSquished
            |> move (midPoint pointsOfInterest.bestTextArea)
            |> move ( 0, -textSize / 2 )
            |> GraphicSVG.clip (filled black theShell)
        ]
        |> move ( -50, 0 )


blobToPoints : ViewSettings -> Environment -> FlowBlob -> { shell : Polygon, bestTextArea : ( Point, Point ) }
blobToPoints displayState env flowBlob =
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

        firstRowStartWall =
            startMs - offsetFromPriorWall startMs

        lastRowStartWall =
            endMs - offsetFromPriorWall endMs

        startsOnWall =
            offsetFromPriorWall startMs == 0

        h =
            toFloat displayState.rowHeight

        startHeight =
            0 - toFloat (rowNumber firstRowStartWall) * h

        rowNumber wall =
            wall // msBetweenWalls

        isOddRow startWall =
            modBy 2 (rowNumber startWall) == 1

        slash =
            0.2

        touchingRightWallBy ( x, y ) =
            if (100 - x) < slash then
                Debug.log "touching right wall portion" (1 - ((100 - x) / slash))

            else
                0

        touchingLeftWallBy ( x, y ) =
            if x < slash then
                Debug.log "touching left wall portion" (1 - (x / slash))

            else
                0

        slashTopLTR ( x, y ) =
            -- let
            --     touchPortion =
            --         touchingRightWallBy ( x, y )
            -- in
            -- if touchPortion > 0 then
            --     ( 100, y - (touchPortion * h) )
            --
            -- else
            ( clamp 0 100 <| x + slash, y )

        slashBottomLTR ( x, y ) =
            -- if touchingRightWallBy ( x, y ) > 0 then
            --     ( 100 - (2 * slash), y )
            --
            -- else
            ( clamp 0 100 <| x - slash, y )

        slashTopRTL ( x, y ) =
            -- let
            --     leftTouchPortion =
            --         touchingLeftWallBy ( x, y )
            -- in
            -- if touchingRightWallBy ( x, y ) > 0 then
            --     ( 100 - (2 * slash), y )
            --
            -- else if leftTouchPortion > 0 then
            --     ( 0, y - (leftTouchPortion * h) )
            --
            -- else
            ( clamp 0 100 <| x - slash, y )

        slashBottomRTL ( x, y ) =
            -- let
            --     rightTouchPortion =
            --         touchingRightWallBy ( x, y )
            -- in
            -- if touchingLeftWallBy ( x, y ) > 0 then
            --     ( 0 + (2 * slash), y )
            --
            -- else if rightTouchPortion > 0 then
            --     ( 100, y + (rightTouchPortion * h) )
            --
            -- else
            ( clamp 0 100 <| x + slash, y )

        floatingBlob =
            -- all Points are in clockwise order, starting with the top left point or the one before it
            if isOddRow firstRowStartWall then
                -- RTL row
                { shell =
                    [ slashBottomRTL ( 100 - endsAtPortion * 100, startHeight - h )
                    , slashTopRTL ( 100 - endsAtPortion * 100, startHeight )
                    , slashTopRTL ( 100 - startsAtPortion * 100, startHeight )
                    , slashBottomRTL ( 100 - startsAtPortion * 100, startHeight - h )
                    ]
                , bestTextArea =
                    ( ( (100 - endsAtPortion * 100) + slash, startHeight )
                    , ( (100 - startsAtPortion * 100) - slash, startHeight - h )
                    )
                }

            else
                -- LTR row
                { shell =
                    [ slashBottomLTR ( startsAtPortion * 100, startHeight - h )
                    , slashTopLTR ( startsAtPortion * 100, startHeight )
                    , slashTopLTR ( endsAtPortion * 100, startHeight )
                    , slashBottomLTR ( endsAtPortion * 100, startHeight - h )
                    ]
                , bestTextArea =
                    ( ( clamp 0 100 <| (startsAtPortion * 100) + slash, startHeight )
                    , ( clamp 0 100 <| (endsAtPortion * 100) - slash, startHeight - h )
                    )
                }

        oneCrossingBlob =
            if isOddRow firstRowStartWall then
                -- RTL row
                { shell =
                    -- share left wall
                    [ ( 0, startHeight - (2 * h) )
                    , ( 0, startHeight )

                    -- starting side, RTL row
                    , slashTopRTL ( 100 - startsAtPortion * 100, startHeight )
                    , slashBottomRTL ( 100 - startsAtPortion * 100, startHeight - h )

                    -- ending side, LTR row
                    , slashTopLTR ( endsAtPortion * 100, startHeight - h )
                    , slashBottomLTR ( endsAtPortion * 100, startHeight - (2 * h) )
                    ]
                , bestTextArea =
                    -- no slash on left side shared wall
                    if startsAtPortion >= endsAtPortion then
                        ( ( 0, startHeight )
                        , ( clamp 0 100 <| (100 - startsAtPortion * 100) - slash, startHeight - h )
                        )

                    else
                        ( ( 0, startHeight - h )
                        , ( clamp 0 100 <| (endsAtPortion * 100) - slash, startHeight - (2 * h) )
                        )
                }

            else
                -- LTR row
                { shell =
                    [ slashBottomLTR ( startsAtPortion * 100, startHeight - h )
                    , slashTopLTR ( startsAtPortion * 100, startHeight )
                    , ( 100, startHeight )
                    , ( 100, startHeight - (2 * h) )

                    -- RTL row
                    , slashBottomRTL ( 100 - endsAtPortion * 100, startHeight - (2 * h) )
                    , slashTopRTL ( 100 - endsAtPortion * 100, startHeight - h )
                    ]
                , bestTextArea =
                    -- no slash on right side shared wall
                    if startsAtPortion >= endsAtPortion then
                        -- use top piece, there's more room
                        ( ( clamp 0 100 <| (startsAtPortion * 100) + slash, startHeight )
                        , ( 100, startHeight - h )
                        )

                    else
                        -- use bottom piece, there's more room
                        ( ( clamp 0 100 <| (100 - endsAtPortion * 100) + slash, startHeight - h )
                        , ( 100, startHeight - (2 * h) )
                        )
                }

        sandwichBlob middlePieces =
            { shell =
                case ( isOddRow firstRowStartWall, isOddRow lastRowStartWall ) of
                    -- top row is LTR, bottom is RTL
                    ( False, True ) ->
                        -- start-side, LTR
                        [ slashBottomLTR ( startsAtPortion * 100, startHeight - h )
                        , slashTopLTR ( startsAtPortion * 100, startHeight )

                        -- right wall
                        , ( 100, startHeight )
                        , ( 100, startHeight - ((2 + middlePieces) * h) )

                        -- end-side, RTL
                        , slashBottomRTL ( 100 - endsAtPortion * 100, startHeight - ((2 + middlePieces) * h) )
                        , slashTopRTL ( 100 - endsAtPortion * 100, startHeight - ((1 + middlePieces) * h) )

                        -- left wall
                        , ( 0, startHeight - ((1 + middlePieces) * h) )
                        , ( 0, startHeight - h )
                        ]

                    -- top row is RTL, bottom is LTR
                    ( True, False ) ->
                        -- left wall
                        [ ( 0, startHeight - ((2 + middlePieces) * h) )
                        , ( 0, startHeight )

                        -- start-side, RTL
                        , slashTopRTL ( 100 - startsAtPortion * 100, startHeight )
                        , slashBottomRTL ( 100 - startsAtPortion * 100, startHeight - h )

                        -- right wall
                        , ( 100, startHeight - h )
                        , ( 100, startHeight - (h * (middlePieces + 1)) )

                        -- end-side, LTR
                        , slashTopLTR ( endsAtPortion * 100, startHeight - (h * (middlePieces + 1)) )
                        , slashBottomLTR ( endsAtPortion * 100, startHeight - (h * (middlePieces + 2)) )
                        ]

                    -- top row is LTR, bottom is LTR
                    ( False, False ) ->
                        -- start-side, LTR
                        [ slashBottomLTR ( startsAtPortion * 100, startHeight - h )
                        , slashTopLTR ( startsAtPortion * 100, startHeight )

                        -- right wall
                        , ( 100, startHeight )
                        , ( 100, startHeight - ((1 + middlePieces) * h) )

                        -- end-side, also LTR
                        , slashTopLTR ( endsAtPortion * 100, startHeight - ((1 + middlePieces) * h) )
                        , slashBottomLTR ( endsAtPortion * 100, startHeight - ((2 + middlePieces) * h) )

                        -- left wall
                        , ( 0, startHeight - ((2 + middlePieces) * h) )
                        , ( 0, startHeight - h )
                        ]

                    -- top row is RTL, bottom is RTL
                    ( True, True ) ->
                        -- left wall
                        [ ( 0, startHeight - ((1 + middlePieces) * h) )
                        , ( 0, startHeight )

                        -- start-side, RTL
                        , slashTopRTL ( 100 - startsAtPortion * 100, startHeight )
                        , slashBottomRTL ( 100 - startsAtPortion * 100, startHeight - h )

                        -- right wall
                        , ( 100, startHeight - h )
                        , ( 100, startHeight - (h * (middlePieces + 2)) )

                        -- end-side, also RTL
                        , slashBottomRTL ( 100 - endsAtPortion * 100, startHeight - (h * (middlePieces + 2)) )
                        , slashTopRTL ( 100 - endsAtPortion * 100, startHeight - (h * (middlePieces + 1)) )
                        ]
            , bestTextArea =
                ( ( 0, startHeight - h ), ( 100, startHeight - ((1 + middlePieces) * h) ) )
            }
    in
    case List.length wallsCrossed of
        0 ->
            floatingBlob

        1 ->
            oneCrossingBlob

        x ->
            sandwichBlob (toFloat x - 1)


historyBlobs env profile displayPeriod =
    let
        historyList =
            Activity.Timeline.switchListLiveToPeriods env.time profile.timeline

        activities =
            Activity.allActivities profile.activities
    in
    List.map (makeHistoryBlob env activities displayPeriod)
        (List.takeWhile
            (\( _, _, m ) -> Period.haveOverlap displayPeriod m)
            historyList
        )


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


dayString : Environment -> Moment -> String
dayString env moment =
    Calendar.toStandardString (HumanMoment.extractDate env.timeZone moment)


makeHistoryBlob : Environment -> IntDict Activity -> Period -> ( Activity.ActivityID, Maybe Task.InstanceID, Period ) -> FlowBlob
makeHistoryBlob env activities displayPeriod ( activityID, instanceIDMaybe, sessionPeriod ) =
    let
        -- sessionPositions =
        --     getPositionInDay day.rowLength day.period sessionPeriod
        ( ( startDate, startTime ), ( endDate, endTime ) ) =
            ( HumanMoment.humanize env.timeZone (Period.start sessionPeriod)
            , HumanMoment.humanize env.timeZone (Period.end sessionPeriod)
            )

        describeTiming =
            activityName
                ++ " "
                ++ Clock.toShortString startTime
                ++ "-"
                ++ Clock.toShortString endTime
                ++ " ("
                ++ String.fromInt (round <| Duration.inMinutes (Period.length sessionPeriod))
                ++ "m)"

        sessionActivity =
            getActivity activityID activities

        activityName =
            Maybe.withDefault "Unnamed Activity" <| List.head sessionActivity.names

        activityIcon =
            case sessionActivity.icon of
                File svgPath ->
                    ""

                Emoji singleEmoji ->
                    singleEmoji

                _ ->
                    "⚪"

        activityHue =
            toFloat (ID.read activityID) / toFloat (IntDict.size activities)

        activityColor =
            hsluv
                { hue = activityHue
                , saturation = 1
                , lightness = 0.5
                , alpha = 0.99
                }
                |> HSLuv.toColor

        croppedSessionPeriod =
            Period.crop displayPeriod sessionPeriod
    in
    FlowBlob (Period.start croppedSessionPeriod) (Period.end croppedSessionPeriod) activityColor activityName


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
            Maybe.withDefault (Tuple.first (init profile env)) maybeVState
    in
    Sub.batch <| List.map (\id -> Sub.map (WidgetMsg id) Widget.subscriptions) (Dict.keys vState.widgets)
