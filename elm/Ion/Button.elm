module Ion.Button exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK
import Ion.Icon


{-| Buttons provide a clickable element, which can be used in forms, or anywhere that needs simple, standard button functionality. They may display text, icons, or both. Buttons can be styled with several attributes to look a specific way.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/button)
-}
button : List (Attribute msg) -> List (Html msg) -> Html msg
button attributes children =
    node "ion-button" attributes children


textButton : List (Attribute msg) -> String -> Html msg
textButton attributes label =
    node "ion-button" attributes [ Html.text label ]


justText : String -> Html msg
justText label =
    node "ion-button" [] [ Html.text label ]


justIcon : String -> Html msg
justIcon iconName =
    node "ion-button" [] [ Ion.Icon.basic iconName ]
