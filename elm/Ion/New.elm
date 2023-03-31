module Ion.New exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK


{-| [Ionic Docs & Preview](https://ionicframework.com/docs/)
-}
button : List (Attribute msg) -> List (Html msg) -> Html msg
button attributes children =
    node "ion-button" attributes children
