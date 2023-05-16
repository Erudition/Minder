module DevTools exposing (Msg, ViewState, init, routeView, subscriptions, update, view)

import Activity.Activity as Activity exposing (..)
import Helpers exposing (..)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE exposing (onClick)
import Html.Styled as SH
import Ion.Item
import Ion.List
import Profile exposing (..)
import Replicated.Change as Change exposing (Change, Frame)
import Replicated.Reducer.RepList as RepList exposing (RepList)
import Shared.Model exposing (..)
import SmartTime.Human.Moment exposing (FuzzyMoment(..))
import Task.Progress exposing (..)
import Url.Parser as P exposing ((</>), Parser)


init : Profile -> Shared -> String -> ( ViewState, Cmd Msg )
init profile shared ron =
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


view : ViewState -> Profile -> Shared -> SH.Html Msg
view state profile _ =
    SH.fromUnstyled <|
        H.div []
            [ errorList profile.errors
            , H.text state.ron
            ]


errorList : RepList String -> Html Msg
errorList errors =
    let
        errorItems =
            List.map showItem <| RepList.list errors

        showItem { handle, value } =
            Ion.Item.item
                [ HE.onDoubleClick (SimpleChange (RepList.remove handle errors))
                ]
                [ H.text value ]
    in
    Ion.List.list [] errorItems



--             _   _ ______ ______   ___   _____  _____
--            | | | || ___ \|  _  \ / _ \ |_   _||  ___|
--            | | | || |_/ /| | | |/ /_\ \  | |  | |__
--            | | | ||  __/ | | | ||  _  |  | |  |  __|
--            | |_| || |    | |/ / | | | |  | |  | |___
--             \___/ \_|    |___/  \_| |_/  \_/  \____/


type Msg
    = SimpleChange Change


update : Msg -> ViewState -> Profile -> Shared -> ( ViewState, Frame, Cmd Msg )
update msg state _ _ =
    case msg of
        SimpleChange change ->
            ( state, Change.saveChanges "Simple change" [ change ], Cmd.none )


subscriptions : Profile -> Shared -> Maybe ViewState -> Sub Msg
subscriptions _ _ _ =
    Sub.none
