module Ion.Tab exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK
import Ion.Icon


{-| The tab bar is a UI component that contains a set of tab buttons. A tab bar must be provided inside of tabs to communicate with each tab.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/tab-bar)
-}
bar : List (Attribute msg) -> List (Html msg) -> Html msg
bar attributes children =
    node "ion-tab-bar" attributes children


{-| A tab button is a UI component that is placed inside of a tab bar. The tab button can specify the layout of the icon and label and connect to a tab view.

See the tabs documentation for more details on configuring tabs.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/tab-button)

-}
button : List (Attribute msg) -> List (Html msg) -> Html msg
button attributes children =
    node "ion-tab-button" attributes children


{-| A tab button that only contains an Icon
-}
iconButton : List (Attribute msg) -> String -> Html msg
iconButton attributes iconName =
    node "ion-tab-button" attributes [ Ion.Icon.basic iconName ]


{-| A tab button that only contains an Icon and a Label
-}
labeledIconButton : List (Attribute msg) -> String -> String -> Html msg
labeledIconButton attributes label iconName =
    node "ion-tab-button" attributes [ Ion.Icon.basic iconName, node "ion-label" [] [ Html.text label ] ]
