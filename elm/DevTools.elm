module DevTools exposing (Msg, init, ViewState, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Element exposing (..)
import Element.Events exposing (onClick)
import Environment exposing (..)
import Helpers exposing (..)
import Html.Attributes as HA
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Html.Styled as SH
import Profile exposing (..)
import Replicated.Change as Change exposing (Change, Frame)
import SmartTime.Human.Moment exposing (FuzzyMoment(..))
import Task.Progress exposing (..)
import Url.Parser as P exposing ((</>), Parser)

init : Profile -> Environment -> String -> ( ViewState, Cmd Msg )
init profile environment ron =
    ( ViewState ron
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
    { ron : String
    }


routeView : Parser (ViewState -> a) a
routeView =
    P.map (ViewState "") (P.s "devtools")


view : ViewState -> Profile -> Environment -> SH.Html Msg
view state profile _ =
    SH.fromUnstyled <|
        layoutWith { options = [ noStaticStyleSheet ] } [ width fill, height fill ] <|
            column [ width fill, height fill ]
                [ (errorList profile.errors)
                , el [] (text state.ron)
                ]

errorList : RepList String -> Element Msg
errorList errors =
    let
        errorItems =
            List.map showItem <| RepList.list errors

        showItem {handle, value} =
            row 
                [
                    onClick (SimpleChange (RepList.remove handle errors))
                ] 
                [text value] 

    in
    column [] errorItems 

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
