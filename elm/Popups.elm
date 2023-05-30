module Popups exposing (..)

import Form exposing (Form)
import Form.Error
import Form.View
import Html as H exposing (Html, li, node, text)
import Html.Attributes as HA exposing (attribute, class, href, placeholder, property, type_)
import Html.Events as HE exposing (on, onClick)
import Json.Decode as JD
import Json.Encode as JE
import Task.AssignedAction as AssignedAction exposing (AssignedAction)


type Popup
    = ProjectEditor AssignedAction
    | Form Model


type Msg
    = FormChanged Model
    | Submit Output


type alias Model =
    Form.View.Model Values


type alias Values =
    { email : String
    , password : String
    , rememberMe : Bool
    }


type alias Output =
    { email : String
    , password : String
    , rememberMe : Bool
    }


initialModel : Model
initialModel =
    { email = ""
    , password = ""
    , rememberMe = False
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newModel ->
            newModel

        Submit { email, password, rememberMe } ->
            { model | state = Form.View.Loading }


htmlView : Form.View.ViewConfig Values msg -> Form Values msg -> Model -> Html msg
htmlView =
    let
        htmlViewConfig =
            Form.View.htmlViewConfig
    in
    Form.View.custom
        { htmlViewConfig
            | textField = inputField "text"
            , passwordField = inputField "password"
            , checkboxField = checkboxField
        }


inputField : String -> Form.View.TextFieldConfig msg -> Html msg
inputField type_ { onChange, onBlur, disabled, value, error, showError, attributes } =
    H.node "ion-input"
        ([ HE.onInput onChange
         , HA.disabled disabled
         , HA.value value
         , HA.placeholder attributes.placeholder
         , HA.type_ type_
         ]
            |> withMaybeAttribute HE.onBlur onBlur
            |> withHtmlAttributes attributes.htmlAttributes
        )
        []
        |> withLabelAndError attributes.label showError error


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
    [ H.div [ HA.class "elm-form-label" ]
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
        , H.text attributes.label
        ]
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
    H.label (fieldContainerAttributes showError error)


fieldContainerAttributes : Bool -> Maybe Form.Error.Error -> List (H.Attribute msg)
fieldContainerAttributes showError error =
    [ HA.classList
        [ ( "elm-form-field", True )
        , ( "elm-form-field-error", showError && error /= Nothing )
        ]
    ]


fieldLabel : String -> Html msg
fieldLabel label =
    H.div [ HA.class "elm-form-label" ] [ H.text label ]


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


withHtmlAttributes : List ( String, String ) -> List (H.Attribute msg) -> List (H.Attribute msg)
withHtmlAttributes list attributes =
    List.map (\( a, b ) -> HA.attribute a b) list
        |> (++) attributes


withMaybeAttribute : (a -> H.Attribute msg) -> Maybe a -> List (H.Attribute msg) -> List (H.Attribute msg)
withMaybeAttribute toAttribute maybeValue attrs =
    Maybe.map (toAttribute >> (\attr -> attr :: attrs)) maybeValue
        |> Maybe.withDefault attrs


demoForm : Form Values Output
demoForm =
    let
        emailField =
            Form.textField
                { parser = Ok
                , value = .email
                , update = \value values -> { values | email = value }
                , error = always Nothing
                , attributes =
                    { label = "E-Mail"
                    , placeholder = "some@email.com"
                    , htmlAttributes = []
                    }
                }

        passwordField =
            Form.passwordField
                { parser = Ok
                , value = .password
                , update = \value values -> { values | password = value }
                , error = always Nothing
                , attributes =
                    { label = "Password"
                    , placeholder = "Your password"
                    , htmlAttributes = []
                    }
                }

        rememberMeCheckbox =
            Form.checkboxField
                { parser = Ok
                , value = .rememberMe
                , update = \value values -> { values | rememberMe = value }
                , error = always Nothing
                , attributes =
                    { label = "Remember me"
                    , htmlAttributes = []
                    }
                }
    in
    Form.succeed Output
        |> Form.append emailField
        |> Form.append passwordField
        |> Form.append rememberMeCheckbox


view : Model -> Html Msg
view =
    htmlView
        { onChange = FormChanged
        , action = "Log in"
        , loading = "Logging in..."
        , validation = Form.View.ValidateOnSubmit
        }
        (Form.map Submit demoForm)


viewPopup : Popup -> Html Msg
viewPopup popup =
    case popup of
        Form formModel ->
            view formModel

        _ ->
            H.text "Not a form popup"


fromString : (String -> Maybe a) -> Maybe a -> String -> Maybe a
fromString parse currentValue input =
    if String.isEmpty input then
        Nothing

    else
        parse input
            |> Maybe.map Just
            |> Maybe.withDefault currentValue
