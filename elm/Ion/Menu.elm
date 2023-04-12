module Ion.Menu exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK


{-| The Menu component is a navigation drawer that slides in from the side of the current view. By default, it slides in from the left, but the side can be overridden. The menu will be displayed differently based on the mode, however the display type can be changed to any of the available menu types. The menu element should be a sibling to the root content element. There can be any number of menus attached to the content. These can be controlled from the templates, or programmatically using the MenuController.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu)
-}
menu : List (Attribute msg) -> List (Html msg) -> Html msg
menu attributes children =
    node "ion-menu" attributes children


{-| The id of the main content. When using a router this is typically ion-router-outlet. When not using a router, this is typically your main view's ion-content. This is not the id of the ion-content inside of your ion-menu.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu#contentid)
-}
contentID : String -> Attribute msg
contentID content =
    HA.attribute "content-id" content


{-| The ion-menu-toggle component can be used to create custom button that can open or close the menu.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu#menu-toggle)
-}
menuToggle : List (Attribute msg) -> List (Html msg) -> Html msg
menuToggle attributes children =
    node "ion-menu-toggle" attributes children


{-| The type property can be used to customize how menus display in your application.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu#menu-types)

-}
overlay : Attribute msg
overlay =
    HA.attribute "type" "overlay"


{-| The type property can be used to customize how menus display in your application.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu#menu-types)

-}
reveal : Attribute msg
reveal =
    HA.attribute "type" "reveal"


{-| The type property can be used to customize how menus display in your application.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu#menu-types)

-}
push : Attribute msg
push =
    HA.attribute "type" "push"



--- BUTTON -----------------------------------------------------------------------


{-| The Menu Button component contains an icon and automatically adds functionality to open a menu when clicked.

See the menu documentation for more information.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu-button)

-}
button : List (Attribute msg) -> List (Html msg) -> Html msg
button attributes children =
    node "ion-menu-button" attributes children


{-| The Menu Toggle component can be used to toggle a menu open or closed.

Menu toggles are only visible when the selected menu is enabled. If the menu is disabled or it's being presented as a split pane, the menu toggle will be hidden. To always display the menu toggle, the autoHide property can be set to false.

See the menu documentation for more information.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu-toggle)

-}
toggle : List (Attribute msg) -> List (Html msg) -> Html msg
toggle attributes children =
    node "ion-menu-toggle" attributes children


{-| Automatically hides the content when the corresponding menu is not active.

By default, it's true. Change it to false in order to keep ion-menu-toggle always visible regardless the state of the menu.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu-toggle#autohide)

-}
autoHide : Bool -> Attribute msg
autoHide shouldAutoHide =
    HA.attribute "autohide"
        (if shouldAutoHide then
            "true"

         else
            "false"
        )


{-| Optional property that maps to a Menu's menuId prop. Can also be start or end for the menu side. This is used to find the correct menu to toggle.

If this property is not used, ion-menu-toggle will toggle the first menu that is active.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu-toggle#menu)

-}
whichMenu : String -> Attribute msg
whichMenu sideOrMenuID =
    HA.attribute "menu" sideOrMenuID



-- SPLIT PANE -------------------------------------------------------------------


{-| A split pane is useful when creating multi-view layouts. It allows UI elements, like menus, to be displayed as the viewport width increases.

If the device's screen width is below a certain size, the split pane will collapse and the menu will be hidden. This is ideal for creating an app that will be served in a browser and deployed through the app store to phones and tablets.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/split-pane)

-}
splitPane : List (Attribute msg) -> List (Html msg) -> Html msg
splitPane attributes children =
    node "ion-split-pane" attributes children


{-| By default, the split pane will expand when the screen is larger than 992px. To customize this, pass a breakpoint in the when property. The when property can accept a boolean value, any valid media query, or one of Ionic's predefined sizes.
[Breakpoints](https://ionicframework.com/docs/api/split-pane#setting-breakpoints)

When the split-pane should be shown. Can be a CSS media query expression, or a shortcut expression. Can also be a boolean expression.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/menu-toggle#menu)

-}
when : String -> Attribute msg
when breakpoint =
    HA.attribute "when" breakpoint
