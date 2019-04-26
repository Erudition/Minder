module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, update, view, viewActivities, viewActivity, viewKeyedActivity)

import Activity.Activity as Activity exposing (..)
import AppData exposing (..)
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Environment exposing (..)
import External.Commands as Commands
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy, lazy2)
import Json.Decode as OldDecode
import Json.Decode.Exploration as Decode
import Json.Decode.Exploration.Pipeline as Pipeline exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Encode.Extra as Encode2 exposing (..)
import Porting exposing (..)
import Task as Job
import Time
import Url.Parser as P exposing ((</>), Parser, fragment, int, map, oneOf, s, string)
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
                [ class "todomvc-wrapper", css [ visibility Css.hidden ] ]
                [ section
                    [ class "todoapp" ]
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
        [ Keyed.ul [ class "activity-list" ] <|
            List.map (viewKeyedActivity app env) (List.filter Activity.showing (allActivities app.activities))
        ]



-- VIEW INDIVIDUAL ENTRIES


viewKeyedActivity : AppData -> Environment -> Activity -> ( String, Html Msg )
viewKeyedActivity app env activity =
    ( Activity.getName activity, lazy2 viewActivity app activity )


viewActivity : AppData -> Activity -> Html Msg
viewActivity app activity =
    li
        [ class "activity" ]
        [ button
            [ class "activity-button"
            , classList [ ( "current", (currentActivity app).id == activity.id ) ]
            , onClick (StartTracking activity.id)
            ]
            [ label
                []
                [ viewIcon activity.icon
                , text (Activity.getName activity)
                ]
            ]
        ]


viewIcon : Activity.Icon -> Html Msg
viewIcon icon =
    case icon of
        File svgPath ->
            img [ class "activity-icon", src ("media/icons/" ++ svgPath) ] []

        Ion ->
            text ""

        Other ->
            text ""



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
            ( state
            , { app | timeline = Switch env.time activityId :: app.timeline }
            , Commands.toast (Encode.string (beforeAndAfter app activityId))
            )


beforeAndAfter : AppData -> ActivityId -> String
beforeAndAfter app newId =
    getName (currentActivity app) ++ " ➤ " ++ getName (getActivity (allActivities app.activities) newId)


currentActivity : AppData -> Activity
currentActivity app =
    Activity.currentActivity (allActivities app.activities) app.timeline
