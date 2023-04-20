module Ion.Icon exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK


{-| Icon is a simple component made available through the Ionicons library, which comes pre-packaged by default with all Ionic Framework applications. It can be used to display any icon from the Ionicons set, or a custom SVG. It also has support for styling such as size and color.

For a list of all available icons, see ionic.io/ionicons. For more information including styling and custom SVG usage, see the Usage page.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/icon)

-}
basic : String -> Html msg
basic iconName =
    node "ion-icon" [ HA.name iconName ] []


withAttr : String -> List (Attribute msg) -> Html msg
withAttr iconName attributes =
    node "ion-icon" (HA.name iconName :: attributes) []
