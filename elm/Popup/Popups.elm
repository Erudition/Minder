module Popup.Popups exposing (Model, Msg, getCorrectModel, init, update, viewPopup)

import Effect exposing (Effect)
import Form
import Html as H exposing (Html)
import Html.Attributes
import Html.Events
import Popup.Editor.Task as TaskEditor
import Replicated.Change as Change
import Shared.Model exposing (Shared)
import Shared.PopupType as PopupType exposing (PopupType)


type Model
    = ProjectEditor TaskEditor.Model
    | JustText (Html ())


type Msg
    = ProjectEditorMsg TaskEditor.Msg
    | JustTextMsg


init : PopupType -> Model
init popupType =
    case popupType of
        PopupType.ProjectEditor maybeAction ->
            ProjectEditor <| TaskEditor.initialModel maybeAction

        PopupType.JustText _ ->
            JustText (H.div [] [ H.text "Just text" ])


update : Msg -> Model -> Shared -> ( Model, List (Effect msg) )
update msg model shared =
    let
        correctModel =
            getCorrectModel shared model
    in
    case ( correctModel, msg ) of
        ( ProjectEditor projectEditorModel, ProjectEditorMsg projectEditorMsg ) ->
            let
                ( outModel, outEffects ) =
                    TaskEditor.update projectEditorMsg projectEditorModel
            in
            ( ProjectEditor outModel, outEffects )

        ( JustText _, JustTextMsg ) ->
            ( correctModel, [] )

        _ ->
            ( correctModel, [] )


viewPopup : Model -> Shared -> Html Msg
viewPopup model shared =
    case getCorrectModel shared model of
        ProjectEditor formModel ->
            TaskEditor.view formModel
                |> H.map ProjectEditorMsg

        JustText htmlWithoutMsg ->
            htmlWithoutMsg
                |> H.map (\_ -> JustTextMsg)


getCorrectModel : Shared -> Model -> Model
getCorrectModel shared model =
    case ( shared.modal, model ) of
        -- model is correct match
        ( Just (PopupType.ProjectEditor newAction), ProjectEditor { action } ) ->
            if newAction == action then
                model

            else
                init (PopupType.ProjectEditor newAction)

        ( Just (PopupType.JustText _), JustText _ ) ->
            model

        ( Nothing, _ ) ->
            --popup is closed, leave old model in place
            JustText (H.div [] [ H.text "Just text" ])

        ( Just popupType, _ ) ->
            -- model doesn't match, substitute blank
            init popupType
