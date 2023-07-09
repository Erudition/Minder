module Ion.ActionSheet exposing (..)

import Helpers exposing (encodeObjectWithoutNothings, loggingDecoder, normal, omittable)
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA exposing (attribute, property)
import Html.Events as HE
import Json.Decode as JD
import Json.Encode as JE
import List.Extra


{-| A button can also be passed data via the data property on ActionSheetButton. This will populate the data field in the return value of the onDidDismiss method.
-}
type alias Button msg =
    { text : String
    , role : Maybe Role
    , icon : Maybe String
    , actionString : String
    , actionMsg : msg
    }


encodeButton : Button msg -> JE.Value
encodeButton buttonToEncode =
    encodeObjectWithoutNothings
        [ normal ( "text", JE.string buttonToEncode.text )
        , omittable ( "role", encodeRole, buttonToEncode.role )
        , omittable ( "icon", JE.string, buttonToEncode.icon )
        , normal ( "data", JE.object [ ( "action", JE.string buttonToEncode.actionString ) ] )
        ]


button : String -> msg -> Button msg
button label action =
    { text = label
    , role = Nothing
    , actionString = label
    , actionMsg = action
    , icon = Nothing
    }


deleteButton : msg -> Button msg
deleteButton action =
    { text = "Delete"
    , role = Just Destructive
    , actionString = "Delete"
    , actionMsg = action
    , icon = Just "trash-outline"
    }


{-| A button's role property can either be destructive or cancel. Buttons without a role property will have the default look for the platform. Buttons with the cancel role will always load as the bottom button, no matter where they are in the array. All other buttons will be displayed in the order they have been added to the buttons array. Note: We recommend that destructive buttons are always the first button in the array, making them the top button. Additionally, if the action sheet is dismissed by tapping the backdrop, then it will fire the handler from the button with the cancel role.
-}
type Role
    = Destructive
    | Cancel


encodeRole : Role -> JE.Value
encodeRole role =
    case role of
        Destructive ->
            JE.string "destructive"

        Cancel ->
            JE.string "cancel"


actionSheet : List (Attribute msg) -> List (Button msg) -> Html msg
actionSheet props buttons =
    let
        buttonProp =
            property "buttons" (JE.list encodeButton buttons)

        onDismiss =
            -- TODO change to WillDismiss so there's no delay triggering the message.
            -- need DidDismiss for now so elm doesn't try to remove the sheet while it's closing, which works fine but logs an error.
            HE.on "ionActionSheetDidDismiss" handler

        handler =
            JD.at [ "detail", "data", "action" ] JD.string
                |> JD.andThen getButtonEvent

        getButtonEvent actionString =
            List.Extra.find (\b -> b.actionString == actionString) buttons
                |> Maybe.map .actionMsg
                |> Maybe.map JD.succeed
                |> Maybe.withDefault (JD.fail actionString)

        allAttributes =
            props ++ [ buttonProp, onDismiss ]
    in
    H.node "ion-action-sheet" allAttributes []


{-| If true, the action sheet will animate. Default true.
-}
animated : Bool -> Attribute msg
animated shouldAnimate =
    property "animated" (JE.bool shouldAnimate)


{-| If true, the action sheet will be dismissed when the backdrop is clicked. Default true.
-}
backdropDismiss : Bool -> Attribute msg
backdropDismiss shouldDismissOnBackdropTap =
    property "backdropDismiss" (JE.bool shouldDismissOnBackdropTap)


{-| Additional classes to apply for custom CSS. If multiple classes are provided they should be separated by spaces.
-}
cssClass : String -> Attribute msg
cssClass classes =
    attribute "css-class" classes


{-| Title for the action sheet.
-}
header : String -> Attribute msg
header headerString =
    attribute "header" headerString


{-| If true, the action sheet will open. If false, the action sheet will close.
isOpen will not automatically be set back to false when the action sheet dismisses. You will need to do that in your code.
-}
isOpen : Bool -> Attribute msg
isOpen openSheet =
    property "isOpen" (JE.bool openSheet)


{-| If true, the keyboard will be automatically dismissed when the overlay is presented. Default true.
-}
keyboardClose : Bool -> Attribute msg
keyboardClose keyboardShouldClose =
    property "keyboardClose" (JE.bool keyboardShouldClose)


{-| Subtitle for the action sheet.
-}
subHeader : String -> Attribute msg
subHeader subHeaderString =
    attribute "sub-header" subHeaderString


{-| If true, the action sheet will be translucent. Only applies when the mode is "ios" and the device supports backdrop-filter.
-}
translucent : Bool -> Attribute msg
translucent isTranslucent =
    property "translucent" (JE.bool isTranslucent)


{-| An ID corresponding to the trigger element that causes the action sheet to open when clicked.
-}
trigger : String -> Attribute msg
trigger triggerID =
    attribute "trigger" triggerID
