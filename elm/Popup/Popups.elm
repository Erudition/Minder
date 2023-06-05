module Popup.Popups exposing (Model, Msg, getCorrectModel, init, popupWrapper, update)

import Effect exposing (Effect)
import Form
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Json.Encode as JE
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
    | RunEffects (List (Effect Msg))


init : PopupType -> Model
init popupType =
    case popupType of
        PopupType.ProjectEditor maybeAction ->
            ProjectEditor <| TaskEditor.initialModel maybeAction

        PopupType.JustText _ ->
            JustText (H.div [] [ H.text "Just text" ])


update : Msg -> Model -> Shared -> ( Model, List (Effect Msg) )
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

        ( _, RunEffects effects ) ->
            ( correctModel, effects )

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


popupWrapper : Model -> Shared -> H.Html Msg
popupWrapper popupModel shared =
    -- It's important that this be unstyled Html for now, since adding style elements throws off the elm-ionic interaction
    let
        outerShell innerStuff =
            [ H.node "ion-header"
                [ HA.id "ion-modal-header" ]
                [ H.node "ion-toolbar"
                    []
                    [ H.node "ion-buttons"
                        [ HA.attribute "slot" "end" ]
                        [ H.node "ion-button"
                            [ HA.attribute "color" "medium"
                            , HE.onClick (RunEffects [ Effect.ClosePopup ])
                            ]
                            [ H.text "Cancel" ]
                        ]
                    , H.node "ion-title" [] [ H.text "Project Editor" ]

                    -- , H.node "ion-buttons"
                    --     [ HA.attribute "slot" "end" ]
                    --     [ H.node "ion-button" [ HA.attribute "strong" "true", HE.onClick (RunEffects [ Effect.ClosePopup, Effect.Toast "Pretended to Save Changes!" ]) ] [ H.text "Confirm" ]
                    --     ]
                    ]
                ]
            , H.node "ion-content"
                [ HA.class "ion-padding" ]
                innerStuff
            ]

        isOpen =
            case shared.modal of
                Just popup ->
                    True

                Nothing ->
                    False

        contents =
            outerShell
                [ viewPopup popupModel shared
                ]
    in
    H.node "ion-modal"
        [ HA.property "isOpen" (JE.bool isOpen)
        , HE.on "didDismiss" <| JD.succeed (RunEffects [ Effect.ClosePopup ])
        ]
        [ H.div [ HA.class "ion-delegate-host", HA.class "ion-page" ] contents ]


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
