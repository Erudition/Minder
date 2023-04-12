module Ion.List exposing (..)

import Html exposing (Attribute, Html, node)
import Html.Attributes as HA
import Html.Keyed as HK


{-| Lists are made up of multiple rows of items which can contain text, buttons, toggles, icons, thumbnails, and much more. Lists generally contain items with similar data content, such as images and text.

Lists support several interactions including swiping items to reveal options, dragging to reorder items within the list, and deleting items.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/list)

-}
list : List (Attribute msg) -> List (Html msg) -> Html msg
list attributes children =
    node "ion-list" attributes children


{-| Adding the inset property to a list will apply margin around the list. In ios mode it will also add rounded corners to the list.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/list#inset-list)
-}
inset : Attribute msg
inset =
    HA.attribute "inset" "true"


{-| Adding the lines property to a list will adjust the bottom borders of all of the items in the list. Setting it to "full" will display full width borders, "inset" will display borders adjusted with left padding, and "none" will show no borders. If the lines property is set on an item in a list, that will take priority over the property on the list.

Also works on list headers.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/list#list-lines)

-}
linesFull : Attribute msg
linesFull =
    HA.attribute "lines" "full"


{-| Adding the lines property to a list will adjust the bottom borders of all of the items in the list. Setting it to "full" will display full width borders, "inset" will display borders adjusted with left padding, and "none" will show no borders. If the lines property is set on an item in a list, that will take priority over the property on the list.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/list#list-lines)

Also works on list headers.

-}
linesInset : Attribute msg
linesInset =
    HA.attribute "lines" "inset"


{-| Adding the lines property to a list will adjust the bottom borders of all of the items in the list. Setting it to "full" will display full width borders, "inset" will display borders adjusted with left padding, and "none" will show no borders. If the lines property is set on an item in a list, that will take priority over the property on the list.
[Ionic Docs & Preview](https://ionicframework.com/docs/api/list#list-lines)
-}
linesNone : Attribute msg
linesNone =
    HA.attribute "lines" "none"



-- HEADERS -------------------------------------------------------


{-| List headers are block elements that are used to describe the contents of a list. Unlike item dividers, list headers should only be used once at the top of a list of items.

[Ionic Docs & Preview](https://ionicframework.com/docs/api/list-header)

-}
header : List (Attribute msg) -> List (Html msg) -> Html msg
header attributes children =
    node "ion-list-header" attributes children
