module Ion.Toolbar exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK



-- HEADER AND FOOTER ---------------------------------------------------


{-| Header is a root component of a page that aligns itself to the top of the page. It is recommended to be used as a wrapper for one or more toolbars, but it can be used to wrap any element. When a toolbar is used inside of a header, the content will be adjusted so it is sized correctly, and the header will account for any device safe areas.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/header)
-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attributes children =
    node "ion-header" attributes children


{-| Footer is a root component of a page that aligns itself to the bottom of the page. It is recommended to be used as a wrapper for one or more toolbars, but it can be used to wrap any element. When a toolbar is used inside of a footer, the content will be adjusted so it is sized correctly, and the footer will account for any device safe areas.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/footer)
-}
footer : List (Attribute msg) -> List (Html msg) -> Html msg
footer attributes children =
    node "ion-footer" attributes children


{-| Suggested attribute for `header` and `footer`.
Many native iOS applications have a fade effect on the toolbar. This can be achieved by setting the collapse property on the header/footer to "fade". When the page is first loaded, the background and border on the header will be hidden. As the content is scrolled, the header will fade back in. When the content is scrolled to the end, the background and border on the footer will fade away. This effect will only apply when the mode is "ios".

This functionality can be combined with a Condensed Header as well. The collapse property with a value set to "fade" should be on the header outside of the content.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/header#fade-header)

-}
fadeOnIos : Attribute msg
fadeOnIos =
    HA.attribute "collapse" "fade"


{-| Suggested attribute for `header` and `footer`.
Headers and Footers can match the transparency found in native iOS applications by setting the translucent property. In order to see the content scrolling behind the footer/header, the fullscreen property needs to be set on the content. This effect will only apply when the mode is "ios" and the device supports backdrop-filter.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/footer#translucent-footer)
-}
translucentOnIos : Attribute msg
translucentOnIos =
    HA.attribute "translucent" "true"


{-| Ionic provides the functionality found in native iOS applications to show a large toolbar title and then collapse it to a small title when scrolling. This can be done by adding two headers, one above the content and one inside of the content, and then setting the collapse property to "condense" on the header inside of the content. This effect will only apply when the mode is "ios".
[Ionic Docs & Preview](https://ionicframework.com/docs/api/header#condensed-header)
-}
condenseOnIos : Attribute msg
condenseOnIos =
    HA.attribute "collapse" "condense"


{-| In "md" mode, the footer will have a box-shadow on the top, the header will have it on bottom. In "ios" mode, header will receive a border on the top, footer on bottom. These can be removed by adding the .ion-no-border class to the header/footer.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/header#condensed-header)
-}
noBorder : Attribute msg
noBorder =
    HA.class "ion-no-border"



-- TOOLBAR -------------------------------------------------------------


{-| Toolbars are generally positioned above or below content and provide content and actions for the current screen. When placed within the content, toolbars will scroll with the content.

Toolbars can contain several different components including titles, buttons, icons, back buttons, menu buttons, searchbars, segments, progress bars, and more.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/toolbar)

It is recommended to put a toolbar inside of a header or footer for proper positioning. When a toolbar is placed in a header it will appear fixed at the top of the content. When it is placed in a footer it will appear fixed at the bottom. Fullscreen content will scroll behind a toolbar in a header or footer. A title component can be used to display text inside of the toolbar.

-}
toolbar : List (Attribute msg) -> List (Html msg) -> Html msg
toolbar attributes children =
    node "ion-toolbar" attributes children


{-| Content is placed to the right of the toolbar text in LTR, and to the left in RTL.
This is a "slot". Content without a slot is placed between the content with slots.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/toolbar#slots)
-}
placeEnd : Attribute msg
placeEnd =
    HA.attribute "slot" "end"


{-| Content is placed to the left of the toolbar text in LTR, and to the right in RTL.
This is a "slot". Content without a slot is placed between the content with slots.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/toolbar#slots)
-}
placeStart : Attribute msg
placeStart =
    HA.attribute "slot" "start"


{-| Content is placed to the right of the toolbar text in ios mode, and to the far right in md mode.
This is a "slot". Content without a slot is placed between the content with slots.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/toolbar#slots)
-}
placePrimary : Attribute msg
placePrimary =
    HA.attribute "slot" "primary"


{-| Content is placed to the left of the toolbar text in ios mode, and directly to the right in md mode.
This is a "slot". Content without a slot is placed between the content with slots.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/toolbar#slots)
-}
placeSecondary : Attribute msg
placeSecondary =
    HA.attribute "slot" "secondary"



-- TOOLBAR TITLE ----------------------------------------------------


{-| Title is a text component that sets the title for a toolbar. It can be used to describe the screen or section a user is currently on or the app being used.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/title)
-}
title : List (Attribute msg) -> List (Html msg) -> Html msg
title attributes children =
    node "ion-title" attributes children


{-| The large title will display when the content is scrolled to the start of the scroll container. When the title is scrolled behind the header, the condensed title will fade in. This feature is only available for iOS.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/header#fade-header)

The `buttons` component can be used with the collapse property to additionally display in the header as the toolbar is collapsed.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/title#collapsible-buttons)

-}
collapsibleLargeTitleOnIos : Attribute msg
collapsibleLargeTitleOnIos =
    HA.attribute "size" "large"



-- BUTTONS CONTAINER -----------------------------------------------------


{-| The Buttons component is a container element. It should be used inside of a toolbar and can contain several types of buttons, including standard buttons, menu buttons, and back buttons.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/buttons)

Buttons can be positioned inside of the toolbar using a named slot.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/buttons#buttons-placement)

-}
buttons : List (Attribute msg) -> List (Html msg) -> Html msg
buttons attributes children =
    node "ion-buttons" attributes children


{-| The collapse property can be set on the buttons to collapse them when the header collapses. This is typically used with collapsible large titles. This feature is only available for iOS.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/buttons#collapsible-buttons)
If true, buttons will disappear when its parent toolbar has fully collapsed if the toolbar is not the first toolbar. If the toolbar is the first toolbar, the buttons will be hidden and will only be shown once all toolbars have fully collapsed.

Only applies in ios mode with collapse set to true on ion-header.

-}
collapseButtonsOnIos : Attribute msg
collapseButtonsOnIos =
    HA.attribute "collapse" "true"



-- BACK BUTTON --------------------------------------------------------------


{-| The back button navigates back in the app's history when clicked. It is only displayed when there is history in the navigation stack, unless defaultHref is set. The back button displays different text and icon based on the mode, but this can be customized.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/back-button)
-}
backButton : List (Attribute msg) -> List (Html msg) -> Html msg
backButton attributes children =
    node "ion-back-button" attributes children


{-| By default, the back button will display the text "Back" with a "chevron-back" icon on ios, and an "arrow-back-sharp" icon on md. This can be customized per back button component by setting the icon or text properties. Alternatively, it can be set globally using the backButtonIcon or backButtonText properties in the global config. See the Config docs for more information.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/back-button#custom-back-button)
-}
customBackText : String -> Attribute msg
customBackText backButtonText =
    HA.attribute "text" backButtonText


{-| By default, the back button will display the text "Back" with a "chevron-back" icon on ios, and an "arrow-back-sharp" icon on md. This can be customized per back button component by setting the icon or text properties. Alternatively, it can be set globally using the backButtonIcon or backButtonText properties in the global config. See the Config docs for more information.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/back-button#custom-back-button)
-}
customBackIcon : String -> Attribute msg
customBackIcon backButtonIcon =
    HA.attribute "icon" backButtonIcon
