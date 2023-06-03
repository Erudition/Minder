module Popups exposing (..)

import Form exposing (Form)
import Form.Error
import Form.View
import Html as H exposing (Html, li, node, text)
import Html.Attributes as HA exposing (attribute, class, href, placeholder, property, type_)
import Html.Events as HE exposing (on, onClick)
import Json.Decode as JD
import Json.Encode as JE
import Popup.Editor.Task as TaskEditor
import Popup.IonicForm
import Replicated.Change as Change


type Popup
    = ProjectEditor TaskEditor.Model
    | JustText (Html ())


type Msg
    = ProjectEditorMsg TaskEditor.Msg
    | JustTextMsg
    | SaveChanges Change.Frame


update : Msg -> Popup -> Popup
update msg model =
    case ( model, msg ) of
        ( ProjectEditor projectEditorModel, ProjectEditorMsg projectEditorMsg ) ->
            ProjectEditor (TaskEditor.update projectEditorMsg projectEditorModel)

        ( JustText _, JustTextMsg ) ->
            model

        _ ->
            model


viewPopup : Popup -> Html Msg
viewPopup popup =
    case popup of
        ProjectEditor formModel ->
            TaskEditor.view formModel
                |> H.map ProjectEditorMsg

        JustText htmlWithoutMsg ->
            htmlWithoutMsg
                |> H.map (\_ -> JustTextMsg)


fromString : (String -> Maybe a) -> Maybe a -> String -> Maybe a
fromString parse currentValue input =
    if String.isEmpty input then
        Nothing

    else
        parse input
            |> Maybe.map Just
            |> Maybe.withDefault currentValue
