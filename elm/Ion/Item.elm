module Ion.Item exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK


{-| Items are elements that can contain text, icons, avatars, images, inputs, and any other native or custom elements. Generally they are placed in a list with other items. Items can be swiped, deleted, reordered, edited, and more.

Items left align text and add an ellipsis when the text is wider than the item. We can modify this behavior using the CSS Utilities provided by Ionic Framework, such as using .ion-text-wrap in the below example. See the CSS Utilities Documentation for more classes that can be added to an item to transform the text.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item)

-}
item : List (Attribute msg) -> List (Html msg) -> Html msg
item attributes children =
    node "ion-item" attributes children


{-| Items left align text and add an ellipsis when the text is wider than the item. We can modify this behavior using the CSS Utilities provided by Ionic Framework, such as using .ion-text-wrap in the below example. See the CSS Utilities Documentation for more classes that can be added to an item to transform the text.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/item#basic-usage)
-}
textWrap : Attribute msg
textWrap =
    HA.class "ion-text-wrap"


{-| Items show an inset bottom border by default. The border has padding on the left and does not appear under any content that is slotted in the "start" slot. The lines property can be modified to "full" or "none" which will show a full width border or no border, respectively.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item#item-lines)

-}
linesFull : Attribute msg
linesFull =
    HA.attribute "lines" "full"


{-| Items show an inset bottom border by default. The border has padding on the left and does not appear under any content that is slotted in the "start" slot. The lines property can be modified to "full" or "none" which will show a full width border or no border, respectively.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item#item-lines)

-}
linesInset : Attribute msg
linesInset =
    HA.attribute "lines" "inset"


{-| Items show an inset bottom border by default. The border has padding on the left and does not appear under any content that is slotted in the "start" slot. The lines property can be modified to "full" or "none" which will show a full width border or no border, respectively.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item#item-lines)

-}
linesNone : Attribute msg
linesNone =
    HA.attribute "lines" "none"


{-| An item is considered "clickable" if it has an href or button property set. Clickable items have a few visual differences that indicate they can be interacted with. For example, a clickable item receives the ripple effect upon activation in md mode, has a highlight when activated in ios mode, and has a detail arrow by default in ios mode.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item#clickable-items)

-}
button : Attribute msg
button =
    HA.attribute "button" "true"


{-| By default clickable items will display a right arrow icon on ios mode. To hide the right arrow icon on clickable elements, set the detail property to false. To show the right arrow icon on an item that doesn't display it naturally, set the detail property to true.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item#detail-arrows)

-}
detail : Attribute msg
detail =
    HA.attribute "detail" "true"



--- SLIDING --------------------------------------------


{-| A sliding item contains an item that can be dragged to reveal option buttons. It requires an item component as a child. All options to reveal should be placed in the item options element.

Sliding item options are placed on the "end" side of the item by default. This means that options are revealed when the item is swiped from end to start, i.e. from right to left in LTR, but from left to right in RTL. To place them on the opposite side, so that they are revealed when swiping in the opposite direction, set the side attribute to "start" on the item options element. Up to two item options can be used at the same time in order to reveal two different sets of options depending on the swiping direction.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item-sliding)

-}
sliding : List (Attribute msg) -> List (Html msg) -> Html msg
sliding attributes children =
    node "ion-item-sliding" attributes children


{-| The item options component is a container for the item option buttons in a sliding item. These buttons can be placed either on the start or end side.

See the item sliding documentation for more information.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item-options)

-}
options : List (Attribute msg) -> List (Html msg) -> Html msg
options attributes children =
    node "ion-item-options" attributes children


{-| The item option component is an button for a sliding item. It must be placed inside of item `options`. The ionSwipe event and the expandable property can be combined to create a full swipe action for the item.

See the item sliding documentation for more information.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item-option)

-}
option : List (Attribute msg) -> List (Html msg) -> Html msg
option attributes children =
    node "ion-item-option" attributes children


{-| If true, the option will expand to take up the available width and cover any other options.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/item-option#expandable)

-}
expandable : Attribute msg
expandable =
    HA.attribute "expandable" "true"



--- LABEL ----------------------------------------------------


{-| Label is a wrapper element that can be used in combination with ion-item, ion-input, ion-toggle, and more. The position of the label inside of an item can be inline, fixed, stacked, or floating.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/label)

-}
label : List (Attribute msg) -> List (Html msg) -> Html msg
label attributes children =
    node "ion-label" attributes children


{-| Notes are text elements generally used as subtitles that provide more information. They are styled to appear grey by default. Notes can be used in an item as metadata text.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/note)

-}
note : List (Attribute msg) -> List (Html msg) -> Html msg
note attributes children =
    node "ion-note" attributes children
