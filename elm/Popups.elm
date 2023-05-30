module Popups exposing (..)

import Form exposing (Form)
import Form.Error
import Form.View
import Html as H exposing (Html, li, node, text)
import Html.Attributes as HA exposing (attribute, class, href, placeholder, property, type_)
import Html.Events as HE exposing (on, onClick)
import Json.Decode as JD
import Json.Encode as JE
import Popup.IonicForm
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


demoForm : Form Values Output
demoForm =
    let
        emailField =
            Form.textField
                { parser =
                    \value ->
                        if String.contains "@" value then
                            Ok value

                        else
                            Err "No at sign"
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
    Popup.IonicForm.htmlView
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
