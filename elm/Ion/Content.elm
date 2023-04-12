module Ion.Content exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK


{-| App is a container element for an Ionic application. There should only be one <ion-app> element per project. An app can have many Ionic components including menus, headers, content, and footers. The overlay components get appended to the <ion-app> when they are presented.

Using ion-app enables the following behaviors:

    Keyboard Lifecycle Events without the need for any native plugins
    Hardware Back Button Listeners for customizing the hardware back button behavior on Android devices
    Status bar support in Capacitor or Cordova which allows users to scroll to the top of the view by tapping the status bar
    Scroll assist utilities which scroll the content so focused text inputs are not covered by the on-screen keyboard
    Ripple effect when activating buttons on Material Design mode
    Other tap and focus utilities which make the experience of using an Ionic app feel more native

[Ionic Docs & Preview](https://ionicframework.com/docs/api/app)

-}
app : List (Html msg) -> Html msg
app children =
    node "ion-app" [] children


{-| App is a container element for an Ionic application. There should only be one <ion-app> element per project. An app can have many Ionic components including menus, headers, content, and footers. The overlay components get appended to the <ion-app> when they are presented.

Using ion-app enables the following behaviors:

    Keyboard Lifecycle Events without the need for any native plugins
    Hardware Back Button Listeners for customizing the hardware back button behavior on Android devices
    Status bar support in Capacitor or Cordova which allows users to scroll to the top of the view by tapping the status bar
    Scroll assist utilities which scroll the content so focused text inputs are not covered by the on-screen keyboard
    Ripple effect when activating buttons on Material Design mode
    Other tap and focus utilities which make the experience of using an Ionic app feel more native

[Ionic Docs & Preview](https://ionicframework.com/docs/api/app)

-}
appWithAttributes : List (Attribute msg) -> List (Html msg) -> Html msg
appWithAttributes attributes children =
    node "ion-app" attributes children



-- CONTENT ----------------------------------------------------


{-| The content component provides an easy to use content area with some useful methods to control the scrollable area. There should only be one content in a single view.

Content, along with many other Ionic components, can be customized to modify its padding, margin, and more using the global styles provided in the CSS Utilities or by individually styling it using CSS and the available CSS Custom Properties.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/content)

-}
content : List (Attribute msg) -> List (Html msg) -> Html msg
content attributes children =
    node "ion-content" attributes children
