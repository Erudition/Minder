module TimeTracker exposing (Msg(..), ViewState(..), defaultView, routeView, update, view, viewActivities, viewActivity, viewKeyedActivity)

import Activity.Activity as Activity exposing (..)
import AppData exposing (..)
import Browser
import Browser.Dom
import Css exposing (..)
import Date
import Environment exposing (..)
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
            List.map (viewKeyedActivity env) (List.filter Activity.showing (allActivities app.activities))
        ]



-- VIEW INDIVIDUAL ENTRIES


viewKeyedActivity : Environment -> Activity -> ( String, Html Msg )
viewKeyedActivity env activity =
    ( Activity.getName activity, lazy2 viewActivity env activity )


viewActivity : Environment -> Activity -> Html Msg
viewActivity env activity =
    li
        [ class "task-entry" ]
        [ div
            [ class "view" ]
            [ button
                [ class "toggle" ]
                []
            , label
                []
                [ text (Activity.getName activity) ]
            , div
                [ class "timing-info" ]
                [ text "5 hours straight" ]
            ]
        ]



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = NoOp


update : Msg -> ViewState -> AppData -> Environment -> ( ViewState, AppData, Cmd Msg )
update msg state app env =
    case msg of
        NoOp ->
            ( state
            , app
            , Cmd.none
            )
