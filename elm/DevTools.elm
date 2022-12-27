module DevTools exposing (Msg, init, ViewState, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Element exposing (..)
import Environment exposing (..)
import Helpers exposing (..)
import Html.Attributes as HA
import Html.Styled as SH
import Profile exposing (..)
import Replicated.Change as Change exposing (Change, Frame)
import SmartTime.Human.Moment exposing (FuzzyMoment(..))
import Task.Progress exposing (..)
import Url.Parser as P exposing ((</>), Parser)

init : Profile -> Environment -> ( ViewState, Cmd Msg )
init profile environment =
    ( ViewState ()
    , Cmd.none
    )

--            MM    MM  OOOOO  DDDDD   EEEEEEE LL
--            MMM  MMM OO   OO DD  DD  EE      LL
--            MM MM MM OO   OO DD   DD EEEEE   LL
--            MM    MM OO   OO DD   DD EE      LL
--            MM    MM  OOOO0  DDDDDD  EEEEEEE LLLLLLL
--            :::     ::: ::::::::::: :::::::::: :::       :::
--            :+:     :+:     :+:     :+:        :+:       :+:
--            +:+     +:+     +:+     +:+        +:+       +:+
--            +#+     +:+     +#+     +#++:++#   +#+  +:+  +#+
--             +#+   +#+      +#+     +#+        +#+ +#+#+ +#+
--              #+#+#+#       #+#     #+#         #+#+# #+#+#
--                ###     ########### ##########   ###   ###


type alias ViewState =
    { dummy : ()
    }


routeView : Parser (ViewState -> a) a
routeView =
    P.map (ViewState ()) (P.s "devtools")


view : ViewState -> Profile -> Environment -> SH.Html Msg
view _ _ _ =
    SH.fromUnstyled <|
        layoutWith { options = [ noStaticStyleSheet ] } [ width fill, height fill ] <|
            column [ width fill, height fill ]
                [ row [ width (fillPortion 1), height fill, htmlAttribute (HA.style "max-height" "inherit") ]
                    [ el [] (text "dev tools") ]
                ]



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = SimpleChange Change


update : Msg -> ViewState -> Profile -> Environment -> ( ViewState, Frame, Cmd Msg )
update msg state _ _ =
    case msg of
        SimpleChange change ->
            ( state, Change.saveChanges "Simple change" [ change ], Cmd.none )


subscriptions : Profile -> Environment -> Maybe ViewState -> Sub Msg
subscriptions _ _ _ =
    Sub.none
