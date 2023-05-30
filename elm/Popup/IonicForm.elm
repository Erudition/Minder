module Popup.IonicForm exposing (..)

import Form exposing (Form)
import Form.Error
import Form.View
import Html as H exposing (Html, li, node, text)
import Html.Attributes as HA exposing (attribute, class, href, placeholder, property, type_)
import Html.Events as HE exposing (on, onClick)
import Json.Decode as JD
import Json.Encode as JE


htmlView : Form.View.ViewConfig values msg -> Form values msg -> Form.View.Model values -> Html msg
htmlView =
    Form.View.custom
        { form = form
        , textField = inputField "text"
        , emailField = inputField "email"
        , passwordField = inputField "password"
        , searchField = inputField "search"
        , textareaField = textareaField
        , numberField = numberField
        , rangeField = rangeField
        , checkboxField = checkboxField
        , radioField = radioField
        , selectField = selectField
        , group = group
        , section = section
        , formList = formList
        , formListItem = formListItem
        }


inputField : String -> Form.View.TextFieldConfig msg -> Html msg
inputField type_ { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        errorString =
            case error of
                Just (Form.Error.External externalError) ->
                    externalError

                Just otherError ->
                    errorToString otherError

                Nothing ->
                    "No errors."
    in
    H.node "ion-input"
        ([ HE.onInput onChange
         , HA.disabled disabled
         , HA.value value
         , HA.placeholder attributes.placeholder
         , HA.type_ type_
         , HA.attribute "error-text" errorString
         , HA.attribute "label-placement" "stacked"
         , HA.attribute "label" attributes.label
         , HA.classList [ ( "ion-invalid", showError ), ( "ion-valid", value /= "" && not showError ), ( "ion-touched", value /= "" ) ]
         ]
            |> withMaybeAttribute HE.onBlur onBlur
            |> withHtmlAttributes attributes.htmlAttributes
        )
        []


textareaField : Form.View.TextFieldConfig msg -> Html msg
textareaField { onChange, onBlur, disabled, value, error, showError, attributes } =
    H.node "textarea"
        ([ HE.onInput onChange
         , HA.disabled disabled
         , HA.placeholder attributes.placeholder
         , HA.value value
         ]
            |> withMaybeAttribute HE.onBlur onBlur
            |> withHtmlAttributes attributes.htmlAttributes
        )
        []
        |> withLabelAndError attributes.label showError error


numberField : Form.View.NumberFieldConfig msg -> Html msg
numberField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        stepAttr =
            attributes.step
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "any"
    in
    H.node "ion-input"
        ([ HE.onInput onChange
         , HA.disabled disabled
         , HA.value value
         , HA.placeholder attributes.placeholder
         , HA.type_ "number"
         , HA.step stepAttr
         ]
            |> withMaybeAttribute (String.fromFloat >> HA.max) attributes.max
            |> withMaybeAttribute (String.fromFloat >> HA.min) attributes.min
            |> withMaybeAttribute HE.onBlur onBlur
            |> withHtmlAttributes attributes.htmlAttributes
        )
        []
        |> withLabelAndError attributes.label showError error


rangeField : Form.View.RangeFieldConfig msg -> Html msg
rangeField { onChange, onBlur, disabled, value, error, showError, attributes } =
    H.node "ion-range"
        [ HA.class "elm-form-range-field" ]
        [ H.input
            ([ HE.onInput (fromString String.toFloat value >> onChange)
             , HA.disabled disabled
             , HA.value (value |> Maybe.map String.fromFloat |> Maybe.withDefault "")
             , HA.type_ "range"
             , HA.step (String.fromFloat attributes.step)
             ]
                |> withMaybeAttribute (String.fromFloat >> HA.max) attributes.max
                |> withMaybeAttribute (String.fromFloat >> HA.min) attributes.min
                |> withMaybeAttribute HE.onBlur onBlur
                |> withHtmlAttributes attributes.htmlAttributes
            )
            []
        , H.span [] [ H.text (value |> Maybe.map String.fromFloat |> Maybe.withDefault "") ]
        ]
        |> withLabelAndError attributes.label showError error


checkboxField : Form.View.CheckboxFieldConfig msg -> Html msg
checkboxField { onChange, onBlur, value, disabled, error, showError, attributes } =
    [ H.node "ion-toggle"
        ([ HE.onCheck onChange
         , HA.checked value
         , HA.disabled disabled
         , HA.type_ "checkbox"
         ]
            |> withMaybeAttribute HE.onBlur onBlur
            |> withHtmlAttributes attributes.htmlAttributes
        )
        []
    , H.node "ion-label" [] [ H.text attributes.label ]
    , maybeErrorMessage showError error
    ]
        |> wrapInFieldContainer showError error


radioField : Form.View.RadioFieldConfig msg -> Html msg
radioField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        radio ( key, label ) =
            H.label []
                [ H.input
                    ([ HA.name attributes.label
                     , HA.value key
                     , HA.checked (value == key)
                     , HA.disabled disabled
                     , HA.type_ "radio"
                     , HE.onClick (onChange key)
                     ]
                        |> withMaybeAttribute HE.onBlur onBlur
                        |> withHtmlAttributes attributes.htmlAttributes
                    )
                    []
                , H.text label
                ]
    in
    H.div (fieldContainerAttributes showError error)
        ((fieldLabel attributes.label
            :: List.map radio attributes.options
         )
            ++ [ maybeErrorMessage showError error ]
        )


selectField : Form.View.SelectFieldConfig msg -> Html msg
selectField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        toOption ( key, label_ ) =
            H.node "ion-select-option"
                [ HA.value key
                , HA.selected (value == key)
                ]
                [ H.text label_ ]

        placeholderOption =
            H.option
                [ HA.disabled True
                , HA.selected (value == "")
                ]
                [ H.text ("-- " ++ attributes.placeholder ++ " --") ]
    in
    H.node "ion-select"
        ([ HE.on "change" (JD.map onChange HE.targetValue)
         , HA.disabled disabled
         ]
            |> withMaybeAttribute HE.onBlur onBlur
            |> withHtmlAttributes attributes.htmlAttributes
        )
        (placeholderOption :: List.map toOption attributes.options)
        |> withLabelAndError attributes.label showError error


group : List (Html msg) -> Html msg
group =
    H.div [ HA.class "elm-form-group" ]


section : String -> List (Html msg) -> Html msg
section title fields =
    H.fieldset []
        (H.legend [] [ H.text title ]
            :: fields
        )


withLabelAndError : String -> Bool -> Maybe Form.Error.Error -> Html msg -> Html msg
withLabelAndError label showError error fieldAsHtml =
    [ fieldLabel label
    , fieldAsHtml
    , maybeErrorMessage showError error
    ]
        |> wrapInFieldContainer showError error


wrapInFieldContainer : Bool -> Maybe Form.Error.Error -> List (Html msg) -> Html msg
wrapInFieldContainer showError error =
    H.node "ion-item" (fieldContainerAttributes showError error)


fieldContainerAttributes : Bool -> Maybe Form.Error.Error -> List (H.Attribute msg)
fieldContainerAttributes showError error =
    [ HA.classList
        [ ( "elm-form-field", True )
        , ( "elm-form-field-error", showError && error /= Nothing )
        ]
    ]


fieldLabel : String -> Html msg
fieldLabel label =
    H.node "ion-label" [ HA.class "elm-form-label", HA.attribute "position" "floating" ] [ H.text label ]


maybeErrorMessage : Bool -> Maybe Form.Error.Error -> Html msg
maybeErrorMessage showError maybeError =
    case maybeError of
        Just (Form.Error.External externalError) ->
            errorMessage externalError

        _ ->
            if showError then
                maybeError
                    |> Maybe.map errorToString
                    |> Maybe.map errorMessage
                    |> Maybe.withDefault (H.text "")

            else
                H.text ""


successMessage : String -> Html msg
successMessage =
    H.text >> List.singleton >> H.div [ HA.class "elm-form-success" ]


errorMessage : String -> Html msg
errorMessage =
    H.text >> List.singleton >> H.div [ HA.class "elm-form-error" ]


errorToString : Form.Error.Error -> String
errorToString error =
    case error of
        Form.Error.RequiredFieldIsEmpty ->
            "This field is required"

        Form.Error.ValidationFailed validationError ->
            validationError

        Form.Error.External externalError ->
            externalError


form : Form.View.FormConfig msg (Html msg) -> Html msg
form { onSubmit, action, loading, state, fields } =
    let
        onSubmitEvent =
            onSubmit
                |> Maybe.map (HE.onSubmit >> List.singleton)
                |> Maybe.withDefault []
    in
    H.form (HA.class "elm-form" :: onSubmitEvent)
        (List.concat
            [ fields
            , [ case state of
                    Form.View.Error error ->
                        errorMessage error

                    Form.View.Success success ->
                        successMessage success

                    _ ->
                        H.text ""
              , H.node "ion-button"
                    [ HA.type_ "submit"
                    , HA.disabled (onSubmit == Nothing)
                    ]
                    [ if state == Form.View.Loading then
                        H.text loading

                      else
                        H.text action
                    ]
              ]
            ]
        )


withHtmlAttributes : List ( String, String ) -> List (H.Attribute msg) -> List (H.Attribute msg)
withHtmlAttributes list attributes =
    List.map (\( a, b ) -> HA.attribute a b) list
        |> (++) attributes


withMaybeAttribute : (a -> H.Attribute msg) -> Maybe a -> List (H.Attribute msg) -> List (H.Attribute msg)
withMaybeAttribute toAttribute maybeValue attrs =
    Maybe.map (toAttribute >> (\attr -> attr :: attrs)) maybeValue
        |> Maybe.withDefault attrs


fromString : (String -> Maybe a) -> Maybe a -> String -> Maybe a
fromString parse currentValue input =
    if String.isEmpty input then
        Nothing

    else
        parse input
            |> Maybe.map Just
            |> Maybe.withDefault currentValue


{-| Describes how a form list should be rendered.

  - `forms` is a list containing the elements of the form list.
  - `add` describes an optional "add an element" button. It contains a lazy `action` that can be called in order to add a new element and a `label` for the button.

-}
type alias FormListConfig msg element =
    { forms : List element
    , label : String
    , add : Maybe { action : () -> msg, label : String }
    , disabled : Bool
    }


{-| Describes how an item in a form list should be rendered.

  - `fields` contains the different fields of the item.
  - `delete` describes an optional "delete item" button. It contains a lazy `action` that can be called in order to delete the item and a `label` for the button.

-}
type alias FormListItemConfig msg element =
    { fields : List element
    , delete : Maybe { action : () -> msg, label : String }
    , disabled : Bool
    }


formList : FormListConfig msg (Html msg) -> Html msg
formList { forms, label, add, disabled } =
    let
        addButton =
            case ( disabled, add ) of
                ( False, Just add_ ) ->
                    H.button
                        [ HE.onClick add_.action
                        , HA.type_ "button"
                        ]
                        [ H.i [ HA.class "fas fa-plus" ] []
                        , H.text add_.label
                        ]
                        |> H.map (\f -> f ())

                _ ->
                    H.text ""
    in
    H.div [ HA.class "elm-form-list" ]
        (fieldLabel label
            :: (forms ++ [ addButton ])
        )


formListItem : FormListItemConfig msg (Html msg) -> Html msg
formListItem { fields, delete, disabled } =
    let
        deleteButton =
            case ( disabled, delete ) of
                ( False, Just delete_ ) ->
                    H.button
                        [ HE.onClick delete_.action
                        , HA.type_ "button"
                        ]
                        [ H.text delete_.label
                        , H.i [ HA.class "fas fa-times" ] []
                        ]
                        |> H.map (\f -> f ())

                _ ->
                    H.text ""
    in
    H.div [ HA.class "elm-form-list-item" ]
        (deleteButton :: fields)
